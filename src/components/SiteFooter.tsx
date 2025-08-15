import Link from 'next/link';

export function SiteFooter() {
  return (
    <footer className="w-full border-t">
      <div className="text-muted-foreground mx-auto grid max-w-6xl gap-4 px-4 py-8 text-sm md:grid-cols-2">
        <p>© {new Date().getFullYear()} Moments. All rights reserved.</p>
        <nav className="flex gap-4 md:justify-end">
          <Link href="/legal/terms">Terms</Link>
          <Link href="/legal/privacy">Privacy</Link>
          <Link href="/about">About</Link>
          <Link href="#">X</Link>
          <Link href="#">IG</Link>
        </nav>
      </div>
    </footer>
  );
}
