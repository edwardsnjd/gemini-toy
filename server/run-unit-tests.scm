#!/usr/bin/env guile
!#

;;; Unit Test Runner
;;; Runs all unit tests in the tests/ directory

(add-to-load-path (string-append (dirname (current-filename)) "/src"))
(add-to-load-path (string-append (dirname (current-filename)) "/tests"))

(use-modules (srfi srfi-64))  ; Testing framework

;;; Test discovery and running
(define (run-all-unit-tests)
  (display "Running unit tests...\n")
  (test-begin "gemini-server-unit-tests")
  
  ;; Load and run all test modules
  (use-modules (tests protocol-parser)
               (tests cli-args)
               (tests mime-types)
               (tests file-handler)
               (tests tls-config)
               (tests integration))
  
  (test-end "gemini-server-unit-tests")
  (display "Unit tests complete.\n"))

(when (batch-mode?)
  (run-all-unit-tests))