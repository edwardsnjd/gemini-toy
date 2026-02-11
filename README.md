# Gemini Toy Server

A toy implementation of the [Gemini protocol](https://gemini.circumlunar.space/) server written in GNU Guile (Scheme). This project was created to better understand the Gemini protocol, not to build a production server.

## What is Gemini?

Gemini is a lightweight internet protocol designed to be simpler than HTTP while more feature-rich than Gopher. It uses TLS encryption by default and serves text-based content using a simple markup format.

## Project Structure

```
gemini-toy/
├── server/                 # Server implementation
│   ├── src/gemini/        # Core server modules
│   ├── tests/             # Unit tests
│   ├── certs/             # TLS certificates
│   └── run-unit-tests.scm # Unit test runner
├── acceptance-tests/      # Integration/acceptance tests
├── test-content/         # Test static files
├── static/              # Default static files directory
└── doc/                 # Additional documentation
```

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

### Running the Server

1. **Start with default settings:**
   ```bash
   cd server/src/gemini/
   guile server.scm
   ```

2. **Start with custom options:**
   ```bash
   guile server.scm -p 1966 -d ../../static -c certs/mycert.pem -k certs/mykey.pem
   ```

3. **View available options:**
   ```bash
   guile server.scm --help
   ```

## Command Line Options

| Option | Short | Default | Description |
|--------|-------|---------|-------------|
| `--port` | `-p` | `1965` | Port to listen on |
| `--static-dir` | `-d` | `./static` | Directory to serve static files from |
| `--cert` | `-c` | `server/certs/cert.pem` | TLS certificate file |
| `--key` | `-k` | `server/certs/key.pem` | TLS private key file |
| `--help` | `-h` | - | Show help message |
| `--version` | `-v` | - | Show version information |

## Usage Examples

### Basic Usage

```bash
# Start server on default port 1965
guile server.scm

# Start on port 1966
guile server.scm --port 1966

# Serve files from custom directory
guile server.scm --static-dir /path/to/my/content
```

### TLS Certificate Management

The server will automatically generate self-signed certificates if none are found:

```bash
# Use custom certificate files
guile server.scm --cert /path/to/cert.pem --key /path/to/key.pem
```

### Development Setup

```bash
# Navigate to server source
cd server/src/gemini/

# Start development server
guile server.scm --port 1966 --static-dir ../../../test-content
```

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