;;; Acceptance Test: Proxy Request Refused
;;; Tests for rejecting proxy-style URI schemes

(define-module (proxy-request-refused)
  #:use-module (srfi srfi-64)
  #:use-module (lib))

(test-begin "proxy-request-refused")

(test-begin "proxy scheme request refused")
;; When requesting a URL with a proxy scheme (e.g., proxy://),
;; the server should respond with status 52 (Proxy Request Refused).
;; Using raw request to send a proxy:// scheme directly.
(with-raw-gemini-request "proxy://localhost/example.txt\r\n"
  (lambda (response)
    (assert-status response 52 "proxy scheme request status")
    (assert-meta-contains response "proxy" "proxy scheme rejection message")))
(test-end)

(test-end "proxy-request-refused")