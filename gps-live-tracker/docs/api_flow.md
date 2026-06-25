# API & Data Flow

This document details the interface contracts, real-time message structures, and Edge Function operations in the GPS Live Tracker system.

## 📡 Live Location Ingestion

GPS devices post coordinates to the Supabase database. The ingestion is handled by direct database inserts (via Flutter SDK or simulated clients) or secure REST API calls.

### Telemetry Payload Schema

When a device updates its position, it posts a record containing:

```json
{
  "device_id": "d9b23b12-9c17-4efd-8b01-524e12c1b52a",
  "trip_id": "b3e0c061-0df8-43d9-a417-0cb855877c4e",
  "latitude": 37.7749,
  "longitude": -122.4194,
  "speed": 12.5,
  "heading": 180.0,
  "altitude": 15.0,
  "created_at": "2026-06-24T12:00:00Z"
}
```

---

## ⚡ Supabase Edge Functions

### 1. `create_trip`
Initiates a new active tracking trip session for a device.

- **Endpoint**: `POST /functions/v1/create_trip`
- **Headers**:
  - `Authorization: Bearer <anon/service_key>`
- **Request Body**:
  ```json
  {
    "device_id": "d9b23b12-9c17-4efd-8b01-524e12c1b52a",
    "trip_name": "Morning Commute"
  }
  ```
- **Response (201 Created)**:
  ```json
  {
    "status": "success",
    "trip_id": "b3e0c061-0df8-43d9-a417-0cb855877c4e"
  }
  ```

### 2. `end_trip`
Concludes an active trip session.

- **Endpoint**: `POST /functions/v1/end_trip`
- **Headers**:
  - `Authorization: Bearer <anon/service_key>`
- **Request Body**:
  ```json
  {
    "trip_id": "b3e0c061-0df8-43d9-a417-0cb855877c4e"
  }
  ```
- **Response (200 OK)**:
  ```json
  {
    "status": "success",
    "message": "Trip marked as completed"
  }
  ```

---

## 🔄 Realtime Subscription Loop

The Flutter frontend subscribes to Postgres database changes via Supabase Realtime Channels.

### Channel Topic
`realtime:public:locations:trip_id=eq.<trip_id>`

### Event Payload Broadcasted
When a new location is inserted, the client receives an event package:

```json
{
  "schema": "public",
  "table": "locations",
  "commit_timestamp": "2026-06-24T12:00:00.500Z",
  "eventType": "INSERT",
  "new": {
    "id": "e81cf5d2-a74e-4f32-abf1-ea1c3a647bc5",
    "trip_id": "b3e0c061-0df8-43d9-a417-0cb855877c4e",
    "device_id": "d9b23b12-9c17-4efd-8b01-524e12c1b52a",
    "latitude": 37.7749,
    "longitude": -122.4194,
    "speed": 12.5,
    "created_at": "2026-06-24T12:00:00Z"
  },
  "old": null
}
```
The frontend parsing engine consumes this event, pushes it into the `RouteService` stream, and shifts the marker to the new coordinates on the OSM Map.
