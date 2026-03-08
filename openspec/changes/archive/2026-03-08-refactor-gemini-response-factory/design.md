## Design: Consistent Gemini Response Definitions

### Shared helper (in `src/server/src/gemini/protocol.scm`)

```scheme
;; Helper that always produces a correctly formatted Gemini response.
(define (make-response status-code meta . body)
  (format-gemini-response status-code meta (if (null? body) #f (car body))))
```

### Redefine response constants using the shared helper
All existing `response/*` symbols will be re‑implemented to call `make-response` so that every constant follows the same pattern.

```scheme
(define response/success (make-response 20 "text/gemini; charset=utf-8"))
(define response/temporary-failure (make-response 40 "Temporary Failure"))
(define response/permanent-failure (make-response 50 "Permanent Failure"))
(define response/client-cert-required (make-response 60 "Client Certificate Required"))
(define response/cert-not-authorized (make-response 61 "Certificate Not Authorized"))
(define response/cert-not-valid (make-response 62 "Certificate Not Valid"))
(define response/request-too-long (make-response 59 "Request too long"))
(define response/bad-request (make-response 59 "Bad Request"))
(define response/not-found (make-response 51 "Not Found"))
(define response/non-gemini-scheme (make-response 59 "Only gemini:// URIs supported"))
```

### Compatibility
- The public symbols `response/success`, `response/temporary-failure`, … remain **exactly the same names** and retain their original values (now generated via `make-response`).
- No deprecation warnings are added; the constants stay part of the public API.

### Usage
Existing code can continue to reference the `response/*` symbols unchanged. The internal definition is now consistent, and any new response can be added by calling `make-response` directly or by defining a new constant in the same style.

### Documentation
- Update the module docstring to explain that all response constants are defined via `make-response`.
- Add a note in the README that the helper exists for future extensions.

### Migration plan
1. Add `make-response` to the module export list.
2. Replace each `define response/...` with the version that calls `make-response` (as shown above).
3. Run the test suite to ensure no behavioural change.
4. Update any internal comments that referenced the old pattern.
5. No changes to the public interface or tests are required.