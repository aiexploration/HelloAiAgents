---
name: clean-code-solid
description: Use when writing, refactoring or reviewing any production or test code in backend/ or frontend/ - SOLID design principles and clean-code rules, applied pragmatically to a small feature-packaged app.
---

# Clean code and SOLID for Prepwise

Developers apply this while writing (the refactor step of red → green → refactor). The `code-reviewer`
checks every diff against it. It complements `spring-boot-conventions` (Java style) and
`frontend-engineer` (UI rules). Where they are more specific, they win.

Balance: Prepwise is small. Apply these principles to **code that exists**, not to features that might
come later. An interface with one implementation, a factory for one type, or a layer "for later" is a
finding, not good design (YAGNI).

## SOLID — what it means here

| Principle | Do | Smell (review finding) |
|---|---|---|
| **S**ingle responsibility | One reason to change per class/component. Controller = HTTP mapping, service = use case, domain object = rules, repository = persistence. | Controller with business rules; a `*Service` mixing marking, points and ranking; React component that fetches, transforms and renders. |
| **O**pen/closed | Extend by adding a type when variation is *real and present* (e.g. `QuestionChecker` per answer type, sealed interface + `switch`). | Growing `if/else` on a type code repeated in several places. Also: abstraction added for one case only. |
| **L**iskov substitution | Subtypes honour the contract: same preconditions or weaker, same guarantees or stronger, no surprise exceptions. | Overrides that throw `UnsupportedOperationException`; `instanceof` checks on a supertype to special-case a child. |
| **I**nterface segregation | Small, role-focused interfaces and props; depend on what you use. | "God" repository/interface; components taking a whole object to read one field. |
| **D**ependency inversion | Domain depends on abstractions it owns at system boundaries (clock, Anthropic API, email, persistence). Constructor injection only. | `Instant.now()`, `new RestClient()` or static calls to external systems inside domain code; field injection. |

## Clean-code rules

**Naming**
- Use names from the domain: `WeeklyTest`, `Submission`, `MilestoneTier`, as in `docs/product/requirements.md`
  and `features/`. No `Manager`, `Helper`, `Util`, `Data`, `Info` suffixes.
- Methods are verbs that say what happens (`releaseWeeklyTest`). Booleans read as questions (`isFlagged`).
- Test names describe behaviour: `submitAfterDeadlineIsRejected()`.

**Functions**
- Small, one level of abstraction, ideally ≤ 20 lines. Extract a well-named method rather than writing a comment.
- ≤ 3 parameters. Beyond that, use a record or value object.
- No boolean flag parameters that switch behaviour. Write two methods.
- Command–query separation: a method either changes state or returns a value, not both (repositories' `save` excepted).

**Classes and modules**
- Package by feature (`com.prepwise.weeklytest`). Classes are package-private unless another feature needs them.
- Prefer immutable records and value objects (`Points`, `YearGroup`) over primitives with rules scattered
  around (primitive obsession).
- Tell, don't ask: put behaviour next to the data it uses (`test.submit(answers, clock)`, not
  `if (test.getDeadline().isBefore(...))` in a service).
- Composition over inheritance.

**Errors and nulls**
- Validate at the boundary (Jakarta Validation, `Assert.notNull`). Inside the domain, trust the types.
- Exceptions say what went wrong in domain terms. Never swallow one. Never use exceptions for normal control flow.
- JSpecify `@NullMarked`. Return `Optional` from lookups; never return `null` collections.

**Duplication and simplicity**
- DRY applies to *knowledge*, not to lines that look alike. Duplicate twice; extract on the third copy
  when the copies change for the same reason.
- No dead code, commented-out code, or speculative parameters. Delete it; git remembers.
- Comments explain *why*, never *what*. A `TODO` needs a Jira key.

**Tests (same standard as production code)**
- One behaviour per test, Arrange–Act–Assert, no logic (loops or branches) in tests.
- Shared test infrastructure lives in one place, e.g. `TestcontainersConfiguration` imported with
  `@Import`, not copied per class.
- Mock only at system boundaries. Over-mocking is a design smell (too many collaborators → split the class).

## Reviewer checklist

For each changed class or component, ask:
1. Can I state its single responsibility in one sentence without "and"?
2. Would a new requirement in `features/` force edits in many unrelated places? (OCP / coupling)
3. Does domain code reach a boundary (time, network, DB, AI) without an injected abstraction? (DIP)
4. Are names taken from the domain, and are functions small with ≤ 3 params and no flag arguments?
5. Is there an abstraction with a single use, or dead code? (YAGNI)
6. Do tests read as behaviour specs, with shared fixtures centralised?

Report violations as `should-fix` (or `blocker` when they will clearly spread, e.g. business rules in a
controller) with the principle named, file:line and a concrete refactoring.
