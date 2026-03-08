#!/usr/bin/env guile
!#

;;; Acceptance Test Runner
;;; Runs black-box tests against running server
;;;
;;; Assumes: Server is already running on localhost:1965
;;;          Started by scripts/run-acceptance-tests.sh

(use-modules (srfi srfi-64))  ; Testing framework

(test-begin "gemini-server-acceptance-tests")
;;; Note: All test modules are loaded and execute their test suites
;;; during module initialization (each calls test-begin/test-end internally)
(use-modules (basic-file-serving)
             (mime-types)
             (directory-index)
             (file-not-found)
             (malformed-requests)
             (redirect-handling))
(test-end "gemini-server-acceptance-tests")
