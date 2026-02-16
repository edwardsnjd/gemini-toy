.PHONY: help setup run test build clean build-container dev

help:
	@echo "gemini-toy - Project Commands"
	@echo ""
	@echo "Available commands:"
	@echo "  make setup          - Install dependencies and initialize the project"
	@echo "  make run            - Start the development server"
	@echo "  make test           - Run all tests (unit, acceptance)"
	@echo "  make build          - Build Docker container"
	@echo "  make clean          - Remove build artifacts and test outputs"
	@echo "  make build-container - Build the development container (alias for 'make build')"
	@echo "  make dev            - Run container interactively with project mounted"
	@echo "  make help           - Show this help message"
	@echo ""

setup:
	@echo "Setting up gemini-toy project..."
	@command -v guile >/dev/null 2>&1 || (echo "ERROR: GNU Guile is not installed. Install with: apt-get install guile-3.0" && exit 1)
	@command -v node >/dev/null 2>&1 || (echo "ERROR: Node.js is not installed. Install from https://nodejs.org" && exit 1)
	@echo "✓ Dependencies verified"
	@echo "✓ Project initialized"

run:
	@echo "Starting development server..."
	@bash scripts/start-server.sh

test:
	@echo "Running all tests..."
	@if [ -f "scripts/run-all-tests.sh" ]; then \
		bash scripts/run-all-tests.sh; \
	else \
		echo "No test runner found. Looking for test files..."; \
		if [ -d "test/acceptance-tests" ]; then \
			echo "Found acceptance tests in test/acceptance-tests"; \
			cd test/acceptance-tests && for test in *.sh; do [ -f "$$test" ] && bash "$$test"; done; \
		else \
			echo "No tests found"; \
		fi; \
	fi

build: build-container

build-container:
	@echo "Building Docker development container..."
	@podman build --tag gemini-toy-dev --file Dockerfile.dev .
	@echo "✓ Container built successfully"

clean:
	@echo "Cleaning build artifacts and test outputs..."
	@rm -f simple-server.log
	@rm -f src/server/server.log
	@rm -rf build/
	@rm -rf dist/
	@find . -name "*.log" -type f -delete
	@find . -name ".cache" -type d -prune -exec rm -rf {} \; 2>/dev/null || true
	@echo "✓ Cleanup complete"

dev:
	@echo "Running development container..."
	@podman run --rm -ti -v $$PWD:$$PWD -w $$PWD gemini-toy-dev

.DEFAULT_GOAL := help
