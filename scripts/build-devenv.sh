#!/usr/bin/env bash

# Build image for the dev environment.

set -e

SCRIPT_DIR="$(dirname "$0")"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_ROOT"

echo "📦 Development environment"
echo "=========================="
echo

echo "Building image..."
podman build --tag gemini-toy-dev --file Dockerfile.dev .
echo "✅ Image built successfully"
