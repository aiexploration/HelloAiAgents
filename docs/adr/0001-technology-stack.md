# ADR-0001: Technology stack

Status: Accepted · Date: 2026-10-14 · Decider: SM

## Context

SM is a Java/Spring engineer who wants to review every PR in IntelliJ, run the app locally on a Mac,
and use it with his own and friends' children. The UI must be mobile-first with a desktop layout.

## Decision

| Concern | Choice | Why |
|---|---|---|
| Language / runtime | Java 25 (LTS) | Current LTS; Spring Boot 4.1 supports 17–26. |
| Framework | Spring Boot 4.1.x (Spring Framework 7) | Latest supported line (4.0 support ends Dec 2026). |
| Build | Maven wrapper | Familiar to SM; best IntelliJ support. |
| Persistence | PostgreSQL 17, Spring Data JPA, Flyway | Required; Flyway keeps schema reviewable as SQL. |
| Security | Spring Security, session cookies (HttpOnly, SameSite=Lax), BCrypt | Same-origin SPA; no tokens in browser storage. |
| Frontend | React 19 + TypeScript + Vite PWA | Mobile-first, installable; matches SM's earlier projects. |
| Styling | CSS variables generated from the Figma design tokens | One source of truth for colours, spacing, radii. |
| Unit tests | JUnit 6, AssertJ, Mockito (sparingly) | Spring Boot defaults. |
| Integration tests | Testcontainers Postgres | Real database; no H2 differences. |
| BDD | Cucumber-JVM + `cucumber-spring` (API level), Playwright (UI level) | Same `.feature` files drive both. |
| Code style | `spring-javaformat` + Checkstyle rules from spring-boot | Requested: follow spring-projects/spring-boot. |
| Packaging | Docker images on GHCR, `compose.yaml` | Runs on the Mac with one command. |
| CI | GitHub Actions | Free for public repos; the cloud agents verify through it. |
| AI | Anthropic Messages API from the backend | Question drafting; parent approval gate. |

## Consequences

- Agents in cloud sessions cannot download Maven artifacts, so **CI is the build of record**; PRs
  must link a green run.
- A single Spring Boot app serves the built frontend in production, keeping auth same-origin.
- Package structure is by feature (`com.prepwise.test`, `.ranking`, `.account`, …), not by layer.
