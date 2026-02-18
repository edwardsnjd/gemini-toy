# Atomic Assertions Guide

## Overview

This guide documents the atomic assertion pattern used in Gemini acceptance tests. The atomic assertion pattern emphasizes single-responsibility test functions and the response-then-assertions pattern for better test maintainability and diagnostics.

## Key Principles

### Anti-patterns to avoid

- DO NOT return values from test handlers for assertions outside the handler
- DO NOT use multi-property helpers (these have been removed)
- DO NOT make multiple network requests in a single test scenario
- DO NOT test multiple unrelated scenarios in a single test function

### 1. Single-Responsibility Assertions
Each assertion function tests exactly one property of a response:
- `assert-successful-status` - Tests only the status code is 20
- `assert-mime-type` - Tests only the MIME type
- `assert-body-contains` - Tests only that body contains expected text

### 2. Response-Then-Assertions Pattern
Always follow this structure:
1. Make a single network request
2. Capture the response
3. Make multiple atomic assertions on that response

## Example: Basic File Serving Test

```scheme
;;; GOOD: Multiple atomic assertions
(test-begin "Some name")
(with-gemini-request "/example"
  (lambda (response)
    (assert-successful-status response "example request")
    (assert-mime-type response "text/gemini" "example request")
    (assert-body-contains response "Expected content" "example request")))
(test-end)
```

```scheme
;;; GOOD: Atomic assertion pattern
(test-group "file serving with atomic assertions"
  (with-gemini-request "/test.txt"
    (lambda (response)
      ;; Single request, multiple focused assertions
      (assert-successful-status response "text file request")
      (assert-mime-type response "text/plain" "text file request")
      (assert-body-not-empty response "text file request")
      (assert-body-contains response "Sample content" "text file request"))))

;;; BAD: Multi-property helper (deprecated)
(test-group "file serving with multi-property helper"
  (with-gemini-request "/test.txt"
    (lambda (response)
      ;; Single assertion tests multiple properties - harder to debug failures
      (assert-status-mime-and-body response 20 "text/plain" "Sample content" "text file"))))
```

## Example: Error Handling Test

```scheme
;;; Testing error responses
(test-group "file not found handling"
  (with-gemini-request "/nonexistent.txt"
    (lambda (response)
      (assert-error-status response "missing file request")
      (assert-error-message response "not found" "missing file request"))))
```

## Example: Complex Test with Multiple Validations

```scheme
;;; Directory index test with comprehensive validation
(test-group "directory index generation"
  (with-gemini-request "/subdir/"
    (lambda (response)
      ;; Status validation
      (assert-successful-status response "directory index")
      
      ;; Content type validation
      (assert-mime-type response "text/gemini" "directory index")
      
      ;; Content validation
      (assert-body-not-empty response "directory index")
      (assert-body-contains response "# Directory Index" "directory index")
      (assert-body-contains response "=> file1.txt" "directory index")
      (assert-body-contains response "=> file2.gmi" "directory index"))))
```

## Anti-Patterns to Avoid

### ❌ Returning Values from Test Handlers
```scheme
;;; BAD: Returns value for external assertion
(test-equal "file status" 20
  (with-gemini-request "/test.txt"
    (lambda (response)
      (gemini-response-status response))))  ; Returns status
```

### ❌ Multiple Network Requests per Test
```scheme
;;; BAD: Multiple requests in single test
(test-group "multiple requests"
  (with-gemini-request "/file1"
    (lambda (response1)
      (with-gemini-request "/file2"  ; Nested request - avoid
        (lambda (response2)
          (assert-successful-status response1 "file1")
          (assert-successful-status response2 "file2")))))
```

### ❌ Using Multi-Property Helpers
```scheme
;;; BAD: Multi-property helper (deprecated)
(assert-status-mime-and-body response 20 "text/plain" "content" "test")
```

## Testing Best Practices

1. **One request per test scenario** - Capture response once, assert multiple times
2. **Descriptive test names** - Use meaningful test descriptions for each assertion
3. **Logical assertion grouping** - Group related assertions in the same test
4. **Clear failure messages** - Each assertion provides specific context
5. **Consistent naming** - Use consistent test description patterns across tests
