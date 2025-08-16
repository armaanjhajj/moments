import { Redis } from '@upstash/redis';

let redis: Redis | null = null;
try {
  redis = new Redis({
    url: process.env.UPSTASH_REDIS_REST_URL!,
    token: process.env.UPSTASH_REDIS_REST_TOKEN!,
  });
} catch {
  redis = null;
}

export async function incrementWithLimit(
  key: string,
  limit: number,
  ttlSeconds: number,
) {
  try {
    if (!redis) return true;
    const count = await redis.incr(key);
    const ttl = await redis.ttl(key);
    if (ttl < 0) await redis.expire(key, ttlSeconds);
    return count <= limit;
  } catch {
    return true;
  }
}

export { redis };
