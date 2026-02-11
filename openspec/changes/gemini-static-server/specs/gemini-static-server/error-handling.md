# Error Handling Specification

## ADDED Requirements

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