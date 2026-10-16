-- Persist the player's cancellation reason on existing Supabase projects.
ALTER TABLE public.bookings
    ADD COLUMN IF NOT EXISTS cancel_reason TEXT;

NOTIFY pgrst, 'reload schema';
