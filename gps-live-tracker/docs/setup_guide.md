# Setup & Getting Started Guide

This guide walks you through setting up the local development environment for the GPS Live Tracker.

## 🛠️ Prerequisites

Ensure you have the following installed:
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (v3.12.0+)
- [Node.js & npm](https://nodejs.org/) (for Supabase local CLI tooling)
- [Docker Desktop](https://www.docker.com/products/docker-desktop/) (required for local Supabase emulator stack)
- [Supabase CLI](https://supabase.com/docs/guides/cli)

---

## ⚡ Supabase Backend Setup

1. **Install Supabase CLI**
   ```bash
   # Windows (using Scoop)
   scoop bucket add supabase https://github.com/supabase/scoop-bucket.git
   scoop install supabase

   # macOS (using Homebrew)
   brew install supabase/tap/supabase
   ```

2. **Initialize Supabase**
   Navigate to the [supabase](file:///c:/project_gps/gps-live-tracker/supabase) directory:
   ```bash
   cd gps-live-tracker/supabase
   supabase init
   ```

3. **Start Local Supabase Emulator Stack**
   Make sure Docker Desktop is running, then start the local services:
   ```bash
   supabase start
   ```
   This will output local URLs and credentials (e.g., Studio URL, API URL, `anon` key, `service_role` key).

4. **Apply Migrations (Local)**
   Apply local database migrations:
   ```bash
   supabase db reset
   ```
   This loads tables, RLS permissions, and seeds sample data into your local database.

5. **Link and Deploy to Supabase Cloud**
   To connect and push these configurations directly to your production cloud project `bthayclrnzcnknexfwhn`:
   
   a. Link the local CLI to the cloud project:
   ```bash
   supabase link --project-ref bthayclrnzcnknexfwhn
   ```
   *(This will prompt you to enter your database password).*

   b. Deploy migrations (database schema & RLS rules) to cloud:
   ```bash
   supabase db push
   ```

   c. Deploy Deno Edge Functions to cloud:
   ```bash
   supabase functions deploy create_trip
   supabase functions deploy end_trip
   ```

---

## 📱 Frontend Flutter App Setup

1. **Configure Environment Keys**
   Navigate to [supabase_config.dart](file:///c:/project_gps/gps-live-tracker/frontend/gps_tracker_app/lib/core/supabase_config.dart):
   ```dart
   class SupabaseConfig {
     static const String url = 'YOUR_LOCAL_SUPABASE_API_URL';
     static const String anonKey = 'YOUR_LOCAL_SUPABASE_ANON_KEY';
   }
   ```
   *Replace these values with the local credentials outputted from the `supabase start` command.*

2. **Fetch Packages**
   From the [gps_tracker_app](file:///c:/project_gps/gps-live-tracker/frontend/gps_tracker_app) directory:
   ```bash
   cd frontend/gps_tracker_app
   flutter pub get
   ```

3. **Configure Platform-Specific Permissions**

   #### Android: `AndroidManifest.xml`
   Add the following permissions inside `<manifest>`:
   ```xml
   <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
   <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
   <uses-permission android:name="android.permission.INTERNET" />
   ```

4. **Run the App**
   ```bash
   flutter run
   ```

---

## 🏎️ Ingress & Simulation Testing

1. Launch the Flutter app on web or mobile emulator.
2. Select an active device from the home dashboard or register a new one.
3. Click **Start Trip** (which calls the `create_trip` Edge function).
4. Enable **Simulation Mode**. 
5. The device location service will publish a mock lat-long point to the database every 30 seconds.
6. The map screen will automatically display the live-moving pointer and draw the polyline route history using Supabase's realtime updates.
