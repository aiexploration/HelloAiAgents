import type { ManifestOptions } from 'vite-plugin-pwa';

// Colours must match --color-primary and --color-background in src/styles/tokens.css
// (guarded by manifest.test.ts); the manifest is JSON, so it cannot reference CSS variables.
export const manifest: Partial<ManifestOptions> = {
  name: 'Prepwise',
  short_name: 'Prepwise',
  lang: 'en-GB',
  description: 'Weekly Maths and English practice for the 11+.',
  start_url: '/',
  display: 'standalone',
  theme_color: '#5B4BDB',
  background_color: '#F6F5FB',
  icons: [
    { src: '/icon.svg', sizes: 'any', type: 'image/svg+xml', purpose: 'any' },
    { src: '/icon-192.png', sizes: '192x192', type: 'image/png', purpose: 'any' },
    { src: '/icon-512.png', sizes: '512x512', type: 'image/png', purpose: 'any' },
    // The star sits inside the maskable safe zone, so the same artwork serves both purposes.
    { src: '/icon-512.png', sizes: '512x512', type: 'image/png', purpose: 'maskable' },
  ],
};
