// @vitest-environment node
import { readFileSync, readdirSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { describe, expect, it } from 'vitest';
import { readToken } from '../test/read-token';

const srcDir = new URL('../', import.meta.url);
const tokensCss = readFileSync(new URL('./tokens.css', import.meta.url), 'utf8');

const HEX_COLOUR = /#[0-9a-f]{3}(?:[0-9a-f]{3})?\b/i;

// Values documented on the Figma "Design system" page (file dN7B8ZKjYGrKkLAbqBfOfz).
const figmaColours: [string, string][] = [
  ['--color-primary', '#5B4BDB'],
  ['--color-primary-soft', '#EEEBFF'],
  ['--color-maths', '#0E9F8E'],
  ['--color-maths-soft', '#DFF5F1'],
  ['--color-maths-text', '#0A6B60'],
  ['--color-english', '#E5643D'],
  ['--color-english-soft', '#FDECE6'],
  ['--color-english-text', '#B44C1D'],
  ['--color-gold', '#F2B705'],
  ['--color-gold-soft', '#FFF5D1'],
  ['--color-warning-text', '#946500'],
  ['--color-success', '#2E9E5B'],
  ['--color-danger', '#D64545'],
  ['--color-review-correct', '#10B981'],
  ['--color-review-incorrect', '#EF4444'],
  ['--color-ink', '#1C1B2E'],
  ['--color-ink-2', '#56556B'],
  ['--color-muted', '#4E4C62'],
  ['--color-line', '#E7E5F0'],
  ['--color-background', '#F6F5FB'],
  ['--color-surface', '#FFFFFF'],
  ['--color-on-primary', '#FFFFFF'],
];

const figmaScale: [string, string][] = [
  ['--font-family', "'Inter', system-ui, sans-serif"],
  ['--font-size-display', '32px'],
  ['--font-size-h1', '26px'],
  ['--font-size-h2', '20px'],
  ['--font-size-h3', '16px'],
  ['--font-size-body', '15px'],
  ['--font-size-small', '13px'],
  ['--font-size-caption', '12px'],
  ['--font-weight-regular', '400'],
  ['--font-weight-medium', '500'],
  ['--font-weight-semibold', '600'],
  ['--font-weight-bold', '700'],
  ['--space-half', '4px'],
  ['--space-1', '8px'],
  ['--space-1-5', '12px'],
  ['--space-2', '16px'],
  ['--space-3', '24px'],
  ['--space-4', '32px'],
  ['--space-6', '48px'],
  ['--space-8', '64px'],
  ['--radius-md', '16px'],
  ['--radius-lg', '20px'],
  ['--radius-pill', '999px'],
  ['--touch-target-min', '44px'],
  ['--answer-tile-min', '64px'],
  ['--border-default', '1.5px'],
  ['--border-strong', '2px'],
];

function componentSources(): string[] {
  return readdirSync(srcDir, { recursive: true, encoding: 'utf8' })
    .filter((file) => /\.(css|tsx)$/.test(file) && !file.endsWith('tokens.css'))
    .map((file) => fileURLToPath(new URL(file, srcDir)));
}

describe('design tokens', () => {
  it.each(figmaColours)('defines %s as the Figma colour %s', (name, value) => {
    expect(readToken(tokensCss, name)?.toUpperCase()).toBe(value);
  });

  it.each(figmaScale)('defines %s as %s', (name, value) => {
    expect(readToken(tokensCss, name)).toBe(value);
  });

  it('keeps literal hex colours out of components and stylesheets', () => {
    const offenders = componentSources().filter((file) => HEX_COLOUR.test(readFileSync(file, 'utf8')));

    expect(offenders).toEqual([]);
  });
});
