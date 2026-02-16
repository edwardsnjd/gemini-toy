## Context

Current specs (`developer-onboarding` and `project-directory-structure`) prescribe specific implementation details: directory names (`docs/`, `src/`, `test/`), make command names (`make setup`, `make test`, `make help`, etc.), file locations, and root-level files. These details become outdated as projects evolve and cause unnecessary spec violations when structure changes for legitimate reasons.

The `gemini-static-server` spec is already outcome-focused and requires no changes—it specifies *what* the server does, not *how* to build it.

## Goals / Non-Goals

**Goals:**
- Replace implementation-detail specs with outcome-focused requirements
- Allow project structure to evolve without violating specs
- Reduce spec maintenance burden by removing prescriptive details
- Preserve ability to guide new developers (via README, not specs)

**Non-Goals:**
- Create formal conventions documentation (that's future work)
- Change the `gemini-static-server` spec (it's already correct)
- Deprecate OpenSpec or the spec-driven workflow
- Remove all guidance (README and other docs still provide structure guidance)

## Decisions

**Decision 1: Remove old specs from active use**
- Rationale: Prevents conflicting requirements; allows clean transition to new spec
- Implementation: How to remove (archive, delete, move to backup) is a team choice, not a spec concern

**Decision 2: Create single replacement spec (`project-development-workflow`) instead of multiple**
- Rationale: Both old specs shared the same problem (over-prescription); consolidating them simplifies structure
- Alternative: Keep separate specs but make them abstract (more complexity, less cohesion)

**Decision 3: Make requirements very abstract (no specific command names, directory names)**
- Rationale: Maximum flexibility; focuses on outcomes that actually matter (setup works, tests run, structure is clear)
- Alternative: Keep some specifics (less flexible but more guidance for new developers—but that belongs in README, not specs)

**Decision 4: Focus on three core outcomes**
- Setup automation must exist (projects must have a way to initialize)
- Tests must be discoverable and runnable (outcomes matter more than location)
- Project structure must be self-documenting (via README and directory layout)
- Rationale: These capture the essential requirements; everything else is implementation choice

## Risks / Trade-offs

**[Risk] Developers may be less guided without prescriptive details**
- Mitigation: README should clearly document actual structure and how to run things (this is separate work but important)

**[Risk] Specs become harder to verify (more subjective)**
- Mitigation: Scenarios still give concrete criteria (e.g., "tests can be executed" is verifiable even if command name isn't specified)

**[Trade-off] We're moving guidance responsibility from specs to README/docs**
- Accepted: Specs should guide *what matters*, not prescribe implementation; that's better separation of concerns
