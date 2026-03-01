## ADDED Requirements

### Requirement: Atomic status assertion
The test library SHALL provide an atomic assertion helper that tests only the response status code.

#### Scenario: Status assertion success
- **WHEN** response has expected status code
- **THEN** assertion passes without error

#### Scenario: Status assertion failure
- **WHEN** response has unexpected status code
- **THEN** assertion fails with clear error message showing expected vs actual status

### Requirement: Atomic meta assertion
The test library SHALL provide an atomic assertion helper that tests only the response meta field.

#### Scenario: Meta assertion success
- **WHEN** response has expected meta content
- **THEN** assertion passes without error

#### Scenario: Meta assertion failure
- **WHEN** response has unexpected meta content
- **THEN** assertion fails with clear error message showing expected vs actual meta

### Requirement: Atomic body assertion
The test library SHALL provide an atomic assertion helper that tests only the response body content.

#### Scenario: Body content assertion success
- **WHEN** response body contains expected content
- **THEN** assertion passes without error

#### Scenario: Body content assertion failure
- **WHEN** response body does not contain expected content
- **THEN** assertion fails with clear error message showing content mismatch

### Requirement: Atomic body length assertion
The test library SHALL provide an atomic assertion helper that tests only the response body length.

#### Scenario: Body length assertion success
- **WHEN** response body has expected length
- **THEN** assertion passes without error

#### Scenario: Body length assertion failure
- **WHEN** response body has unexpected length
- **THEN** assertion fails with clear error message showing expected vs actual length

### Requirement: Single responsibility principle
Each atomic assertion helper SHALL test exactly one response property.

#### Scenario: Single property testing
- **WHEN** atomic assertion helper is called
- **THEN** it tests only one property (status OR meta OR body content OR body length)

#### Scenario: No multi-property assertions
- **WHEN** examining atomic assertion helpers
- **THEN** no helper tests multiple properties simultaneously

### Requirement: Clear failure messages
Each atomic assertion helper SHALL provide descriptive error messages on failure.

#### Scenario: Descriptive status failure
- **WHEN** status assertion fails
- **THEN** error message includes expected status, actual status, and test description

#### Scenario: Descriptive meta failure
- **WHEN** meta assertion fails
- **THEN** error message includes expected meta, actual meta, and test description

#### Scenario: Descriptive body failure
- **WHEN** body assertion fails
- **THEN** error message includes content comparison details and test description