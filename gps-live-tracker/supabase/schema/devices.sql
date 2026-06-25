-- Schema for public.devices table
CREATE TABLE public.devices (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    owner_id UUID REFERENCES auth.users(id) DEFAULT auth.uid(),
    name VARCHAR(255) NOT NULL,
    status VARCHAR(50) DEFAULT 'offline' CHECK (status IN ('offline', 'online', 'tracking')),
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

-- Descriptions
COMMENT ON TABLE public.devices IS 'Registered devices representing physical GPS trackers or emulated clients.';
COMMENT ON COLUMN public.devices.id IS 'Primary key UUID for tracking devices.';
COMMENT ON COLUMN public.devices.owner_id IS 'Reference to the owner user in auth.users.';
COMMENT ON COLUMN public.devices.status IS 'Active telemetry status of the device.';
