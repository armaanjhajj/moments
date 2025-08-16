import { kv } from '@vercel/kv';

export async function incrementWithLimit(
  key: string,
  limit: number,
  ttlSeconds: number,
) {
  const count = await kv.incr(key);
  if (count === 1) {
    await kv.expire(key, ttlSeconds);
  }
  return count <= limit;
}

export { kv };
