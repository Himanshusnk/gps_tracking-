# Supabase Backend Services

This directory contains database schema definitions, data migration SQL scripts, and Edge Functions running Deno.

## 📁 Folder Directory

- **`migrations/`**: Automatically run in sequential order by Supabase CLI (`supabase db reset`) to load tables, indexes, and configure permissions.
- **`functions/`**: Edge functions serving administrative REST endpoints.
- **`seed/`**: Base datasets populated in local databases during initialization.
- **`schema/`**: Clean descriptive schemas mapping databases.

## 🚀 Running Local Edge Functions

To run or test Edge Functions locally:

1. **Start Supabase emulator**:
   ```bash
   supabase start
   ```

2. **Serve Edge Functions locally**:
   ```bash
   supabase functions serve
   ```
   *By default, local functions can be triggered on `http://localhost:54321/functions/v1/<function_name>`.*

## ☁️ Deploying to Supabase Cloud

To push this entire local setup to your live Supabase project (`bthayclrnzcnknexfwhn`):

1. **Link the CLI**:
   ```bash
   supabase link --project-ref bthayclrnzcnknexfwhn
   ```
2. **Push Migrations**:
   ```bash
   supabase db push
   ```
3. **Deploy Functions**:
   ```bash
   supabase functions deploy create_trip
   supabase functions deploy end_trip
   ```
