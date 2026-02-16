# Gemini Toy Server

A toy implementation of the [Gemini protocol](https://gemini.circumlunar.space/) server written in GNU Guile (Scheme). This project was created to better understand the Gemini protocol, not to build a production server.

## What is Gemini?

Gemini is a lightweight internet protocol designed to be simpler than HTTP while more feature-rich than Gopher. It uses TLS encryption by default and serves text-based content using a simple markup format.

## Quick Start

### Prerequisites

- GNU Guile (version 3.0 or later recommended)
- GnuTLS development libraries
- OpenSSL (for certificate generation)

On Ubuntu/Debian:
```bash
sudo apt-get install guile-3.0 guile-3.0-dev libgnutls28-dev openssl
```

On macOS with Homebrew:
```bash
brew install guile gnutls openssl
```

### Get Started in 2 Steps

1. **Initialize the project:**
   ```bash
   make setup
   ```

2. **Start the server:**
   ```bash
   make run
   ```

The server will start on port 1965. Visit `gemini://localhost:1965/` to test it!

## Make Commands

Use these simple commands to work with the project:

| Command | Description |
|---------|-------------|
| `make setup` | Install dependencies and initialize the project |
| `make run` | Start the development server (port 1965) |
| `make test` | Run all tests (unit, acceptance) |
| `make build` | Build the Docker development container |
| `make clean` | Remove build artifacts and logs |
| `make help` | Show all available commands |
| `make dev` | Run interactive development container |

## Project Structure

```
gemini-toy/
├── src/                     # Application source code
│   └── server/              # Server implementation
│       ├── src/gemini/      # Core server modules
│       ├── tests/           # Unit tests
│       ├── certs/           # TLS certificates
│       └── run-unit-tests.scm
├── test/                    # Testing files and utilities
│   ├── acceptance-tests/    # Integration/acceptance tests
│   └── test-content/        # Test static files
├── docs/                    # Documentation
│   ├── TESTING.md          # Detailed testing guide
│   ├── adr/                # Architecture Decision Records
│   │   └── 0001-record-architecture-decisions.md
│   └── MIGRATION.md        # Migration guide
├── scripts/                 # Utility and build scripts
│   ├── start-server.sh      # Start development server
│   ├── run-all-tests.sh     # Run complete test suite
│   └── [other utilities]
├── static/                  # Default static files served by server
├── Makefile                 # Project commands
├── Dockerfile.dev           # Development container
└── .opencode/              # OpenCode specification artifacts
```

## Running the Server

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
GUILE_LOAD_PATH=src guile src/gemini/server.scm -d ../../static
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

- **[TESTING.md](docs/TESTING.md)** - Testing guide with test organization and procedures
- **[Architecture Decision Records](docs/adr/)** - Design decisions and rationale for the project
- **[MIGRATION.md](docs/MIGRATION.md)** - Project evolution and migration notes

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
- ✅ **Unit Tests**: 28 tests covering protocol parsing, validation, MIME types, file handling
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

### TLS Certificate Management

The server will automatically generate self-signed certificates if none are found:

```bash
# Use custom certificate files
bash scripts/start-server.sh -c /path/to/cert.pem -k /path/to/key.pem
```

### Using Docker

Build the development container:
```bash
make build
```

Run an interactive session:
```bash
make dev
```

This mounts the entire project into the container for development.

## Security Considerations

⚠️ **Warning: This is a toy implementation!**

- Not intended for production use
- May have security vulnerabilities
- Self-signed certificates are not trusted by default
- No user authentication or access controls

For production use, consider established Gemini servers like:
- Agate
- Molly Brown
- Titan
- Jetforce

## Contributing

This project is primarily for educational purposes. However, if you find bugs or want to improve the implementation:

1. Check existing issues
2. Create a detailed bug report or feature request
3. Submit pull requests with clear descriptions

## License

This project is provided as-is for educational purposes. See the repository for any specific license terms.

## Resources

- [Gemini Protocol Specification](https://gemini.circumlunar.space/docs/specification.gmi)
- [Gemini Software List](https://gemini.circumlunar.space/software/)
- [GNU Guile Documentation](https://www.gnu.org/software/guile/manual/)
- [GnuTLS Documentation](https://gnutls.org/manual/)

## Support

For questions about the Gemini protocol itself, visit the [Gemini community](https://gemini.circumlunar.space/).

For issues with this specific implementation, please check the project's issue tracker or create a new issue with detailed information about your problem.
