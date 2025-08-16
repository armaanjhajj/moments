# theimpulse.xyz (migrated into moments repo)

This repository now serves the Impulse static site, replacing the previous Moments Next.js app. Deployments continue via Vercel on this repo.

## Getting Started

### Development
```bash
npm install
npm run dev
```

### Build for Production
```bash
npm run build
```

### Preview Production Build
```bash
npm run preview
```

## Tech Stack

- React 19
- Vite
- Modern CSS with Flexbox and Grid
- Responsive Design

## Deployment

This project is configured for deployment on Vercel as a static SPA. A rewrite rule in `vercel.json` serves `index.html` for all routes.

### Migration notes

- Previous Moments assets are backed up under `public/_moments_backup/`.
- Branch: `swap-impulse` was used for the swap; a backup tag `backup-pre-swap-impulse-YYYYMMDD-HHMMSS` was created.
- Environment: No secrets required for this static app.
