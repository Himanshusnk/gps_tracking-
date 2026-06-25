# GPS Live Tracker

A modern, real-time GPS tracking system leveraging the Supabase backend ecosystem for seamless real-time data sync, secure database storage, and quick deployment.

## 📌 Project Overview

This repository contains the complete codebase for the GPS Live Tracker project, leveraging Supabase for user authentication, real-time database subscription channels, and secure Edge Functions.

## 📂 Repository Structure

The project is structured as follows:

```text
gps-live-tracker/
│
├── frontend/
│   └── gps_tracker_app/     # Web/mobile client utilizing Supabase client library for live sync
│
├── supabase/                 # Supabase local config, edge functions, migrations, and database schema
│
├── docs/                     # Documentation, design specs, and system guides
│
├── .gitignore                # Git ignore configuration
├── README.md                 # Project roadmap, setup instructions, and overview
└── architecture.md           # Visual & structural documentation of the system design
```

## 🛠️ Tech Stack & Components

- **Frontend**: A modern UI map visualization dashboard subscribing directly to database changes using the `@supabase/supabase-js` Realtime client.
- **Supabase Backend**: 
  - **Database (PostgreSQL + PostGIS)**: Handles geospatial coordinates and location records.
  - **Authentication**: Direct user signup and device token authentication.
  - **Realtime Service**: Subscribes to insert events on the coordinates table and pushes telemetry changes to the frontend.
  - **Edge Functions**: Used for custom webhooks or device ingestion endpoints.

## 🚀 Quick Start (Future Setup)

Detailed initialization and startup instructions for the frontend and Supabase cli will be populated as their implementations are built out.

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd gps-live-tracker
   ```

2. **Supabase Local Setup**
   Ensure the Supabase CLI is installed:
   ```bash
   cd supabase
   supabase init
   ```
