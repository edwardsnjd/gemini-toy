# 3. TLS Handshake Implementation Details and Gotchas

Date: 2026-03-08

## Status

Accepted

## Context

During implementation of TLS client certificate handling, we encountered several issues that caused acceptance test failures. These issues revealed subtle but important details about how Guile's GnuTLS bindings work.

## Decision

Document the key findings to prevent future confusion:

### 1. Port must be obtained AFTER handshake

The port used for communication must be obtained **after** the TLS handshake completes, not before. The `session-record-port` function returns a port tied to the session's internal state, which is not properly initialized until after `handshake` succeeds.

```scheme
;; WRONG - port obtained before handshake
(let ((port (session-record-port session)))
  (handshake session)
  (handle-client port ...))

;; CORRECT - port obtained after handshake
(handshake session)
(let ((port (session-record-port session)))
  (handle-client port ...))
```

### 2. peer-certificate-status throws when no client cert present

The GnuTLS function `peer-certificate-status` throws a `gnutls-error` with code `No certificate was found` when the client does not present a certificate. It does NOT return a simple value like `#f`.

This is different from a certificate that is present but invalid - that returns `certificate-status/invalid`.

```scheme
;; This throws if no client cert was provided:
(let ((cert-status (peer-certificate-status session)))
  ...)

;; Must wrap in catch to handle the "no cert" case:
(let ((cert-status 
       (catch #t
         (lambda () (peer-certificate-status session))
         (lambda (key . args) #f))))  ; returns #f on error
  ...)
```

### 3. The outer catch in server-loop is important

The outer `catch #t` in `server-loop` serves two purposes:
- It prevents a single client error from crashing the entire server
- It provides structured logging of connection errors

Removing it (even temporarily) breaks the error handling architecture.

### 4. safe-operation macro expansion

The `safe-operation` macro in `utils.scm` wraps its body in `begin` to ensure it expands to a single expression. Without this, macro expansion could introduce extra arguments to surrounding `catch` forms.

## Consequences

- **Debugging TLS issues requires server logs** - The logs showed "TLS handshake completed" followed by "No certificate was found" errors, which helped identify the `peer-certificate-status` issue
- **Test client must handle TLS properly** - The acceptance test client uses standard GnuTLS client setup; if it fails, the error message indicates the stage that failed
- **Client certificates are optional by default** - The server allows connections without client certificates; the TLS cert checking code handles the case where certs are provided but invalid
