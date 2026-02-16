## Context

The gemini-toy project has grown with files scattered across the root directory. Currently:
- Source code is in `server/` but also has root-level files
- Test/demo files are mixed with documentation at the root
- Build artifacts and logs clutter the workspace
- No clear make-based workflow exists for common operations
- New developers cannot immediately understand project structure from the root directory

## Goals / Non-Goals

**Goals:**
- Establish a standard directory layout following common conventions (src, test, docs, scripts)
- Create a README with onboarding instructions and make command reference
- Implement a Makefile with targets for: setup, run, test, build, clean, help
- Move all test/demo files into organized test directory
- Move documentation into docs directory
- Move utility scripts into scripts directory
- Enable new developers to be productive with minimal setup (ideally: clone → make setup → make run)

**Non-Goals:**
- Refactoring code functionality or internal organization within modules
- Changing build tools, test frameworks, or development dependencies
- Rewriting tests or documentation content (only reorganizing)
- Supporting multiple simultaneous directory structures during transition

## Decisions

1. **Directory Structure** → Use conventional layout:
   - `src/` - Main application code (currently `server/` will move here; root scripts consolidated)
   - `test/` - All testing files, test data, test scripts, acceptance tests
   - `docs/` - All documentation (README, TESTING guide, API docs, architecture)
   - `scripts/` - Utility scripts (demo, error testing, helpers)
   - `static/` and `test-content/` - Keep as-is (test/demo data)
   - `.opencode/` - Keep as-is (opencode artifacts)
   - `.git/` - Keep as-is
   
   *Rationale:* Follows Go/Python/JS conventions; developers immediately recognize structure; tools and IDEs understand it.

2. **Makefile Targets** → Implement core commands:
   - `make setup` - Install dependencies, initialize project
   - `make run` - Start the development server
   - `make test` - Run all tests
   - `make build` - Build artifacts (if applicable)
   - `make clean` - Clean build artifacts and test outputs
   - `make help` - Show available commands
   
   *Rationale:* Simple, discoverable interface; single command for common tasks; no shell knowledge required; works across platforms.

3. **README Structure** → Include sections:
   - Project overview and purpose
   - Prerequisites and dependencies
   - Quick-start (setup → run)
   - Make commands reference
   - Project structure explanation
   - Contributing guidelines (link to existing docs if any)
   
   *Rationale:* Optimizes for new developer experience; minimal friction to first successful run.

4. **Migration Strategy** → Incremental move:
   - Create new directory structure
   - Move files with git mv to preserve history
   - Update relative paths in moved files
   - Create Makefile and README
   - Update CI/CD or run scripts to reference new paths
   - Archive/remove clutter files after verification
   
   *Rationale:* Preserves git history; reduces risk of missing dependencies; allows rollback if needed.

## Risks / Trade-offs

| Risk | Mitigation |
|------|-----------|
| Breaking relative paths in scripts | Audit all scripts before moving; update paths; test execution in new structure |
| CI/CD pipelines fail after move | Test new paths in CI/CD environment before committing changes |
| Git history becomes harder to trace across renames | Document the migration; git mv preserves most history; accept minor history disruption |
| Developers have old clones with conflicts | Include migration instructions in README; this is a one-time structural change |

**Trade-offs:**
- **Simplicity vs. Flexibility**: Conventional structure is rigid but clear. Custom structure would be more flexible but confusing for new developers. → Choose convention.
- **Big bang vs. Gradual**: Moving everything at once is disruptive but clean; gradual migration is safer but messy. → Choose incremental but fast.
