# Static File Serving Specification

## ADDED Requirements

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