# 4. Use Guile Scheme for gemini-client CLI

Date: 2026-03-08

## Status

Accepted

## Context

The gemini-server project has a working Gemini protocol server prototype. We need to implement a `gemini-client` CLI tool to browse Gemini sites and test the server. We must choose an implementation language that balances simplicity, dependency management, and developer experience.

## Decision

Implement the `gemini-client` CLI tool in Guile Scheme.

## Consequences

- **Positive**:
  - Embeddable and extensibility-friendly
  - Good FFI for calling C libraries (including TLS libraries like GnuTLS or OpenSSL)
  - REPL enables interactive testing and debugging
  - Scheme's simple, minimal syntax suits protocol implementation
  - No separate build step required (interpreted)

- **Negative**:
  - Less common than Go or Python for CLI tools - steeper learning curve for some contributors
  - Requires Guile to be installed on the system
  - TLS library dependencies (GnuTLS or libssl via FFI)
  - Less ecosystem for HTTP/networking compared to Go
