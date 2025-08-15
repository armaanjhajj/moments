import { prisma } from '@/lib/db';

export async function GET() {
  if (process.env.VERCEL !== '1') {
    return Response.json({ ok: true, skipped: true });
  }
  const waitlistCount = await prisma.waitlist.count();
  console.log({ weeklyWaitlistCount: waitlistCount });
  return Response.json({ ok: true });
}
