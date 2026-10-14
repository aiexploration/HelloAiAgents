---
name: bdd-gherkin
description: Use when adding or changing any user-visible behaviour - write the Gherkin scenario in features/ first, then wire it to Cucumber (API) or Playwright (UI) before implementing.
---

# BDD with Gherkin for Prepwise

Scenarios are the contract SM approves. They are written **before** code and changed only on purpose.

## File layout

```
features/
  account/parent-sign-in.feature
  account/child-sign-in.feature
  group/invite-family.feature
  weeklytest/take-weekly-test.feature
  weeklytest/approve-questions.feature
  scoring/mark-and-award-points.feature
  ranking/weekly-ranking.feature
  dashboard/parent-progress.feature
```

## Writing scenarios

- Business language only. A parent should understand every line. No URLs, JSON, CSS, SQL or class names.
- One behaviour per scenario; 3–7 steps. Use `Background` for shared setup, `Scenario Outline` for tables of cases.
- `Given` = state, `When` = one action, `Then` = observable outcome. No `When` after `Then`.
- Tags: requirement ID (`@R8`), layer (`@api` and/or `@ui`), `@wip` until it passes in CI.
- Use the shared cast: parent **Sam**, children **Aarav** (Year 6) and **Maya** (Year 4), group **Oakfield Friends**.
- Times are explicit and in UK time: "Given it is Monday 20 October 2026 at 07:00".

```gherkin
@R8 @R9 @api
Feature: Mark a weekly test and award points

  Background:
    Given Aarav has an approved week 8 test with 30 questions
    And it is Saturday 25 October 2026 at 10:00

  Scenario: Correct answers earn points
    When Aarav submits the test with 26 correct answers in 21 minutes
    Then his score is 26 out of 30
    And he earns 310 points

  Scenario: A late submission is not accepted
    Given it is Monday 27 October 2026 at 00:05
    When Aarav tries to submit the test
    Then he is told the test has closed
    And no points are awarded
```

## Wiring

- **API steps:** `backend/src/test/java/com/prepwise/bdd/`, Cucumber-JVM with `cucumber-spring`,
  `@CucumberContextConfiguration` on a `@SpringBootTest` with Testcontainers Postgres and a fixed `Clock`.
  Steps call the HTTP API (MockMvc/RestTestClient), not services directly.
- **UI steps:** `frontend/e2e/`, Playwright against `docker compose` running the app; locators by role and label.
- Step definitions stay thin: translate words to API calls and assertions. Logic goes in test helpers.
- Shared world state per scenario only; no static state between scenarios.

## Changing a scenario

If an implementation reveals the scenario is wrong, do not edit it quietly. Change it in its own
commit (`test: revise … because …`) and call it out in the PR description for SM.
