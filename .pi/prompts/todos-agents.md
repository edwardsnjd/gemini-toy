---
description: Manage sub-agents collaborating on the current work.
---

Delegate tasks to sub-agents then coordinate purpose, notes, and tasks with them via the single markdown file.

# Input

The argument after `/todos-agents` is the change name (kebab-case), OR a description of what the user wants to build.

# Steps

**1. Determine what the work entails**

From their input, derive a file-safe, kebab-case name (e.g., "add user authentication" → `add-user-auth`).

**IMPORTANT**: Do NOT proceed without understanding what the user wants to build.
**IMPORTANT**: In the following steps, the kebab-case name will be referred to as `<name>`.

**2. Find or create the change file to track the change**

The file should be called: `TODOS.<name>.md` (with `<name>` replace as above)

If that file already exists, that's the context file for the current piece of work you're collaborating on.

If that file doesn't exist, stop and report the error to the user.  DO NOT CONTINUE.

**IMPORTANT**: In the following steps, the file path will be referred to as `<todos>`.

**3. Collaborate with the user and other agents in the file**

Tell the user about the file, `<todos>`.

Treat the file as your memory for anything interesting about this proposed work.  For example (but not limited to):

- intended change
- design changes
- tasks to implement this change (as `- [ ] ...` markdown checklist)
- progress on tasks (`- [x] ...` ticked off tasks)

**4. Delegate some of your work to other agents in the file**

When you identify a subtask or exploratory question that you can clearly describe then you should delegate it rather than doing it yourself.

Treat the file as your shared memory and collaborative notes for anything interesting about this proposed work.  For example (but not limited to):

- intended change
- design changes
- tasks to implement this change (as `- [ ] ...` markdown checklist)
- progress on tasks (`- [x] ...` ticked off tasks)

# How to use an agent

To start an agent, run the following command: `pi --print "PROMPT"`

Prompt guidelines:

- The `<todos>` file should clearly describe the agent's work
- The prompt should tell the agent to coordinate via the file, `<todos>`
- The prompt should tell the agent which aspect of the work described in the file it should perform

Coordinating with the agent:

- The agent may run for some minutes (depending on the nature of the task you've assigned)
- The agent will update `<todos>` with progress and notes
- The agent will return its response on `stdout`

Parallel agents

- If you need to, run the agent as a background task: `pi --print "PROMPT" &`
- Capture it's process ID and monitor it using normal bash techniques
