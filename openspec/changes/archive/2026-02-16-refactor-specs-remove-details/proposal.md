## Why

Current specs prescribe too many implementation details (specific directory names, make command names, file locations) that lock the project into a rigid structure. When the project evolves, these implementation choices become spec violations instead of simply reflecting reality. Specs should focus on outcomes and constraints that matter, not how to achieve them.

## What Changes

- Archive `developer-onboarding` and `project-directory-structure` specs
- Create new `project-development-workflow` spec focused on outcomes only
- New spec specifies: setup must be automated, tests must be runnable, structure must be self-documenting
- Removes prescriptions about: specific make command names, directory names, file locations, root-level files

## Capabilities

### New Capabilities
- `project-development-workflow`: Outcome-focused requirements for development automation, test discoverability, and self-documenting project structure

### Modified Capabilities
<!-- No existing capability requirements are changing - we're replacing prescriptive specs with abstract ones, not changing behavior requirements -->

## Impact

- Specs become less prescriptive and more flexible
- Project structure can evolve without violating specs
- Reduces spec maintenance burden (fewer details to keep current)
- Old specs moved to archive for historical reference if needed
