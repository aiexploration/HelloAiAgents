# Prepwise frontend

React 19 + TypeScript + Vite, installable PWA (vite-plugin-pwa). Mobile-first; one breakpoint at 1024px.

| Task | Command |
|---|---|
| Install | `npm ci` |
| Dev server | `npm run dev` |
| Unit tests (Vitest + Testing Library) | `npm test` |
| Type check | `npm run typecheck` |
| Production build | `npm run build` then `npm run preview` |

Design tokens live in `src/styles/tokens.css`. Values come from the Figma "Design system" page
(file `dN7B8ZKjYGrKkLAbqBfOfz`). It is the only file allowed to contain literal colours;
`src/styles/tokens.test.ts` enforces this. The manifest colours in `src/pwa/manifest.ts` must match the tokens.
