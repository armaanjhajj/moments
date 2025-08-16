import { kv } from '@vercel/kv';

export async function incrementWithLimit(
  key: string,
  limit: number,
  ttlSeconds: number,
) {
  try {
    const count = await kv.incr(key);
    if (count === 1) {
      await kv.expire(key, ttlSeconds);
    }
    return count <= limit;
  } catch {
    // If KV is unavailable, do not block the request.
    return true;
  }
}

export { kv };
