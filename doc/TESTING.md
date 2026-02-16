# Testing Guide

This document describes the testing infrastructure and procedures for the Gemini server project.

## Test Organization

The project uses a two-tier testing approach:

```
gemini-toy/
├── src/
│   └── server/
│       ├── tests/                    # Unit tests
│       │   ├── tests/
│       │   │   ├── protocol-parser.scm
│       │   │   ├── cli-args.scm
│       │   │   ├── mime-types.scm
│       │   │   ├── file-handler.scm
│       │   │   ├── tls-config.scm
│       │   │   └── integration.scm
│       │   └── run-unit-tests.scm    # Unit test runner
│       └── src/                      # Server source code
├── test/
│   ├── acceptance-tests/             # Integration/black-box tests
│   │   └── server/                   # Test scenarios
│   └── test-content/                 # Test static files
└── scripts/                          # Build and test scripts
```

## Running Unit Tests

Unit tests verify individual module functionality in isolation.

### Run All Unit Tests

```bash
# From project root
cd src/server
./run-unit-tests.scm

# Or explicitly with Guile
guile run-unit-tests.scm
```

### Run Specific Test Modules

```bash
# From server directory
guile -c "
(add-to-load-path \"src\")
(add-to-load-path \"tests\")
(use-modules (srfi srfi-64) (tests protocol-parser))
(test-begin \"protocol-tests\")
(test-end \"protocol-tests\")
"
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

Acceptance tests require a running server instance:

```bash
# Terminal 1: Start test server
cd src/server/src
guile server.scm --port 1966 --static-dir ../../test/test-content

# Terminal 2: Run acceptance tests
cd test/acceptance-tests
./run-acceptance-tests.scm
```

### Manual Server Testing

#### Using OpenSSL s_client

```bash
# Basic connection test
echo "gemini://localhost:1966/" | \
openssl s_client -connect localhost:1966 -servername localhost -quiet

# Test specific paths
echo "gemini://localhost:1966/test.gmi" | \
openssl s_client -connect localhost:1966 -servername localhost -quiet

# Test non-existent files
echo "gemini://localhost:1966/nonexistent.gmi" | \
openssl s_client -connect localhost:1966 -servername localhost -quiet
```

#### Using Gemini Clients

```bash
# With Amfora (if installed)
amfora gemini://localhost:1966/

# With Lagrange (if installed)
lagrange gemini://localhost:1966/
```

### Automated Test Scenarios

Create test scenarios in `test/acceptance-tests/server/`:

```bash
# Example test structure
test/acceptance-tests/server/
├── basic-requests/
├── error-handling/
├── security/
└── tls-tests/
```

## Test Content Structure

The `test/test-content/` directory contains files for testing:

```
test/test-content/
├── index.gmi              # Homepage test
├── test.txt               # Plain text test
├── subdir/
│   ├── index.gmi          # Subdirectory index
│   └── nested.gmi         # Nested content
├── binary/
│   └── test.pdf           # Binary file test
└── special-chars/
    └── ünicode.gmi        # Unicode filename test
```

### Creating Test Content

```bash
# Create basic test files
mkdir -p test/test-content/subdir

# Homepage
cat > test/test-content/index.gmi << 'EOF'
# Test Homepage

This is a test page for the Gemini server.

=> /test.txt Plain text file
=> /subdir/ Subdirectory
=> /binary/test.pdf Binary file
EOF

# Plain text test
cat > test/test-content/test.txt << 'EOF'
This is a plain text file for testing MIME type detection.
EOF

# Subdirectory index
cat > test/test-content/subdir/index.gmi << 'EOF'
# Subdirectory Test

This page tests subdirectory serving.

=> ../index.gmi Back to homepage
EOF
```

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

### Custom Test Utilities

Add common test utilities to modules:

```scheme
;;; Common test utilities
(define (test-server-connection)
  "Test if server is responding"
  ;; Implementation here
  #t)

(define (make-test-request uri)
  "Make a test request to the server"
  ;; Implementation here
  "expected-response")
```

## Continuous Integration

### Test Automation

Create a test script for CI/CD:

```bash
#!/bin/bash
# test-all.sh

set -e

echo "Starting Gemini server tests..."

# Run unit tests
echo "Running unit tests..."
cd src/server
./run-unit-tests.scm

# Start server for acceptance tests
echo "Starting test server..."
cd src
guile server.scm --port 1966 --static-dir ../../test/test-content &
SERVER_PID=$!

# Wait for server to start
sleep 2

# Run acceptance tests
echo "Running acceptance tests..."
cd ../../test/acceptance-tests
./run-acceptance-tests.scm

# Cleanup
echo "Cleaning up..."
kill $SERVER_PID

echo "All tests completed successfully!"
```

### Make Integration

Add test targets to `Makefile`:

```makefile
.PHONY: test test-unit test-acceptance

test: test-unit test-acceptance

test-unit:
	cd src/server && ./run-unit-tests.scm

test-acceptance:
	./test-all.sh
```

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

### Test Isolation

```bash
# Run tests in clean environment
env -i guile run-unit-tests.scm

# Test with specific module paths (from src/server directory)
GUILE_LOAD_PATH="$(pwd)/src:$(pwd)/tests" guile run-unit-tests.scm
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

### Manual Coverage Analysis

Review test coverage by examining:

1. **Module Coverage**: Ensure all modules have corresponding tests
2. **Function Coverage**: Verify all public functions are tested
3. **Error Path Coverage**: Test error conditions and edge cases
4. **Integration Coverage**: Test module interactions

### Coverage Checklist

- [ ] All exported functions tested
- [ ] Error conditions covered
- [ ] Edge cases handled
- [ ] Integration scenarios tested
- [ ] Security features verified
- [ ] Configuration options tested

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