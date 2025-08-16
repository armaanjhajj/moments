import { NextResponse, type NextRequest } from 'next/server';
import { redis } from '@/lib/kv';

export async function middleware(req: NextRequest) {
  const res = NextResponse.next();

  const csp = [
    "default-src 'self'",
    "img-src 'self' data: https:",
    "script-src 'self' 'unsafe-inline' 'unsafe-eval' https:",
    "style-src 'self' 'unsafe-inline' https:",
    "connect-src 'self' https:",
    "font-src 'self' data: https:",
  ].join('; ');

  res.headers.set('Content-Security-Policy-Report-Only', csp);
  res.headers.set('Referrer-Policy', 'strict-origin-when-cross-origin');
  res.headers.set('X-Frame-Options', 'DENY');
  res.headers.set('X-Content-Type-Options', 'nosniff');
  res.headers.set(
    'Permissions-Policy',
    'camera=(), microphone=(), geolocation=()',
  );

  // A/B variant pinning via cookie and KV default
  const cookie = req.cookies.get('hero-variant');
  let variant = cookie?.value;
  if (!variant) {
    try {
      variant = (
        (await redis?.get<string>('feature:hero-variant')) || 'A'
      ).toString();
    } catch {
      variant = 'A';
    }
    res.cookies.set('hero-variant', variant, {
      path: '/',
      maxAge: 60 * 60 * 24 * 30,
    });
  }
  res.headers.set('x-hero-variant', variant || 'A');

  return res;
}

export const config = {
  matcher: '/:path*',
};
