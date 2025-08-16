import type { Metadata } from 'next';
import { EB_Garamond, Geist_Mono } from 'next/font/google';
import { Toaster } from '@/components/ui/sonner';
import { Analytics } from '@vercel/analytics/react';
import './globals.css';

const ebGaramond = EB_Garamond({
  variable: '--font-eb-garamond',
  subsets: ['latin'],
});

const geistMono = Geist_Mono({
  variable: '--font-geist-mono',
  subsets: ['latin'],
});

export const metadata: Metadata = {
  title: {
    default: 'Moments — Capture and share meaningful moments',
    template: '%s — Moments',
  },
  description:
    'Moments helps you save, organize, and share the moments that matter.',
  metadataBase: new URL(
    process.env.NEXT_PUBLIC_SITE_URL || 'https://makemoments.app',
  ),
  openGraph: {
    title: 'Moments',
    description:
      'Moments helps you save, organize, and share the moments that matter.',
    url: '/',
    siteName: 'Moments',
    images: [{ url: '/og.png', width: 1200, height: 630 }],
    locale: 'en_US',
    type: 'website',
  },
  twitter: {
    card: 'summary_large_image',
    title: 'Moments',
    description:
      'Moments helps you save, organize, and share the moments that matter.',
    images: ['/og.png'],
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body
        className={`${ebGaramond.variable} ${geistMono.variable} antialiased`}
      >
        {children}
        <Toaster />
        <Analytics />
      </body>
    </html>
  );
}
