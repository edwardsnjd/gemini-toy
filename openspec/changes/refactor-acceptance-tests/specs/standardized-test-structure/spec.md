## ADDED Requirements

### Requirement: Response-then-assertions pattern
All acceptance test modules SHALL follow the pattern of obtaining a response first, then performing one or more atomic assertions on that response.

#### Scenario: Standard test structure
- **WHEN** writing an acceptance test
- **THEN** test obtains response via `with-gemini-request` followed by atomic assertions on the response object

#### Scenario: No nested response building
- **WHEN** examining test structure
- **THEN** no test performs assertions on the result of response-building functions

### Requirement: Consistent test module organization
Each acceptance test module SHALL organize tests using SRFI-64 test groups with consistent naming patterns.

#### Scenario: Test group structure
- **WHEN** examining test module structure
- **THEN** each module uses `test-begin` and `test-end` with descriptive group names

#### Scenario: Test naming consistency
- **WHEN** reviewing test names within modules
- **THEN** test names clearly describe the scenario being tested

### Requirement: Single response per test scenario
Each test scenario SHALL obtain the response exactly once and perform multiple atomic assertions on that single response.

#### Scenario: One response multiple assertions
- **WHEN** test scenario needs to verify multiple response properties
- **THEN** test calls `with-gemini-request` once and performs multiple atomic assertions within the handler

#### Scenario: No repeated response fetching
- **WHEN** examining test implementation
- **THEN** no test makes multiple requests to test the same response properties

### Requirement: Explicit assertion structure
All assertions SHALL be explicit `test-equal` or equivalent calls, not hidden within helper functions.

#### Scenario: Explicit test calls
- **WHEN** reading test code
- **THEN** all `test-equal` calls are visible in the test structure, not buried in helper functions

#### Scenario: No side-effect assertions
- **WHEN** examining assertion helpers
- **THEN** helpers return values for explicit testing rather than performing `test-equal` calls internally

### Requirement: Atomic assertion composition
Complex testing scenarios SHALL be achieved by composing multiple atomic assertions rather than using multi-property assertion helpers.

#### Scenario: Status and meta verification
- **WHEN** test needs to verify both status and meta fields
- **THEN** test uses separate atomic assertions for status and meta rather than combined helper

#### Scenario: Status and body verification  
- **WHEN** test needs to verify both status and body content
- **THEN** test uses separate atomic assertions for status and body rather than combined helper

### Requirement: Elimination of multi-property helpers
The test suite SHALL NOT use assertion helpers that test multiple response properties simultaneously.

#### Scenario: No combined status-meta helpers
- **WHEN** examining assertion helpers
- **THEN** no helper tests both status and meta properties in a single call

#### Scenario: No combined status-body helpers
- **WHEN** examining assertion helpers  
- **THEN** no helper tests both status and body properties in a single call