## 1. Directory Structure Setup

- [x] 1.1 Create `src/` directory
- [x] 1.2 Create `src/server/` directory structure
- [x] 1.3 Create `test/` directory
- [x] 1.4 Create `test/acceptance-tests/` directory
- [x] 1.5 Create `docs/` directory
- [x] 1.6 Create `scripts/` directory

## 2. Move Source Code

- [x] 2.1 Move `server/` contents to `src/server/` using git mv (preserving history)
- [x] 2.2 Move utility scripts from root to `scripts/` (e.g., simple-gemini-test-server.py, start-server.sh)
- [x] 2.3 Update relative paths in moved scripts to reflect new locations

## 3. Move Test Files and Utilities

- [x] 3.1 Move `acceptance-tests/` contents to `test/acceptance-tests/` using git mv
- [x] 3.2 Move test/demo scripts to `scripts/` (comprehensive-error-tests.sh, demonstrate-error-testing.sh, manual-error-tests.sh, run-acceptance-tests.sh, run-all-tests.sh, run-unit-tests.sh, etc.)
- [x] 3.3 Move `test-content/` to `test/test-content/` using git mv
- [x] 3.4 Update paths in moved test scripts

## 4. Move Documentation

- [x] 4.1 Create docs structure (docs/guides/, docs/reference/, etc. as appropriate)
- [x] 4.2 Move TESTING.md to docs/TESTING.md
- [x] 4.3 Move error testing documentation (ERROR_TESTING_SUMMARY.md, GEMINI_ERROR_TESTING_RESULTS.md) to docs/ if keeping, or mark for archive

## 5. Create Makefile

- [x] 5.1 Create Makefile at project root with `setup`, `run`, `test`, `build`, `clean`, `help` targets
- [x] 5.2 Implement `make setup` target (install dependencies, initialize project)
- [x] 5.3 Implement `make run` target (start development server)
- [x] 5.4 Implement `make test` target (run all tests)
- [x] 5.5 Implement `make build` target (if applicable; create necessary build artifacts)
- [x] 5.6 Implement `make clean` target (remove build artifacts, logs, and test outputs)
- [x] 5.7 Implement `make help` target (list all targets with descriptions)
- [x] 5.8 Test all make targets to ensure they work correctly

## 6. Create/Update README

- [x] 6.1 Create comprehensive README with project overview
- [x] 6.2 Add "Prerequisites" section with dependencies and versions
- [x] 6.3 Add "Quick Start" section with setup and run instructions
- [x] 6.4 Add "Make Commands" reference section with all available targets
- [x] 6.5 Add "Project Structure" section explaining each top-level directory
- [x] 6.6 Add "Contributing" section (link to existing guidelines if any)
- [x] 6.7 Verify README renders correctly on GitHub

## 7. Update Build/Run Paths

- [x] 7.1 Audit Dockerfile.dev and update paths if needed
- [x] 7.2 Audit any CI/CD configuration files and update paths (GitHub Actions, etc.)
- [x] 7.3 Update any environment variables or configuration that reference old paths
- [x] 7.4 Test that container builds still work with new structure

## 8. Cleanup and Finalization

- [x] 8.1 Remove or archive root-level test/demo files that have been moved
- [x] 8.2 Archive old error testing results if not needed in docs/
- [x] 8.3 Verify no critical files are left at root (should only have src/, test/, docs/, scripts/, and config files)
- [x] 8.4 Clean up any leftover `simple-server.log` or build artifacts
- [x] 8.5 Run full test suite to verify nothing is broken after reorganization
- [x] 8.6 Document any breaking changes for developers with old clones

## 9. Verification

- [x] 9.1 Verify `make setup` initializes project correctly
- [x] 9.2 Verify `make run` starts server successfully
- [x] 9.3 Verify `make test` runs all tests and reports results
- [x] 9.4 Verify `make clean` removes build artifacts without affecting source code
- [x] 9.5 Verify all file paths in source code resolve correctly
- [x] 9.6 Verify git history is preserved for moved files
