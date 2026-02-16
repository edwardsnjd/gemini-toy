# Project Reorganization - Migration Guide

## Overview

The gemini-toy project has been reorganized to improve developer experience and maintainability. This document explains the changes and how to update your workflow if you have an existing clone of the project.

## What Changed

The project root has been reorganized into semantic directories:

### Old Structure → New Structure

| Old Path | New Path | Notes |
|----------|----------|-------|
| `server/` | `src/server/` | Main application code |
| `acceptance-tests/` | `test/acceptance-tests/` | Integration tests |
| `test-content/` | `test/test-content/` | Test data |
| `*.sh` scripts | `scripts/` | Utility and test scripts |
| Root documentation | `docs/` | All documentation centralized |
| `doc/` | `docs/doc_old/` | Legacy documentation archived |

### New Top-Level Files

- **Makefile** - Simplified commands (`make run`, `make test`, etc.)
- **Updated README.md** - References new commands and structure

## Updating Your Existing Clone

If you already have the project cloned, follow these steps:

### Option 1: Start Fresh (Recommended)

```bash
# Backup your work if needed
cp -r gemini-toy gemini-toy.backup

# Remove and re-clone
rm -rf gemini-toy
git clone https://github.com/[repository]/gemini-toy.git
cd gemini-toy
make setup
make run
```

### Option 2: Stash Changes and Pull

```bash
cd gemini-toy
git stash                 # Save any uncommitted work
git pull origin main      # Get latest structure
make setup
make run
```

### Option 3: Manual Update

If you have ongoing work:

```bash
cd gemini-toy
git fetch origin
git merge origin/main     # This will move files according to git's tracking

# Update any relative paths in your working scripts/code:
# Replace: server/ → src/server/
# Replace: acceptance-tests/ → test/acceptance-tests/
# Replace: test-content/ → test/test-content/
```

## Path Changes for Scripts

If you've written custom scripts that reference the old paths, update them:

### Common Replacements

```bash
# Old                      # New
server/                    src/server/
acceptance-tests/          test/acceptance-tests/
test-content/             test/test-content/
./run-all-tests.sh        bash scripts/run-all-tests.sh
./start-server.sh         bash scripts/start-server.sh
```

### Shell Script Example

**Before:**
```bash
cd server
GUILE_LOAD_PATH=src guile src/gemini/server.scm
```

**After:**
```bash
cd src/server
GUILE_LOAD_PATH=src guile src/gemini/server.scm
```

## New Recommended Commands

Instead of using individual shell scripts, use the simplified Makefile commands:

| Old Way | New Way | Benefit |
|---------|---------|---------|
| `./start-server.sh` | `make run` | Shorter, more discoverable |
| `./run-all-tests.sh` | `make test` | Standard interface |
| `./help.sh` | `make help` | Built-in command |
| (Manual setup) | `make setup` | Automated initialization |

## Git History

All file moves used `git mv` to preserve history. You can still view the complete history:

```bash
git log -p --follow src/server/README.md  # View history of a moved file
git log --oneline -- server/              # See commits before the move
```

## Troubleshooting

### Tests fail with "server directory not found"

You're probably running an old test script. Update paths:

```bash
# Instead of: ./run-unit-tests.sh
bash scripts/run-unit-tests.sh
# Or use: make test
```

### Build fails with path errors

Check for hardcoded `server/` paths in your build configuration. Update to `src/server/`.

### Docker container won't start

The Dockerfile.dev hasn't changed, but ensure you rebuild:

```bash
make build-container
# Or: docker build -t gemini-toy-dev -f Dockerfile.dev .
```

## Support

If you encounter issues:

1. Check this guide first
2. Verify your paths are updated correctly
3. Try a fresh clone if problems persist
4. Report issues with details in the project issue tracker

## Benefits of the New Structure

- **Clarity**: Obvious where code, tests, and docs are located
- **Standards**: Follows conventional project layout
- **Simplicity**: One-command setup with `make setup`
- **Discoverability**: `make help` shows all available commands
- **Onboarding**: New developers don't need to ask where things are
