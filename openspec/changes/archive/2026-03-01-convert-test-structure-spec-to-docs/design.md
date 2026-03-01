## Context

The project has a formal specification at `openspec/specs/standardized-test-structure/spec.md` that defines test structure requirements. However, a user-facing guide with similar content already exists at `test/acceptance-tests/README.md`. This redundancy creates maintenance burden and potential for drift.

## Goals / Non-Goals

**Goals:**
- Consolidate test structure documentation into a single location
- Ensure the documentation is the authoritative source going forward
- Remove the obsolete spec file

**Non-Goals:**
- Rewrite or enhance the existing documentation content
- Add new test patterns or change testing approach
- Modify any test code

## Decisions

1. **Use `test/acceptance-tests/README.md` as the canonical location**
   - Rationale: This is the user-facing guide that developers already reference. It's more accessible than the internal openspec directory.

2. **Keep the existing README content as-is**
   - Rationale: The README already accurately describes the atomic assertion pattern. Only the spec file needs to be removed.

3. **Add cross-reference in `doc/TESTING.md`**
   - Rationale: `doc/TESTING.md` is the main testing documentation hub. It should link to the detailed acceptance test guide.

## Risks / Trade-offs

- **Risk**: Someone expects to find requirements in openspec/specs
  - **Mitigation**: The documentation in README.md serves as the actual reference. The spec was marked as TBD in Purpose anyway.

- **Risk**: Documentation becomes stale in the future
  - **Mitigation**: By having a single source of truth (the README), there's no risk of spec/documentation drift.