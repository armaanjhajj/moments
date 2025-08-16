'use client';

import Link from 'next/link';
import Image from 'next/image';
import { Button } from '@/components/ui/button';

export function SiteHeader() {
  return (
    <header className="bg-background/60 supports-[backdrop-filter]:bg-background/60 w-full border-b backdrop-blur">
      <div className="mx-auto flex max-w-6xl items-center justify-between px-4 py-3">
        <Link href="/" className="flex items-center gap-3">
          <Image src="/logo.png" alt="Moments" width={28} height={28} />
          <span className="wordmark text-2xl font-semibold tracking-tight">
            moments
          </span>
        </Link>
        <nav className="flex items-center gap-3">
          <Link
            href="/about"
            className="text-muted-foreground hover:text-foreground text-sm"
          >
            About
          </Link>
          <Link
            href="/waitlist"
            className="text-muted-foreground hover:text-foreground text-sm"
          >
            Waitlist
          </Link>
          <Link
            href="/api/auth/signin"
            className="text-muted-foreground hover:text-foreground text-sm"
          >
            Sign in
          </Link>
          <Button asChild>
            <Link href="/waitlist">Join waitlist</Link>
          </Button>
        </nav>
      </div>
    </header>
  );
}
