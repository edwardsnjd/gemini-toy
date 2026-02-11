# Gemini Static Server Specification

## Purpose

A static file server implementation that demonstrates correct Gemini protocol compliance. This server serves static files over TLS according to the Gemini specification, with proper request parsing, MIME type detection, and error handling.

## Requirements

### Requirement: Gemini Protocol Request Handling

The server must correctly parse and respond to Gemini protocol requests according to the specification.

#### Scenario: Valid request processing

- **WHEN** a client sends a valid Gemini request "gemini://localhost:1965/path\r\n"
- **THEN** the server should parse the URI correctly
- **AND** respond with proper status code and meta information
- **AND** close the connection after sending the complete response

#### Scenario: Malformed request rejection

- **WHEN** a client sends a request longer than 1024 bytes
- **THEN** the server should respond with status code 59 (Bad Request)
- **AND** close the connection immediately

#### Scenario: Invalid URI handling

- **WHEN** a client sends a request with userinfo or fragment components
- **THEN** the server should respond with status code 59 (Bad Request)
- **AND** close the connection immediately

### Requirement: TLS Connection Handling

The server must use TLS for all connections and handle them according to Gemini protocol requirements.

#### Scenario: TLS connection establishment

- **WHEN** a client connects to port 1965
- **THEN** the server should establish a TLS connection using TLS 1.2 or higher
- **AND** support Server Name Indication (SNI)

#### Scenario: Connection closure

- **WHEN** the server finishes sending a response
- **THEN** it should close the connection using TLS close_notify
- **AND** not accept additional requests on the same connection

### Requirement: Response Format Compliance

The server must format responses according to the Gemini specification.

#### Scenario: Success response format

- **WHEN** serving a file successfully
- **THEN** the response should start with "20 <mime-type>\r\n"
- **AND** be followed immediately by the file content
- **AND** not include any additional headers or formatting

#### Scenario: Error response format

- **WHEN** an error occurs (file not found, server error, etc.)
- **THEN** the response should start with "<status-code> <meta>\r\n"
- **AND** not include a response body
- **AND** close the connection after the header

### Requirement: File System Mapping

The server must map Gemini URIs to filesystem paths within a configured static directory.

#### Scenario: Basic file serving

- **WHEN** a client requests "gemini://localhost:1965/example.txt"
- **THEN** the server should serve the file at "<static-root>/example.txt"
- **AND** respond with status code 20
- **AND** include the correct MIME type in the response

#### Scenario: Directory index handling

- **WHEN** a client requests a directory path like "gemini://localhost:1965/docs/"
- **THEN** the server should look for "index.gmi" or "index.gemini" in that directory
- **AND** serve the index file if it exists with status code 20
- **AND** respond with status code 51 (Not Found) if no index file exists

#### Scenario: Root path handling

- **WHEN** a client requests "gemini://localhost:1965/" or "gemini://localhost:1965"
- **THEN** the server should treat both as requests for the root directory
- **AND** look for index files in the static root directory

### Requirement: MIME Type Detection

The server must correctly determine and report MIME types for served files.

#### Scenario: Gemini file type detection

- **WHEN** serving a file with .gmi or .gemini extension
- **THEN** the server should use MIME type "text/gemini; charset=utf-8"

#### Scenario: Plain text file type detection

- **WHEN** serving a file with .txt extension
- **THEN** the server should use MIME type "text/plain; charset=utf-8"

#### Scenario: Binary file type detection

- **WHEN** serving a file with .png extension
- **THEN** the server should use MIME type "image/png"
- **AND** serve the file content as binary data

#### Scenario: Unknown file type handling

- **WHEN** serving a file with an unknown or no extension
- **THEN** the server should use MIME type "application/octet-stream"

### Requirement: File Not Found Handling

The server must properly handle requests for non-existent files.

#### Scenario: Missing file request

- **WHEN** a client requests a file that does not exist in the static directory
- **THEN** the server should respond with status code 51 (Not Found)
- **AND** include an appropriate error message in the meta field
- **AND** not include a response body

#### Scenario: Path traversal prevention

- **WHEN** a client requests a path containing ".." components
- **THEN** the server should either normalize the path safely or reject it
- **AND** never serve files outside the configured static directory

### Requirement: Server Error Response

The server must handle internal errors gracefully and return appropriate status codes.

#### Scenario: File system permission error

- **WHEN** the server cannot read a file due to permission issues
- **THEN** it should respond with status code 40 (Temporary Failure)
- **AND** include a generic error message in the meta field
- **AND** log the specific error details internally

#### Scenario: Server resource exhaustion

- **WHEN** the server runs out of available resources (file descriptors, memory, etc.)
- **THEN** it should respond with status code 41 (Server Unavailable)
- **AND** include an appropriate message in the meta field

#### Scenario: Configuration error

- **WHEN** the server is misconfigured (invalid static directory, missing certificates, etc.)
- **THEN** it should fail to start with a clear error message
- **AND** not accept any client connections

### Requirement: Client Error Response

The server must detect and respond to client errors appropriately.

#### Scenario: Request too large

- **WHEN** a client sends a request longer than 1024 bytes
- **THEN** the server should respond with status code 59 (Bad Request)
- **AND** include "Request too long" in the meta field

#### Scenario: Invalid URI format

- **WHEN** a client sends a malformed URI (missing scheme, invalid characters, etc.)
- **THEN** the server should respond with status code 59 (Bad Request)
- **AND** include "Invalid URI" in the meta field

#### Scenario: Unsupported scheme

- **WHEN** a client sends a request with a non-gemini scheme
- **THEN** the server should respond with status code 59 (Bad Request)
- **AND** include "Only gemini:// URIs supported" in the meta field

### Requirement: Network Error Handling

The server must handle network-level errors gracefully.

#### Scenario: Client disconnection during request

- **WHEN** a client disconnects before sending a complete request
- **THEN** the server should close the connection cleanly
- **AND** not crash or log excessive error messages

#### Scenario: TLS handshake failure

- **WHEN** a TLS handshake fails with a client
- **THEN** the server should close the connection
- **AND** continue accepting other client connections
- **AND** log the handshake failure for debugging