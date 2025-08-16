import { prisma } from '@/lib/db';
import { redis } from '@/lib/kv';

export async function GET() {
  if (process.env.VERCEL !== '1') {
    return Response.json({ ok: true, skipped: true });
  }
  const waitlistCount = await prisma.waitlist.count();
  try {
    await redis?.set('feature:hero-variant', Math.random() > 0.5 ? 'A' : 'B');
  } catch {}
  console.log({ waitlistCount, rotated: true });
  return Response.json({ ok: true });
}
