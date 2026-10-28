// @vitest-environment node
import { readFileSync } from 'node:fs';
import { describe, expect, it } from 'vitest';
import { readToken } from '../test/read-token';
import { manifest } from './manifest';

const tokensCss = readFileSync(new URL('../styles/tokens.css', import.meta.url), 'utf8');

describe('web app manifest', () => {
  it('names the app Prepwise', () => {
    expect(manifest.name).toBe('Prepwise');
    expect(manifest.short_name).toBe('Prepwise');
  });

  it('launches standalone from the root', () => {
    expect(manifest.start_url).toBe('/');
    expect(manifest.display).toBe('standalone');
  });

  it('uses the primary token as theme colour', () => {
    expect(manifest.theme_color).toBe(readToken(tokensCss, '--color-primary'));
  });

  it('uses the background token as background colour', () => {
    expect(manifest.background_color).toBe(readToken(tokensCss, '--color-background'));
  });

  it('provides at least one icon', () => {
    expect(manifest.icons?.length).toBeGreaterThan(0);
  });
});
