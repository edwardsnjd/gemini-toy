#!/usr/bin/env guile
!#

;;; Unit Test Runner
;;; Runs all unit tests in the tests/ directory
;;; 
;;; Note: This script expects GUILE_LOAD_PATH to be set by the calling script
;;; to include 'src' and 'tests' directories.

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
  
  (test-end "gemini-server-unit-tests"))

(when (batch-mode?)
  (run-all-unit-tests))