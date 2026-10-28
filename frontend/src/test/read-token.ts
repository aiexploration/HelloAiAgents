/** Returns the value of a CSS custom property declared in the given stylesheet text. */
export function readToken(css: string, name: string): string | undefined {
  const declaration = new RegExp(`${name}\\s*:\\s*([^;]+);`);
  return declaration.exec(css)?.[1]?.trim();
}
