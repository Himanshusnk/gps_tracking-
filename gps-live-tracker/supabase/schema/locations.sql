-- Schema for public.locations table
CREATE TABLE public.locations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    trip_id UUID REFERENCES public.trips(id) ON DELETE CASCADE NOT NULL,
    device_id UUID REFERENCES public.devices(id) ON DELETE CASCADE NOT NULL,
    latitude NUMERIC(9,6) NOT NULL CHECK (latitude BETWEEN -90 AND 90),
    longitude NUMERIC(9,6) NOT NULL CHECK (longitude BETWEEN -180 AND 180),
    speed NUMERIC DEFAULT 0 NOT NULL,
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

-- Descriptions
COMMENT ON TABLE public.locations IS 'Recorded GPS coordinates tracking device movements.';
COMMENT ON COLUMN public.locations.trip_id IS 'Foreign key referencing the trip during which these coordinates were recorded.';
COMMENT ON COLUMN public.locations.latitude IS 'Geographical latitude coordinate.';
COMMENT ON COLUMN public.locations.longitude IS 'Geographical longitude coordinate.';
