import { withSupabase } from "@supabase/server"

export default {
  fetch: withSupabase({ auth: "user" }, async (req, ctx) => {
    try {
      const { device_id, trip_name } = await req.json()

      if (!device_id || !trip_name) {
        return Response.json({ error: 'Missing device_id or trip_name' }, { status: 400 })
      }

      // Insert new trip
      const { data: trip, error: tripError } = await ctx.supabase
        .from('trips')
        .insert({
          device_id,
          name: trip_name,
          status: 'active'
        })
        .select()
        .single()

      if (tripError) throw tripError

      // Set device status to tracking
      const { error: deviceError } = await ctx.supabase
        .from('devices')
        .update({ status: 'tracking' })
        .eq('id', device_id)

      if (deviceError) throw deviceError

      return Response.json({ status: 'success', trip_id: trip.id }, { status: 201 })
    } catch (error) {
      return Response.json({ error: error.message }, { status: 500 })
    }
  }),
}

