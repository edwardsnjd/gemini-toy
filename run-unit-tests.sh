#!/bin/bash
#
# Run Unit Tests for Gemini Server
#
# This script runs all unit tests for the Gemini server implementation.
# Tests cover protocol parsing, request validation, response formatting,
# CLI argument parsing, MIME type detection, file handling, and TLS configuration.
#

set -e

cd "$(dirname "$0")"

echo "🧪 Running Gemini Server Unit Tests..."
echo "========================================"

# Check if Guile is available
if ! command -v guile &> /dev/null; then
    echo "❌ Error: GNU Guile is not installed or not in PATH"
    echo "   Install with: apt-get install guile-3.0"
    exit 1
fi

# Check if server directory exists
if [ ! -d "server" ]; then
    echo "❌ Error: server directory not found"
    echo "   Run this script from the gemini-toy project root"
    exit 1
fi

# Run the unit tests
echo "📂 Running from: $(pwd)"
echo "🔧 Using Guile: $(guile --version | head -1)"
echo

cd server
GUILE_LOAD_PATH=src:tests guile run-unit-tests.scm

echo
echo "✅ Unit tests completed!"
echo
echo "💡 Tips:"
echo "   • To run individual test modules: cd server && GUILE_LOAD_PATH=src:tests guile -c \"(use-modules (tests protocol-parser))\""
echo "   • To run with verbose output: remove '2>/dev/null' from the commands above"
echo "   • Test files are located in: server/tests/tests/"