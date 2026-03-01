## ADDED Requirements

This change does not introduce new requirements or modify existing requirements. It is purely a documentation consolidation task.

### Requirement: Documentation consolidation process
This change SHALL consolidate the standardized-test-structure specification into user-facing documentation without changing any functional requirements.

#### Scenario: Spec to documentation conversion
- **WHEN** the standardized-test-structure spec is no longer needed as a formal specification
- **THEN** its content is preserved in test/acceptance-tests/README.md and the spec file is deleted

## MODIFIED Requirements

None - this change does not modify any existing requirements.

## REMOVED Requirements

### Requirement: standardized-test-structure spec exists
**Reason**: The specification content is already documented in test/acceptance-tests/README.md. Maintaining a separate formal spec creates redundancy.
**Migration**: Use test/acceptance-tests/README.md as the authoritative source for test structure guidelines.