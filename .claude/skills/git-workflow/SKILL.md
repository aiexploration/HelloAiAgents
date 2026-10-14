---
name: git-workflow
description: Use before creating a branch, committing, pushing or opening a pull request. Mandatory branch, commit and PR naming tied to the Jira issue key, and the checks to run before raising a PR.
---

# Git workflow — Jira-linked branches, commits and PRs

Work is tracked in Jira project **SCRUM** (site `privaterelay-team-m6b8dopi.atlassian.net`).
Every change belongs to exactly one Jira **Story/Task** (not an Epic). Jira's GitHub app links
branches, commits, PRs, CI builds and deployments to that issue **only when the key appears in them**.

## The rules (enforced by `.githooks/` locally and `.github/workflows/pr-conventions.yml` on every PR)

| Thing | Format | Example |
|---|---|---|
| Branch | `feature/<JIRA-KEY>` — exactly, nothing after the key | `feature/SCRUM-32` |
| Commit message | `<JIRA-KEY> <type>: <summary>` | `SCRUM-32 feat: sign in parent with email and password` |
| PR title | `<JIRA-KEY> <type>: <summary>` | `SCRUM-32 feat: parent sign-in` |
| PR body | first line `Jira: https://privaterelay-team-m6b8dopi.atlassian.net/browse/<JIRA-KEY>` | |

- `<type>` is one of `feat`, `fix`, `test`, `refactor`, `docs`, `chore`, `ci`, `build`, `perf`.
- One branch = one Jira key = one PR. If the work needs a second key, it is a second branch.
- Bug fixes and chores use the same `feature/` prefix — the rule is deliberately uniform.
- Never push to `main`. Never force-push to `main`. Force-push to your own `feature/*` branch only
  with `--force-with-lease`.

## Before starting work

1. Find the Jira key (Atlassian MCP: `searchJiraIssuesUsingJql`, e.g. `project = SCRUM AND status = "To Do"`).
   No key → stop and ask SM to create the issue. Do not invent keys.
2. Move the issue to **In Progress** (`transitionJiraIssue`).
3. `git fetch origin main && git switch -c feature/SCRUM-32 origin/main`
4. Once per clone: `git config core.hooksPath .githooks` (installs the local checks).

## Mandatory checklist before raising a PR

Run these; do not open the PR until every line is true.

```bash
KEY=$(git branch --show-current | sed -n 's#^feature/\([A-Z][A-Z0-9]*-[0-9]*\)$#\1#p')
[ -n "$KEY" ] || echo "FAIL: branch must be feature/<JIRA-KEY>"
git fetch origin main && git rebase origin/main            # up to date with main
git log --format=%s origin/main..HEAD | grep -v "^$KEY " && echo "FAIL: commit without $KEY"
```

- [ ] Branch is `feature/<JIRA-KEY>` and the key exists in Jira
- [ ] Every commit subject starts with `<JIRA-KEY> `
- [ ] Rebased on `origin/main`
- [ ] Definition of done in `CLAUDE.md` is met, with evidence (CI run link)
- [ ] PR title `<JIRA-KEY> <type>: <summary>`; body starts with the Jira link

Open the PR with the REST API (GraphQL is blocked in cloud sessions):

```bash
gh api repos/aiexploration/helloaiagents/pulls -X POST \
  -f title="SCRUM-32 feat: parent sign-in" -f head="feature/SCRUM-32" -f base=main \
  -F body=@pr-body.md
```

Then comment the PR link on the Jira issue (`addOrEditJiraIssueComment`) and move it to **In Review**
if that status exists, otherwise leave it **In Progress**. SM moves it to **Done** by merging.

## If a check fails

- Wrong branch name: `git branch -m feature/SCRUM-32` then push the new name and delete the old remote branch.
- Commit missing the key: `git rebase -i origin/main` → `reword` the commit, then `git push --force-with-lease`.
- PR title wrong: edit it — the check re-runs on edit.
