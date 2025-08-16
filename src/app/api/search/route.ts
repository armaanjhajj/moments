import { Search } from '@upstash/search';

export async function POST() {
  try {
    const client = Search.fromEnv();
    const index = client.index('movies');
    const result = await index.search({ query: 'hello world!' });
    return Response.json({ result });
  } catch (err) {
    return new Response(JSON.stringify({ error: 'Search failed' }), {
      status: 500,
    });
  }
}
