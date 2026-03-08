## ADDED Requirements

### Requirement: Connect to gemini:// URL
The gemini-client SHALL accept a gemini:// URL as a command-line argument and establish a connection to the specified server.

#### Scenario: Valid gemini URL provided
- **WHEN** user runs `guile -L . gemini-client.scm gemini://example.com/`
- **THEN** client SHALL attempt to establish a TCP connection to example.com on port 1965

#### Scenario: Invalid URL format
- **WHEN** user provides a non-gemini URL (e.g., http://example.com)
- **THEN** client SHALL display an error message indicating only gemini:// URLs are supported

### Requirement: Send valid Gemini request
The gemini-client SHALL send a properly formatted Gemini request including the URL and CRLF terminator.

#### Scenario: Simple request
- **WHEN** client connects to gemini://example.com/page
- **THEN** client SHALL send `gemini://example.com/page\r\n` to the server

#### Scenario: Request with query
- **WHEN** client connects to gemini://example.com/search?q=test
- **THEN** client SHALL URL-encode the query string and send `gemini://example.com/search?q%3Dtest\r\n`

#### Scenario: Request with special characters
- **WHEN** client connects to gemini://example.com/search?q=hello world!
- **THEN** client SHALL URL-encode special characters (space → %20, ! → %21) in the query string

### Requirement: Handle Gemini response status codes
The gemini-client SHALL parse and respond appropriately to Gemini protocol status codes.

#### Scenario: Successful response (2x)
- **WHEN** server returns status 20 (success)
- **THEN** client SHALL read and display the response body

#### Scenario: Redirect response (3x)
- **WHEN** server returns status 30 (redirect)
- **THEN** client SHALL read the Location header and display the redirect target to user

#### Scenario: Client error (4x)
- **WHEN** server returns status 4x (client error)
- **THEN** client SHALL display the error message from server

#### Scenario: Server error (5x)
- **WHEN** server returns status 5x (server error)
- **THEN** client SHALL display the error message from server

### Requirement: Handle input required (status 10)
The gemini-client SHALL handle the Gemini input request (status 10) by prompting user for input and resubmitting.

#### Scenario: Simple text input
- **WHEN** server returns status 10 with meta "Enter your name:"
- **THEN** client SHALL prompt user for input and resubmit the request with the user's response

#### Scenario: Sensitive input (password)
- **WHEN** server returns status 10 with meta "Enter password:" (preceded by 1*)
- **THEN** client SHALL use secure password input and resubmit

### Requirement: Display text content
The gemini-client SHALL render text/gemini and text/plain response types appropriately.

#### Scenario: text/gemini content
- **WHEN** response Content-Type is text/gemini
- **THEN** client SHALL render Gemini markup (headings, links as URLs) to terminal

#### Scenario: text/plain content
- **WHEN** response Content-Type is text/plain
- **THEN** client SHALL display the content as plain text

#### Scenario: Unsupported content type
- **WHEN** response Content-Type is image/png or other unsupported type
- **THEN** client SHALL display a message indicating the content type cannot be displayed

### Requirement: Follow redirects
The gemini-client SHALL follow at least one level of redirect automatically.

#### Scenario: Single redirect
- **WHEN** server returns status 31 with Location header
- **THEN** client SHALL automatically fetch the new URL and display the result

#### Scenario: No automatic redirect follow for 30 without location
- **WHEN** server returns status 30 but no Location header
- **THEN** client SHALL display the redirect status and abort

### Requirement: TLS certificate handling
The gemini-client SHALL support both normal TLS verification and an option to skip verification for local testing.

#### Scenario: Default TLS verification
- **WHEN** client connects to gemini:// URL without any flags
- **THEN** client SHALL verify the server certificate against system CA store

#### Scenario: Skip TLS verification
- **WHEN** user provides -k or --insecure flag
- **THEN** client SHALL skip certificate verification, allowing self-signed certs