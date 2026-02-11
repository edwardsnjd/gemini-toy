# Proposal: Gemini Static Server

## Why

The gemini-toy project needs a basic static file server to demonstrate understanding of the Gemini protocol. This will serve as the foundation for exploring how Gemini's simple request/response model works with real content. Using TDD with both acceptance and unit tests will ensure correct protocol implementation and make the learning process more systematic.

## What Changes

- Add a Guile Scheme-based Gemini server that serves static files over TLS
- Implement proper Gemini protocol request/response handling using Scheme's networking libraries
- Support standard file type detection and MIME type mapping
- Handle directory requests with index file support
- **Follow TDD approach: write acceptance tests first (black-box), then unit tests, then implement to make them pass**

## Capabilities

### New Capabilities
- `gemini-static-server`: A Guile Scheme server that serves a static directory over the Gemini protocol on port 1965 with TLS
- `acceptance-test-suite`: Technology-agnostic black-box tests that verify protocol compliance by making real network requests
- `unit-test-suite`: White-box tests for internal server components and functions

## Impact

- `acceptance-tests/server/test-protocol-compliance.scm`: Black-box tests that connect to server and verify Gemini protocol responses
- `acceptance-tests/server/test-static-serving.scm`: Tests for file serving behavior, MIME types, directory handling (via network)
- `acceptance-tests/server/test-error-conditions.scm`: Tests for 404, server errors, malformed requests (via network)
- `server/tests/test-protocol-parser.scm`: Unit tests for request parsing and response formatting functions
- `server/tests/test-mime-types.scm`: Unit tests for file extension to MIME type mapping
- `server/tests/test-file-handler.scm`: Unit tests for file system operations
- `server/src/server.scm`: Main server implementation (developed test-first)
- `server/src/mime-types.scm`: File extension to MIME type mapping module
- `server/src/gemini-protocol.scm`: Core protocol handling functions
- Test runners for both acceptance and unit test suites