## 1. Project Setup

- [ ] 1.1 Create gemini-client.scm main entry point
- [ ] 1.2 Create lib/ directory for modules
- [ ] 1.3 Set up module system and imports (ice-9, web client)
- [ ] 1.4 Add shebang and executable permissions

## 2. CLI Argument Parsing

- [ ] 2.1 Parse command-line arguments using (ice-9 getopt-long)
- [ ] 2.2 Support positional URL argument
- [ ] 2.3 Add -k/--insecure flag for TLS verification bypass
- [ ] 2.4 Add --help flag with usage information
- [ ] 2.5 Validate URL is gemini:// scheme

## 3. Network Connection

- [ ] 3.1 Extract host and port from gemini:// URL
- [ ] 3.2 Establish TCP connection to host:1965
- [ ] 3.3 Set up TLS connection using (web client)
- [ ] 3.4 Implement TLS with verification (default)
- [ ] 3.5 Implement TLS without verification (--insecure flag)
- [ ] 3.6 Add connection timeout handling (30 seconds)

## 4. Gemini Protocol - Request

- [ ] 4.1 Construct Gemini request line (URL + CRLF)
- [ ] 4.2 Send request over connection
- [ ] 4.3 Handle URL encoding for queries

## 5. Gemini Protocol - Response Parsing

- [ ] 5.1 Read response status line
- [ ] 5.2 Parse status code (2 digits)
- [ ] 5.3 Parse meta field (error message or headers)
- [ ] 5.4 Handle success (20) - read response body
- [ ] 5.5 Handle input required (10) - prompt for input
- [ ] 5.6 Handle redirect (30-31) - parse Location header
- [ ] 5.7 Handle client error (40) - display error
- [ ] 5.8 Handle server error (50) - display error
- [ ] 5.9 Implement single-level redirect following

## 6. Content Display

- [ ] 6.1 Parse Content-Type header
- [ ] 6.2 Display text/plain content as-is
- [ ] 6.3 Render text/gemini markup (headings, links)
- [ ] 6.4 Show placeholder for unsupported content types
- [ ] 6.5 Handle binary content gracefully

## 7. Error Handling

- [ ] 7.1 Handle connection failures (host unreachable, timeout)
- [ ] 7.2 Handle TLS certificate errors
- [ ] 7.3 Handle malformed responses from server
- [ ] 7.4 Display user-friendly error messages

## 8. Testing

### Unit Tests
- [ ] 8.1 Set up Guile test framework (srfi-64 or similar)
- [ ] 8.2 Write unit tests for URL parsing
- [ ] 8.3 Write unit tests for request line construction
- [ ] 8.4 Write unit tests for status code parsing
- [ ] 8.5 Write unit tests for Content-Type parsing

### Integration Tests
- [ ] 8.6 Test with local gemini-server
- [ ] 8.7 Test with public gemini:// URLs
- [ ] 8.8 Test --insecure flag with self-signed certs
- [ ] 8.9 Test redirect following (status 31)
- [ ] 8.10 Test error handling (invalid URL, unreachable host)
- [ ] 8.11 Test URL encoding with special characters

### Manual Tests
- [ ] 8.12 Test status 10 input required (if local server supports)
- [ ] 8.13 Test all status codes: 10, 20, 30, 31, 40, 41, 50, 51
- [ ] 8.14 Test text/gemini markup rendering
- [ ] 8.15 Test unsupported content type display

### End-to-End Tests (using gemini-server)
- [ ] 8.16 Create test fixtures in server (sample text/plain, text/gemini pages)
- [ ] 8.17 Start local gemini-server with test fixtures
- [ ] 8.18 Run client against local server, verify text/plain output matches fixture
- [ ] 8.19 Run client, verify text/gemini markup renders correctly
- [ ] 8.20 Configure server to return redirect (31), verify client follows
- [ ] 8.21 Configure server to return 40/50 errors, verify client displays error
- [ ] 8.22 Verify end-to-end test script captures all output for CI/CD