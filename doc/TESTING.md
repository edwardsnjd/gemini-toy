# Testing Guide

This document describes the testing infrastructure and procedures for the Gemini server project.

## Test Organization

The project uses a two-tier testing approach:

```
gemini-toy/
├── src/
│   └── server/
│       ├── src/               # Server implementation
│       └── tests/             # Server unit tests
└── test/
    ├── acceptance-tests/      # Integration/black-box tests
    └── test-content/          # Test static files
```

## Running Unit Tests

Unit tests verify individual module functionality in isolation.

### Run All Unit Tests

```bash
# From project root
scripts/run-unit-tests.scm
```

### Unit Test Modules

#### tests/protocol-parser.scm
Tests the Gemini protocol parsing and formatting:
- Request line parsing
- URI validation
- Response formatting
- Error handling

```bash
# Example test run
guile -c "
(add-to-load-path \"src\")
(add-to-load-path \"tests\")
(use-modules (tests protocol-parser))
"
```

#### tests/cli-args.scm
Tests command line argument processing:
- Option parsing
- Argument validation
- Default value handling
- Error conditions

#### tests/mime-types.scm
Tests MIME type detection:
- File extension mapping
- Default type handling
- Special Gemini types

#### tests/file-handler.scm
Tests file system operations:
- Path resolution
- Security checks
- File reading
- Error handling

#### tests/tls-config.scm
Tests TLS certificate management:
- Certificate loading
- Context setup
- Error handling

#### tests/integration.scm
Tests module integration:
- End-to-end request processing
- Error propagation
- Configuration handling

## Running Acceptance Tests

Acceptance tests verify the server's behavior from a client perspective.

### Prerequisites

See `scripts/run-acceptance-tests.sh` - it handles all prerequisites, server startup, and test execution automatically.

## Writing New Tests

### Unit Test Template

Create new unit test modules in `src/server/tests/tests/`:

```scheme
;;; tests/my-feature.scm
;;; Test module for my-feature functionality

(define-module (tests my-feature)
  #:use-module (srfi srfi-64)  ; Testing framework
  #:use-module (gemini my-feature))

;;; Test group
(test-group "my-feature-tests"
  
  ;; Basic functionality test
  (test-equal "basic-operation"
    'expected-result
    (my-function 'test-input))
  
  ;; Error handling test
  (test-assert "error-handling"
    (catch #t
      (lambda () (my-function 'invalid-input) #f)
      (lambda (key . args) #t)))
  
  ;; Edge case test
  (test-equal "edge-case"
    'edge-result
    (my-function 'edge-input)))
```

### Acceptance Test Template

Create test scenarios in `test/acceptance-tests/`:

```scheme
;;; acceptance-tests/my-scenario.scm
;;; Acceptance test for specific scenario

(define-module (acceptance-tests my-scenario)
  #:use-module (srfi srfi-64))

(test-group "my-scenario"
  
  ;; Setup test environment
  (test-begin "my-scenario-setup")
  
  ;; Test connection
  (test-assert "server-connectivity"
    (test-server-connection))
  
  ;; Test specific scenario
  (test-equal "scenario-result"
    'expected-response
    (make-test-request "gemini://localhost:1966/test-path"))
  
  (test-end "my-scenario-setup"))
```

## Test Framework Features

### SRFI-64 Testing Framework

The project uses SRFI-64, which provides:

- `test-begin` / `test-end` - Test group management
- `test-equal` - Value comparison tests
- `test-assert` - Boolean tests
- `test-error` - Exception tests
- `test-approximate` - Numerical comparison with tolerance

## Debugging Tests

### Verbose Test Output

```bash
# Run tests with verbose output
guile --debug run-unit-tests.scm

# Run specific test with debugging
guile -c "
(use-modules (srfi srfi-64))
(test-begin \"debug-test\")
(test-equal \"my-test\" 'expected (my-function))
(test-end \"debug-test\")
"
```

## Performance Testing

### Load Testing

```bash
# Simple load test with concurrent requests
for i in {1..10}; do
  echo "gemini://localhost:1966/" | \
  openssl s_client -connect localhost:1966 -quiet &
done
wait
```

### Memory Usage Testing

```bash
# Monitor memory usage during tests
valgrind --tool=memcheck guile server.scm &
# Run test requests
# Check valgrind output
```

## Test Coverage

## Common Testing Issues

### Server Not Starting
```bash
# Check port availability
netstat -tlnp | grep 1966

# Check certificate files
ls -la src/server/certs/

# Run with verbose logging
guile --debug src/server/src/server.scm
```

### Test Failures
```bash
# Check Guile module path
echo $GUILE_LOAD_PATH

# Verify test dependencies
guile -c "(use-modules (srfi srfi-64))"

# Run individual test modules
guile tests/tests/protocol-parser.scm
```

### TLS Connection Issues
```bash
# Test certificate validity
openssl x509 -in src/server/certs/cert.pem -text -noout

# Check TLS configuration
openssl s_client -connect localhost:1966 -servername localhost
```
