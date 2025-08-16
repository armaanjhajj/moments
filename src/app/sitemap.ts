import type { MetadataRoute } from 'next';

export default function sitemap(): MetadataRoute.Sitemap {
  const site = process.env.NEXT_PUBLIC_SITE_URL || 'https://makemoments.app';
  const routes = [
    '',
    '/about',
    '/waitlist',
    '/legal/privacy',
    '/legal/terms',
  ].map((path) => ({
    url: `${site}${path}`,
    lastModified: new Date(),
  }));
  return routes;
}
