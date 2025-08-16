import { getServerSession } from 'next-auth';
import { authOptions } from '@/lib/auth';
import { redirect } from 'next/navigation';

export default async function ProtectedPage() {
  const session = await getServerSession(authOptions);
  if (!session) {
    redirect('/api/auth/signin');
  }
  return (
    <div className="mx-auto max-w-xl px-4 py-16">
      <h1 className="text-3xl font-semibold">Protected</h1>
      <p className="text-muted-foreground mt-2">You are signed in.</p>
    </div>
  );
}
