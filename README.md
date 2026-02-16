# Gemini Toy Server

A toy implementation of the [Gemini protocol](https://gemini.circumlunar.space/) server written in GNU Guile (Scheme). This project was created to better understand the Gemini protocol, not to build a production server.

## What is Gemini?

Gemini is a lightweight internet protocol designed to be simpler than HTTP while more feature-rich than Gopher. It uses TLS encryption by default and serves text-based content using a simple markup format.

## Security Considerations

⚠️ **Warning: This is a toy implementation!**

- Not intended for production use
- May have security vulnerabilities
- Self-signed certificates are not trusted by default
- No user authentication or access controls

## Make Commands

Use these simple commands to work with the project:

| Command | Description |
|---------|-------------|
| `make setup` | Install dependencies and initialize the project |
| `make run` | Start the development server (port 1965) |
| `make test` | Run all tests (unit, acceptance) |
| `make clean` | Remove build artifacts and logs |
| `make devenv` | Run devenv |

## Project Structure

```
gemini-toy/
├── doc/                     # Documentation
│   ├── adr/                 # Architecture Decision Records
│   └── TESTING.md           # Detailed testing guide
├── openspec/                # OpenSpec format specs
├── src/                     # Application source code
│   └── server/              # Server implementation
│       ├── src/             # Core server modules (server.scm, etc.)
│       ├── tests/           # Unit tests
│       └── certs/           # TLS certificates
├── test/                    # Testing files and utilities
│   ├── acceptance-tests/    # Integration/acceptance tests
│   └── test-content/        # Test static files
├── scripts/                 # Utility and build scripts
├── Makefile                 # Project commands
└── Dockerfile.dev           # Development container
```

## Running the Server

### Prerequisites

- GNU Guile (version 3.0 or later recommended)
- GnuTLS development libraries
- OpenSSL (for certificate generation)

### Using Make (Recommended)

```bash
make run
```

### Using the Script Directly

```bash
bash scripts/start-server.sh --help
bash scripts/start-server.sh                          # Default: port 1965
bash scripts/start-server.sh -p 1966 -d static       # Custom port and directory
bash scripts/start-server.sh --verbose               # Verbose output
```

### Manual Start (Advanced)

```bash
cd src/server
GUILE_LOAD_PATH=src guile src/gemini/server.scm -d ../../test/test-content
```

## Server Options

| Option | Short | Default | Description |
|--------|-------|---------|-------------|
| `--port` | `-p` | `1965` | Port to listen on |
| `--static-dir` | `-d` | `./static` | Directory to serve static files from |
| `--cert` | `-c` | `src/server/certs/cert.pem` | TLS certificate file |
| `--key` | `-k` | `src/server/certs/key.pem` | TLS private key file |
| `--help` | `-h` | - | Show help message |
| `--verbose` | `-v` | - | Enable verbose output |

## Documentation

This project maintains comprehensive documentation:

- **[TESTING.md](doc/TESTING.md)** - Testing guide with test organization and procedures
- **[Architecture Decision Records](doc/adr/)** - Design decisions and rationale for the project
- **[MIGRATION.md](doc/MIGRATION.md)** - Project evolution and migration notes

## Running Tests

### Using Make

```bash
make test           # Run all tests
make clean          # Clean up test artifacts
```

### Using Scripts Directly

```bash
bash scripts/run-all-tests.sh        # Complete test suite (recommended)
bash scripts/run-unit-tests.sh       # Unit tests only (fast)
bash scripts/run-acceptance-tests.sh # Integration tests only
bash scripts/test-quick.sh           # Quick smoke test
```

**Test Coverage:**
- ✅ **Unit Tests**: Tests covering protocol parsing, validation, MIME types, file handling
- ✅ **Acceptance Tests**: Black-box testing with real TLS connections
- ✅ **Security Tests**: Path traversal prevention, request validation, error handling
- ✅ **Protocol Compliance**: Full Gemini specification compliance verification

## Testing Your Server

Once the server is running, you can test it using:

1. **Gemini clients:**
   - Lagrange (graphical client)
   - Amfora (terminal client)
   - Telescope (terminal client)

2. **Command line tools:**
   ```bash
   # Using openssl s_client
   echo "gemini://localhost/" | openssl s_client -connect localhost:1965 -servername localhost -quiet

   # Using curl (if built with Gemini support)
   curl --proto '=gemini' gemini://localhost/
   ```

## Content Structure

The server serves static files from the specified directory. Common file types:

- `.gmi` or `.gemini` - Gemini markup files
- `.txt` - Plain text files
- Images, PDFs, and other binary files

Example content structure:
```
static/
├── index.gmi          # Homepage
├── about.gmi          # About page
├── blog/
│   ├── index.gmi      # Blog index
│   └── post1.gmi      # Blog post
└── files/
    └── document.pdf   # Binary file
```

## Development

### Using Docker

Run an interactive session:
```bash
make dev
```

This mounts the entire project into the container for development.

### TLS Certificate Management

The server will automatically generate self-signed certificates if none are found:

```bash
# Use custom certificate files
bash scripts/start-server.sh -c /path/to/cert.pem -k /path/to/key.pem
```

## Resources

- [Gemini Protocol Specification](https://gemini.circumlunar.space/docs/specification.gmi)
- [Gemini Software List](https://gemini.circumlunar.space/software/)
- [GNU Guile Documentation](https://www.gnu.org/software/guile/manual/)
- [GnuTLS Documentation](https://gnutls.org/manual/)
