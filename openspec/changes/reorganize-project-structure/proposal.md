## Why

The project root is cluttered with many top-level directories and files (scripts, tests, documentation, source code all mixed together), making it difficult for new developers to understand the project structure at a glance. A clear, organized directory structure with a comprehensive README and simple make commands will significantly improve developer onboarding and maintainability.

## What Changes

- Reorganize top-level directories into logical groups: `src/` for application code, `test/` for all testing, `docs/` for documentation, `scripts/` for utilities
- Create a comprehensive README with project overview, quick-start guide, and make command reference
- Establish simple `make` commands for common tasks (setup, run, test, build, clean)
- Archive or remove test/demo files that clutter the root (error testing files, test scripts, demo scripts)
- Move server-related code into organized subdirectories

## Capabilities

### New Capabilities
- `project-directory-structure`: Clear, semantic top-level directory organization with appropriate subdirectories for code, tests, documentation, and scripts
- `developer-onboarding`: Comprehensive README and make-based commands for quick project setup and common workflows

### Modified Capabilities
<!-- None - this is a structural reorganization without changing core functionality -->

## Impact

- **Code locations**: Source code moves from root and scattered directories into `src/`
- **Test locations**: All test files and test scripts consolidate into `test/`
- **Documentation**: Documentation files move into `docs/`
- **Build/Run**: Make commands become the primary interface for developers
- **Onboarding**: New developers can read one README and run `make setup` to get started
- **No functional changes**: All code functionality remains identical; this is purely structural
