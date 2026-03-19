// Send Drop Notification — Supabase Edge Function
// Called when a user enters a drop's geofence region.
// Sends a push notification to the drop creator.

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

Deno.serve(async (req) => {
  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
  );

  const { drop_id, finder_id } = await req.json();

  // Get drop details
  const { data: drop } = await supabase
    .from("drops")
    .select("user_id, hint, places(name)")
    .eq("id", drop_id)
    .single();

  if (!drop) {
    return new Response(JSON.stringify({ error: "Drop not found" }), {
      status: 404,
    });
  }

  // Get finder info
  const { data: finder } = await supabase
    .from("users")
    .select("display_name, handle")
    .eq("id", finder_id)
    .single();

  // Record the find
  await supabase.from("drop_finds").insert({
    drop_id,
    finder_id,
  });

  // TODO: Send push notification via APNs when configured
  // For now, log the event
  console.log(
    `Drop found: ${finder?.display_name ?? "Someone"} found drop at ${(drop as any).places?.name ?? "unknown"}`
  );

  return new Response(
    JSON.stringify({
      success: true,
      message: `${finder?.display_name ?? "Someone"} found your drop!`,
    }),
    { headers: { "Content-Type": "application/json" } }
  );
});
