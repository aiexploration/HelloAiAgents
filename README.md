# HelloAiAgents · Prepwise

An 11+ (GL, CEM, ISEB) Maths and English practice app for Year 4–7, built by a team of AI agents
and reviewed by a human.

- **For kids:** a weekly 30-question test, points, a kind group leaderboard, and a review of mistakes.
- **For parents:** progress and weak topics, invite-only groups, and approval of every AI-drafted question.

| | |
|---|---|
| Requirements | [docs/product/requirements.md](docs/product/requirements.md) |
| Stack | [docs/adr/0001-technology-stack.md](docs/adr/0001-technology-stack.md) — Java 25, Spring Boot 4.1, PostgreSQL, React PWA, Docker |
| How the agents work | [docs/workflow.md](docs/workflow.md) · team in [.claude/agents](.claude/agents) · rules in [CLAUDE.md](CLAUDE.md) |
| Design | Figma file `dN7B8ZKjYGrKkLAbqBfOfz` |

## Run it (from Phase 3)

```
cp .env.example .env   # add your Anthropic API key
docker compose up --build
open http://localhost:8080
```

## Work tracking

All work lives in Jira project **SCRUM**. Branches are `feature/SCRUM-n`; commits and PR titles start with the key
(see [.claude/skills/git-workflow](.claude/skills/git-workflow/SKILL.md)). Run `git config core.hooksPath .githooks` once per clone.

## Feedback

Create a Jira issue in SCRUM with the label `feedback`. The daily agent loop picks those up.
