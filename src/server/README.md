# Gemini Server Implementation

This directory contains the core implementation of the Gemini protocol server written in GNU Guile (Scheme).

## Architecture Overview

The server is designed with a modular architecture, separating concerns into distinct modules:

```
server/
├── src/
│   └── gemini/               # Core server modules
│       ├── server.scm        # Main entry point and socket handling
│       ├── protocol.scm      # Gemini protocol parsing and formatting
│       ├── file-handler.scm  # File system operations and content serving
│       ├── tls-config.scm    # TLS/SSL certificate management
│       └── mime-types.scm    # MIME type detection
├── tests/
│   ├── run-unit-tests.scm    # Test runner
│   └── tests/                # Unit test modules
└── certs/                    # TLS certificates directory
```

## Module Descriptions

### server.scm
**Main entry point and networking**

- Command line argument parsing and validation
- Socket creation and binding
- TLS session management
- Client connection handling
- Main server loop
- Request processing orchestration
- Logging functionality

Key functions:
- `main` - Entry point and CLI processing
- `server-loop` - Main accept loop
- `handle-client` - Per-client request processing
- `process-request` - Request routing and response generation

### protocol.scm
**Gemini protocol implementation**

- Request line parsing and validation
- URI parsing and normalization
- Response formatting
- Protocol compliance checking

Key functions:
- `parse-gemini-request` - Parse incoming request URIs
- `format-gemini-response` - Create properly formatted responses
- `validate-request` - Ensure request meets protocol requirements

### file-handler.scm
**File system operations**

- File path resolution and security
- Content reading and serving
- Directory traversal protection
- File existence and accessibility checks

Key functions:
- `resolve-file-path` - Safely resolve requested file paths
- `read-file-content` - Read file contents for serving
- Security features for preventing path traversal attacks

### tls-config.scm
**TLS certificate management**

- Certificate loading and validation
- TLS context setup
- Self-signed certificate generation
- GnuTLS configuration

Key functions:
- `setup-tls-context` - Initialize TLS credentials
- `generate-self-signed-cert` - Create certificates when needed

### mime-types.scm
**Content type detection**

- File extension to MIME type mapping
- Gemini-specific content types
- Default type handling

Key functions:
- `get-mime-type` - Determine MIME type from file extension

## Configuration Options

### Server Configuration

The server accepts several configuration parameters:

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `port` | integer | 1965 | TCP port to bind to |
| `static-dir` | string | "./static" | Root directory for static files |
| `cert` | string | "certs/cert.pem" | TLS certificate file path |
| `key` | string | "certs/key.pem" | TLS private key file path |

### Environment Requirements

- GNU Guile 3.0+ with GnuTLS bindings
- Read access to static content directory
- Read access to TLS certificate and key files
- Write access to certificate directory (for auto-generation)
- Network binding privileges for the specified port

## TLS Setup Instructions

### Automatic Certificate Generation

The server will automatically generate self-signed certificates if none are found:

```bash
# Certificates will be created in certs/
cd src
GUILE_LOAD_PATH=. guile gemini/server.scm
```

### Using Custom Certificates

#### Self-Signed Certificate

```bash
# Create certificate directory
mkdir -p certs

# Generate private key
openssl genrsa -out certs/key.pem 2048

# Generate self-signed certificate
openssl req -new -x509 -key certs/key.pem \
    -out certs/cert.pem -days 365 \
    -subj "/CN=localhost"
```

#### Certificate Authority Signed

```bash
# Generate private key
openssl genrsa -out certs/key.pem 2048

# Generate certificate signing request
openssl req -new -key certs/key.pem \
    -out certs/cert.csr \
    -subj "/CN=yourdomain.com"

# Submit CSR to your CA and save the certificate as:
# certs/cert.pem
```

#### Let's Encrypt Certificate

```bash
# Use certbot to obtain certificate
sudo certbot certonly --standalone -d yourdomain.com

# Copy certificates to server directory
cp /etc/letsencrypt/live/yourdomain.com/fullchain.pem certs/cert.pem
cp /etc/letsencrypt/live/yourdomain.com/privkey.pem certs/key.pem
```

### Certificate File Formats

- **Certificate file** (`.pem`): X.509 certificate in PEM format
- **Private key file** (`.pem`): RSA/ECDSA private key in PEM format
- Files must be readable by the server process
- Private key should have restricted permissions (600)

```bash
# Set proper permissions
chmod 600 certs/key.pem
chmod 644 certs/cert.pem
```

## Request Processing Flow

1. **Accept Connection**: Server accepts TCP connection on configured port
2. **TLS Handshake**: Establish encrypted TLS session
3. **Read Request**: Read single line request (max 1024 bytes)
4. **Validate Format**: Check request line format and length
5. **Parse URI**: Extract and validate Gemini URI
6. **Security Check**: Prevent path traversal attacks
7. **Resolve Path**: Map URI to filesystem path
8. **Read Content**: Load file content if accessible
9. **Determine Type**: Detect MIME type from extension
10. **Format Response**: Create Gemini protocol response
11. **Send Response**: Transmit response to client
12. **Close Connection**: Clean up TLS session and socket

## Error Handling

The server implements comprehensive error handling:

### Client Errors (5x codes)
- `59 Bad Request` - Invalid request format or URI
- `51 Not Found` - Requested resource doesn't exist

### Server Errors (4x codes)
- `40 Temporary Failure` - File system or internal errors

### Security Features

- **Path Traversal Protection**: Blocks `..` sequences in paths
- **Request Size Limits**: Maximum 1024 byte request lines
- **TLS Enforcement**: All connections must use TLS encryption
- **Safe File Access**: Validates file accessibility before serving

## Performance Characteristics

- **Single-threaded**: One request at a time
- **Memory Efficient**: Streams file content, doesn't cache
- **Connection Model**: One connection per request (as per Gemini spec)
- **TLS Overhead**: Handshake required for each connection

## Development and Debugging

### Running with Debug Output

```bash
# Enable verbose logging
cd src
guile --debug gemini/server.scm

# Run with custom log level
cd src
GUILE_WARN_DEPRECATED=detailed guile gemini/server.scm
```

### Module Testing

```bash
# Test individual modules (from src/server)
cd src
GUILE_LOAD_PATH=. guile -c "(use-modules (gemini protocol)) (display \"Module loaded successfully\")"
```

### Performance Monitoring

Monitor server performance:

```bash
# Check resource usage
top -p $(pgrep guile)

# Monitor network connections
netstat -tlnp | grep :1965

# Check TLS handshake performance
time (echo "gemini://localhost/" | openssl s_client -connect localhost:1965 -quiet)
```

## Common Issues

### Port Permission Errors
Ports below 1024 require root privileges:
```bash
cd src
sudo GUILE_LOAD_PATH=. guile gemini/server.scm --port 965
# or use a higher port
cd src
GUILE_LOAD_PATH=. guile gemini/server.scm --port 1966
```

### Certificate Errors
Check certificate file permissions and paths:
```bash
ls -la certs/
openssl x509 -in certs/cert.pem -text -noout
```

### Module Load Errors
Ensure Guile can find the modules (from src/server):
```bash
export GUILE_LOAD_PATH="$(pwd)/src:$GUILE_LOAD_PATH"
```

## Future Enhancements

Potential areas for improvement:
- Multi-threading support
- Connection pooling
- Request rate limiting
- Access logging
- Configuration file support
- CGI script support
- Virtual host support
