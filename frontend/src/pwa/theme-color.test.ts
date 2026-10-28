// @vitest-environment node
import { readFileSync } from 'node:fs';
import { describe, expect, it } from 'vitest';
import { readToken } from '../test/read-token';

const tokensCss = readFileSync(new URL('../styles/tokens.css', import.meta.url), 'utf8');
const indexHtml = readFileSync(new URL('../../index.html', import.meta.url), 'utf8');

describe('index.html theme colour', () => {
  it('matches the primary token', () => {
    const themeColor = /<meta\s+name="theme-color"\s+content="([^"]+)"/.exec(indexHtml)?.[1];

    expect(themeColor).toBe(readToken(tokensCss, '--color-primary'));
  });
});
