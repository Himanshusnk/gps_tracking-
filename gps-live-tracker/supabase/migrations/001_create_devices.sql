-- Create devices table
CREATE TABLE IF NOT EXISTS public.devices (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    owner_id UUID REFERENCES auth.users(id) DEFAULT auth.uid(),
    name VARCHAR(255) NOT NULL,
    status VARCHAR(50) DEFAULT 'offline' CHECK (status IN ('offline', 'online', 'tracking')),
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

-- Create trips table
CREATE TABLE IF NOT EXISTS public.trips (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    owner_id UUID REFERENCES auth.users(id) DEFAULT auth.uid(),
    device_id UUID REFERENCES public.devices(id) ON DELETE CASCADE NOT NULL,
    name VARCHAR(255) NOT NULL,
    status VARCHAR(50) DEFAULT 'active' CHECK (status IN ('active', 'completed')),
    start_time TIMESTAMPTZ DEFAULT now() NOT NULL,
    end_time TIMESTAMPTZ
);
