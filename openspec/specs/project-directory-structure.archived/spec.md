## ADDED Requirements

### Requirement: Project root contains only semantic directories
The project root SHALL contain only top-level directories with clear, semantic purposes. Utility scripts and test files SHALL NOT clutter the root.

#### Scenario: Root directory organization
- **WHEN** viewing the project root directory
- **THEN** only the following directories and essential files are visible: `.git/`, `.gitignore`, `.opencode/`, `src/`, `test/`, `docs/`, `scripts/`, `static/`, `test-content/`, `Makefile`, `README.md`, `LICENSE`, and `.github/` (if applicable)

### Requirement: Source code located in src/ directory
The project SHALL organize all source code within the `src/` directory, including the main server application and utilities.

#### Scenario: Server code in src/
- **WHEN** looking for the main application code
- **THEN** the server and related application code are located in `src/server/` or appropriate subdirectory

#### Scenario: Root scripts consolidated
- **WHEN** looking for application-level utilities or helper scripts
- **THEN** these scripts are in `src/` or `scripts/` directory, not in root

### Requirement: Test files organized in test/ directory
The project SHALL consolidate all testing artifacts, test data, test scripts, and acceptance tests within the `test/` directory.

#### Scenario: Unit and acceptance tests located together
- **WHEN** running tests or looking for test files
- **THEN** all test files and acceptance tests are found in `test/` and its subdirectories

#### Scenario: Test data isolated
- **WHEN** running tests
- **THEN** test data and test content is in `test/` or clearly marked test directories, not mixed with source code

### Requirement: Documentation organized in docs/ directory
The project SHALL move all documentation files into the `docs/` directory.

#### Scenario: Documentation discoverable
- **WHEN** seeking project documentation
- **THEN** README files, guides, testing documentation, and API docs are found in `docs/` directory or linked from root README

### Requirement: Utility scripts organized in scripts/ directory
The project SHALL organize build scripts, demo scripts, helper utilities, and other tools in a `scripts/` directory.

#### Scenario: Build and utility scripts organized
- **WHEN** looking for build, demo, or utility scripts
- **THEN** these scripts are located in `scripts/` directory, not scattered at root

### Requirement: Directory structure is discoverable
The project structure SHALL be intuitive and self-documenting for new developers.

#### Scenario: First-time developer understands structure
- **WHEN** a developer clones the project and views the root directory
- **THEN** they can immediately understand the project layout and find source code, tests, documentation, and scripts
