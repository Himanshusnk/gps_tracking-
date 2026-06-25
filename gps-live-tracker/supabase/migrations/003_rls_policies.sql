-- Enable RLS on all tables
ALTER TABLE public.devices ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.trips ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.locations ENABLE ROW LEVEL SECURITY;

-- 1. Devices Policies
CREATE POLICY "Allow users to read their own devices"
ON public.devices FOR SELECT
TO authenticated
USING (auth.uid() = owner_id);

CREATE POLICY "Allow service_role full control of devices"
ON public.devices FOR ALL
TO service_role
USING (true)
WITH CHECK (true);

CREATE POLICY "Allow users to manage their own devices"
ON public.devices FOR ALL
TO authenticated
USING (auth.uid() = owner_id)
WITH CHECK (auth.uid() = owner_id);

-- 2. Trips Policies
CREATE POLICY "Allow users to read their own trips"
ON public.trips FOR SELECT
TO authenticated
USING (auth.uid() = owner_id);

CREATE POLICY "Allow service_role full control of trips"
ON public.trips FOR ALL
TO service_role
USING (true)
WITH CHECK (true);

CREATE POLICY "Allow users to manage their own trips"
ON public.trips FOR ALL
TO authenticated
USING (auth.uid() = owner_id)
WITH CHECK (auth.uid() = owner_id);

-- 3. Locations Policies
CREATE POLICY "Allow users to read locations of their own trips"
ON public.locations FOR SELECT
TO authenticated
USING (EXISTS (
    SELECT 1 FROM public.trips 
    WHERE trips.id = locations.trip_id AND trips.owner_id = auth.uid()
));

CREATE POLICY "Allow service_role full control of locations"
ON public.locations FOR ALL
TO service_role
USING (true)
WITH CHECK (true);

CREATE POLICY "Allow users to insert locations for their own trips"
ON public.locations FOR INSERT
TO authenticated
WITH CHECK (EXISTS (
    SELECT 1 FROM public.trips 
    WHERE trips.id = locations.trip_id AND trips.owner_id = auth.uid()
));
