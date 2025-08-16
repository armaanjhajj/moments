import { WaitlistForm } from '@/components/WaitlistForm';

export default function WaitlistPage() {
  return (
    <div className="mx-auto max-w-xl px-4 py-16">
      <h1 className="text-3xl font-semibold">Join the waitlist</h1>
      <p className="text-muted-foreground mt-2">
        Sign up to be the first to try Moments.
      </p>
      <WaitlistForm defaultSource="waitlist" />
    </div>
  );
}
