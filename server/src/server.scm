#!/usr/bin/env guile
!#

;;; Gemini Static Server
;;; Main entry point and socket handling

(define-module (gemini server)
  #:use-module (ice-9 networking)
  #:use-module (gnutls)
  #:use-module (ice-9 textual-ports)
  #:use-module (ice-9 getopt-long)
  #:use-module (gemini protocol)
  #:use-module (gemini file-handler)
  #:use-module (gemini tls-config)
  #:export (main))

;;; Main server implementation will go here
(define (main args)
  (display "Gemini server starting...\n"))

;;; When run as script
(when (batch-mode?)
  (main (command-line)))