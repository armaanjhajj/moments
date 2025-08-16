import Link from 'next/link';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { SiteHeader } from '@/components/SiteHeader';
import { SiteFooter } from '@/components/SiteFooter';

export default function Home() {
  return (
    <div className="flex min-h-screen flex-col">
      <SiteHeader />
      <main className="flex-1">
        <section className="from-background to-muted/30 bg-gradient-to-b">
          <div className="mx-auto max-w-6xl px-4 py-20 text-center">
            <div className="bg-primary/15 mx-auto mb-6 flex h-12 w-12 items-center justify-center rounded-xl">
              <div className="bg-primary h-6 w-6 rounded-md" />
            </div>
            <h1 className="text-4xl font-semibold tracking-tight md:text-6xl">
              Capture and share your most meaningful moments
            </h1>
            <p className="text-muted-foreground mx-auto mt-4 max-w-2xl text-lg">
              Moments helps you save, organize, and share the moments that
              matter with the people who matter.
            </p>
            <div className="mt-8 flex items-center justify-center gap-3">
              <Button asChild>
                <Link href="/waitlist">Join Waitlist</Link>
              </Button>
              <Button asChild variant="secondary">
                <Link href="#how">Learn more</Link>
              </Button>
            </div>
          </div>
        </section>

        <section id="how" className="mx-auto max-w-6xl px-4 py-16">
          <h2 className="text-2xl font-semibold">How it works</h2>
          <div className="mt-6 grid gap-6 md:grid-cols-3">
            {[
              {
                title: 'Save',
                desc: 'Quickly capture moments as they happen.',
              },
              {
                title: 'Organize',
                desc: 'Keep moments organized and findable.',
              },
              {
                title: 'Share',
                desc: 'Share with friends and family securely.',
              },
            ].map((item) => (
              <Card key={item.title}>
                <CardHeader>
                  <CardTitle>{item.title}</CardTitle>
                </CardHeader>
                <CardContent>
                  <p className="text-muted-foreground">{item.desc}</p>
                </CardContent>
              </Card>
            ))}
          </div>
        </section>

        <section className="mx-auto max-w-6xl px-4 py-16">
          <h2 className="text-2xl font-semibold">Why Moments</h2>
          <div className="mt-6 grid gap-6 md:grid-cols-3">
            {[
              {
                title: 'Private by default',
                desc: 'You control who sees what.',
              },
              {
                title: 'Fast and reliable',
                desc: 'Built for speed and scale.',
              },
              { title: 'Future-proof', desc: 'Designed to evolve with you.' },
            ].map((item) => (
              <Card key={item.title}>
                <CardHeader>
                  <CardTitle>{item.title}</CardTitle>
                </CardHeader>
                <CardContent>
                  <p className="text-muted-foreground">{item.desc}</p>
                </CardContent>
              </Card>
            ))}
          </div>
        </section>
      </main>
      <SiteFooter />
    </div>
  );
}
