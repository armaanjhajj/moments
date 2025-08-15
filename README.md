Moments — Capture and share meaningful moments

This repository contains a scalable Next.js (App Router + TypeScript) application configured for Vercel with Tailwind, shadcn/ui, Prisma + Postgres, Auth.js (email magic link), Vercel KV & Blob, Cron jobs, API routes, middleware, SEO, analytics, testing, linting, CI, and a branded landing page.

Setup

1. Node 20 (see `.nvmrc`): `nvm use`
2. Install deps: `npm i`
3. Copy envs: `cp .env.example .env.local` and fill values
4. Prisma: set `DATABASE_URL`, then `npm run prisma:generate && npm run prisma:push`
5. Dev: `npm run dev`

Environment variables (.env.local)

- DATABASE_URL=
- AUTH_SECRET=
- EMAIL_SERVER_HOST=
- EMAIL_SERVER_PORT=
- EMAIL_SERVER_USER=
- EMAIL_SERVER_PASSWORD=
- EMAIL_FROM=no-reply@makemoments.app
- KV_REST_API_URL=
- KV_REST_API_TOKEN=
- BLOB_READ_WRITE_TOKEN=
- NEXT_PUBLIC_SITE_URL=https://makemoments.app

Deploy

- Vercel CLI: `vercel link` then `vercel --prod`
- Or connect GitHub repo and configure envs in Vercel dashboard

Cron

- Defined in `vercel.json`: daily 03:00 UTC and weekly Monday 04:00 UTC

Testing & CI

- Unit: Vitest `npm test`
- E2E: Playwright `npm run e2e`
- CI: see `.github/workflows/ci.yml`
