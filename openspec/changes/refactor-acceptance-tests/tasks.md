# Acceptance Test Refactoring - Implementation Tasks

## Stage A: Parallel Foundation (4 Subagents Simultaneously)

### Subagent A1: Status Assertions
- [x] 1. Create `assert-status` function in `test/acceptance-tests/lib/gemini-test-utils.scm`
- [x] 2. Create `assert-successful-status` function (validates status 20)
- [x] 3. Create `assert-error-status` function (validates status in 40-69 range)
- [x] 4. Add unit tests for new status assertion functions

### Subagent A2: Meta Field Assertions
- [x] 5. Create `assert-mime-type` function in `test/acceptance-tests/lib/gemini-test-utils.scm`
- [x] 6. Create `assert-meta-contains` function for partial meta field matching
- [x] 7. Create `assert-error-message` function for error meta validation
- [x] 8. Add unit tests for new meta assertion functions

### Subagent A3: Body Content Assertions
- [x] 9. Create `assert-body-contains` function in `test/acceptance-tests/lib/gemini-test-utils.scm`
- [x] 10. Create `assert-body-length` function for body size validation
- [x] 11. Create `assert-body-empty` function for empty body validation
- [x] 12. Create `assert-body-not-empty` function for non-empty body validation
- [x] 13. Add unit tests for new body assertion functions

### Subagent A4: Early Documentation
- [x] 14. Add code comments documenting the atomic assertion pattern for future developers
- [x] 15. Create simple example in documentation showing proper test structure
- [x] 16. Draft module documentation for atomic assertion approach

## Stage B: Integration (Single Agent)

- [x] 17. Add atomic assertion functions to export list in `test/acceptance-tests/lib/gemini-test-utils.scm`
- [x] 18. Keep existing multi-property helpers temporarily for backward compatibility
- [x] 19. Finalize module documentation to reflect new atomic assertion approach

## Stage C: Parallel Module Refactoring (4 Subagents Simultaneously)

### Subagent C1: Basic File Serving + File Not Found
- [x] 20. Update `test/acceptance-tests/acceptance-tests/basic-file-serving.scm` line 11-16: Replace `assert-status-and-body-length` with atomic assertions
- [x] 21. Update `test/acceptance-tests/acceptance-tests/basic-file-serving.scm` line 18-23: Replace `assert-status-and-body-length` with atomic assertions
- [x] 22. Update `test/acceptance-tests/acceptance-tests/basic-file-serving.scm` line 25-29: Standardize root path test structure with atomic assertions
- [x] 23. Remove anti-pattern of returning status from test handlers in basic-file-serving.scm
- [x] 24. Verify all tests in basic-file-serving.scm follow response-then-assertions pattern
- [x] 25. Update `test/acceptance-tests/acceptance-tests/file-not-found.scm` line 11-18: Replace mixed assertions with atomic pattern
- [x] 26. Update `test/acceptance-tests/acceptance-tests/file-not-found.scm` line 20-26: Replace mixed assertions with atomic pattern
- [x] 27. Update `test/acceptance-tests/acceptance-tests/file-not-found.scm` line 28-34: Replace mixed assertions with atomic pattern
- [x] 28. Update `test/acceptance-tests/acceptance-tests/file-not-found.scm` line 36-43: Replace complex assertion logic with atomic pattern
- [x] 29. Update `test/acceptance-tests/acceptance-tests/file-not-found.scm` line 45-50: Replace complex assertion logic with atomic pattern
- [x] 30. Remove anti-pattern of returning values from test handlers in file-not-found.scm
- [x] 31. Verify all tests in file-not-found.scm follow response-then-assertions pattern

### Subagent C2: MIME Types + Malformed Requests
- [x] 32. Update `test/acceptance-tests/acceptance-tests/mime-types.scm` line 25-30: Replace combined status/meta assertion with atomic assertions
- [x] 33. Refactor declarative `test-mime-types` function in `test/acceptance-tests/lib/gemini-test-utils.scm` line 103-117 to use atomic assertions
- [x] 34. Update MIME type test specs usage to follow response-then-assertions pattern
- [x] 35. Remove embedded test-equal calls from test-mime-types helper function
- [x] 36. Verify all tests in mime-types.scm follow standardized structure
- [x] 37. Refactor declarative `test-malformed-requests` function in `test/acceptance-tests/lib/gemini-test-utils.scm` line 120-138 to use atomic assertions
- [x] 38. Update malformed request test specs usage to follow response-then-assertions pattern
- [x] 39. Remove embedded test-equal calls from test-malformed-requests helper function
- [x] 40. Verify malformed-requests.scm follows standardized structure after helper refactoring

### Subagent C3: Directory Index
- [x] 41. Update `test/acceptance-tests/acceptance-tests/directory-index.scm` line 11-20: Replace mixed assertions with atomic pattern
- [x] 42. Update `test/acceptance-tests/acceptance-tests/directory-index.scm` line 22-31: Replace mixed assertions with atomic pattern
- [x] 43. Update `test/acceptance-tests/acceptance-tests/directory-index.scm` line 33-40: Replace mixed assertions with atomic pattern
- [x] 44. Update `test/acceptance-tests/acceptance-tests/directory-index.scm` line 42-48: Replace mixed assertions with atomic pattern
- [x] 45. Remove anti-pattern of returning status from test handlers in directory-index.scm
- [x] 46. Verify all tests in directory-index.scm follow response-then-assertions pattern

### Subagent C4: Continuous Quality Assurance
- [x] 47. Run acceptance tests continuously after each module refactoring completion
- [x] 48. Verify SRFI-64 test group naming consistency across modules
- [x] 49. Verify single response per scenario pattern across modules
- [x] 50. Verify explicit test-equal calls across all modules

## Stage D: Final Validation

- [x] 51. Verify no test performs assertions on response-building function results

## Stage E: Parallel Cleanup (2 Subagents Simultaneously)

### Subagent E1: Remove Multi-Property Helpers
- [x] 52. Remove `assert-status-and-mime` function from `test/acceptance-tests/lib/gemini-test-utils.scm` line 141-148
- [x] 53. Remove `assert-status-mime-and-body` function from `test/acceptance-tests/lib/gemini-test-utils.scm` line 151-155
- [x] 54. Remove `assert-status-and-body-length` function from `test/acceptance-tests/lib/gemini-test-utils.scm` line 158-164
- [x] 55. Update module exports to remove deprecated multi-property helpers
- [x] 56. Remove `test-mime-types` declarative helper (replace with explicit test structure)
- [x] 57. Remove `test-malformed-requests` declarative helper (replace with explicit test structure)

### Subagent E2: Documentation and Verification
- [x] 58. Run complete acceptance test suite to verify all functionality preserved
- [x] 59. Verify no multi-property assertion helpers remain in codebase
- [x] 60. Verify all test modules follow consistent atomic assertion patterns
- [x] 61. Update test utility module documentation to reflect atomic assertion approach

## Stage F: Final Integration Testing

- [x] 62. Run acceptance tests multiple times to ensure consistency
- [x] 63. Verify test error messages are clear and actionable with atomic assertions
- [x] 64. Check that test failures are more specific and easier to diagnose
- [x] 65. Review all test modules for consistent naming and organization
- [x] 66. Validate that response-then-assertions pattern is followed universally

## Dependencies

**Stage A**: All subagents run in parallel, no dependencies between them
**Stage B**: Requires completion of Stage A tasks 1-16
**Stage C**: Requires completion of Stage B tasks 17-19
**Stage D**: Requires completion of Stage C tasks 20-50
**Stage E**: Requires completion of Stage D task 51
**Stage F**: Requires completion of Stage E tasks 52-61

## Success Criteria

Each task is complete when:
1. Code changes made as described
2. All acceptance tests continue to pass with no regressions
3. Implementation follows response-then-assertions pattern
4. No test scenarios lost during refactoring
5. Atomic assertions provide clearer failure messages than replaced multi-property helpers