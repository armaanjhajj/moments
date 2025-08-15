import { ImageResponse } from '@vercel/og';

export const runtime = 'edge';

export async function GET() {
  return new ImageResponse(
    (
      <div
        style={{
          display: 'flex',
          height: '100%',
          width: '100%',
          alignItems: 'center',
          justifyContent: 'center',
          backgroundColor: '#ffffff',
          color: '#0a0a0a',
          fontSize: 64,
          letterSpacing: -1,
        }}
      >
        Moments
      </div>
    ),
    { width: 1200, height: 630 },
  );
}
