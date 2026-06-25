-- Enable Realtime replication for public.locations table
ALTER PUBLICATION supabase_realtime ADD TABLE public.locations;

-- Drop existing location insert policy to update it
DROP POLICY IF EXISTS "Allow users to insert locations for their own trips" ON public.locations;

-- Recreate policy with stricter validation to ensure device_id matching the trip configuration
CREATE POLICY "Allow users to insert locations for their own trips"
ON public.locations FOR INSERT
TO authenticated
WITH CHECK (EXISTS (
    SELECT 1 FROM public.trips 
    WHERE trips.id = locations.trip_id 
      AND trips.owner_id = auth.uid()
      AND trips.device_id = locations.device_id
));
