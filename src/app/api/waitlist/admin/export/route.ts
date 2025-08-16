import { cookies } from 'next/headers';
import { prisma } from '@/lib/db';

const COOKIE_NAME = 'mm_admin_session';

export async function GET() {
  const cookieStore = await cookies();
  if (!cookieStore.get(COOKIE_NAME)?.value) {
    return new Response('Unauthorized', { status: 401 });
  }
  const entries = await prisma.waitlist.findMany({
    orderBy: { createdAt: 'desc' },
  });
  const rows = [
    ['email', 'source', 'createdAt'],
    ...entries.map((e) => [e.email, e.source ?? '', e.createdAt.toISOString()]),
  ];
  const csv = rows
    .map((r) => r.map((v) => `"${String(v).replaceAll('"', '""')}"`).join(','))
    .join('\n');
  return new Response(csv, {
    status: 200,
    headers: {
      'Content-Type': 'text/csv; charset=utf-8',
      'Content-Disposition': 'attachment; filename=waitlist.csv',
    },
  });
}
