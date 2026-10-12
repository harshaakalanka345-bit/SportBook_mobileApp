-- ==============================================================================
-- MIGRATION 002: roles, court-complex ownership, incidents, reviews, tighter RLS
-- Run AFTER supabase_schema.sql (Dashboard > SQL Editor > New query). Safe to re-run.
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- 1. PROFILES: role ('player' | 'owner' | 'admin')
-- ------------------------------------------------------------------------------
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS role TEXT NOT NULL DEFAULT 'player';
ALTER TABLE public.profiles DROP CONSTRAINT IF EXISTS profiles_role_check;
ALTER TABLE public.profiles ADD CONSTRAINT profiles_role_check CHECK (role IN ('player', 'owner', 'admin'));
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS sports TEXT[] DEFAULT ARRAY[]::TEXT[];
-- (older databases were created without this column, which made the sign-up trigger fail)
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();

-- Sign-up trigger: copy name / phone / sports and allow self-service 'player' or 'owner' only.
-- ('admin' can only be granted manually from the dashboard.)
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    requested_role TEXT := COALESCE(NEW.raw_user_meta_data->>'role', 'player');
BEGIN
    IF requested_role NOT IN ('player', 'owner') THEN
        requested_role := 'player';
    END IF;

    INSERT INTO public.profiles (id, full_name, email, phone, role, sports)
    VALUES (
        NEW.id,
        COALESCE(NULLIF(NEW.raw_user_meta_data->>'full_name', ''), 'SportsBook Member'),
        NEW.email,
        COALESCE(NULLIF(NEW.raw_user_meta_data->>'phone', ''), NEW.phone),
        requested_role,
        COALESCE(
            ARRAY(SELECT jsonb_array_elements_text(NEW.raw_user_meta_data->'sports')),
            ARRAY[]::TEXT[]
        )
    )
    ON CONFLICT (id) DO UPDATE SET
        full_name = EXCLUDED.full_name,
        email = EXCLUDED.email,
        phone = EXCLUDED.phone,
        updated_at = NOW();
    RETURN NEW;
EXCEPTION WHEN OTHERS THEN
    -- Never block sign-up because the profile row failed; the app creates the profile on first login.
    RAISE WARNING 'handle_new_user failed for %: %', NEW.id, SQLERRM;
    RETURN NEW;
END;
$$;

-- Users must not be able to promote themselves or edit their own wallet through the API.
CREATE OR REPLACE FUNCTION public.protect_profile_columns()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    IF COALESCE(auth.role(), '') = 'authenticated' THEN
        IF TG_OP = 'UPDATE' THEN
            NEW.role := OLD.role;
        ELSIF NEW.role = 'admin' THEN
            NEW.role := 'player';   -- nobody can create themselves as admin
        END IF;
    END IF;
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS protect_profile_columns ON public.profiles;
CREATE TRIGGER protect_profile_columns
    BEFORE INSERT OR UPDATE ON public.profiles
    FOR EACH ROW EXECUTE FUNCTION public.protect_profile_columns();

-- Profiles contain emails / phones: only the owner of the row (or venue staff via RPC) should read them.
DROP POLICY IF EXISTS "Users can read all profiles" ON public.profiles;
DROP POLICY IF EXISTS "Users can read own profile" ON public.profiles;
CREATE POLICY "Users can read own profile"
    ON public.profiles FOR SELECT
    USING (auth.uid() = id);

-- ------------------------------------------------------------------------------
-- 2. VENUES: ownership + descriptive fields for "Register Court Complex"
-- ------------------------------------------------------------------------------
ALTER TABLE public.venues ADD COLUMN IF NOT EXISTS owner_id UUID REFERENCES auth.users(id) ON DELETE SET NULL;
ALTER TABLE public.venues ADD COLUMN IF NOT EXISTS description TEXT;
ALTER TABLE public.venues ADD COLUMN IF NOT EXISTS contact_phone TEXT;
ALTER TABLE public.venues ADD COLUMN IF NOT EXISTS opening_time TEXT DEFAULT '06:00';
ALTER TABLE public.venues ADD COLUMN IF NOT EXISTS closing_time TEXT DEFAULT '22:00';
ALTER TABLE public.venues ADD COLUMN IF NOT EXISTS status TEXT NOT NULL DEFAULT 'active';

DROP POLICY IF EXISTS "Owners can register venues" ON public.venues;
CREATE POLICY "Owners can register venues"
    ON public.venues FOR INSERT
    WITH CHECK (
        auth.uid() = owner_id
        AND EXISTS (SELECT 1 FROM public.profiles p WHERE p.id = auth.uid() AND p.role IN ('owner', 'admin'))
    );

DROP POLICY IF EXISTS "Owners can update their venues" ON public.venues;
CREATE POLICY "Owners can update their venues"
    ON public.venues FOR UPDATE
    USING (auth.uid() = owner_id);

DROP POLICY IF EXISTS "Owners can delete their venues" ON public.venues;
CREATE POLICY "Owners can delete their venues"
    ON public.venues FOR DELETE
    USING (auth.uid() = owner_id);

-- ------------------------------------------------------------------------------
-- 3. COURTS: sport, price, active flag; only the venue owner can change them
-- ------------------------------------------------------------------------------
ALTER TABLE public.courts ADD COLUMN IF NOT EXISTS sport TEXT;
ALTER TABLE public.courts ADD COLUMN IF NOT EXISTS hourly_rate NUMERIC;
ALTER TABLE public.courts ADD COLUMN IF NOT EXISTS is_active BOOLEAN NOT NULL DEFAULT TRUE;

DROP POLICY IF EXISTS "Allow create and update courts" ON public.courts;
DROP POLICY IF EXISTS "Owners manage their courts" ON public.courts;
CREATE POLICY "Owners manage their courts"
    ON public.courts FOR ALL
    USING (EXISTS (SELECT 1 FROM public.venues v WHERE v.id = courts.venue_id AND v.owner_id = auth.uid()))
    WITH CHECK (EXISTS (SELECT 1 FROM public.venues v WHERE v.id = courts.venue_id AND v.owner_id = auth.uid()));

-- ------------------------------------------------------------------------------
-- 4. BOOKINGS: players see their own, owners see bookings at their venues
-- ------------------------------------------------------------------------------
DROP POLICY IF EXISTS "Allow authenticated and anonymous access to bookings" ON public.bookings;
DROP POLICY IF EXISTS "Players read own bookings" ON public.bookings;
DROP POLICY IF EXISTS "Players create own bookings" ON public.bookings;
DROP POLICY IF EXISTS "Players update own bookings" ON public.bookings;

CREATE POLICY "Players read own bookings"
    ON public.bookings FOR SELECT
    USING (
        auth.uid() = user_id
        OR EXISTS (SELECT 1 FROM public.venues v WHERE v.id = bookings.venue_id AND v.owner_id = auth.uid())
    );

CREATE POLICY "Players create own bookings"
    ON public.bookings FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Players update own bookings"
    ON public.bookings FOR UPDATE
    USING (
        auth.uid() = user_id
        OR EXISTS (SELECT 1 FROM public.venues v WHERE v.id = bookings.venue_id AND v.owner_id = auth.uid())
    );

-- ------------------------------------------------------------------------------
-- 5. MATCH BEACONS: anyone reads, only the host writes
-- ------------------------------------------------------------------------------
DROP POLICY IF EXISTS "Allow create and update match beacons" ON public.match_beacons;
DROP POLICY IF EXISTS "Hosts manage their beacons" ON public.match_beacons;
CREATE POLICY "Hosts manage their beacons"
    ON public.match_beacons FOR ALL
    USING (auth.uid() = host_user_id)
    WITH CHECK (auth.uid() = host_user_id);

-- ------------------------------------------------------------------------------
-- 6. INCIDENTS
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.incidents (
    id TEXT PRIMARY KEY DEFAULT ('inc-' || substr(md5(random()::text), 1, 8)),
    venue_id TEXT REFERENCES public.venues(id) ON DELETE SET NULL,
    court_name TEXT,
    reporter_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    category TEXT NOT NULL,                 -- 'Court damage', 'Lighting', 'Injury', 'Safety', 'Cleanliness', 'Other'
    severity TEXT NOT NULL DEFAULT 'Medium', -- 'Low', 'Medium', 'High'
    description TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'open',    -- 'open', 'in_progress', 'resolved'
    resolution_note TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    resolved_at TIMESTAMPTZ
);

ALTER TABLE public.incidents ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Reporters create incidents" ON public.incidents;
CREATE POLICY "Reporters create incidents"
    ON public.incidents FOR INSERT
    WITH CHECK (auth.uid() = reporter_id);

DROP POLICY IF EXISTS "Reporters and venue owners read incidents" ON public.incidents;
CREATE POLICY "Reporters and venue owners read incidents"
    ON public.incidents FOR SELECT
    USING (
        auth.uid() = reporter_id
        OR EXISTS (SELECT 1 FROM public.venues v WHERE v.id = incidents.venue_id AND v.owner_id = auth.uid())
    );

DROP POLICY IF EXISTS "Venue owners update incidents" ON public.incidents;
CREATE POLICY "Venue owners update incidents"
    ON public.incidents FOR UPDATE
    USING (EXISTS (SELECT 1 FROM public.venues v WHERE v.id = incidents.venue_id AND v.owner_id = auth.uid()));

-- ------------------------------------------------------------------------------
-- 7. REVIEWS
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.reviews (
    id TEXT PRIMARY KEY DEFAULT ('rev-' || substr(md5(random()::text), 1, 8)),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    venue_id TEXT REFERENCES public.venues(id) ON DELETE CASCADE,
    booking_ref TEXT,
    rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Anyone can read reviews" ON public.reviews;
CREATE POLICY "Anyone can read reviews" ON public.reviews FOR SELECT USING (true);

DROP POLICY IF EXISTS "Players create own reviews" ON public.reviews;
CREATE POLICY "Players create own reviews" ON public.reviews FOR INSERT WITH CHECK (auth.uid() = user_id);

-- ------------------------------------------------------------------------------
-- 8. OPTIONAL: promote an existing account to admin (replace the email)
-- ------------------------------------------------------------------------------
-- UPDATE public.profiles SET role = 'admin' WHERE email = 'you@example.com';

-- ------------------------------------------------------------------------------
-- 9. BOOKING AVAILABILITY + DOUBLE-BOOKING GUARD
-- ------------------------------------------------------------------------------
-- Players can't read each other's bookings (RLS), so availability is exposed through this RPC.
CREATE OR REPLACE FUNCTION public.get_booked_slots(p_venue_id TEXT, p_date TEXT)
RETURNS TABLE (court_name TEXT, time_slot TEXT)
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
AS $$
    SELECT b.court_name, b.time_slot
    FROM public.bookings b
    WHERE b.venue_id = p_venue_id
      AND b.date_schedule = p_date
      AND b.status <> 'Cancelled';
$$;

GRANT EXECUTE ON FUNCTION public.get_booked_slots(TEXT, TEXT) TO anon, authenticated;

-- Reject a booking whose slots overlap an existing, non-cancelled booking on the same court/date.
CREATE OR REPLACE FUNCTION public.prevent_double_booking()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    IF NEW.status <> 'Cancelled' AND EXISTS (
        SELECT 1 FROM public.bookings b
        WHERE b.venue_id = NEW.venue_id
          AND b.court_name = NEW.court_name
          AND b.date_schedule = NEW.date_schedule
          AND b.status <> 'Cancelled'
          AND b.id <> COALESCE(NEW.id, '')
          AND string_to_array(b.time_slot, ', ') && string_to_array(NEW.time_slot, ', ')
    ) THEN
        RAISE EXCEPTION 'That time slot has just been booked by someone else. Please pick another.';
    END IF;
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS prevent_double_booking ON public.bookings;
CREATE TRIGGER prevent_double_booking
    BEFORE INSERT OR UPDATE OF time_slot, date_schedule, court_name, status ON public.bookings
    FOR EACH ROW EXECUTE FUNCTION public.prevent_double_booking();

-- ------------------------------------------------------------------------------
-- 10. FAVOURITES, SLOT ALERTS, FRIENDS
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.favorite_venues (
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    venue_id TEXT REFERENCES public.venues(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    PRIMARY KEY (user_id, venue_id)
);
ALTER TABLE public.favorite_venues ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users manage own favourites" ON public.favorite_venues;
CREATE POLICY "Users manage own favourites" ON public.favorite_venues FOR ALL
    USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

CREATE TABLE IF NOT EXISTS public.slot_alerts (
    id TEXT PRIMARY KEY DEFAULT ('al-' || substr(md5(random()::text), 1, 8)),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    sport TEXT NOT NULL,
    area TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
ALTER TABLE public.slot_alerts ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users manage own alerts" ON public.slot_alerts;
CREATE POLICY "Users manage own alerts" ON public.slot_alerts FOR ALL
    USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

CREATE TABLE IF NOT EXISTS public.friends (
    id TEXT PRIMARY KEY DEFAULT ('fr-' || substr(md5(random()::text), 1, 8)),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    friend_name TEXT NOT NULL,
    friend_contact TEXT NOT NULL,   -- email or phone
    created_at TIMESTAMPTZ DEFAULT NOW()
);
ALTER TABLE public.friends ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users manage own friends" ON public.friends;
CREATE POLICY "Users manage own friends" ON public.friends FOR ALL
    USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- ------------------------------------------------------------------------------
-- 11. PROFILE PREFERENCES, SAVED CARDS (display details only), ACCOUNT DELETION
-- ------------------------------------------------------------------------------
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS preferences JSONB NOT NULL DEFAULT '{}'::jsonb;

CREATE TABLE IF NOT EXISTS public.payment_methods (
    id TEXT PRIMARY KEY DEFAULT ('pm-' || substr(md5(random()::text), 1, 8)),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    brand TEXT NOT NULL,
    last4 TEXT NOT NULL,
    holder_name TEXT,
    expiry TEXT,
    is_default BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
ALTER TABLE public.payment_methods ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users manage own cards" ON public.payment_methods;
CREATE POLICY "Users manage own cards" ON public.payment_methods FOR ALL
    USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

CREATE OR REPLACE FUNCTION public.delete_my_account()
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    IF auth.uid() IS NULL THEN
        RAISE EXCEPTION 'Not signed in';
    END IF;
    DELETE FROM auth.users WHERE id = auth.uid();
END;
$$;
REVOKE ALL ON FUNCTION public.delete_my_account() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.delete_my_account() TO authenticated;

-- ------------------------------------------------------------------------------
-- 12. SUPPORT: incident photos + venue suggestions
-- ------------------------------------------------------------------------------
ALTER TABLE public.incidents ADD COLUMN IF NOT EXISTS photo_url TEXT;

INSERT INTO storage.buckets (id, name, public)
VALUES ('incident-photos', 'incident-photos', TRUE)
ON CONFLICT (id) DO NOTHING;

DROP POLICY IF EXISTS "Users upload own incident photos" ON storage.objects;
CREATE POLICY "Users upload own incident photos" ON storage.objects FOR INSERT TO authenticated
    WITH CHECK (bucket_id = 'incident-photos' AND (storage.foldername(name))[1] = auth.uid()::text);

DROP POLICY IF EXISTS "Incident photos are readable" ON storage.objects;
CREATE POLICY "Incident photos are readable" ON storage.objects FOR SELECT
    USING (bucket_id = 'incident-photos');

CREATE TABLE IF NOT EXISTS public.venue_suggestions (
    id TEXT PRIMARY KEY DEFAULT ('vs-' || substr(md5(random()::text), 1, 8)),
    user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    name TEXT NOT NULL,
    area TEXT NOT NULL,
    sport TEXT,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
ALTER TABLE public.venue_suggestions ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users submit suggestions" ON public.venue_suggestions;
CREATE POLICY "Users submit suggestions" ON public.venue_suggestions FOR INSERT WITH CHECK (auth.uid() = user_id);
DROP POLICY IF EXISTS "Users read own suggestions" ON public.venue_suggestions;
CREATE POLICY "Users read own suggestions" ON public.venue_suggestions FOR SELECT USING (auth.uid() = user_id);

-- ------------------------------------------------------------------------------
-- 13. COURT COMPLEX PROFILE DETAILS (bio, contact, rules, cover image)
-- ------------------------------------------------------------------------------
ALTER TABLE public.venues ADD COLUMN IF NOT EXISTS tagline TEXT;
ALTER TABLE public.venues ADD COLUMN IF NOT EXISTS website TEXT;
ALTER TABLE public.venues ADD COLUMN IF NOT EXISTS contact_email TEXT;
ALTER TABLE public.venues ADD COLUMN IF NOT EXISTS established_year INT;
ALTER TABLE public.venues ADD COLUMN IF NOT EXISTS parking_slots INT;
ALTER TABLE public.venues ADD COLUMN IF NOT EXISTS house_rules TEXT;
ALTER TABLE public.venues ADD COLUMN IF NOT EXISTS cancellation_policy TEXT;

INSERT INTO storage.buckets (id, name, public)
VALUES ('venue-images', 'venue-images', TRUE)
ON CONFLICT (id) DO NOTHING;

DROP POLICY IF EXISTS "Owners upload venue images" ON storage.objects;
CREATE POLICY "Owners upload venue images" ON storage.objects FOR INSERT TO authenticated
    WITH CHECK (bucket_id = 'venue-images' AND (storage.foldername(name))[1] = auth.uid()::text);

DROP POLICY IF EXISTS "Venue images are readable" ON storage.objects;
CREATE POLICY "Venue images are readable" ON storage.objects FOR SELECT
    USING (bucket_id = 'venue-images');

-- ------------------------------------------------------------------------------
-- 14. ADMIN ACCOUNT (run once; the account is created from the app / sign-up)
-- ------------------------------------------------------------------------------
UPDATE public.profiles SET role = 'admin' WHERE email = 'admin@sportsbook.test';
