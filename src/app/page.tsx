'use client';
import Link from 'next/link';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { SiteHeader } from '@/components/SiteHeader';
import { SiteFooter } from '@/components/SiteFooter';
import Image from 'next/image';
import useScrollAnimations from '@/lib/useScrollAnimations';

export default function Home() {
  useScrollAnimations();
  return (
    <div className="flex min-h-screen flex-col">
      <SiteHeader />
      <main className="flex-1">
        <section
          id="hero"
          className="from-background to-muted/30 relative bg-gradient-to-b"
        >
          <div className="mx-auto max-w-6xl px-4 py-32 text-center">
            <div className="bg-primary/15 mx-auto mb-6 flex h-12 w-12 items-center justify-center rounded-xl">
              <div className="bg-primary h-6 w-6 rounded-md" />
            </div>
            <h1 className="hero-title text-[clamp(4rem,15vw,12rem)] tracking-tight">
              In‑person connection, not another feed.
            </h1>
            <p className="hero-subtitle text-muted-foreground mx-auto mt-4 max-w-2xl text-lg">
              Connect people in a way a social presence can’t. Personality‑first
              matching, mutual timed meetups, and real‑world prompts that bring
              urgency back to forming connections.
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
          <div className="mt-8 grid gap-8 md:grid-cols-2">
            <div className="parallax-section space-y-3">
              <h3 className="text-3xl font-semibold">Meet in real life.</h3>
              <p className="text-muted-foreground">
                People meeting or talking in person.
              </p>
              <div className="blocky overflow-hidden">
                <Image
                  src="/images/people-meeting.jpg"
                  alt="People meeting"
                  width={1200}
                  height={800}
                  className="h-auto w-full"
                />
              </div>
            </div>
            <div className="parallax-section space-y-3">
              <h3 className="text-3xl font-semibold">
                Personality‑first matching.
              </h3>
              <p className="text-muted-foreground">
                App facilitates matching based on personality.
              </p>
              <div className="blocky overflow-hidden">
                <Image
                  src="/images/personality.jpg"
                  alt="Personality"
                  width={1200}
                  height={800}
                  className="h-auto w-full"
                />
              </div>
            </div>
            <div className="parallax-section space-y-3">
              <h3 className="text-3xl font-semibold">Mutual, timed meetups.</h3>
              <p className="text-muted-foreground">
                Privacy‑first, no oversharing.
              </p>
              <div className="blocky overflow-hidden">
                <Image
                  src="/images/meetup.jpg"
                  alt="Meetup"
                  width={1200}
                  height={800}
                  className="h-auto w-full"
                />
              </div>
            </div>
          </div>
          <div className="mt-12 text-center">
            <Button asChild size="lg" className="blocky glowButton">
              <Link href="/waitlist">Join the waitlist</Link>
            </Button>
          </div>
        </section>

        <section id="how-it-works" className="relative h-[300vh]">
          <div className="sticky top-1/4 mx-auto max-w-3xl px-4">
            <div id="step1" className="how-step">
              <h3 className="text-4xl font-semibold">Build your profile</h3>
              <p className="text-muted-foreground mt-2">
                Personality in, labels out.
              </p>
            </div>
            <div id="step2" className="how-step mt-10 opacity-0">
              <h3 className="text-4xl font-semibold">Mutual windows</h3>
              <p className="text-muted-foreground mt-2">
                We suggest a time and place.
              </p>
            </div>
            <div id="step3" className="how-step mt-10 opacity-0">
              <h3 className="text-4xl font-semibold">Meet in real life</h3>
              <p className="text-muted-foreground mt-2">
                Capture the moment, not a feed.
              </p>
            </div>
          </div>
        </section>

        <section className="mx-auto max-w-6xl px-4 py-16">
          <h2 className="text-2xl font-semibold">Why Moments</h2>
          <div className="mt-6 grid gap-6 md:grid-cols-3">
            {[
              {
                title: 'In‑person network',
                desc: 'A graph of people you actually met—captured as moments.',
              },
              {
                title: 'Urgency, not endless scroll',
                desc: 'Mutual windows create reasons to act, not doomscroll.',
              },
              {
                title: 'Not just dating',
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
