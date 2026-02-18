# Acceptance Test Refactoring - Task Breakdown

## Phase 1: Create Atomic Assertion Library

### 1.1 Implement Atomic Status Assertions
- [ ] 1. Create `assert-status` function in `test/acceptance-tests/lib/gemini-test-utils.scm`
- [ ] 2. Create `assert-successful-status` function (validates status 20)
- [ ] 3. Create `assert-error-status` function (validates status in 40-69 range)
- [ ] 4. Add unit tests for new status assertion functions

### 1.2 Implement Atomic Meta Field Assertions
- [ ] 5. Create `assert-mime-type` function in `test/acceptance-tests/lib/gemini-test-utils.scm`
- [ ] 6. Create `assert-meta-contains` function for partial meta field matching
- [ ] 7. Create `assert-error-message` function for error meta validation
- [ ] 8. Add unit tests for new meta assertion functions

### 1.3 Implement Atomic Body Content Assertions
- [ ] 9. Create `assert-body-contains` function in `test/acceptance-tests/lib/gemini-test-utils.scm`
- [ ] 10. Create `assert-body-length` function for body size validation
- [ ] 11. Create `assert-body-empty` function for empty body validation
- [ ] 12. Create `assert-body-not-empty` function for non-empty body validation
- [ ] 13. Add unit tests for new body assertion functions

### 1.4 Update Module Exports
- [ ] 14. Add atomic assertion functions to export list in `test/acceptance-tests/lib/gemini-test-utils.scm`
- [ ] 15. Keep existing multi-property helpers temporarily for backward compatibility
- [ ] 16. Update module documentation to reflect new atomic assertion approach

## Phase 2: Refactor Test Modules to Standardized Structure

### 2.1 Refactor Basic File Serving Tests
- [ ] 17. Update `test/acceptance-tests/acceptance-tests/basic-file-serving.scm` line 11-16: Replace `assert-status-and-body-length` with atomic assertions
- [ ] 18. Update `test/acceptance-tests/acceptance-tests/basic-file-serving.scm` line 18-23: Replace `assert-status-and-body-length` with atomic assertions
- [ ] 19. Update `test/acceptance-tests/acceptance-tests/basic-file-serving.scm` line 25-29: Standardize root path test structure with atomic assertions
- [ ] 20. Remove anti-pattern of returning status from test handlers in basic-file-serving.scm
- [ ] 21. Verify all tests in basic-file-serving.scm follow response-then-assertions pattern

### 2.2 Refactor MIME Types Tests
- [ ] 22. Update `test/acceptance-tests/acceptance-tests/mime-types.scm` line 25-30: Replace combined status/meta assertion with atomic assertions
- [ ] 23. Refactor declarative `test-mime-types` function in `test/acceptance-tests/lib/gemini-test-utils.scm` line 103-117 to use atomic assertions
- [ ] 24. Update MIME type test specs usage to follow response-then-assertions pattern
- [ ] 25. Remove embedded test-equal calls from test-mime-types helper function
- [ ] 26. Verify all tests in mime-types.scm follow standardized structure

### 2.3 Refactor Directory Index Tests
- [ ] 27. Update `test/acceptance-tests/acceptance-tests/directory-index.scm` line 11-20: Replace mixed assertions with atomic pattern
- [ ] 28. Update `test/acceptance-tests/acceptance-tests/directory-index.scm` line 22-31: Replace mixed assertions with atomic pattern  
- [ ] 29. Update `test/acceptance-tests/acceptance-tests/directory-index.scm` line 33-40: Replace mixed assertions with atomic pattern
- [ ] 30. Update `test/acceptance-tests/acceptance-tests/directory-index.scm` line 42-48: Replace mixed assertions with atomic pattern
- [ ] 31. Remove anti-pattern of returning status from test handlers in directory-index.scm
- [ ] 32. Verify all tests in directory-index.scm follow response-then-assertions pattern

### 2.4 Refactor File Not Found Tests
- [ ] 33. Update `test/acceptance-tests/acceptance-tests/file-not-found.scm` line 11-18: Replace mixed assertions with atomic pattern
- [ ] 34. Update `test/acceptance-tests/acceptance-tests/file-not-found.scm` line 20-26: Replace mixed assertions with atomic pattern
- [ ] 35. Update `test/acceptance-tests/acceptance-tests/file-not-found.scm` line 28-34: Replace mixed assertions with atomic pattern
- [ ] 36. Update `test/acceptance-tests/acceptance-tests/file-not-found.scm` line 36-43: Replace complex assertion logic with atomic pattern
- [ ] 37. Update `test/acceptance-tests/acceptance-tests/file-not-found.scm` line 45-50: Replace complex assertion logic with atomic pattern
- [ ] 38. Remove anti-pattern of returning values from test handlers in file-not-found.scm
- [ ] 39. Verify all tests in file-not-found.scm follow response-then-assertions pattern

### 2.5 Refactor Malformed Requests Tests
- [ ] 40. Refactor declarative `test-malformed-requests` function in `test/acceptance-tests/lib/gemini-test-utils.scm` line 120-138 to use atomic assertions
- [ ] 41. Update malformed request test specs usage to follow response-then-assertions pattern
- [ ] 42. Remove embedded test-equal calls from test-malformed-requests helper function
- [ ] 43. Verify malformed-requests.scm follows standardized structure after helper refactoring

### 2.6 Validate Standardized Structure Implementation
- [ ] 44. Run all acceptance tests to ensure no regressions in test coverage
- [ ] 45. Verify each test module uses consistent SRFI-64 test group naming
- [ ] 46. Verify each test obtains response exactly once per scenario
- [ ] 47. Verify all test-equal calls are explicit in test structure (not hidden in helpers)
- [ ] 48. Verify no test performs assertions on response-building function results

## Phase 3: Clean Up and Remove Deprecated Helpers

### 3.1 Remove Multi-Property Assertion Helpers
- [ ] 49. Remove `assert-status-and-mime` function from `test/acceptance-tests/lib/gemini-test-utils.scm` line 141-148
- [ ] 50. Remove `assert-status-mime-and-body` function from `test/acceptance-tests/lib/gemini-test-utils.scm` line 151-155
- [ ] 51. Remove `assert-status-and-body-length` function from `test/acceptance-tests/lib/gemini-test-utils.scm` line 158-164
- [ ] 52. Update module exports to remove deprecated multi-property helpers
- [ ] 53. Remove `test-mime-types` declarative helper (replace with explicit test structure)
- [ ] 54. Remove `test-malformed-requests` declarative helper (replace with explicit test structure)

### 3.2 Final Validation and Documentation
- [ ] 55. Run complete acceptance test suite to verify all functionality preserved
- [ ] 56. Verify no multi-property assertion helpers remain in codebase
- [ ] 57. Verify all test modules follow consistent atomic assertion patterns
- [ ] 58. Update test utility module documentation to reflect atomic assertion approach
- [ ] 59. Add code comments documenting the atomic assertion pattern for future developers
- [ ] 60. Create simple example in documentation showing proper test structure

### 3.3 Integration Testing and Final Cleanup
- [ ] 61. Run acceptance tests multiple times to ensure consistency
- [ ] 62. Verify test error messages are clear and actionable with atomic assertions
- [ ] 63. Check that test failures are more specific and easier to diagnose
- [ ] 64. Review all test modules for consistent naming and organization
- [ ] 65. Validate that response-then-assertions pattern is followed universally

## Dependencies and Ordering

**Phase 1 Dependencies:**
- Tasks 1-4 must complete before Phase 2 begins
- Tasks 5-8 must complete before Phase 2 begins  
- Tasks 9-13 must complete before Phase 2 begins
- Tasks 14-16 can be done in parallel with other Phase 1 tasks

**Phase 2 Dependencies:**
- All Phase 1 tasks must complete before Phase 2 begins
- Tasks 17-21 (basic file serving) can be done in parallel with other 2.x task groups
- Tasks 22-26 (MIME types) can be done in parallel with other 2.x task groups
- Tasks 27-32 (directory index) can be done in parallel with other 2.x task groups  
- Tasks 33-39 (file not found) can be done in parallel with other 2.x task groups
- Tasks 40-43 (malformed requests) can be done in parallel with other 2.x task groups
- Tasks 44-48 (validation) must complete after all 2.1-2.5 task groups finish

**Phase 3 Dependencies:**
- All Phase 2 tasks must complete before Phase 3 begins
- Tasks 49-54 (cleanup) must complete before final validation tasks
- Tasks 55-60 (documentation) can be done in parallel
- Tasks 61-65 (integration testing) must be done last

## Success Criteria

Each task is complete when:
1. **Code changes made**: Specific functions/files modified as described
2. **Tests pass**: All acceptance tests continue to pass with no regressions
3. **Pattern verified**: Implementation follows response-then-assertions pattern
4. **Coverage maintained**: No test scenarios lost during refactoring
5. **Code quality**: Atomic assertions provide clearer failure messages than replaced multi-property helpers