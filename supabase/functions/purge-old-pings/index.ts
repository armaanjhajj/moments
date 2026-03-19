// Purge Old Pings — Supabase Edge Function
// Runs on a cron schedule to delete location_pings older than 48 hours.
// Keeps the pings table lean for fast overlap computation.

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

Deno.serve(async (_req) => {
  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
  );

  const cutoff = new Date(Date.now() - 48 * 60 * 60 * 1000).toISOString();

  const { count, error } = await supabase
    .from("location_pings")
    .delete()
    .lt("pinged_at", cutoff)
    .select("*", { count: "exact", head: true });

  if (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
    });
  }

  return new Response(
    JSON.stringify({
      purged: count ?? 0,
      cutoff,
    }),
    { headers: { "Content-Type": "application/json" } }
  );
});
