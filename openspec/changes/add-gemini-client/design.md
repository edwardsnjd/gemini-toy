## Context

The gemini-server project has a working Gemini protocol server prototype, but lacks a client for browsing Gemini sites or testing the server with real requests. This design outlines a Gemini client to fill that gap, supporting both CLI and TUI modes.

**Current State:**
- Gemini server is functional for basic requests
- No client exists to test the server or browse other Gemini sites
- Need ability to connect to any gemini:// URL

**Constraints:**
- Keep external dependencies minimal (leverage existing server dependencies)
- Must handle TLS with option to disable verification for local testing
- Support both CLI (non-interactive) and TUI (interactive terminal) modes
- Support text/gemini and text/plain response types
- Use fibers for non-blocking network I/O to keep the interface responsive

**Stakeholders:**
- Developers testing the gemini-server
- Users wanting to browse Gemini sites from command line

## Goals / Non-Goals

**Goals:**
- Create a `gemini-client` tool that connects to any gemini:// URL
- Implement CLI mode with stdout output (non-interactive, scriptable)
- Implement minimal Gemini protocol compliance (request/response handling)
- Support displaying text/gemini and text/plain responses
- Handle Gemini response status codes (success, redirect, client/server errors)
- Follow redirects (single level for simplicity)
- Support self-signed certificates for local testing
- Use Guile Fibers for non-blocking network I/O
- Provide foundation for future TUI mode

**Non-Goals:**
- Interactive TUI features (keyboard navigation, history, bookmarks) - future enhancement
- Proxy/gateway functionality - direct connections only, no HTTP/SOCKS proxy support
- Caching or offline support
- Full status code handling (focus on common codes)
- Input handling (forms) - status 10 input prompt for initial version
- Image/media content display - text responses only for now
- Persistent session management

### Scope Limitations

**Images and media:**
- Images (image/* MIME types) are not supported in this version
- Any non-text response will show a placeholder message indicating the content type cannot be displayed
- Future versions may add image display via terminal graphics or external viewer integration

**Proxies:**
- Direct connections only - no HTTP or SOCKS proxy support
- No proxy environment variable handling (HTTP_PROXY, HTTPS_PROXY, etc.)
- All requests go directly to the target gemini:// URL

## Guiding Principles

1. **Always runnable** - Every iteration produces a working CLI, even if it does minimal work
2. **Tests always passing** - Each increment adds tests before implementation
3. **Small chunks** - Each task should be completable in a single session
4. **Feature-based** - Group by capability, not by technical layer
5. **Deep abstractions** - Separate application shell from the client logic

## Decisions

### 1. Implementation Language: Guile Scheme
**Decision:** Implement the client in Guile Scheme, leveraging its built-in networking and FFI capabilities.

**Rationale:**
- Embeddable, extensibility-friendly language
- Good FFI for calling C libraries (including TLS libraries)
- REPL enables interactive testing and debugging
- Scheme's simple syntax suits protocol implementation

**Alternative considered:**
- Go - Requires separate build toolchain, no REPL
- Rust - Different programming model, good concurrency, no REPL

### 2. Output Mode: CLI stdout first, TUI later
**Decision:** The initial implementation will output to stdout (CLI mode) without interactive TUI features. Future versions will add interactive TUI capabilities.

**Rationale:**
- Simpler to implement and test
- Easier to script and pipe output
- Clear separation between non-interactive and interactive modes
- The fibers architecture (needed for TUI) still provides value for non-blocking network I/O in CLI mode

**Alternative considered:** Start with TUI - More complex, delays initial delivery

### 3. Concurrency: Guile Fibers for Network I/O
**Decision:** Use Guile Fibers library for network operations, even in CLI mode.

**Rationale:**
- Enables non-blocking I/O, keeping the client responsive
- Provides foundation for future TUI mode (where UI and network run in separate fibers)
- Uses channel-based communication between fibers
- Aligns with ADR 0005 (Fibers-Based Architecture for Responsive Guile TUI)

**Alternative considered:** Blocking I/O - Simpler but blocks during network operations

### 4. TLS Handling: Configurable verification toggle
**Decision:** Add `-k` / `--insecure` flag to skip TLS certificate verification for local testing with self-signed certs.

**Rationale:**
- Essential for testing against local server with self-signed certificates
- Clear opt-in to skip verification (not default)
- Use Guile's (web client) make_ssl-context with #:verify? #f

**Alternative considered:** Custom certificate bundling - More complex, unnecessary for local testing

### 5. Response Handling: Content-type based rendering
**Decision:** Parse `Content-Type` header and render appropriately:
- `text/gemini` → Render as Gemini markup (links as URLs, headings)
- `text/plain` → Render as plain text
- Other types → Show placeholder message

**Rationale:**
- Matches proposal requirements
- Simple switch statement on media type
- Extensible for future types

**Alternative considered:** Unified rendering - Less useful, loses semantic meaning

### 6. Redirect Handling: Single-level automatic follow
**Decision:** Automatically follow one level of redirects, then stop.

**Rationale:**
- Simplicity as specified in proposal
- Prevents infinite redirect loops
- Sufficient for common cases (HTTP→HTTPS, short URLs)

**Alternative considered:** Full redirect following - More complex, potential security concerns

### 7. Request Format: Minimal Gemini request
**Decision:** Send standard Gemini request with:
- URL in absolute form
- No custom headers (for simplicity)
- Default timeout (30 seconds)

**Rationale:**
- Gemini protocol is simple, no complex headers needed
- Timeout prevents hanging connections

## Risks / Trade-offs

1. **[Risk] Unicode/encoding issues** → **Mitigation:** Assume UTF-8, use Guile's string handling
2. **[Risk] Large response bodies** → **Mitigation:** Stream to port, don't load entirely in memory
3. **[Risk] Gemini protocol edge cases** → **Mitigation:** Handle known status codes (10, 11, 20, 30, 40, 50), fail gracefully on unknown
4. **[Risk] TLS library availability** → **Mitigation:** Require GnuTLS or use libssl via Guile FFI
5. **[Risk] Terminal output formatting** → **Mitigation:** Use basic ANSI codes for headings, plain text for body
