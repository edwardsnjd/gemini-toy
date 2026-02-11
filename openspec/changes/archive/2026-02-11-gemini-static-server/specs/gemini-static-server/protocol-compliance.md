# Protocol Compliance Specification

## ADDED Requirements

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