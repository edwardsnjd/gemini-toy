# 5. Fibers-Based Architecture for Responsive Guile TUI

Date: 2026-03-09

## Status

Accepted

## Context

Building a terminal user interface (TUI) in Guile Scheme that performs network requests while maintaining UI responsiveness. Traditional blocking I/O would freeze the interface during network operations, degrading user experience.

## Decision

Use Guile's **Fibers** library to implement a concurrent architecture with:

- **Suspendable ports** for non-blocking network I/O
- **Channel-based communication** between UI and worker fibers
- **Lightweight cooperative concurrency** via the fibers scheduler

## Architecture

```
             ┌─────────────────────────────────┐
             │          run-fibers             │
             │         (event loop)            │
             └─────────────────────────────────┘
                        │         │
              ┌─────────┘         └──────────┐
              │                              │
              v                              v
     ┌─────────────────┐             ┌─────────────────┐
     │   UI Fiber      │             │ Network Worker  │
     │                 │             │    Fiber(s)     │
     │  - Read keys    │             │                 │
     │  - Update       │             │  - Socket I/O   │
     │    screen       │             │  - HTTP reqs    │
     │  - Handle       │             │  - Suspends on  │
     │    events       │             │    blocking ops │
     └─────────────────┘             └─────────────────┘
           │  ^  │                         ^  │  │
           │  │  │     request-channel     │  │  │
           │  │  └─────────────────────────┘  │  │
           │  │                               │  │
           │  │       response-channel        │  │
           │  └───────────────────────────────┘  │
           │                                     │
           │                                     │
           v                                     v
    ┌─────────────┐                       ┌─────────────┐
    │     UI      │                       │   Network   │
    │   updates   │                       │   Sockets   │
    └─────────────┘                       └─────────────┘
```

## Key Components

### 1. Fibers Runtime

- `run-fibers` establishes the scheduler and configures suspendable ports
- Blocking operations (socket reads/writes) suspend only the calling fiber
- Other fibers continue execution, keeping UI responsive

### 2. UI Fiber

- Polls keyboard input (stdin in raw mode)
- Renders screen updates
- Sends work requests via `put-message` to request channel
- Receives results via `get-message` from response channel (non-blocking check)

### 3. Network Worker Fiber(s)

- Blocks on `get-message` waiting for work from request channel
- Performs network I/O (HTTP GET, socket operations)
- Sends results back via `put-message` to response channel
- Can spawn multiple workers for parallel requests

### 4. Channels

- `(make-channel)` creates thread-safe FIFO queues
- `put-message` and `get-message` integrate with fiber scheduler
- Decouples UI from network timing

## Implementation Sketch

```scheme
(use-modules (fibers)
             (fibers channels)
             (ice-9 rdelim))

(define (network-worker req-ch resp-ch)
  (let loop ()
    (let ((req (get-message req-ch)))
      ;; Blocking socket I/O suspends this fiber only
      (let ((result (perform-http-get (request-url req))))
        (put-message resp-ch result))
      (loop))))

(define (tui-loop req-ch resp-ch)
  (let loop ((state 'idle))
    ;; Check keyboard, update display, send requests
    (when (char-ready? (current-input-port))
      (let ((key (read-char)))
        (when (want-request? key)
          (put-message req-ch (make-request key)))))
    ;; Check for responses (non-blocking)
    (when (channel-ready? resp-ch)
      (let ((resp (get-message resp-ch)))
        (update-display resp)))
    (loop state)))

(run-fibers
  (lambda ()
    (let ((req-ch  (make-channel))
          (resp-ch (make-channel)))
      (spawn-fiber (lambda () (network-worker req-ch resp-ch)))
      (tui-loop req-ch resp-ch))))
```

## Consequences

### Positive

- UI remains responsive during slow network operations
- Natural expression of concurrent activities
- Thousands of cheap fibers enable multiple parallel requests
- No callback hell; sequential-looking code

### Negative

- Requires Guile Fibers library as a dependency (not in core)
- Learning curve for channel patterns
- Raw terminal handling still requires manual control codes or curses bindings

## Alternatives Considered

- **call/cc coroutines**: Stack-copying overhead, discouraged by Guile docs
- **Guile prompt/abort delimited coroutines**: Possible approach, manual effort
- **POSIX threads**: Heavy, requires locking, doesn't integrate with Guile ports
- **select/poll event loop**: Manual, complex state machines

## References

- Guile Fibers manual: https://github.com/wingo/fibers
- "Growing Fibers" (Wingo, 2017): https://wingolog.org/archives/2017/06/27/growing-fibers
