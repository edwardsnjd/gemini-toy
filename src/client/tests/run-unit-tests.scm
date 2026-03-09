#!/usr/bin/env guile
!#

;;; Client Unit Test Runner
;;; Runs all client unit tests in the tests/ directory

(use-modules (srfi srfi-64))  ; Testing framework

(test-begin "gemini-client-unit-tests")
(use-modules (tests url-tests))
(test-end "gemini-client-unit-tests")
