# How the agent team works

## Roles

| Agent | Owns | Never does |
|---|---|---|
| `tech-lead` | Breaks an issue into a plan, picks the agents, keeps PRs small, writes the PR description | Writes large amounts of code itself; merges |
| `qa-bdd-engineer` | Gherkin scenarios, Cucumber step definitions, Playwright e2e | Changes a scenario to make a failing build pass |
| `backend-engineer` | Spring Boot code, Flyway migrations, unit and integration tests | Adds endpoints without a scenario |
| `frontend-engineer` | React PWA, matching Figma, component tests | Invents colours or spacing outside the tokens |
| `curriculum-designer` | Topic taxonomy, question templates, AI prompts, answer checking | Writes questions that skip parent approval |
| `devops-engineer` | Docker, Compose, GitHub Actions, backups | Commits secrets; weakens a CI check |
| `code-reviewer` | Independent review of the diff against requirements and conventions | Reviews its own work; approves on SM's behalf |

Humans: **SM** approves the plan for anything risky, reviews and merges every PR.

## One slice, end to end

```
Jira story SCRUM-n (SM or feedback)
   │
   ▼
tech-lead ── writes plan on the Jira issue; branch feature/SCRUM-n
   │
   ▼
qa-bdd-engineer ── adds/updates .feature scenarios  ──► commit "SCRUM-n test: …" (red)
   │
   ▼
backend / frontend engineers ── TDD: failing unit test → code → refactor, per behaviour
   │
   ▼
CI (GitHub Actions) ── build, format check, unit, Cucumber, Playwright
   │
   ▼
code-reviewer ── independent review; findings fixed before PR is marked ready
   │
   ▼
Pull request ── SM reviews in IntelliJ / GitHub, requests changes or merges
   │
   ▼
CI on main ── publishes images to GHCR ──► runner on the Mac redeploys
```

## Daily loop (from Phase 5)

A scheduled cloud session runs each weekday morning:

1. Reads Jira issues in SCRUM labelled `feedback` or `ready` with status To Do, highest priority first.
2. Picks **one** and runs the slice above, ending with a draft PR.
3. Comments on the Jira issue: PR link, CI link, how to try it.

SM's routine: review the PR → merge (CI deploys to the Mac) → use the app → file feedback as Jira issues
(label `feedback`).

## Traceability

Branch `feature/SCRUM-n`, commits and PR titles starting with `SCRUM-n` let the GitHub for Jira app show
the branch, commits, PR, CI runs and deployments on the Jira issue. Rules: `.claude/skills/git-workflow`.

## Phases

| # | Phase | Output |
|---|---|---|
| 0 | Setup | Tools installed, repo access, branch protection |
| 1 | Team and conventions | This PR |
| 2 | Behaviour spec | `features/` for login, groups, weekly test, scoring, rankings, dashboards |
| 3 | Walking skeleton | Boot app + Postgres + React shell + CI + Compose, deployed to the Mac |
| 4 | Vertical slices | Auth → question bank → weekly test → scoring → rankings → dashboards → approval |
| 5 | Daily loop | Scheduled task working the backlog |
