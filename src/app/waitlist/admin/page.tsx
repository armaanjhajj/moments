'use client';

import { useEffect, useState } from 'react';

type Entry = {
  id: string;
  email: string;
  source?: string | null;
  createdAt: string;
};

export default function AdminWaitlistPage() {
  const [password, setPassword] = useState('');
  const [entries, setEntries] = useState<Entry[] | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);

  async function fetchEntries() {
    setLoading(true);
    setError(null);
    try {
      const res = await fetch('/api/waitlist/admin/entries', {
        cache: 'no-store',
      });
      if (res.status === 401) {
        setEntries(null);
        return;
      }
      const data = await res.json();
      setEntries(data.entries as Entry[]);
    } catch (e) {
      setError('Failed to load entries');
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    fetchEntries();
  }, []);

  async function onLogin(e: React.FormEvent) {
    e.preventDefault();
    setLoading(true);
    setError(null);
    try {
      const res = await fetch('/api/waitlist/admin/login', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ password }),
      });
      if (!res.ok) {
        setError('Invalid password');
        return;
      }
      setPassword('');
      await fetchEntries();
    } catch (e) {
      setError('Login failed');
    } finally {
      setLoading(false);
    }
  }

  if (!entries) {
    return (
      <div className="mx-auto max-w-md px-4 py-16">
        <h1 className="heroTitle">Admin</h1>
        <p className="heroSubtitle mt-2">Waitlist dashboard</p>
        <form onSubmit={onLogin} className="[&_*]:blocky mt-8 space-y-3">
          <input
            type="password"
            required
            placeholder="Password"
            className="bg-background w-full border px-3 py-2"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
          />
          <button
            type="submit"
            disabled={loading}
            className="bg-primary w-full px-4 py-2 text-white"
          >
            {loading ? 'Signing in…' : 'Sign in'}
          </button>
          {error ? <p className="text-sm text-red-600">{error}</p> : null}
        </form>
      </div>
    );
  }

  return (
    <div className="mx-auto max-w-5xl px-4 py-16">
      <div className="flex items-end justify-between gap-3">
        <div>
          <h1 className="heroTitle">Waitlist</h1>
          <p className="heroSubtitle mt-2">{entries.length} entries</p>
        </div>
        <a
          href="/api/waitlist/admin/export"
          className="blocky bg-primary px-4 py-2 text-white"
        >
          Export CSV
        </a>
      </div>
      <div className="mt-8 overflow-x-auto">
        <table className="w-full border-collapse">
          <thead>
            <tr className="bg-muted text-left">
              <th className="border px-3 py-2">Email</th>
              <th className="border px-3 py-2">Source</th>
              <th className="border px-3 py-2">Date</th>
            </tr>
          </thead>
          <tbody>
            {entries.map((e, i) => (
              <tr key={e.id} className={i % 2 ? 'bg-muted/30' : ''}>
                <td className="border px-3 py-2">{e.email}</td>
                <td className="border px-3 py-2">{e.source || '-'}</td>
                <td className="border px-3 py-2">
                  {new Date(e.createdAt).toLocaleString()}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}
