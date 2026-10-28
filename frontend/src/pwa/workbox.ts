import type { VitePWAOptions } from 'vite-plugin-pwa';

// Server routes must reach the backend; the service worker must not answer them with index.html.
export const workbox: VitePWAOptions['workbox'] = {
  navigateFallbackDenylist: [/^\/api\//, /^\/actuator/, /^\/login/, /^\/logout/],
};
