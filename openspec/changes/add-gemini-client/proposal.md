## Why

We have a Gemini server prototype but no way to browse Gemini sites or test our server with a real client. A Gemini client will enable both exploring the broader Gemini web and testing our local server implementation. The client will support both CLI (non-interactive, scriptable) and TUI (interactive terminal UI) modes.

## What Changes

- Add a new `gemini-client` command-line tool
- Implement minimal Gemini protocol compliance (request/response handling)
- Support browsing arbitrary Gemini URLs (gemini://)
- Support displaying text/gemini and text/plain responses
- Handle basic TLS verification (with option to disable for local testing)

## Capabilities

### New Capabilities

- **gemini-client**: A client for browsing Gemini sites, supporting both CLI and TUI modes
  - Connect to any gemini:// URL
  - Send valid Gemini requests with headers
  - Handle Gemini response status codes (success, redirect, client/server errors)
  - Display text/gemini and text/plain content
  - Follow redirects (single level for simplicity)
  - Support self-signed certificates for local testing
  - **CLI mode**: Non-interactive, scriptable output to stdout
  - **TUI mode**: Interactive terminal UI with keyboard navigation (future enhancement)

### Modified Capabilities

*(none - this is a new capability)*

## Impact

- New package: `gemini-client` in the codebase
- Enables testing of the gemini-server without external tools
- First pass of a usable gemini client to play with external sites
