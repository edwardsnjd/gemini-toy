## Proposal: Refactor Gemini response handling for consistency

### Why
The current implementation defines a set of response constants (`response/success`, `response/temporary-failure`, …) and a thin `error-response` helper. This leads to:
- Mixed patterns: success is a raw string, errors are built via a helper.
- Duplication of status‑code handling across modules.
- Difficulty extending or modifying response formats without touching many files.

### Goal
Create a consistent way to define and use Gemini response constants while **keeping the existing `response/...` symbols**. The goal is to:
- Unify the definition of all response symbols through a single helper.
- Ensure every part of the codebase uses the same approach (e.g., always via `error-response` or a shared factory).
- Preserve the exact output format required by the Gemini specification.
- Avoid any observable behaviour change; all tests must continue to pass.

### Constraints
- No change to the public interface used by the test suite.
- Existing `response/*` symbols must remain available and retain their current names.
- The refactor must be optional – callers may continue to use the symbols directly.
- All changes must be captured as an OpenSpec change, with clear tasks for implementation.

### Scope
- Introduce a shared helper (e.g., `make-response`) in the `gemini protocol` module.
- Redefine all `response/...` constants to use that helper, ensuring they are defined consistently.
- Update internal usage to call the helper or the constants uniformly.
- Document the new approach and provide a migration path for future changes.