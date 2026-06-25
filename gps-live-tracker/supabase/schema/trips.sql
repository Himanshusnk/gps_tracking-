-- Schema for public.trips table
CREATE TABLE public.trips (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    owner_id UUID REFERENCES auth.users(id) DEFAULT auth.uid(),
    device_id UUID REFERENCES public.devices(id) ON DELETE CASCADE NOT NULL,
    name VARCHAR(255) NOT NULL,
    status VARCHAR(50) DEFAULT 'active' CHECK (status IN ('active', 'completed')),
    start_time TIMESTAMPTZ DEFAULT now() NOT NULL,
    end_time TIMESTAMPTZ
);

-- Descriptions
COMMENT ON TABLE public.trips IS 'Collections of recorded points grouped by user-initiated trip paths.';
COMMENT ON COLUMN public.trips.owner_id IS 'Reference to the owner user in auth.users.';
COMMENT ON COLUMN public.trips.status IS 'Status indicator if the tracking run is active or completed.';
