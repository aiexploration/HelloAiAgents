# Prepwise — project guide for agents

Prepwise is an invite-only web app (mobile-first, with a desktop layout) that helps Year 4–7 children
prepare for 11+ grammar-school entrance exams in **Maths and English**. Every week each child gets a
30-question test, earns points and appears on a group ranking. Parents see progress and
weak topics, and approve the AI-drafted questions before release.

The human owner (SM) is an experienced Java/Spring engineer. He reviews and merges every PR.
**Agents never merge, never push to `main`, and never bypass review.**

## Source of truth

| What | Where |
|---|---|
| Requirements | [docs/product/requirements.md](docs/product/requirements.md) |
| Behaviour (acceptance) | `features/**/*.feature` (Gherkin) — written before code |
| UI | Figma file `dN7B8ZKjYGrKkLAbqBfOfz` (pages: Mobile screens, Desktop screens, Design system) |
| Architecture decisions | [docs/adr/](docs/adr/) |
| How the team works | [docs/workflow.md](docs/workflow.md) |

If code and a `.feature` file disagree, the feature file wins. If a feature file and the requirements
disagree, stop and ask SM in the PR description.

## Stack (see ADR-0001)

- **Backend:** Java 25, Spring Boot 4.1.x, Spring Security, Spring Data JPA, Flyway, PostgreSQL 17. Maven wrapper.
- **Frontend:** React 19 + TypeScript + Vite, installable PWA, mobile-first.
- **Tests:** JUnit 6 + AssertJ, Testcontainers (real Postgres, no H2), Cucumber-JVM for BDD,
  Vitest + Testing Library for UI units, Playwright for end-to-end.
- **Runtime:** Docker Compose on SM's Mac. Images published to GHCR by CI.
- **AI questions:** Anthropic API, called only from the backend; drafts are never shown to a child until a parent approves them.

## Repository layout (target)

```
backend/            Spring Boot app (package root: com.prepwise)
frontend/           React PWA
features/           Gherkin acceptance specs, shared by backend and e2e
docs/               requirements, ADRs, workflow
.claude/agents/     the agent team
.claude/skills/     skills the team must follow
compose.yaml        local runtime
```

## Non-negotiables

1. **TDD.** No production code without a failing test first — follow `.claude/skills/test-driven-development`.
2. **BDD.** Every user-visible behaviour starts as a scenario in `features/` — follow `.claude/skills/bdd-gherkin`.
3. **Evidence before claims.** Never say "tests pass" without the CI run or command output — follow `.claude/skills/verification-before-completion`.
4. **Spring Boot house style.** Code is formatted and checked the way `spring-projects/spring-boot` is — follow `.claude/skills/spring-boot-conventions`.
5. **Small PRs.** One vertical slice per PR, ideally under ~400 changed lines excluding generated files.
6. **Child safety and privacy.** Children have a nickname, year group and PIN only — no email, surname, school or photo.
   Never log PINs, answers tied to a real name, or tokens. This repo is **public**: no real data, secrets or `.env` files in git.
7. **No new dependency** without a line in the PR description saying why, and its licence.

## Commands

| Task | Command |
|---|---|
| Backend build + all tests | `cd backend && ./mvnw verify` |
| Format Java | `cd backend && ./mvnw spring-javaformat:apply` |
| Frontend tests | `cd frontend && npm test` |
| E2E | `cd frontend && npx playwright test` |
| Run everything | `docker compose up --build` |

> **Cloud sessions cannot reach Maven Central.** When working from a cloud session, push the branch and
> treat the GitHub Actions run as the verification step (`gh run watch`, `gh run view --log-failed`).
> On SM's Mac, run commands locally.

## Definition of done (every PR)

- [ ] Linked to a GitHub issue or a scenario in `features/`
- [ ] New or changed scenarios pass; unit tests written first (red → green → refactor visible in commits)
- [ ] `./mvnw verify` / `npm test` green in CI — paste the run link in the PR
- [ ] UI matches the Figma frame named in the PR (screenshot attached)
- [ ] No secrets, no real child data, no TODOs without an issue number
- [ ] PR description: what, why, how to test, risks

## Git

- Branch: `<type>/<issue>-<slug>` e.g. `feat/12-weekly-test-scoring`
- Conventional commits: `feat:`, `fix:`, `test:`, `refactor:`, `docs:`, `chore:`, `ci:`
- Rebase on `main` before opening the PR. Squash-merge is done by SM.
