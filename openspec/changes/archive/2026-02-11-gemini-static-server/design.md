# Design: Gemini Static Server

## Context

This is a toy implementation to understand the Gemini protocol. We're building a static file server in Guile Scheme that demonstrates correct protocol implementation while maintaining clean, testable code. The server needs to handle TLS connections, parse Gemini requests, and serve files from a static directory.

## Goals / Non-Goals

**Goals:**
- Demonstrate correct Gemini protocol implementation
- Create a foundation for learning how Gemini works
- Use TDD to ensure protocol compliance
- Keep the implementation simple and readable
- Separate acceptance tests from implementation details

**Non-Goals:**
- Production-ready performance or scalability
- Advanced features like CGI, client certificates, or proxying
- Comprehensive logging or monitoring
- Configuration beyond basic static directory setting

## Decisions

### Decision 1: Guile Scheme Libraries and Architecture

**Approach:** Use Guile's built-in networking with GnuTLS for TLS support

**Rationale:** 
- Guile has good networking support via `(ice-9 networking)` and socket primitives
- GnuTLS integration is available through `(gnutls)` module
- This keeps dependencies minimal and uses Guile's strengths
- Simple single-threaded event loop is sufficient for a toy implementation

**Implementation:**
```scheme
;; Core modules we'll use
(use-modules (ice-9 networking)
             (gnutls)
             (ice-9 textual-ports)
             (srfi srfi-1))  ; for list processing
```

### Decision 2: TDD Structure and Test Organization

**Approach:** Separate acceptance and unit tests completely

**Acceptance Tests Structure:**
- Live in `acceptance-tests/server/` 
- Use network sockets to connect to running server
- Test only public behavior via protocol
- Can start/stop server process as needed

**Unit Tests Structure:**
- Live in `server/tests/`
- Import and test internal functions directly
- Focus on individual components (parsing, MIME detection, etc.)
- Use Guile's built-in testing framework or SRFI-64

### Decision 3: Module Organization

**Approach:** Split functionality into focused modules

```
server/src/
├── server.scm           ; Main entry point, socket handling
├── gemini-protocol.scm  ; Request parsing, response formatting  
├── mime-types.scm       ; File extension to MIME type mapping
├── file-handler.scm     ; File system operations, path resolution
└── tls-config.scm       ; TLS setup and certificate handling
```

**Rationale:**
- Each module has a single responsibility
- Easy to unit test individual components
- Clean separation between protocol logic and file operations

### Decision 4: Request Processing Pipeline

**Approach:** Simple sequential pipeline with error handling at each stage

```
TLS Connection → Read Request → Parse URI → Resolve File → Send Response → Close
```

Each stage can fail and return an appropriate error response:
- Read Request: 59 (Bad Request) for malformed input
- Parse URI: 59 (Bad Request) for invalid URIs  
- Resolve File: 51 (Not Found) for missing files, 40 (Temporary Failure) for permissions
- Send Response: 40 (Temporary Failure) for I/O errors

### Decision 5: TLS Certificate Handling

**Approach:** Use self-signed certificate for development, configurable cert/key files

**Rationale:**
- Self-signed certificates are acceptable in Gemini
- Keeps the toy implementation simple
- Demonstrates proper TLS usage without PKI complexity

**Implementation:**
- Generate self-signed cert/key on first run if not present
- Store in `server/certs/` directory
- Make cert/key paths configurable via command line

### Decision 6: Configuration and Command Line Interface

**Approach:** Simple command-line arguments with sensible defaults

```bash
guile server/src/server.scm [--port 1965] [--static-dir ./static] [--cert cert.pem] [--key key.pem]
```

**Rationale:**
- Minimal configuration needed for toy implementation
- Clear defaults make it easy to get started
- Command line args are simpler than config files for this scope

### Decision 7: Error Handling Strategy

**Approach:** Fail fast with clear error messages, graceful degradation for client errors

**Server Startup Errors:** Fail immediately with helpful messages
- Missing static directory
- Invalid certificate files  
- Port already in use

**Runtime Errors:** Return appropriate Gemini status codes
- Log errors internally for debugging
- Never expose internal error details to clients
- Continue serving other requests after recoverable errors