import react from '@vitejs/plugin-react';
import { VitePWA } from 'vite-plugin-pwa';
import { defineConfig } from 'vitest/config';
import { manifest } from './src/pwa/manifest.ts';
import { workbox } from './src/pwa/workbox.ts';

export default defineConfig({
  plugins: [react(), VitePWA({ registerType: 'autoUpdate', manifest, workbox })],
  test: {
    environment: 'jsdom',
    setupFiles: ['./src/test/setup.ts'],
  },
});
