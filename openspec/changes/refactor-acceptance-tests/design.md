## Context

The acceptance test suite in `test/acceptance-tests/` uses Scheme and SRFI-64 to test the Gemini server via actual TLS connections. While it has good architectural foundations (clean data modeling with records, organized test suites), the implementation has grown complex with mixed concerns and inconsistent patterns.

Current problematic patterns include:
- Assertion helpers like `assert-status-and-mime` that test multiple properties simultaneously
- Inconsistent test structure: some tests return values for outer `test-equal`, others do assertions inside handlers
- Mixed imperative/declarative patterns that obscure test intent
- Hidden error conditions and scattered configuration

The existing `<gemini-response>` record type and `with-gemini-request` abstraction provide good foundations to build upon.

## Goals / Non-Goals

**Goals:**
- Establish atomic assertion helpers that test single properties (status, meta, body, etc.)
- Standardize all acceptance test modules to follow: get response → atomic assertions pattern
- Maintain existing test coverage while improving readability and maintainability
- Keep the beneficial abstractions (response records, connection management) while simplifying their interfaces
- Make test failures easier to diagnose through focused, single-purpose assertions

**Non-Goals:**
- Changing the overall test runner architecture or SRFI-64 usage
- Modifying the core server behavior being tested
- Addressing broader server coding standards (explicitly out of scope)
- Rewriting the TLS connection logic (focus on test structure, not networking)

## Decisions

**1. Atomic Assertion Pattern**
- **Decision**: Replace multi-property helpers with single-property atomic assertions
- **Rationale**: `assert-status-and-mime` testing both status and MIME type makes failures ambiguous. Atomic helpers like `assert-status` and `assert-mime-type` make failures immediately clear.
- **Alternative Considered**: Keep combined helpers but add better error messages - rejected because it doesn't address the fundamental mixing of concerns

**2. Standardized Test Structure**
- **Decision**: All tests follow: `(with-gemini-request path (lambda (response) (assert-status response 20) (assert-mime-type response "text/gemini")))`
- **Rationale**: Consistent structure where response is obtained once, then subjected to multiple focused assertions. Eliminates the confusing pattern of tests returning values for outer `test-equal`.
- **Alternative Considered**: Keep mixed patterns - rejected because inconsistency makes the test suite harder to understand and maintain

**3. Preserve Connection Abstractions**
- **Decision**: Keep `with-gemini-request` and `<gemini-response>` record, but simplify the implementation
- **Rationale**: These abstractions work well and provide good separation between networking and testing concerns. The issue is implementation complexity, not the abstractions themselves.
- **Alternative Considered**: Replace with simpler HTTP-style testing - rejected because Gemini protocol specifics require the current approach

**4. Eliminate Side-Effect Assertions**
- **Decision**: Remove assertion helpers that perform `test-equal` calls internally
- **Rationale**: Helpers should be pure functions that return boolean results, letting the test structure be explicit about what's being asserted.
- **Alternative Considered**: Keep side effects but standardize them - rejected because implicit test execution makes debugging harder

## Risks / Trade-offs

**[Temporary Test Complexity]** → During refactoring, some tests may temporarily have more verbose assertion blocks
**[Breaking Changes to Helpers]** → Existing test code will need updates → Provides opportunity to review and improve each test
**[Learning Curve for New Patterns]** → Developers need to learn new atomic assertion style → Patterns will be more consistent and predictable once established
**[Potential for Missing Edge Cases]** → Refactoring might accidentally remove important test coverage → Careful review of each test during conversion to ensure coverage is maintained

## Migration Plan

**Phase 1: Create Atomic Assertion Library**
- Implement new atomic helpers (`assert-status`, `assert-mime-type`, `assert-body-contains`, etc.)
- Keep existing helpers temporarily for backward compatibility

**Phase 2: Refactor Test Modules**
- Convert one test module at a time to new standardized structure
- Remove usage of old multi-property helpers
- Verify test coverage remains equivalent

**Phase 3: Clean Up**
- Remove deprecated multi-property assertion helpers
- Validate all test modules follow consistent patterns
- Update any documentation or examples

**Rollback Strategy**: Each phase can be rolled back independently since old helpers remain until final cleanup phase.

## Open Questions

- Should we introduce a test utility to verify response structure before assertions, or rely on existing record accessors?
- Are there any edge cases in the current complex error handling that need to be preserved in the simplified version?
