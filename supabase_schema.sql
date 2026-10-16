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
    ('ven-06', 'Otters Aquatic Club Tennis', 'Tennis', 'Outdoor', 'Colombo 07', 2200, 'Bauddhaloka Mawatha, Colombo 07', ARRAY['Floodlights', 'Showers', 'Cafeteria']),
    ('ven-07', 'Colombo Cricket Nets', 'Cricket', 'Outdoor', 'Colombo 05', 3000, 'Havelock Road, Colombo 05', ARRAY['Parking', 'Changing Rooms', 'Floodlights']),
    ('ven-08', 'Colombo Hoop Arena', 'Basketball', 'Indoor', 'Colombo 03', 2800, 'Duplication Road, Colombo 03', ARRAY['Air Conditioned', 'Changing Rooms', 'Drinking Water']),
    ('ven-09', 'Padel Colombo', 'Padel', 'Outdoor', 'Colombo 02', 3500, 'Union Place, Colombo 02', ARRAY['Parking', 'Floodlights', 'Showers']),
    ('ven-10', 'Colombo Table Tennis Centre', 'Table Tennis', 'Indoor', 'Colombo 06', 1800, 'Marine Drive, Colombo 06', ARRAY['Air Conditioned', 'Changing Rooms', 'Cafeteria']),
    ('ven-11', 'Colombo Squash Centre', 'Squash', 'Indoor', 'Colombo 03', 2200, 'Alfred House Gardens, Colombo 03', ARRAY['Air Conditioned', 'Changing Rooms', 'Showers'])
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
    wallet_balance NUMERIC NOT NULL DEFAULT 0,
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
        ALTER TABLE public.profiles ADD COLUMN wallet_balance NUMERIC NOT NULL DEFAULT 0;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'profiles' AND column_name = 'email') THEN
        ALTER TABLE public.profiles ADD COLUMN email TEXT;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'profiles' AND column_name = 'phone') THEN
        ALTER TABLE public.profiles ADD COLUMN phone TEXT;
    END IF;
END $$;

ALTER TABLE public.profiles ALTER COLUMN wallet_balance SET DEFAULT 0;

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

ALTER TABLE public.bookings ADD COLUMN IF NOT EXISTS cancel_reason TEXT;

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
VALUES
    ('Badminton', 'Intermediate', 'Royal Indoor Badminton', 'Tomorrow 06:00 PM'),
    ('Badminton', 'Beginner', 'Torrington Racquet Hub', 'Saturday 04:00 PM'),
    ('Tennis', 'Advanced', 'CR & FC Outdoor Courts', 'Sunday 07:00 AM');
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

-- Seed bookable sample courts for every sport. The pair check keeps this safe to rerun.
INSERT INTO public.courts (venue_id, name, type)
SELECT sample.venue_id, sample.name, sample.type
FROM (VALUES
    ('ven-01', 'Court 1', 'Premium Teak Parquet Floor'),
    ('ven-01', 'Court 2', 'Synthetic Indoor Shoe Rubber'),
    ('ven-02', 'Court 1', 'Synthetic Indoor Shoe Rubber'),
    ('ven-03', 'Court 1', 'Hard Court Acrylic'),
    ('ven-04', 'Court 1', 'Wooden Parquet'),
    ('ven-05', 'Pitch 1', 'Synthetic Turf'),
    ('ven-06', 'Court 1', 'Hard Court Acrylic'),
    ('ven-07', 'Practice Pitch 1', 'Natural Turf'),
    ('ven-08', 'Court 1', 'Hardwood'),
    ('ven-09', 'Court 1', 'Synthetic Padel Turf'),
    ('ven-10', 'Table 1', 'Synthetic Table Tennis Mat'),
    ('ven-11', 'Court 1', 'Glassback Squash Court')
) AS sample(venue_id, name, type)
WHERE NOT EXISTS (
    SELECT 1 FROM public.courts c
    WHERE c.venue_id = sample.venue_id AND c.name = sample.name
);

