#!/bin/bash
#
# Setup Script for Gemini Toy Project
#
# Verifies and initializes dependencies
#

set -e

SCRIPT_DIR="$(dirname "$0")"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_ROOT"

echo "🔧 Setting up gemini-toy project..."
echo "===================================="
echo

# Check for required tools
echo "🔍 Checking dependencies..."

if ! command -v guile &> /dev/null; then
    echo "❌ ERROR: GNU Guile is not installed"
    echo "   Install with: apt-get install guile-3.0"
    exit 1
fi
echo "✓ GNU Guile found: $(guile --version | head -1)"

if ! command -v openssl &> /dev/null; then
    echo "❌ ERROR: OpenSSL is not installed"
    echo "   Install with: apt-get install openssl"
    exit 1
fi
echo "✓ OpenSSL found"

if ! command -v podman &> /dev/null; then
    echo "⚠️  WARNING: Podman is not installed (only needed for container commands)"
fi

echo
echo "✅ Setup complete! Project is ready to use."
echo
echo "📝 Next steps:"
echo "  • make run       - Start the development server"
echo "  • make test      - Run all tests"
echo "  • make clean     - Clean up build artifacts"
