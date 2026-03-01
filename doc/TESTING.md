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

## Unit Tests

Unit tests verify individual module functionality in isolation.

```bash
# From project root
scripts/run-unit-tests.scm
```

## Acceptance Tests

Acceptance tests verify the server's behavior from a client perspective.

For detailed guidance on test structure and atomic assertion patterns, see the [Acceptance Tests README](../test/acceptance-tests/README.md).

```bash
scripts/run-acceptance-tests.sh
# handles all prerequisites, server startup, and test execution automatically.
```

## Writing New Tests

Structure unit and acceptance tests similarly:
- Find or create the appropriate test group according to the feature/module under test.
- Follow an Arrange,Act,Assert pattern i.e. when reading the test implementation, it should have the assertions last.

### SRFI-64 Testing Framework

The project uses SRFI-64, which provides:

- `test-begin` / `test-end` - Test group management
- `test-equal` - Value comparison tests
- `test-assert` - Boolean tests
- `test-error` - Exception tests
- `test-approximate` - Numerical comparison with tolerance

## Load Testing

```bash
# Simple load test with concurrent requests
for i in {1..10}; do
  echo "gemini://localhost:1966/" | \
  openssl s_client -connect localhost:1966 -quiet &
done
wait
```

## Debugging Tests

Try running with verbose output:

```bash
# Run tests with verbose output
guile --debug run-unit-tests.scm
```

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
