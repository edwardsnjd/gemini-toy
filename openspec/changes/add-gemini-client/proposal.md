## Why

We have a Gemini server prototype but no way to browse Gemini sites or test our server with a real client. A simple CLI-based Gemini client will enable both exploring the broader Gemini web and testing our local server implementation.

## What Changes

- Add a new `gemini-client` command-line tool
- Implement minimal Gemini protocol compliance (request/response handling)
- Support browsing arbitrary Gemini URLs (gemini://)
- Support displaying text/gemini and text/plain responses
- Handle basic TLS verification (with option to disable for local testing)

## Capabilities

### New Capabilities

- **gemini-client**: A bare-bones CLI client for browsing Gemini sites
  - Connect to any gemini:// URL
  - Send valid Gemini requests with headers
  - Handle Gemini response status codes (success, redirect, client/server errors)
  - Display text/gemini and text/plain content
  - Follow redirects (single level for simplicity)
  - Support self-signed certificates for local testing

### Modified Capabilities

*(none - this is a new capability)*

## Impact

- New package: `gemini-client` in the codebase
- Adds no new external dependencies beyond what the server already uses
- Enables testing of the gemini-server without external tools

## Navigation Options (TBD)

The client needs a way to allow users to navigate from one Gemini page to another when the response contains links. Below are several options considered, each with trade-offs between simplicity, interactivity, and scriptability.

### Option 1: Numbered Links + Interactive Prompt (Semi-Interactive)

After rendering the page, display numbered links and prompt for selection:

```
$ gemini-client gemini://example.com

# Welcome to Example

This is a sample page with links:

=> gemini://example.com/about About
=> gemini://example.com/contact Contact

[Enter link number to follow, or q to quit]: 
```

- **Pros:** Simple to implement, intuitive UX
- **Cons:** Requires interaction, breaks pipe-ability
- **Add `--no-prompt` flag** for scripted/non-interactive usage

### Option 2: List Links Only Mode

Add a `--links` flag that lists URLs without rendering content:

```
$ gemini-client --links gemini://example.com
1. gemini://example.com/about (About)
2. gemini://example.com/contact (Contact)

$ gemini-client gemini://example.com/1
# fetches link by index
```

- **Pros:** Fully scriptable, pipe-friendly
- **Cons:** Extra step to navigate, less intuitive

### Option 3: Inline Numbered Links

Render content with numbered links inline:

```
$ gemini-client gemini://example.com

# Welcome

See [1] for more info.

[1] => gemini://example.com/about
```

- **Pros:** No interaction, full output preserved
- **Cons:** User must manually copy URLs

### Option 4: State File / History

Maintain a `.gemini-client-history` file with visited URLs:

```
$ cat .gemini-client-history
1. gemini://example.com
2. gemini://example.com/about

$ gemini-client --back     # go to previous page
$ gemini-client --links    # show links from last page
```

- **Pros:** Full CLI semantics, supports back/forward navigation
- **Cons:** State management, file cleanup needed

### Option 5: TUI with Keybindings (Interactive)

Full terminal UI with arrow keys, Enter to follow links, 'q' to quit, 'b' for back:

- **Pros:** Real browsing experience, familiar to users of w3m/lynx
- **Cons:** More complex, requires ncurses/termbox, less scriptable

---

### Decision Needed

Before implementation, we should decide which approach(es) to support:

1. **Start simple:** Implement Option 1 (interactive prompt) as default, with `--no-prompt` for scripting
2. **Fully non-interactive:** Implement Options 2 or 3, allow manual URL entry
3. **Full TUI:** Skip interactive prompt, go straight to Option 5

**Recommendation:** Start with Option 1 (numbered links + prompt) as default, but add `--no-prompt` flag for CI/scripting use cases. This gives the best user experience while maintaining scriptability.