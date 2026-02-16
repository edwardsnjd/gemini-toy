#!/bin/bash
#
# Start Gemini Server
#
# Convenient script to start the Gemini server with proper configuration.
# Handles module loading, checks prerequisites, and provides helpful output.
#

set -e

# Get the project root (parent of scripts directory)
SCRIPT_DIR="$(dirname "$0")"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_ROOT"

# Default configuration
DEFAULT_PORT=1965
DEFAULT_STATIC_DIR="static"
DEFAULT_CERT="src/server/certs/cert.pem"
DEFAULT_KEY="src/server/certs/key.pem"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Parse command line arguments
PORT=$DEFAULT_PORT
STATIC_DIR=$DEFAULT_STATIC_DIR
CERT_FILE=$DEFAULT_CERT
KEY_FILE=$DEFAULT_KEY
VERBOSE=false

show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo
    echo "Start the Gemini static file server"
    echo
    echo "Options:"
    echo "  -p, --port PORT        Port to listen on (default: $DEFAULT_PORT)"
    echo "  -d, --dir DIR          Static files directory (default: $DEFAULT_STATIC_DIR)"
    echo "  -c, --cert FILE        TLS certificate file (default: $DEFAULT_CERT)"
    echo "  -k, --key FILE         TLS private key file (default: $DEFAULT_KEY)"
    echo "  -v, --verbose          Enable verbose output"
    echo "  -h, --help             Show this help"
    echo
    echo "Examples:"
    echo "  $0                                    # Start with defaults"
    echo "  $0 -p 1965 -d static                # Specify port and directory"
    echo "  $0 --verbose                         # Start with verbose logging"
    echo
    echo "The server will:"
    echo "  • Generate self-signed certificates if none exist"
    echo "  • Serve files from the static directory"
    echo "  • Use TLS encryption (required by Gemini protocol)"
    echo "  • Log requests and responses"
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -p|--port)
            PORT="$2"
            shift 2
            ;;
        -d|--dir)
            STATIC_DIR="$2"
            shift 2
            ;;
        -c|--cert)
            CERT_FILE="$2"
            shift 2
            ;;
        -k|--key)
            KEY_FILE="$2"
            shift 2
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        *)
            echo -e "${RED}❌ Unknown option: $1${NC}"
            echo
            show_usage
            exit 1
            ;;
    esac
done

echo -e "${BLUE}🚀 Starting Gemini Server${NC}"
echo "=========================="

# Check prerequisites
echo "🔍 Checking prerequisites..."

if ! command -v guile &> /dev/null; then
    echo -e "${RED}❌ Error: GNU Guile is not installed${NC}"
    echo "   Install with: apt-get install guile-3.0"
    exit 1
fi

if [ ! -d "src/server" ]; then
    echo -e "${RED}❌ Error: src/server directory not found${NC}"
    echo "   Run this script from the gemini-toy project root"
    exit 1
fi

if [ ! -d "$STATIC_DIR" ]; then
    echo -e "${YELLOW}⚠️  Warning: Static directory '$STATIC_DIR' not found${NC}"
    echo "   Creating directory with sample content..."
    mkdir -p "$STATIC_DIR"
    echo "# Welcome to Gemini!

This is a test page served by the gemini-toy server.

## Test Links
=> test.txt Plain text file
=> missing.txt Test 404 handling

Built with GNU Guile Scheme." > "$STATIC_DIR/index.gmi"
    echo "This is a plain text test file." > "$STATIC_DIR/test.txt"
    echo -e "${GREEN}✅ Created sample static content${NC}"
fi

echo -e "${GREEN}✅ Prerequisites satisfied${NC}"
echo

# Display configuration
echo -e "${BLUE}📋 Server Configuration${NC}"
echo "======================="
echo "Port:        $PORT"
echo "Static dir:  $STATIC_DIR"
echo "Certificate: $CERT_FILE"
echo "Private key: $KEY_FILE"
echo "Verbose:     $VERBOSE"
echo

# Start server
echo -e "${BLUE}🌐 Starting server...${NC}"
echo "===================="

cd "$PROJECT_ROOT/src/server"

if [ "$VERBOSE" = true ]; then
    echo -e "${YELLOW}💡 Starting in verbose mode (Ctrl+C to stop)${NC}"
    echo
    GUILE_LOAD_PATH=src guile src/gemini/server.scm -p "$PORT" -d "../../$STATIC_DIR" -c "certs/cert.pem" -k "certs/key.pem"
else
    echo -e "${YELLOW}💡 Starting server (Ctrl+C to stop)${NC}"
    echo -e "${YELLOW}   For verbose output, use: $0 --verbose${NC}"
    echo -e "${YELLOW}   Server log: src/server/server.log${NC}"
    echo
    
    # Start server and capture PID for clean shutdown
    GUILE_LOAD_PATH=src guile src/gemini/server.scm -p "$PORT" -d "../../$STATIC_DIR" -c "certs/cert.pem" -k "certs/key.pem" &
    SERVER_PID=$!
    
    echo -e "${GREEN}✅ Server started with PID $SERVER_PID${NC}"
    echo
    echo -e "${BLUE}🔗 Test the server:${NC}"
    echo "   echo 'gemini://localhost:$PORT/' | openssl s_client -connect localhost:$PORT -servername localhost -quiet"
    echo
    echo -e "${BLUE}💡 Useful commands:${NC}"
    echo "   • View logs:     tail -f src/server/server.log"
    echo "   • Stop server:   kill $SERVER_PID"
    echo "   • Run tests:     make test"
    
    # Wait for server process
    wait $SERVER_PID
fi