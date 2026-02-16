#!/usr/bin/env guile
!#

;;; Acceptance Test Runner
;;; Runs black-box tests against running server

;; Add lib directory to load path for shared utilities
(add-to-load-path (string-append (dirname (current-filename)) "/lib"))

(use-modules (srfi srfi-64)    ; Testing framework
             ;; Note: socket functions available as built-ins
             (gnutls)          ; For TLS connections
             (gemini-test-utils)) ; Our shared test utilities

;;; Configuration
(define test-server-host "localhost")
(define test-server-port 1965)
(define test-static-dir "./test-content")

;;; Helper to start test server if needed
(define (ensure-test-server)
  (display "Note: These tests expect a Gemini server running on ")
  (display test-server-host) (display ":") (display test-server-port)
  (newline)
  (display "Start server manually or implement auto-start here.\n"))

;;; Test discovery and running
(define (run-all-acceptance-tests)
  (display "Running acceptance tests...\n")
  (ensure-test-server)
  (test-begin "gemini-server-acceptance-tests")
  
  ;; Load and run all acceptance test modules
  ;; Will be populated as we create tests
  
  (test-end "gemini-server-acceptance-tests")
  (display "Acceptance tests complete.\n"))

(when (batch-mode?)
  (run-all-acceptance-tests))