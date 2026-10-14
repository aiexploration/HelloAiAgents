---
name: spring-boot-conventions
description: Use when writing or reviewing any Java code in backend/ - formatting, Checkstyle, test style and structure rules taken from spring-projects/spring-boot, adapted for an application.
---

# Spring Boot house style for Prepwise

Derived from `spring-projects/spring-boot` (`config/checkstyle/checkstyle.xml` at commit `6cb91f9`)
and the `spring-javaformat` tooling the Spring team uses. Where spring-boot rules exist for library
concerns (`@since` tags, licence headers) we drop them because Prepwise is an application.

## Tooling (enforced in the build)

- `io.spring.javaformat:spring-javaformat-maven-plugin` — `validate` runs in `./mvnw verify`;
  fix with `./mvnw spring-javaformat:apply`. **Tabs for indentation**, Spring formatter style.
  IntelliJ: install the "Spring Javaformat" plugin so the IDE formats identically.
- Checkstyle with `io.spring.javaformat.checkstyle.SpringChecks` plus the rules below. A violation fails the build.

## Rules the build checks

| Rule | Do | Don't |
|---|---|---|
| Assertions | `import static org.assertj.core.api.Assertions.assertThat;` | `org.junit.jupiter.api.Assertions`, `org.junit.Assert`, non-static AssertJ import |
| Expected exceptions | `assertThatIllegalArgumentException().isThrownBy(...)`, `assertThatExceptionOfType(X.class).isThrownBy(...)` | `assertThatThrownBy(...)`; `assertThatExceptionOfType(IllegalArgumentException.class)` |
| Mockito | BDD style: `given(...)`, `then(...).should()` from `BDDMockito` | `when(...)`, `verify(...)`, `@InjectMocks` |
| Empty collections | `Collections.emptyList()` / `emptyMap()` / `emptySet()` | `List.of()`, `Map.of()`, `Set.of()` with no args |
| Type checks | `obj instanceof Type`, `type.isInstance(obj)` | `Type.class.isInstance(obj)`, `isAssignableFrom(x.getClass())` |
| Logging | `LogFactory.getLog(...)` (commons-logging, as Spring does) | `org.slf4j.LoggerFactory` |
| Lifecycle | constructor or `InitializingBean` / `@EventListener` | `@PostConstruct` |
| Banned imports | — | `com.google.common.*`, `org.apache.commons.*` (except logging), `sun.*`, `org.jetbrains.annotations.*` |
| Initialisation | rely on defaults | `int count = 0;` on fields (ExplicitInitialization) |
| JUnit | JUnit Jupiter, test methods package-private, no `public` | JUnit 4 rules or runners |

## Rules reviewers check

- **`this.`** for every field access (Spring style), e.g. `this.repository.save(test)`.
- **`final`** on fields that never change; not on parameters or locals.
- **Javadoc** on public types: one sentence on what it is, `@author` tag not required.
- Package by feature; classes package-private unless another package needs them.
- Constructor injection only; one constructor means no `@Autowired`.
- Records for DTOs and value objects; no Lombok.
- Nullability: JSpecify `@NullMarked` per package (`package-info.java`); use `@Nullable` where null is allowed.
- Test class `XxxTests` (plural, as spring-boot does); method names describe behaviour in camelCase,
  e.g. `submitAfterDeadlineIsRejected()`.
- Prefer real collaborators and Testcontainers over mocks. Mock only at system boundaries
  (clock, Anthropic API, email).
- Inject `java.time.Clock`; never call `Instant.now()` / `LocalDate.now()` directly in domain code.

## Example

```java
/**
 * Marks a submitted weekly test and records the points earned.
 */
class TestMarker {

	private final AnswerKeyRepository answerKeys;

	private final Clock clock;

	TestMarker(AnswerKeyRepository answerKeys, Clock clock) {
		this.answerKeys = answerKeys;
		this.clock = clock;
	}

	Result mark(Submission submission) {
		Assert.notNull(submission, "'submission' must not be null");
		AnswerKey key = this.answerKeys.forTest(submission.testId());
		return Result.of(submission, key, this.clock.instant());
	}

}
```

```java
class TestMarkerTests {

	private final AnswerKeyRepository answerKeys = mock(AnswerKeyRepository.class);

	private final TestMarker marker = new TestMarker(this.answerKeys, Clock.fixed(MONDAY_9AM, UTC));

	@Test
	void markCountsCorrectAnswers() {
		given(this.answerKeys.forTest(TEST_ID)).willReturn(KEY_ALL_B);
		Result result = this.marker.mark(submission("B", "B", "C"));
		assertThat(result.correct()).isEqualTo(2);
	}

	@Test
	void markWhenSubmissionIsNullThrowsException() {
		assertThatIllegalArgumentException().isThrownBy(() -> this.marker.mark(null))
			.withMessage("'submission' must not be null");
	}

}
```
