## Why

We have a Gemini server prototype but no way to browse Gemini sites or test our server with a real client. A simple CLI-based Gemini client will enable both exploring the broader Gemini web and testing our local server implementation.

## What Changes

- Add a new `gemini-client` command-line tool
- Implement minimal Gemini protocol compliance (request/response handling)
- Support browsing arbitrary Gemini URLs (gemini://)
- Support displaying text/gemini and text/plain responses
- Handle basic TLS verification (with option to disable for local testing)

## Capabilities

### New Capabilities

- **gemini-client**: A bare-bones CLI client for browsing Gemini sites
  - Connect to any gemini:// URL
  - Send valid Gemini requests with headers
  - Handle Gemini response status codes (success, redirect, client/server errors)
  - Display text/gemini and text/plain content
  - Follow redirects (single level for simplicity)
  - Support self-signed certificates for local testing

### Modified Capabilities

*(none - this is a new capability)*

## Impact

- New package: `gemini-client` in the codebase
- Adds no new external dependencies beyond what the server already uses
- Enables testing of the gemini-server without external tools