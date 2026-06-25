-- Create locations table for time-series geospatial points
CREATE TABLE IF NOT EXISTS public.locations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    trip_id UUID REFERENCES public.trips(id) ON DELETE CASCADE NOT NULL,
    device_id UUID REFERENCES public.devices(id) ON DELETE CASCADE NOT NULL,
    latitude NUMERIC(9,6) NOT NULL CHECK (latitude BETWEEN -90 AND 90),
    longitude NUMERIC(9,6) NOT NULL CHECK (longitude BETWEEN -180 AND 180),
    speed NUMERIC DEFAULT 0 NOT NULL,
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

-- Optimize location queries sorted by newest points first
CREATE INDEX IF NOT EXISTS idx_locations_trip_time ON public.locations(trip_id, created_at DESC);

-- Trigger to update device status to "tracking" when new locations are logged
CREATE OR REPLACE FUNCTION public.update_device_status_on_location()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE public.devices
    SET status = 'tracking'
    WHERE id = NEW.device_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER trg_update_device_status
AFTER INSERT ON public.locations
FOR EACH ROW
EXECUTE FUNCTION public.update_device_status_on_location();
