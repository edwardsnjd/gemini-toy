#!/usr/bin/env guile
!#

;;; Minimal Gemini Server for Acceptance Testing

(use-modules (gnutls)
            (ice-9 textual-ports)
            (ice-9 format)
            (srfi srfi-19))

(define static-directory "./static")
(define server-port 1965)

;;; Simple logging
(define (log-info message . args)
  (apply format #t message args)
  (newline))

;;; Basic MIME type detection
(define (get-mime-type filename)
  (cond
    ((string-suffix? ".gmi" filename) "text/gemini")
    ((string-suffix? ".txt" filename) "text/plain")
    ((string-suffix? ".html" filename) "text/html")
    (else "application/octet-stream")))

;;; Simple file serving
(define (serve-file file-path)
  (if (file-exists? file-path)
      (if (file-is-directory? file-path)
          ;; Directory listing
          (let ((entries (scandir file-path)))
            (string-append "20 text/gemini\r\n"
                          "# Directory Listing\n"
                          (string-join 
                            (map (lambda (entry)
                                   (string-append "=> " entry "\n"))
                                 (filter (lambda (e) (not (string-prefix? "." e)))
                                         entries))
                            "")))
          ;; Regular file
          (let ((content (call-with-input-file file-path get-string-all))
                (mime-type (get-mime-type file-path)))
            (string-append "20 " mime-type "\r\n" content)))
      ;; File not found
      "51 Not Found\r\n"))

;;; Process Gemini request
(define (process-request request)
  (log-info "Request: ~a" request)
  (let ((clean-request (string-trim-right request)))
    (if (string-prefix? "gemini://" clean-request)
        (let* ((uri-parts (string-split clean-request #\/))
               (path-parts (if (> (length uri-parts) 3)
                              (drop uri-parts 3)
                              '()))
               (file-path (if (null? path-parts)
                             static-directory
                             (string-append static-directory "/" 
                                           (string-join path-parts "/")))))
          (log-info "Serving: ~a" file-path)
          (serve-file file-path))
        "59 Bad Request\r\n")))

;;; Handle client connection
(define (handle-client client-socket)
  (let ((session (make-session connection-end/server)))
    ;; Simple TLS setup - in real server this would be more robust
    (set-session-transport-fd! session client-socket)
    ;; Skip certificate setup for now - just handle plain socket
    (close session)
    ;; For testing, just use the socket directly
    (let ((request (get-line (fdopen client-socket "r+"))))
      (if (eof-object? request)
          (log-info "Client disconnected")
          (let ((response (process-request request)))
            (display response (fdopen client-socket "w"))
            (force-output (fdopen client-socket "w"))
            (log-info "Response sent")))
      (close client-socket))))

;;; Main server loop
(define (run-server)
  (log-info "Starting simple Gemini server on port ~a" server-port)
  (log-info "Serving files from: ~a" static-directory)
  
  (let ((server-socket (socket PF_INET SOCK_STREAM 0)))
    (setsockopt server-socket SOL_SOCKET SO_REUSEADDR 1)
    (bind server-socket AF_INET INADDR_ANY server-port)
    (listen server-socket 5)
    (log-info "Server listening...")
    
    (let loop ()
      (let ((client-connection (accept server-socket)))
        (let ((client-socket (car client-connection)))
          (log-info "Client connected")
          (handle-client client-socket)
          (loop))))))

;;; Parse command line
(define (main args)
  (if (and (> (length args) 1)
           (string=? "-d" (list-ref args 1)))
      (begin
        (if (> (length args) 2)
            (set! static-directory (list-ref args 2)))
        (run-server))
      (begin
        (format #t "Usage: ~a -d <static-directory>\n" (car args))
        (exit 1))))

;;; Auto-run if called as script
(when (batch-mode?)
  (main (command-line)))