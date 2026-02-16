#!/usr/bin/env guile
!#

;;; Acceptance Test Runner
;;; Runs black-box tests against running server
;;;
;;; Assumes: Server is already running on localhost:1965
;;;          Started by scripts/run-acceptance-tests.sh

;; Add lib directory to load path for shared utilities
(add-to-load-path (string-append (dirname (current-filename)) "/lib"))

(use-modules (srfi srfi-64)      ; Testing framework
             (gemini-test-utils)) ; Shared test utilities

;;; Test discovery and running
(define (run-all-acceptance-tests)
  (display "Running acceptance tests...\n")
  (test-begin "gemini-server-acceptance-tests")
  
  ;; Load and run all acceptance test modules
  ;; Will be populated as we create tests
  
  (test-end "gemini-server-acceptance-tests")
  (display "Acceptance tests complete.\n"))

(when (batch-mode?)
  (run-all-acceptance-tests))