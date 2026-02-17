#!/usr/bin/env guile
!#

;;; Acceptance Test Runner
;;; Runs black-box tests against running server
;;;
;;; Assumes: Server is already running on localhost:1965
;;;          Started by scripts/run-acceptance-tests.sh

;; Add lib directory to load path for shared utilities
(add-to-load-path (string-append (dirname (current-filename)) "/lib"))
;; Add current directory to load path so (acceptance-tests ...) modules can be found
(add-to-load-path (dirname (current-filename)))

(use-modules (srfi srfi-64)       ; Testing framework
             (gemini-test-utils)) ; Shared test utilities

(test-begin "gemini-server-acceptance-tests")
;;; Note: All test modules are loaded and execute their test suites
;;; during module initialization (each calls test-begin/test-end internally)
(use-modules (acceptance-tests basic-file-serving)
             (acceptance-tests mime-types)
             (acceptance-tests directory-index)
             (acceptance-tests file-not-found)
             (acceptance-tests malformed-requests))
(test-end "gemini-server-acceptance-tests")
