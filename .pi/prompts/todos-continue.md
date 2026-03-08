---
description: Continue working on a proposed change using a "TODO" markdown file
---

Manage the outline, define the tasks, and track task completion for for a piece of work via a single markdown file.

**Input**: The argument after `/todos-continue` is the change name (kebab-case), OR a description of what the user wants to build.

**Steps**

# 1. If no input provided, ask what they want to build

Use the **AskUserQuestion tool** (open-ended, no preset options) to ask:
> "What change do you want to work on? Describe what you want to build or fix."

From their description, derive a file-safe, kebab-case name (e.g., "add user authentication" → `add-user-auth`).

**IMPORTANT**: Do NOT proceed without understanding what the user wants to build.

**IMPORTANT**: In the following steps, the kebab-case name will be referred to as `<name>`.

# 2. Find or create the change file to track the change

The file should be called: `TODOS.<name>.md` (with `<name>` replace as above)

If that file already exists, that's the context file for the current piece of work you're collaborating on.

If that file doesn't exist, create it: `touch "TODOS.<name>.md"`

**IMPORTANT**: In the following steps, this file path will be referred to as `<todos>`.

# 3. Collaborate with the user in the file

Tell the user about the file, `<todos>`.

Treat the file as your memory for anything interesting about this proposed work.  For example (but not limited to):

- intended change
- design changes
- tasks to implement this change (as `- [ ] ...` markdown checklist)
- progress on tasks (`- [x] ...` ticked off tasks)
