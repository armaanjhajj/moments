import { cookies } from 'next/headers';

const ADMIN_PASSWORD = process.env.ADMIN_PASSWORD || 'Moments2025!!';
const COOKIE_NAME = 'mm_admin_session';

export async function POST(req: Request) {
  const { password } = await req.json();
  if (typeof password !== 'string' || password !== ADMIN_PASSWORD) {
    return new Response(JSON.stringify({ ok: false }), { status: 401 });
  }
  const cookieStore = await cookies();
  cookieStore.set(COOKIE_NAME, '1', {
    httpOnly: true,
    path: '/',
    maxAge: 60 * 60 * 8,
  });
  return Response.json({ ok: true });
}
