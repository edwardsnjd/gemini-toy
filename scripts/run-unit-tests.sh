#!/bin/bash
#
# Run Unit Tests for Gemini Server
#
# This script runs all unit tests for the Gemini server implementation.
# Tests cover protocol parsing, request validation, response formatting,
# CLI argument parsing, MIME type detection, file handling, and TLS configuration.
#

# Get the project root (parent of scripts directory)
SCRIPT_DIR="$(dirname "$0")"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_ROOT"

echo "🧪 Running Gemini Server Unit Tests..."
echo "========================================"

cd src/server

# Capture output to check for failures
OUTPUT=$(GUILE_LOAD_PATH=src:tests guile tests/run-unit-tests.scm 2>&1)
EXIT_CODE=$?

# Display the output
echo "$OUTPUT"

# Check for unexpected failures in output
if echo "$OUTPUT" | grep -q "# of unexpected failures: [1-9]"; then
    echo
    echo "❌ Unit tests FAILED"
    exit 1
fi

# Check for test errors in output
if echo "$OUTPUT" | grep -q "# of unexpected errors: [1-9]"; then
    echo
    echo "❌ Unit tests FAILED"
    exit 1
fi

echo
echo "✅ Unit tests completed!"
exit 0