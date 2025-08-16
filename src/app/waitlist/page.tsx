import { WaitlistForm } from '@/components/WaitlistForm';

export default function WaitlistPage() {
  return (
    <div className="mx-auto max-w-2xl px-4 py-16">
      <h1 className="heroTitle">Join the waitlist</h1>
      <p className="heroSubtitle mt-2">Be first to try Moments.</p>
      <div className="[&_*]:blocky mt-6">
        <WaitlistForm defaultSource="waitlist" />
      </div>
    </div>
  );
}
