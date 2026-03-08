;;; TLS Client Certificate Error Tests
;;; Verify that the server requests a client certificate and returns the appropriate response

(define-module (tls-client-cert-errors)
  #:use-module (srfi srfi-64)
  #:use-module (lib))

(test-begin "tls-client-cert-errors")

;; Attempt a request without a client certificate; expect client-cert-required response
(with-gemini-request "/test.txt"
  (lambda (response)
    (assert-status response 60 "client cert required")
    (assert-error-message response "Client Certificate Required" "client cert required")))

(test-end "tls-client-cert-errors")
