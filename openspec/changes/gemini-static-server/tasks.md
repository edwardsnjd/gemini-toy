# Implementation Tasks: Gemini Static Server

## 1. Project Structure Setup

- [x] 1.1 Create server directory structure (`server/src/`, `server/tests/`, `server/certs/`)
- [ ] 1.2 Create acceptance tests directory structure (`acceptance-tests/server/`)
- [ ] 1.3 Set up basic Guile module files with proper headers
- [ ] 1.4 Create test runner scripts for both unit and acceptance tests

## 2. Acceptance Tests (Black-box, Protocol-level)

- [ ] 2.1 Write acceptance test for basic file serving over TLS
- [ ] 2.2 Write acceptance test for directory index handling  
- [ ] 2.3 Write acceptance test for file not found (404) responses
- [ ] 2.4 Write acceptance test for malformed request handling
- [ ] 2.5 Write acceptance test for MIME type correctness (.gmi, .txt, .png)

## 3. Core Protocol Module (Unit Tests + Implementation)

- [ ] 3.1 Write unit tests for URI parsing function
- [ ] 3.2 Implement URI parsing (validate scheme, extract path, handle malformed URIs)
- [ ] 3.3 Write unit tests for response formatting  
- [ ] 3.4 Implement response formatting (status codes, meta fields, proper CRLF)
- [ ] 3.5 Write unit tests for request validation
- [ ] 3.6 Implement request validation (length limits, format checking)

## 4. MIME Type Module (Unit Tests + Implementation)

- [ ] 4.1 Write unit tests for file extension detection
- [ ] 4.2 Implement file extension parsing from file paths
- [ ] 4.3 Write unit tests for MIME type mapping
- [ ] 4.4 Implement MIME type database (.gmi → text/gemini, .txt → text/plain, etc.)
- [ ] 4.5 Write unit tests for charset handling
- [ ] 4.6 Implement charset defaults for text types

## 5. File Handler Module (Unit Tests + Implementation)

- [ ] 5.1 Write unit tests for path resolution and validation
- [ ] 5.2 Implement safe path resolution (prevent directory traversal)
- [ ] 5.3 Write unit tests for directory index file detection  
- [ ] 5.4 Implement index file lookup (index.gmi, index.gemini)
- [ ] 5.5 Write unit tests for file reading and error conditions
- [ ] 5.6 Implement file reading with proper error handling

## 6. TLS Configuration Module (Unit Tests + Implementation)

- [ ] 6.1 Write unit tests for certificate validation and loading
- [ ] 6.2 Implement certificate file reading and validation
- [ ] 6.3 Write unit tests for TLS context setup
- [ ] 6.4 Implement GnuTLS context configuration
- [ ] 6.5 Create self-signed certificate generation for development

## 7. Main Server Integration (Unit Tests + Implementation)

- [ ] 7.1 Write unit tests for command-line argument parsing
- [ ] 7.2 Implement CLI argument handling and validation
- [ ] 7.3 Write integration tests for request processing pipeline
- [ ] 7.4 Implement main request processing loop
- [ ] 7.5 Implement TLS socket handling and connection management
- [ ] 7.6 Add proper error handling and logging

## 8. End-to-End Verification

- [ ] 8.1 Run all acceptance tests against implemented server
- [ ] 8.2 Run all unit tests to verify component correctness  
- [ ] 8.3 Test with sample static content (create test .gmi files)
- [ ] 8.4 Verify TLS certificate handling works correctly
- [ ] 8.5 Test error conditions manually (malformed requests, missing files)

## 9. Documentation and Examples

- [ ] 9.1 Create example static content with .gmi files
- [ ] 9.2 Write basic usage instructions in server README
- [ ] 9.3 Document test running procedures
- [ ] 9.4 Add code comments explaining Gemini protocol implementation choices

---

Each checkbox becomes a unit of work in the apply phase. The TDD approach means we write tests first (steps 2, 3.1, 3.3, etc.) then implement to make them pass.

Ready to implement?