import { describe, expect, it } from 'vitest';
import { workbox } from './workbox';

function isDeniedNavigateFallback(path: string): boolean {
  return (workbox.navigateFallbackDenylist ?? []).some((pattern) => pattern.test(path));
}

describe('service worker navigate fallback', () => {
  it.each(['/api/x', '/actuator/health', '/login', '/logout'])('leaves server route %s to the network', (path) => {
    expect(isDeniedNavigateFallback(path)).toBe(true);
  });

  it('serves the app shell for /', () => {
    expect(isDeniedNavigateFallback('/')).toBe(false);
  });
});
