# Implementation Plan: Iterative TDD Approach

## Guiding Principles

1. **Always runnable** - Every iteration produces a working CLI, even if it does minimal work
2. **Tests always passing** - Each increment adds tests before implementation
3. **Small chunks** - Each task should be completable in a single session
4. **Feature-based** - Group by capability, not by technical layer

---

## Iteration 1: CLI Skeleton

**Goal:** Get a runnable CLI that parses arguments and shows help

### Tasks

- [x] 1.1 Create gemini-client.scm with main entry point
- [x] 1.2 Implement --help flag that exits cleanly
- [x] 1.3 Add shebang and executable permissions
- [x] 1.4 Verify `gemini-client --help` works

**Tests:**
- `--help` displays usage and exits with 0
- Missing URL shows error message and exits with non-zero

**Verification:** `./gemini-client --help` shows usage message

---

## Iteration 2: URL Parsing

**Goal:** Extract components from gemini:// URLs

### Tasks

- [ ] 2.1 Write unit tests for URL parsing (host, port, path)
- [ ] 2.2 Implement URL parsing module
- [ ] 2.3 Validate gemini:// scheme, reject others
- [ ] 2.4 Wire URL parsing into CLI, print parsed URL and exit

**Tests:**
- Valid gemini:// URLs parse correctly
- Invalid schemes rejected with error
- Default port 1965 assumed

**Verification:** `./gemini-client gemini://example.com/foo` prints parsed components

---

## Iteration 3: Fibers Infrastructure

**Goal:** Set up fibers runtime with channels, even before networking works

### Tasks

- [ ] 3.1 Add fibers dependency to project
- [ ] 3.2 Write tests for channel communication (put/get message)
- [ ] 3.3 Implement fibers runtime in CLI entry point
- [ ] 3.4 Create request and response channels
- [ ] 3.5 Spawn a trivial "echo" fiber that puts messages back on response channel

**Tests:**
- Channel creation works
- Messages round-trip through fiber

**Verification:** Client runs without error (even if it doesn't fetch anything yet)

---

## Iteration 4: Network Worker Fiber

**Goal:** Fiber that can connect to a server and send a request

### Tasks

- [ ] 4.1 Write integration test that starts a simple test server
- [ ] 4.2 Implement TCP connection in network worker fiber
- [ ] 4.3 Handle connection errors gracefully
- [ ] 4.4 Add --insecure flag for TLS (implemented as no-op for now)
- [ ] 4.5 Main fiber sends URL on request channel, network worker connects and returns raw bytes

**Tests:**
- Connection to localhost:1965 succeeds (or fails gracefully)
- Timeout handling works

**Verification:** Run against local gemini-server, see connection attempt

---

## Iteration 5: TLS Support

**Goal:** Add TLS encryption to network connections

### Tasks

- [ ] 5.1 Write test for TLS connection (or mock)
- [ ] 5.2 Implement TLS wrapper using (web client)
- [ ] 5.3 Implement --insecure flag to skip verification
- [ ] 5.4 Add timeout to TLS handshake

**Tests:**
- TLS connection to gemini://example.com works
- --insecure bypasses certificate verification

**Verification:** `gemini-client gemini://gemini.capsuleaudio.com` fetches page

---

## Iteration 6: Gemini Protocol - Requests

**Goal:** Send valid Gemini protocol requests

### Tasks

- [ ] 6.1 Write tests for request line construction
- [ ] 6.2 Implement Gemini request format (URL + CRLF)
- [ ] 6.3 Handle URL encoding for query strings
- [ ] 6.4 Add request timeout

**Tests:**
- Request line matches Gemini spec
- Query strings encoded correctly

**Verification:** Use netcat to observe raw request from client

---

## Iteration 7: Gemini Protocol - Response Parsing

**Goal:** Parse status line and headers from server

### Tasks

- [ ] 7.1 Write tests for status line parsing (2-digit code + meta)
- [ ] 7.2 Implement status code parser
- [ ] 7.3 Parse headers (at minimum: Content-Type, Location)
- [ ] 7.4 Handle all major status codes (10, 20, 30, 40, 50)

**Tests:**
- Valid status lines parsed correctly
- Unknown status codes handled gracefully
- Headers extracted correctly

**Verification:** Print parsed status and headers to stdout

---

## Iteration 8: Response Body & Redirects

**Goal:** Read response body and follow redirects

### Tasks

- [ ] 8.1 Write tests for body reading
- [ ] 8.2 Implement body reading (stream to stdout)
- [ ] 8.3 Implement single redirect follow (status 31)
- [ ] 8.4 Limit redirect depth to prevent loops

**Tests:**
- Body content output to stdout
- Redirects followed automatically
- Redirect loop prevention works

**Verification:** Test against server that returns redirects

---

## Iteration 9: Content Rendering

**Goal:** Format content based on Content-Type

### Tasks

- [ ] 9.1 Write tests for Content-Type parsing
- [ ] 9.2 Render text/plain as-is
- [ ] 9.3 Render text/gemini with basic formatting (headings, links as URLs)
- [ ] 9.4 Show placeholder for unsupported types
- [ ] 9.5 Handle binary content gracefully

**Tests:**
- text/plain displays raw
- text/gemini links shown as URLs
- Unsupported types show placeholder

**Verification:** Test against various content types

---

## Iteration 10: Error Handling Polish

**Goal:** Robust error handling for production use

### Tasks

- [ ] 10.1 Write tests for error scenarios
- [ ] 10.2 Improve error messages (user-friendly, not debuggy)
- [ ] 10.3 Proper exit codes (0 success, 1 client error, 2 server error, 3 network error)
- [ ] 10.4 Resource cleanup on exit

**Tests:**
- All error cases have appropriate messages
- Exit codes are correct

**Verification:** Test various error scenarios

---

## Future Iterations (Not in Scope)

- TUI mode with keyboard navigation
- History/back navigation
- Input handling for status 10
- Image/media display
- Caching
