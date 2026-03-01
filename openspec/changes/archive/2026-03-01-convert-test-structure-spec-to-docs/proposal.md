## Why

The "standardized-test-structure" spec exists as a formal specification, but its content is already documented in `test/acceptance-tests/README.md`. Maintaining the spec as a separate file creates redundancy and the risk of drift between spec and documentation. Converting this spec to documentation and deleting it simplifies the project and ensures there's a single source of truth.

## What Changes

- Merge the formal requirements from `openspec/specs/standardized-test-structure/spec.md` into `test/acceptance-tests/README.md`
- Delete the `openspec/specs/standardized-test-structure/` directory
- Update `doc/TESTING.md` to reference the detailed test structure guide in `test/acceptance-tests/README.md`

## Capabilities

### New Capabilities
- N/A (this change converts an existing spec to documentation)

### Modified Capabilities
- N/A (no requirement changes - purely a documentation consolidation)

## Impact

- **Files modified**: `test/acceptance-tests/README.md`, `doc/TESTING.md`
- **Files deleted**: `openspec/specs/standardized-test-structure/`
- **No code changes**: This is purely a documentation cleanup