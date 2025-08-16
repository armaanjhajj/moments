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
              In‑person connection, reimagined.
            </h1>
            <p className="text-muted-foreground mx-auto mt-4 max-w-2xl text-lg">
              Connect with people nearby in a way social feeds can’t.
              Personality‑first, time‑bound, and designed to nudge real
              conversations.
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
                title: 'Match on personality',
                desc: 'Go beyond swipes. Build a public, nuanced profile.',
              },
              {
                title: 'Mutual, timed meetups',
                desc: 'Only facilitate when both sides are ready—at a time and place.',
              },
              {
                title: 'In‑person first',
                desc: 'Migrate socials, reduce digital noise, and act in the real world.',
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
                title: 'In‑person network',
                desc: 'Connections are earned IRL, not farmed online.',
              },
              {
                title: 'Urgency, not endless scroll',
                desc: 'Mutual windows encourage action, not lurking.',
              },
              {
                title: 'Not a dating app',
                desc: 'Infrastructure for real connections—romantic or not.',
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
      </main>
      <SiteFooter />
    </div>
  );
}
