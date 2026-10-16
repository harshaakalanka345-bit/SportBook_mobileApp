-- Protect wallet balances from client-side edits and remove free-credit defaults.
-- Run after migrations 002-005. Safe to rerun.

ALTER TABLE public.profiles
    ADD COLUMN IF NOT EXISTS wallet_balance NUMERIC NOT NULL DEFAULT 0;
ALTER TABLE public.profiles
    ALTER COLUMN wallet_balance SET DEFAULT 0;

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
            IF current_setting('sportsbook.wallet_update', true) IS DISTINCT FROM 'allowed' THEN
                NEW.wallet_balance := OLD.wallet_balance;
            END IF;
        ELSE
            IF NEW.role = 'admin' THEN
                NEW.role := 'player';
            END IF;
            NEW.wallet_balance := 0;
        END IF;
    END IF;
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS protect_profile_columns ON public.profiles;
CREATE TRIGGER protect_profile_columns
    BEFORE INSERT OR UPDATE ON public.profiles
    FOR EACH ROW EXECUTE FUNCTION public.protect_profile_columns();

CREATE OR REPLACE FUNCTION public.debit_customer_wallet(p_user UUID, p_amount NUMERIC)
RETURNS NUMERIC
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    new_balance NUMERIC;
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM public.profiles p
        WHERE p.id = auth.uid() AND p.role IN ('owner', 'admin')
    ) THEN
        RAISE EXCEPTION 'Only owners can charge a customer wallet';
    END IF;
    IF p_amount <= 0 THEN
        RAISE EXCEPTION 'Invalid wallet charge';
    END IF;

    PERFORM set_config('sportsbook.wallet_update', 'allowed', true);
    UPDATE public.profiles
       SET wallet_balance = wallet_balance - p_amount
     WHERE id = p_user AND wallet_balance >= p_amount
    RETURNING wallet_balance INTO new_balance;
    IF new_balance IS NULL THEN
        RAISE EXCEPTION 'Insufficient wallet balance';
    END IF;
    RETURN new_balance;
END;
$$;
GRANT EXECUTE ON FUNCTION public.debit_customer_wallet(UUID, NUMERIC) TO authenticated;

CREATE OR REPLACE FUNCTION public.credit_customer_wallet(p_user UUID, p_amount NUMERIC)
RETURNS NUMERIC
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    new_balance NUMERIC;
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM public.profiles p
        WHERE p.id = auth.uid() AND p.role IN ('owner', 'admin')
    ) THEN
        RAISE EXCEPTION 'Only owners can refund to a customer wallet';
    END IF;
    IF p_amount <= 0 THEN
        RAISE EXCEPTION 'Invalid refund amount';
    END IF;

    PERFORM set_config('sportsbook.wallet_update', 'allowed', true);
    UPDATE public.profiles
       SET wallet_balance = wallet_balance + p_amount
     WHERE id = p_user
    RETURNING wallet_balance INTO new_balance;
    IF new_balance IS NULL THEN
        RAISE EXCEPTION 'Customer wallet was not found';
    END IF;
    RETURN new_balance;
END;
$$;
GRANT EXECUTE ON FUNCTION public.credit_customer_wallet(UUID, NUMERIC) TO authenticated;

ALTER TABLE public.bookings
    ADD COLUMN IF NOT EXISTS refund_method TEXT;

NOTIFY pgrst, 'reload schema';
