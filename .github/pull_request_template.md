## What

## Why
Closes #  · Requirements: R…

## How to test
```
docker compose up --build
```

## Evidence
- CI run:
- Scenarios now passing:
- Figma frame + screenshots (mobile 390px / desktop 1440px):

## Risks / notes for review

## New dependencies (name · licence · why)

## Checklist
- [ ] Scenario(s) in `features/` written before code
- [ ] Unit tests written first; red → green → refactor visible in commits
- [ ] `spring-javaformat` / lint clean; CI green
- [ ] No secrets, no real child data
- [ ] Reviewed by the `code-reviewer` agent; blockers fixed
