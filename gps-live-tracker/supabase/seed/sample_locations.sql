-- Seed a sample device
INSERT INTO public.devices (id, name, status)
VALUES ('d9b23b12-9c17-4efd-8b01-524e12c1b52a', 'Delivery Drone 01', 'online')
ON CONFLICT (id) DO NOTHING;

-- Seed a completed trip
INSERT INTO public.trips (id, device_id, name, status, start_time, end_time)
VALUES (
    'b3e0c061-0df8-43d9-a417-0cb855877c4e', 
    'd9b23b12-9c17-4efd-8b01-524e12c1b52a', 
    'Central Park Route', 
    'completed', 
    '2026-06-24T10:00:00Z', 
    '2026-06-24T10:02:30Z'
)
ON CONFLICT (id) DO NOTHING;

-- Seed location route coordinates representing a real walk
INSERT INTO public.locations (trip_id, device_id, latitude, longitude, speed, created_at)
VALUES
  ('b3e0c061-0df8-43d9-a417-0cb855877c4e', 'd9b23b12-9c17-4efd-8b01-524e12c1b52a', 40.785091, -73.968285, 1.2, '2026-06-24T10:00:00Z'),
  ('b3e0c061-0df8-43d9-a417-0cb855877c4e', 'd9b23b12-9c17-4efd-8b01-524e12c1b52a', 40.784550, -73.967520, 1.5, '2026-06-24T10:00:30Z'),
  ('b3e0c061-0df8-43d9-a417-0cb855877c4e', 'd9b23b12-9c17-4efd-8b01-524e12c1b52a', 40.783920, -73.966950, 1.4, '2026-06-24T10:01:00Z'),
  ('b3e0c061-0df8-43d9-a417-0cb855877c4e', 'd9b23b12-9c17-4efd-8b01-524e12c1b52a', 40.783450, -73.966450, 1.3, '2026-06-24T10:01:30Z'),
  ('b3e0c061-0df8-43d9-a417-0cb855877c4e', 'd9b23b12-9c17-4efd-8b01-524e12c1b52a', 40.782800, -73.965800, 1.6, '2026-06-24T10:02:00Z'),
  ('b3e0c061-0df8-43d9-a417-0cb855877c4e', 'd9b23b12-9c17-4efd-8b01-524e12c1b52a', 40.782100, -73.965100, 1.1, '2026-06-24T10:02:30Z');
