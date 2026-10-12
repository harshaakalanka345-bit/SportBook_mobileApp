-- ==============================================================================
-- SPORTSBOOK - COMPLETE SUPABASE SETUP (base schema + migration 002 + migration 003)
-- Paste into Supabase > SQL Editor > New query and click Run. Safe to re-run.
-- ==============================================================================

-- ############ PART 1: BASE SCHEMA ############
-- ==============================================================================
-- SPORTSBOOK SUPABASE DATABASE SCHEMA (ALIGNED WITH SupabaseService)
-- Run this script in your Supabase SQL Editor (Dashboard > SQL Editor > New query)
-- ==============================================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ------------------------------------------------------------------------------
-- 1. VENUES TABLE (Member 2: Venue Discovery & Filters)
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.venues (
    id TEXT PRIMARY KEY DEFAULT ('ven-' || substr(md5(random()::text), 1, 8)),
    name TEXT NOT NULL,
    sport TEXT NOT NULL DEFAULT 'Badminton',
    environment TEXT NOT NULL DEFAULT 'Indoor', -- 'Indoor', 'Outdoor'
    area TEXT NOT NULL DEFAULT 'Colombo 07',
    hourly_rate NUMERIC NOT NULL DEFAULT 1500,
    address TEXT DEFAULT 'Colombo, Sri Lanka',
    image_url TEXT,
    amenities TEXT[] DEFAULT ARRAY['Parking', 'Changing Rooms', 'Drinking Water'],
    created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.venues ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow public read access to venues" ON public.venues;
CREATE POLICY "Allow public read access to venues"
    ON public.venues FOR SELECT
    USING (true);

-- Seed Initial Venues
INSERT INTO public.venues (id, name, sport, environment, area, hourly_rate, address, amenities)
VALUES
    ('ven-01', 'Royal Indoor Badminton', 'Badminton', 'Indoor', 'Colombo 07', 1800, 'Reid Avenue, Colombo 07', ARRAY['Parking', 'Changing Rooms', 'Pro Shop', 'Floodlights']),
    ('ven-02', 'Torrington Racquet Hub', 'Badminton', 'Indoor', 'Colombo 05', 1500, 'Torrington Square, Colombo 05', ARRAY['Parking', 'Changing Rooms', 'Racket Rental']),
    ('ven-03', 'CR & FC Outdoor Courts', 'Tennis', 'Outdoor', 'Colombo 07', 2500, 'Malalasekara Mawatha, Colombo 07', ARRAY['Floodlights', 'Parking', 'Club House']),
    ('ven-04', 'Bambalapitiya Smash Courts', 'Badminton', 'Indoor', 'Colombo 04', 1600, 'Galle Road, Colombo 04', ARRAY['Air Conditioned', 'Changing Rooms', 'Refreshments']),
    ('ven-05', 'Futsal World Colombo', 'Futsal', 'Indoor', 'Colombo 10', 3200, 'T.B. Jayah Mawatha, Colombo 10', ARRAY['Locker Rooms', 'Showers', 'Parking', 'Floodlights']),
    ('ven-06', 'Otters Aquatic Club Tennis', 'Tennis', 'Outdoor', 'Colombo 07', 2200, 'Bauddhaloka Mawatha, Colombo 07', ARRAY['Floodlights', 'Showers', 'Cafeteria'])
ON CONFLICT (id) DO UPDATE SET
    environment = EXCLUDED.environment,
    sport = EXCLUDED.sport,
    hourly_rate = EXCLUDED.hourly_rate;

-- ------------------------------------------------------------------------------
-- 2. PROFILES TABLE (Member 1: Auth & Profile)
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    full_name TEXT NOT NULL DEFAULT 'SportsBook Member',
    wallet_balance NUMERIC NOT NULL DEFAULT 2500,
    email TEXT,
    phone TEXT,
    avatar_url TEXT,
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create profiles inside the auth transaction so sign-up does not depend on
-- a client session being available when email confirmation is enabled.
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    INSERT INTO public.profiles (id, full_name, email, phone)
    VALUES (
        NEW.id,
        COALESCE(NULLIF(NEW.raw_user_meta_data->>'full_name', ''), 'SportsBook Member'),
        NEW.email,
        NEW.phone
    )
    ON CONFLICT (id) DO UPDATE SET
        full_name = EXCLUDED.full_name,
        email = EXCLUDED.email,
        phone = EXCLUDED.phone,
        updated_at = NOW();
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- If columns already existed from previous run, ensure full_name and wallet_balance exist
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'profiles' AND column_name = 'full_name') THEN
        ALTER TABLE public.profiles ADD COLUMN full_name TEXT NOT NULL DEFAULT 'SportsBook Member';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'profiles' AND column_name = 'wallet_balance') THEN
        ALTER TABLE public.profiles ADD COLUMN wallet_balance NUMERIC NOT NULL DEFAULT 2500;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'profiles' AND column_name = 'email') THEN
        ALTER TABLE public.profiles ADD COLUMN email TEXT;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'profiles' AND column_name = 'phone') THEN
        ALTER TABLE public.profiles ADD COLUMN phone TEXT;
    END IF;
END $$;

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can read all profiles" ON public.profiles;
CREATE POLICY "Users can read all profiles"
    ON public.profiles FOR SELECT
    USING (true);

DROP POLICY IF EXISTS "Users can update their own profile" ON public.profiles;
CREATE POLICY "Users can update their own profile"
    ON public.profiles FOR UPDATE
    USING (auth.uid() = id);

DROP POLICY IF EXISTS "Users can insert their own profile" ON public.profiles;
CREATE POLICY "Users can insert their own profile"
    ON public.profiles FOR INSERT
    WITH CHECK (auth.uid() = id);

-- ------------------------------------------------------------------------------
-- 3. BOOKINGS TABLE (Member 3: Bookings & Locks, Member 4: Reschedule)
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.bookings (
    id TEXT PRIMARY KEY DEFAULT ('bk-' || substr(md5(random()::text), 1, 8)),
    booking_ref TEXT UNIQUE NOT NULL,
    venue_id TEXT REFERENCES public.venues(id) ON DELETE SET NULL,
    user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    court_name TEXT NOT NULL,
    date_schedule TEXT NOT NULL,
    time_slot TEXT NOT NULL,
    total_paid NUMERIC NOT NULL DEFAULT 1500,
    qr_turnstile_pin TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'Confirmed', -- 'Confirmed', 'Rescheduled', 'Cancelled'
    addons JSONB DEFAULT '[]'::jsonb,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.bookings ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow authenticated and anonymous access to bookings" ON public.bookings;
CREATE POLICY "Allow authenticated and anonymous access to bookings"
    ON public.bookings FOR ALL
    USING (true);

-- ------------------------------------------------------------------------------
-- 4. MATCH BEACONS TABLE (Member 4: Beacons & Community)
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.match_beacons (
    id TEXT PRIMARY KEY DEFAULT ('mb-' || substr(md5(random()::text), 1, 8)),
    host_user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    sport TEXT NOT NULL DEFAULT 'Badminton',
    skill_level TEXT NOT NULL DEFAULT 'Intermediate',
    venue_name TEXT NOT NULL,
    scheduled_time TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.match_beacons ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow public read access to match beacons" ON public.match_beacons;
CREATE POLICY "Allow public read access to match beacons"
    ON public.match_beacons FOR SELECT
    USING (true);

DROP POLICY IF EXISTS "Allow create and update match beacons" ON public.match_beacons;
CREATE POLICY "Allow create and update match beacons"
    ON public.match_beacons FOR ALL
    USING (true);

-- Seed initial match beacons
INSERT INTO public.match_beacons (sport, skill_level, venue_name, scheduled_time)
SELECT * FROM (VALUES
    ('Badminton', 'Intermediate', 'Royal Indoor Badminton', 'Tomorrow 06:00 PM'),
    ('Badminton', 'Beginner', 'Torrington Racquet Hub', 'Saturday 04:00 PM'),
    ('Tennis', 'Advanced', 'CR & FC Outdoor Courts', 'Sunday 07:00 AM')
) AS v(sport, skill_level, venue_name, scheduled_time)
WHERE NOT EXISTS (SELECT 1 FROM public.match_beacons);
-- ------------------------------------------------------------------------------
-- 5. COURTS TABLE (Admin CRUD)
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.courts (
    id TEXT PRIMARY KEY DEFAULT ('crt-' || substr(md5(random()::text), 1, 8)),
    venue_id TEXT REFERENCES public.venues(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    type TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.courts ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow public read access to courts" ON public.courts;
CREATE POLICY "Allow public read access to courts"
    ON public.courts FOR SELECT
    USING (true);

DROP POLICY IF EXISTS "Allow create and update courts" ON public.courts;
CREATE POLICY "Allow create and update courts"
    ON public.courts FOR ALL
    USING (true);

-- Seed initial courts for ven-01
INSERT INTO public.courts (venue_id, name, type)
SELECT * FROM (VALUES
    ('ven-01', 'Court 1', 'Premium Teak Parquet Floor'),
    ('ven-01', 'Court 2', 'Synthetic Indoor Shoe Rubber')

) AS v(venue_id, name, type)
WHERE NOT EXISTS (SELECT 1 FROM public.courts);



-- ############ PART 2: ROLES, INCIDENTS, PROFILE, SUPPORT ############
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


-- ############ PART 3: OWNER SCHEDULE, WALK-INS, LEDGER ############
-- ==============================================================================
-- MIGRATION 003: owner Schedule (slot blocks, surge pricing) and walk-in bookings
-- Run AFTER supabase_migration_002_roles_incidents.sql. Safe to re-run.
-- ==============================================================================

ALTER TABLE public.bookings ADD COLUMN IF NOT EXISTS source TEXT NOT NULL DEFAULT 'app';   -- 'app' | 'walk_in'
ALTER TABLE public.bookings ADD COLUMN IF NOT EXISTS guest_name TEXT;
ALTER TABLE public.bookings ADD COLUMN IF NOT EXISTS guest_phone TEXT;
ALTER TABLE public.bookings ADD COLUMN IF NOT EXISTS payment_method TEXT;

-- Owners can create bookings (walk-ins) at venues they own; user_id may be NULL for guests.
DROP POLICY IF EXISTS "Owners create walk-in bookings" ON public.bookings;
CREATE POLICY "Owners create walk-in bookings"
    ON public.bookings FOR INSERT
    WITH CHECK (EXISTS (SELECT 1 FROM public.venues v WHERE v.id = bookings.venue_id AND v.owner_id = auth.uid()));

-- ------------------------------------------------------------------------------
-- Slot blocks: cleaning / maintenance / locks / short walk-in holds
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.slot_blocks (
    id TEXT PRIMARY KEY DEFAULT ('blk-' || substr(md5(random()::text), 1, 8)),
    venue_id TEXT NOT NULL REFERENCES public.venues(id) ON DELETE CASCADE,
    court_name TEXT NOT NULL,
    date_schedule TEXT NOT NULL,
    time_slot TEXT NOT NULL,               -- one slot label per row, e.g. '06:00 - 07:00 AM'
    reason TEXT NOT NULL DEFAULT 'Locked', -- 'Cleaning' | 'Maintenance' | 'Private event' | 'Locked' | 'Hold' | 'Other'
    note TEXT,
    expires_at TIMESTAMPTZ,                -- set for short walk-in holds
    created_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE (venue_id, court_name, date_schedule, time_slot)
);
ALTER TABLE public.slot_blocks ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Owners manage slot blocks" ON public.slot_blocks;
CREATE POLICY "Owners manage slot blocks" ON public.slot_blocks FOR ALL
    USING (EXISTS (SELECT 1 FROM public.venues v WHERE v.id = slot_blocks.venue_id AND v.owner_id = auth.uid()))
    WITH CHECK (EXISTS (SELECT 1 FROM public.venues v WHERE v.id = slot_blocks.venue_id AND v.owner_id = auth.uid()));

-- ------------------------------------------------------------------------------
-- Surge pricing: extra LKR charged for a given court / date / slot
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.slot_surges (
    venue_id TEXT NOT NULL REFERENCES public.venues(id) ON DELETE CASCADE,
    court_name TEXT NOT NULL,
    date_schedule TEXT NOT NULL,
    time_slot TEXT NOT NULL,
    amount NUMERIC NOT NULL CHECK (amount >= 0),
    PRIMARY KEY (venue_id, court_name, date_schedule, time_slot)
);
ALTER TABLE public.slot_surges ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Anyone can read surges" ON public.slot_surges;
CREATE POLICY "Anyone can read surges" ON public.slot_surges FOR SELECT USING (true);
DROP POLICY IF EXISTS "Owners manage surges" ON public.slot_surges;
CREATE POLICY "Owners manage surges" ON public.slot_surges FOR ALL
    USING (EXISTS (SELECT 1 FROM public.venues v WHERE v.id = slot_surges.venue_id AND v.owner_id = auth.uid()))
    WITH CHECK (EXISTS (SELECT 1 FROM public.venues v WHERE v.id = slot_surges.venue_id AND v.owner_id = auth.uid()));

-- ------------------------------------------------------------------------------
-- Availability now includes owner blocks (but not expired holds)
-- ------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.get_booked_slots(p_venue_id TEXT, p_date TEXT)
RETURNS TABLE (court_name TEXT, time_slot TEXT)
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
AS $$
    SELECT b.court_name, b.time_slot
    FROM public.bookings b
    WHERE b.venue_id = p_venue_id AND b.date_schedule = p_date AND b.status <> 'Cancelled'
    UNION ALL
    SELECT k.court_name, k.time_slot
    FROM public.slot_blocks k
    WHERE k.venue_id = p_venue_id AND k.date_schedule = p_date
      AND (k.expires_at IS NULL OR k.expires_at > NOW());
$$;
GRANT EXECUTE ON FUNCTION public.get_booked_slots(TEXT, TEXT) TO anon, authenticated;

-- Reject bookings that overlap another booking, or (for app bookings) an active owner block
CREATE OR REPLACE FUNCTION public.prevent_double_booking()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    IF NEW.status <> 'Cancelled' THEN
        IF EXISTS (
            SELECT 1 FROM public.bookings b
            WHERE b.venue_id = NEW.venue_id AND b.court_name = NEW.court_name AND b.date_schedule = NEW.date_schedule
              AND b.status <> 'Cancelled' AND b.id <> COALESCE(NEW.id, '')
              AND string_to_array(b.time_slot, ', ') && string_to_array(NEW.time_slot, ', ')
        ) THEN
            RAISE EXCEPTION 'That time slot has just been booked by someone else. Please pick another.';
        END IF;
        IF NEW.source <> 'walk_in' AND EXISTS (
            SELECT 1 FROM public.slot_blocks k
            WHERE k.venue_id = NEW.venue_id AND k.court_name = NEW.court_name AND k.date_schedule = NEW.date_schedule
              AND (k.expires_at IS NULL OR k.expires_at > NOW())
              AND k.time_slot = ANY (string_to_array(NEW.time_slot, ', '))
        ) THEN
            RAISE EXCEPTION 'That time slot has just been booked by someone else. Please pick another.';
        END IF;
    END IF;
    RETURN NEW;
END;
$$;

-- ------------------------------------------------------------------------------
-- Owner tools for walk-in customers (SECURITY DEFINER, restricted to owners / admins)
-- ------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.lookup_customer(p_phone TEXT)
RETURNS TABLE (id UUID, full_name TEXT, phone TEXT, wallet_balance NUMERIC, bookings_count BIGINT)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM public.profiles p WHERE p.id = auth.uid() AND p.role IN ('owner', 'admin')) THEN
        RAISE EXCEPTION 'Only owners can look up customers';
    END IF;
    RETURN QUERY
        SELECT p.id, p.full_name, p.phone, p.wallet_balance,
               (SELECT COUNT(*) FROM public.bookings b WHERE b.user_id = p.id)
        FROM public.profiles p
        WHERE regexp_replace(COALESCE(p.phone, ''), '[^0-9]', '', 'g') <> ''
          AND right(regexp_replace(p.phone, '[^0-9]', '', 'g'), 9) = right(regexp_replace(p_phone, '[^0-9]', '', 'g'), 9)
        LIMIT 1;
END;
$$;
GRANT EXECUTE ON FUNCTION public.lookup_customer(TEXT) TO authenticated;

CREATE OR REPLACE FUNCTION public.debit_customer_wallet(p_user UUID, p_amount NUMERIC)
RETURNS NUMERIC
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    new_balance NUMERIC;
BEGIN
    IF NOT EXISTS (SELECT 1 FROM public.profiles p WHERE p.id = auth.uid() AND p.role IN ('owner', 'admin')) THEN
        RAISE EXCEPTION 'Only owners can charge a customer wallet';
    END IF;
    UPDATE public.profiles SET wallet_balance = wallet_balance - p_amount
    WHERE id = p_user AND wallet_balance >= p_amount AND p_amount > 0
    RETURNING wallet_balance INTO new_balance;
    IF new_balance IS NULL THEN
        RAISE EXCEPTION 'Insufficient wallet balance';
    END IF;
    RETURN new_balance;
END;
$$;
GRANT EXECUTE ON FUNCTION public.debit_customer_wallet(UUID, NUMERIC) TO authenticated;

-- Owners can read the names / phones of customers who booked at their venues
DROP POLICY IF EXISTS "Owners read their customers" ON public.profiles;
CREATE POLICY "Owners read their customers" ON public.profiles FOR SELECT
    USING (EXISTS (
        SELECT 1 FROM public.bookings b JOIN public.venues v ON v.id = b.venue_id
        WHERE b.user_id = profiles.id AND v.owner_id = auth.uid()
    ));

-- ------------------------------------------------------------------------------
-- Ledger: refunds and shift reconciliation
-- ------------------------------------------------------------------------------
ALTER TABLE public.bookings ADD COLUMN IF NOT EXISTS refunded_at TIMESTAMPTZ;
ALTER TABLE public.bookings ADD COLUMN IF NOT EXISTS refund_method TEXT;   -- 'wallet' | 'card'

CREATE OR REPLACE FUNCTION public.credit_customer_wallet(p_user UUID, p_amount NUMERIC)
RETURNS NUMERIC
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    new_balance NUMERIC;
BEGIN
    IF NOT EXISTS (SELECT 1 FROM public.profiles p WHERE p.id = auth.uid() AND p.role IN ('owner', 'admin')) THEN
        RAISE EXCEPTION 'Only owners can refund to a customer wallet';
    END IF;
    IF p_amount <= 0 THEN
        RAISE EXCEPTION 'Invalid refund amount';
    END IF;
    UPDATE public.profiles SET wallet_balance = wallet_balance + p_amount WHERE id = p_user
    RETURNING wallet_balance INTO new_balance;
    RETURN new_balance;
END;
$$;
GRANT EXECUTE ON FUNCTION public.credit_customer_wallet(UUID, NUMERIC) TO authenticated;

CREATE TABLE IF NOT EXISTS public.shift_closures (
    id TEXT PRIMARY KEY DEFAULT ('sh-' || substr(md5(random()::text), 1, 8)),
    venue_id TEXT REFERENCES public.venues(id) ON DELETE CASCADE,
    closed_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    shift_date TEXT NOT NULL,
    bookings_count INT NOT NULL DEFAULT 0,
    cash_total NUMERIC NOT NULL DEFAULT 0,
    digital_total NUMERIC NOT NULL DEFAULT 0,
    refunds_total NUMERIC NOT NULL DEFAULT 0,
    counted_cash NUMERIC,
    note TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
ALTER TABLE public.shift_closures ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Owners manage shift closures" ON public.shift_closures;
CREATE POLICY "Owners manage shift closures" ON public.shift_closures FOR ALL
    USING (EXISTS (SELECT 1 FROM public.venues v WHERE v.id = shift_closures.venue_id AND v.owner_id = auth.uid()))
    WITH CHECK (EXISTS (SELECT 1 FROM public.venues v WHERE v.id = shift_closures.venue_id AND v.owner_id = auth.uid()));
