#!/bin/bash
#
# Clean Script for Gemini Toy Project
#
# Removes build artifacts, test outputs, and cache files
#

set -e

SCRIPT_DIR="$(dirname "$0")"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_ROOT"

echo "🧹 Cleaning build artifacts and test outputs..."
echo "==============================================="
echo

# Remove log files
echo "  Removing log files..."
rm -f simple-server.log
rm -f src/server/server.log

# Remove build directories
echo "  Removing build directories..."
rm -rf build/
rm -rf dist/

# Remove all .log files
find . -name "*.log" -type f -delete

# Remove Guile cache
echo "  Clearing Guile cache..."
find ~/.cache/guile -type f -delete 2>/dev/null || true

# Remove other cache directories
find . -type d -name ".cache" -prune -exec rm -rf {} \; 2>/dev/null || true
find . -type d -name "__pycache__" -prune -exec rm -rf {} \; 2>/dev/null || true

echo
echo "✅ Cleanup complete"
