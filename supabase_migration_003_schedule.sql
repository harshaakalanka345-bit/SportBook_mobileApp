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

ALTER TABLE public.bookings ADD COLUMN IF NOT EXISTS cancel_reason TEXT;   -- e.g. 'Weather void', 'Maintenance'
