import { z } from 'zod';
import { prisma } from '@/lib/db';
import { incrementWithLimit, kv } from '@/lib/kv';

const WaitlistSchema = z.object({
  email: z.string().email(),
  source: z.string().optional(),
});

export async function POST(req: Request) {
  const ip = (
    req.headers.get('x-forwarded-for') ||
    req.headers.get('x-real-ip') ||
    'unknown'
  ).split(',')[0];
  const body = await req.json().catch(() => null);
  const parsed = WaitlistSchema.safeParse(body);
  if (!parsed.success) {
    return new Response(JSON.stringify({ error: 'Invalid input' }), {
      status: 400,
    });
  }

  const { email, source } = parsed.data;

  const allowedByIp = await incrementWithLimit(
    `rl:waitlist:ip:${ip}`,
    5,
    60 * 10,
  );
  const allowedByEmail = await incrementWithLimit(
    `rl:waitlist:email:${email}`,
    3,
    60 * 60,
  );
  if (!allowedByIp || !allowedByEmail) {
    return new Response(JSON.stringify({ error: 'Rate limit exceeded' }), {
      status: 429,
    });
  }

  try {
    await prisma.waitlist.upsert({
      where: { email },
      update: { source },
      create: { email, source },
    });
    // Stub: enqueue confirmation
    await kv.set(`waitlist:confirm:${email}`, Date.now(), { ex: 60 * 60 });
  } catch (e) {
    return new Response(JSON.stringify({ error: 'Failed to save' }), {
      status: 500,
    });
  }

  return Response.json({ ok: true });
}
