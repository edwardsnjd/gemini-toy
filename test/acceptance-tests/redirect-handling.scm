;;; Acceptance Test: Redirect Handling
;;; Tests for redirecting directory requests without trailing slash

(define-module (redirect-handling)
  #:use-module (srfi srfi-64)
  #:use-module (lib))

(test-begin "redirect-handling")

(test-begin "directory request without trailing slash redirects")
;; When requesting a directory path without a trailing slash,
;; the server should respond with a redirect (status 30) to the
;; same path with a trailing slash appended.
(with-gemini-request "/subdir"
  (lambda (response)
    (assert-status response 30 "subdir without slash redirect status")
    (assert-meta-contains response "/subdir/" "redirect target contains slash")))
(test-end)

(test-end "redirect-handling")
