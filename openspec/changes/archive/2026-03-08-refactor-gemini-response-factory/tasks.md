## Tasks for implementing consistent Gemini response definitions

- [x] **Add shared helper**
  - In `src/server/src/gemini/protocol.scm` add a `make-response` helper (as described in the design) and export it.

- [x] **Redefine response constants**
  - Update each `define response/...` to call `make-response` so that all constants are defined consistently.
  - Keep the public names unchanged; no deprecation warnings are required.

- [x] **Update documentation**
  - Revise the module docstring and README to explain that response constants are now built via `make-response`.

- [x] **Testing**
  - Run the existing test suite to confirm no behavioural changes.
  - (Optional) Add unit tests for `make-response` itself in a future change.

- [x] **CI / Review**
  - Run `run-unit-tests.scm` to ensure all tests pass.
  - Review code for style and consistency.

- [x] **Finalize**
  - Once implementation is complete, verify that all tasks are marked done and prepare for archiving the change.
