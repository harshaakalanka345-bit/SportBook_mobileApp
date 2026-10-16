-- SportsBook migration 004: complete sports sample catalog and enforce venue hours.
-- Run after supabase_migration_002_roles_incidents.sql and
-- supabase_migration_003_schedule.sql. Safe to rerun.

INSERT INTO public.venues (id, name, sport, environment, area, hourly_rate, address, amenities)
VALUES
    ('ven-07', 'Colombo Cricket Nets', 'Cricket', 'Outdoor', 'Colombo 05', 3000, 'Havelock Road, Colombo 05', ARRAY['Parking', 'Changing Rooms', 'Floodlights']),
    ('ven-08', 'Colombo Hoop Arena', 'Basketball', 'Indoor', 'Colombo 03', 2800, 'Duplication Road, Colombo 03', ARRAY['Air Conditioned', 'Changing Rooms', 'Drinking Water']),
    ('ven-09', 'Padel Colombo', 'Padel', 'Outdoor', 'Colombo 02', 3500, 'Union Place, Colombo 02', ARRAY['Parking', 'Floodlights', 'Showers']),
    ('ven-10', 'Colombo Table Tennis Centre', 'Table Tennis', 'Indoor', 'Colombo 06', 1800, 'Marine Drive, Colombo 06', ARRAY['Air Conditioned', 'Changing Rooms', 'Cafeteria']),
    ('ven-11', 'Colombo Squash Centre', 'Squash', 'Indoor', 'Colombo 03', 2200, 'Alfred House Gardens, Colombo 03', ARRAY['Air Conditioned', 'Changing Rooms', 'Showers'])
ON CONFLICT (id) DO NOTHING;

-- Each demo venue has at least one court, and rerunning does not duplicate it.
INSERT INTO public.courts (venue_id, name, type)
SELECT sample.venue_id, sample.name, sample.type
FROM (VALUES
    ('ven-01', 'Court 1', 'Premium Teak Parquet Floor'),
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

-- Refuse customer and walk-in bookings that fall outside the venue's opening hours.
-- Status is derived from bookings (booked), slot_blocks (closed/cleaning/locked),
-- and the remaining unblocked time (available); no conflicting manual status is stored.
CREATE OR REPLACE FUNCTION public.prevent_double_booking()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    venue_open TIME;
    venue_close TIME;
    slot_label TEXT;
    start_label TEXT;
    end_label TEXT;
    meridiem TEXT;
    slot_start TIME;
    slot_end TIME;
BEGIN
    IF NEW.status <> 'Cancelled' THEN
        SELECT COALESCE(NULLIF(v.opening_time, ''), '06:00')::TIME,
               COALESCE(NULLIF(v.closing_time, ''), '22:00')::TIME
          INTO venue_open, venue_close
          FROM public.venues v
         WHERE v.id = NEW.venue_id;

        IF venue_open IS NOT NULL AND venue_close IS NOT NULL THEN
            FOREACH slot_label IN ARRAY string_to_array(NEW.time_slot, ', ') LOOP
                start_label := split_part(slot_label, ' - ', 1);
                end_label := split_part(slot_label, ' - ', 2);
                meridiem := upper(right(trim(end_label), 2));
                IF meridiem NOT IN ('AM', 'PM') OR end_label !~ '^\s*[0-9]{1,2}:[0-9]{2}\s+(AM|PM)$' THEN
                    RAISE EXCEPTION 'Invalid time slot label: %', slot_label;
                END IF;
                slot_start := (to_timestamp(start_label || ' ' || meridiem, 'HH12:MI AM') AT TIME ZONE 'UTC')::TIME;
                slot_end := (to_timestamp(end_label, 'HH12:MI AM') AT TIME ZONE 'UTC')::TIME;
                IF slot_start < venue_open OR slot_end > venue_close THEN
                    RAISE EXCEPTION 'This venue is open from % to %. Choose a time inside those hours.', venue_open, venue_close;
                END IF;
            END LOOP;
        END IF;

        IF EXISTS (
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

        IF NEW.source IS DISTINCT FROM 'walk_in' AND EXISTS (
            SELECT 1 FROM public.slot_blocks k
             WHERE k.venue_id = NEW.venue_id
               AND k.court_name = NEW.court_name
               AND k.date_schedule = NEW.date_schedule
               AND (k.expires_at IS NULL OR k.expires_at > NOW())
               AND k.time_slot = ANY (string_to_array(NEW.time_slot, ', '))
        ) THEN
            RAISE EXCEPTION 'That time slot is closed or blocked. Choose another time.';
        END IF;
    END IF;
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS prevent_double_booking ON public.bookings;
CREATE TRIGGER prevent_double_booking
    BEFORE INSERT OR UPDATE OF time_slot, date_schedule, court_name, status ON public.bookings
    FOR EACH ROW EXECUTE FUNCTION public.prevent_double_booking();

-- Owner accounts are created through the app's Court Owner registration flow.
-- Promote only a verified, existing account when you intentionally need a global admin:
-- UPDATE public.profiles SET role = 'admin' WHERE email = 'your-admin-email@example.com';
