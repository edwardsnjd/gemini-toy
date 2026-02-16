#!/usr/bin/env guile
!#

;;; Simple connection test to debug the utilities

(use-modules (gnutls)
             (ice-9 textual-ports)
             (ice-9 format))

(define (simple-test)
  (let* ((socket (socket AF_INET SOCK_STREAM 0))
         (addr (make-socket-address AF_INET 
                                   (inet-pton AF_INET "127.0.0.1") 
                                   1965)))
    (connect socket addr)
    (let ((session (make-session connection-end/client)))
      (set-session-transport-fd! session (port->fdes socket))
      (set-session-default-priority! session)
      
      (handshake session)
      (display "TLS handshake successful\n")
      
      ;; Send request
      (put-string session "gemini://localhost:1965/test.txt\r\n")
      (force-output session)
      (display "Request sent\n")
      
      ;; Read response
      (let ((response-line (get-line session)))
        (display (format #f "Response: ~a\n" response-line))
        (bye session close-request/rdwr)
        (close-port session)))))

(simple-test)