import react from '@vitejs/plugin-react';
import { VitePWA } from 'vite-plugin-pwa';
import { defineConfig } from 'vitest/config';
import { manifest } from './src/pwa/manifest.ts';

export default defineConfig({
  plugins: [react(), VitePWA({ registerType: 'autoUpdate', manifest })],
  test: {
    environment: 'jsdom',
    setupFiles: ['./src/test/setup.ts'],
  },
});
