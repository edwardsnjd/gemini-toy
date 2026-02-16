#!/usr/bin/env bash

# Run a container for the development environment
# building the image if required.

set -e

SCRIPT_DIR="$(dirname "$0")"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_ROOT"

echo "📦 Development environment"
echo "=========================="
echo

echo "Running development container..."
podman run --rm -ti -v $PWD:$PWD -w $PWD gemini-toy-dev
