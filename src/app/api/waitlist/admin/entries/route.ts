import { cookies } from 'next/headers';
import { prisma } from '@/lib/db';

const COOKIE_NAME = 'mm_admin_session';

export async function GET() {
  const cookieStore = await cookies();
  if (!cookieStore.get(COOKIE_NAME)?.value) {
    return new Response(JSON.stringify({ error: 'Unauthorized' }), {
      status: 401,
    });
  }
  const entries = await prisma.waitlist.findMany({
    orderBy: { createdAt: 'desc' },
  });
  return Response.json({ entries });
}
