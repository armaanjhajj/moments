// Compute Overlaps — Supabase Edge Function
// Triggered by cron (every 30 min) or manually.
// Reads location_pings from the last window, detects co-presence events,
// updates overlap_scores, and creates Sparks when threshold is met.

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const OVERLAP_WINDOW_MINUTES = 30;
const SPARK_THRESHOLD = 3; // co-presence events needed to create a Spark

Deno.serve(async (req) => {
  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
  );

  const cutoff = new Date(
    Date.now() - OVERLAP_WINDOW_MINUTES * 60 * 1000
  ).toISOString();

  // 1. Get recent pings grouped by place
  const { data: pings, error: pingErr } = await supabase
    .from("location_pings")
    .select("user_id, school_id, place_id, pinged_at")
    .gte("pinged_at", cutoff);

  if (pingErr || !pings) {
    return new Response(JSON.stringify({ error: pingErr?.message }), {
      status: 500,
    });
  }

  // 2. Group pings by (school_id, place_id)
  const grouped: Record<string, Set<string>> = {};
  for (const ping of pings) {
    const key = `${ping.school_id}:${ping.place_id}`;
    if (!grouped[key]) grouped[key] = new Set();
    grouped[key].add(ping.user_id);
  }

  // 3. For each place with 2+ users, create co-presence events
  let eventsCreated = 0;
  let sparksCreated = 0;

  for (const [key, userSet] of Object.entries(grouped)) {
    const users = Array.from(userSet);
    if (users.length < 2) continue;

    const [schoolId, placeId] = key.split(":");

    // Generate pairs (canonical ordering: user_a < user_b)
    for (let i = 0; i < users.length; i++) {
      for (let j = i + 1; j < users.length; j++) {
        const [userA, userB] =
          users[i] < users[j]
            ? [users[i], users[j]]
            : [users[j], users[i]];

        // Insert co-presence event
        await supabase.from("copresence_events").insert({
          user_a: userA,
          user_b: userB,
          place_id: placeId,
          school_id: schoolId,
        });
        eventsCreated++;

        // Update overlap score
        const { data: existing } = await supabase
          .from("overlap_scores")
          .select("score")
          .eq("user_a", userA)
          .eq("user_b", userB)
          .maybeSingle();

        const newScore = (existing?.score ?? 0) + 1;

        await supabase.from("overlap_scores").upsert({
          user_a: userA,
          user_b: userB,
          school_id: schoolId,
          score: newScore,
          last_computed_at: new Date().toISOString(),
        });

        // Check if we should create a Spark
        if (newScore >= SPARK_THRESHOLD) {
          // Only create if no existing spark or connection
          const { data: existingSpark } = await supabase
            .from("sparks")
            .select("id")
            .eq("user_a", userA)
            .eq("user_b", userB)
            .maybeSingle();

          const { data: existingConn } = await supabase
            .from("connections")
            .select("id")
            .eq("user_a", userA)
            .eq("user_b", userB)
            .maybeSingle();

          if (!existingSpark && !existingConn) {
            // Get top shared place
            const { data: topPlace } = await supabase
              .from("copresence_events")
              .select("place_id, places(name)")
              .eq("user_a", userA)
              .eq("user_b", userB)
              .order("occurred_at", { ascending: false })
              .limit(1)
              .maybeSingle();

            const overlapContext = {
              place_name: (topPlace as any)?.places?.name ?? null,
              visit_count: newScore,
              shared_interest: null,
            };

            await supabase.from("sparks").insert({
              user_a: userA,
              user_b: userB,
              school_id: schoolId,
              overlap_score: newScore,
              overlap_context: overlapContext,
            });
            sparksCreated++;
          }
        }
      }
    }
  }

  return new Response(
    JSON.stringify({
      events_created: eventsCreated,
      sparks_created: sparksCreated,
    }),
    { headers: { "Content-Type": "application/json" } }
  );
});
