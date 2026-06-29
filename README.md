# GPS Live Tracker (Supabase + Flutter)

A modern, high-performance, real-time GPS tracking system leveraging Flutter for the client dashboard and the Supabase backend ecosystem for auth, storage, and WebSocket updates.

This app streams real-time telemetry coordinates from devices and renders smooth path animations on a vector map using OpenStreetMap (OSM).

## 🚀 Key Features

* **Real-time Map Synchronization:** Subscribes to PostgreSQL database updates over WebSockets using the Supabase Realtime client.
* **Smooth Animation Engine:** Integrates a custom animation controller that smoothly translates the location marker and pans the camera in sync, avoiding sudden "teleporting" jumps on the map.
* **30-Second Ping Interval:** Employs a periodic tracker to gather physical coordinates and ping the database exactly every 30 seconds, eliminating GPS hardware jitter and optimizing network resources.
* **Device Telemetry Workspace:** Registers multiple tracking devices (e.g., cellphones, drones) under a single owner.
* **Supabase Authentication:** Secure user signup and sign-in gates utilizing the Supabase Auth framework.
* **Android Native Optimizations:**
  * Configured permissions for internet access and high-accuracy GPS locations.
  * Stylized **Google Maps pointer** app icon and internal marker pin.
  * Custom R8 code and resource shrinking for highly optimized production sizes.

---

## 📂 Repository Structure

```text
gps-live-tracker/
│
├── frontend/
│   └── gps_tracker_app/     # Flutter application
│       ├── android/         # Android configurations (permissions, app icon, Gradle optimization)
│       └── lib/
│           ├── core/        # App theme & Supabase credentials configuration
│           ├── models/      # Device & Location schemas
│           ├── screens/     # Map workspace, authentication view, and home panels
│           ├── services/    # Location services & Supabase client handlers
│           └── widgets/     # Custom UI buttons and maps
│
├── supabase/                # Local database schemas and migration SQLs
│   └── migrations/          # Table structures, RLS rules, and triggers
