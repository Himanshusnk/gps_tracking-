import { withSupabase } from "@supabase/server"

export default {
  fetch: withSupabase({ auth: "user" }, async (req, ctx) => {
    try {
      const { trip_id } = await req.json()

      if (!trip_id) {
        return Response.json({ error: 'Missing trip_id' }, { status: 400 })
      }

      // Fetch the trip to get device_id
      const { data: trip, error: tripFetchError } = await ctx.supabase
        .from('trips')
        .select('device_id')
        .eq('id', trip_id)
        .single()

      if (tripFetchError) throw tripFetchError

      // Complete the trip
      const { error: tripError } = await ctx.supabase
        .from('trips')
        .update({
          status: 'completed',
          end_time: new Date().toISOString()
        })
        .eq('id', trip_id)

      if (tripError) throw tripError

      // Revert device status back to online
      const { error: deviceError } = await ctx.supabase
        .from('devices')
        .update({ status: 'online' })
        .eq('id', trip.device_id)

      if (deviceError) throw deviceError

      return Response.json({ status: 'success', message: 'Trip marked as completed' }, { status: 200 })
    } catch (error) {
      return Response.json({ error: error.message }, { status: 500 })
    }
  }),
}

