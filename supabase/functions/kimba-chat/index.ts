// Kimba Chat — Supabase Edge Function
// AI campus navigator powered by GPT-4o-mini.
// Never stores API keys on client. Always scoped to school_id.

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const OPENAI_API_KEY = Deno.env.get("OPENAI_API_KEY")!;

interface ChatRequest {
  user_id: string;
  school_id: string;
  message: string;
  conversation_history?: Array<{ role: string; content: string }>;
}

Deno.serve(async (req) => {
  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
  );

  const { user_id, school_id, message, conversation_history = [] } =
    (await req.json()) as ChatRequest;

  // Gather campus context for this school
  const { data: places } = await supabase
    .from("places")
    .select("name, type")
    .eq("school_id", school_id);

  const { data: rooms } = await supabase
    .from("rooms")
    .select("name, description, tags")
    .eq("school_id", school_id)
    .limit(20);

  // Get recent activity
  const { data: recentLogs } = await supabase
    .from("place_logs")
    .select("places(name), mood, rating")
    .eq("school_id", school_id)
    .order("created_at", { ascending: false })
    .limit(10);

  const placeList = places?.map((p) => `${p.name} (${p.type})`).join(", ") ?? "none";
  const roomList = rooms?.map((r) => `${r.name}: ${r.description ?? ""}`).join("; ") ?? "none";
  const activitySummary =
    recentLogs
      ?.map((l: any) => `${l.places?.name}: ${l.mood} (${l.rating}/5)`)
      .join("; ") ?? "no recent logs";

  const systemPrompt = `You are Kimba, the AI campus navigator for Moments. You help students discover what's happening on campus.

Current school context:
- Places: ${placeList}
- Active rooms: ${roomList}
- Recent vibes: ${activitySummary}

Rules:
- Always be helpful, brief, and campus-aware
- If you don't know something, say so — don't make things up
- You can suggest places, rooms, or actions
- When recommending a place or room, include an action card in your response
- Never discuss other schools or off-campus topics
- Keep responses under 3 sentences unless the user asks for more detail

Action cards (optional JSON in your response):
- {"type": "place", "id": "<place_id>", "label": "Check out [name]"}
- {"type": "room", "id": "<room_id>", "label": "Join [room name]"}
- {"type": "user", "id": "<user_id>", "label": "View [user]'s profile"}`;

  const messages = [
    { role: "system", content: systemPrompt },
    ...conversation_history.slice(-8),
    { role: "user", content: message },
  ];

  try {
    const response = await fetch("https://api.openai.com/v1/chat/completions", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${OPENAI_API_KEY}`,
      },
      body: JSON.stringify({
        model: "gpt-4o-mini",
        messages,
        max_tokens: 300,
        temperature: 0.7,
      }),
    });

    const data = await response.json();
    const content = data.choices?.[0]?.message?.content ?? "I'm not sure about that.";

    // Try to extract action card from response
    let action = null;
    const actionMatch = content.match(/\{[^}]*"type"\s*:\s*"(room|place|user)"[^}]*\}/);
    if (actionMatch) {
      try {
        action = JSON.parse(actionMatch[0]);
      } catch {
        // ignore parse errors
      }
    }

    // Clean action JSON from the visible message
    const cleanMessage = content
      .replace(/\{[^}]*"type"\s*:\s*"(room|place|user)"[^}]*\}/g, "")
      .trim();

    return new Response(
      JSON.stringify({ message: cleanMessage, action }),
      { headers: { "Content-Type": "application/json" } }
    );
  } catch (error) {
    return new Response(
      JSON.stringify({
        message: "I'm not available right now — try checking the map.",
        action: null,
      }),
      { headers: { "Content-Type": "application/json" } }
    );
  }
});
