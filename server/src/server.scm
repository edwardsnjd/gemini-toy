#!/usr/bin/env guile
!#

;;; Gemini Static Server
;;; Main entry point and socket handling

(define-module (gemini server)
  #:use-module (ice-9 networking)
  #:use-module (gnutls)
  #:use-module (ice-9 textual-ports)
  #:use-module (ice-9 getopt-long)
  #:use-module (ice-9 threads)
  #:use-module (ice-9 format)
  #:use-module (srfi srfi-19) ; Time/date formatting
  #:use-module (gemini protocol)
  #:use-module (gemini file-handler)
  #:use-module (gemini tls-config)
  #:export (main parse-cli-args validate-cli-args process-request server-loop log-message))

;;; Logging utility
(define (log-message level message . args)
  (let ((timestamp (strftime "%Y-%m-%d %H:%M:%S" (localtime (current-time))))
        (formatted-msg (apply format #f message args)))
    (display (format #f "[~a] ~a: ~a\n" timestamp level formatted-msg))
    (force-output)))

;;; Command line option specification
(define option-spec
  '((port (single-char #\p) (value #t))
    (static-dir (single-char #\d) (value #t))
    (cert (single-char #\c) (value #t))
    (key (single-char #\k) (value #t))
    (help (single-char #\h) (value #f))
    (version (single-char #\v) (value #f))))

;;; Parse command line arguments
(define (parse-cli-args args)
  (catch #t
    (lambda ()
      (let ((options (getopt-long args option-spec)))
        (cond
          ((option-ref options 'help #f) 'help)
          ((option-ref options 'version #f) 'version)
          (else
            `((port . ,(string->number (option-ref options 'port "1965")))
              (static-dir . ,(option-ref options 'static-dir "./static"))
              (cert . ,(option-ref options 'cert "server/certs/cert.pem"))
              (key . ,(option-ref options 'key "server/certs/key.pem")))))))
    (lambda (key . args)
      'error)))

;;; Validate parsed command line arguments
(define (validate-cli-args args)
  (if (eq? args 'error) #f
      (let ((port (assq-ref args 'port))
            (static-dir (assq-ref args 'static-dir))
            (cert-file (assq-ref args 'cert))
            (key-file (assq-ref args 'key)))
        (and
          ;; Validate port number
          (and (number? port) 
               (> port 0) 
               (<= port 65535)
               (if (<= port 1024) 'warning #t))
          ;; Validate static directory path
          (and static-dir (not (string-null? static-dir)))
          ;; Validate certificate file path
          (and cert-file (not (string-null? cert-file)))
          ;; Validate private key file path
          (and key-file (not (string-null? key-file)))
          ;; Ensure cert and key are different files
          (not (string=? cert-file key-file))))))

;;; Display help message
(define (show-help)
  (display "Gemini Static Server\n\n")
  (display "Usage: guile server.scm [OPTIONS]\n\n")
  (display "Options:\n")
  (display "  -p, --port PORT        Port to listen on (default: 1965)\n")
  (display "  -d, --static-dir DIR   Static files directory (default: ./static)\n")
  (display "  -c, --cert FILE        TLS certificate file (default: server/certs/cert.pem)\n")
  (display "  -k, --key FILE         TLS private key file (default: server/certs/key.pem)\n")
  (display "  -h, --help             Show this help message\n")
  (display "  -v, --version          Show version information\n\n"))

;;; Display version information
(define (show-version)
  (display "Gemini Static Server 1.0.0\n")
  (display "A toy implementation of the Gemini protocol\n"))

;;; Main server implementation
(define (main args)
  (let ((parsed-args (parse-cli-args args)))
    (cond
      ((eq? parsed-args 'help)
       (show-help)
       (exit 0))
      ((eq? parsed-args 'version)
       (show-version)
       (exit 0))
      ((eq? parsed-args 'error)
       (display "Error: Invalid command line arguments\n")
       (show-help)
       (exit 1))
      (else
        (let ((validation (validate-cli-args parsed-args)))
          (cond
            ((eq? validation #f)
             (display "Error: Invalid argument values\n")
             (show-help)
             (exit 1))
            ((eq? validation 'warning)
             (display "Warning: Running on privileged port, may require root privileges\n")
             (start-server parsed-args))
            (else
              (start-server parsed-args)))))))

;;; Process a single Gemini request
(define (process-request request-line static-dir)
  (catch #t
    (lambda ()
      ;; Step 1: Validate request format
      (if (not (validate-request request-line))
          (cond
            ((> (string-length request-line) 1024) "59 Request too long\r\n")
            (else "59 Bad Request\r\n"))
          ;; Step 2: Parse URI
          (let ((uri (parse-gemini-request request-line)))
            (if (not uri)
                "59 Bad Request\r\n"
                ;; Step 3: Check for path traversal and normalize path
                (let ((path (uri-path uri)))
                  (if (string-contains path "..")
                      "59 Bad Request\r\n"
                      ;; Step 4: Resolve file path
                      (let ((file-path (resolve-file-path static-dir path)))
                        (if (not file-path)
                            "51 Not Found\r\n"
                            ;; Step 5: Read file and determine MIME type
                            (catch #t
                              (lambda ()
                                (let ((content (read-static-file file-path)))
                                  (if content
                                      (let ((mime-type (get-mime-type file-path)))
                                        (format-gemini-response 20 mime-type content))
                                      "51 Not Found\r\n")))
                              (lambda (key . args)
                                ;; Handle file access errors
                                (cond
                                  ((eq? key 'system-error) "40 Temporary Failure\r\n")
                                  (else "51 Not Found\r\n"))))))))))))
    (lambda (key . args)
      "40 Temporary Failure\r\n")))

;;; Start the Gemini server
(define (start-server config)
  (let ((port (assq-ref config 'port))
        (static-dir (assq-ref config 'static-dir))
        (cert-file (assq-ref config 'cert))
        (key-file (assq-ref config 'key)))
    
    (log-message "INFO" "Starting Gemini server on port ~a" port)
    (log-message "INFO" "Serving files from: ~a" static-dir)
    (log-message "INFO" "Using certificate: ~a" cert-file)
    (log-message "INFO" "Using private key: ~a" key-file)
    
    ;; Check if static directory exists
    (if (not (file-exists? static-dir))
        (begin
          (log-message "ERROR" "Static directory '~a' does not exist" static-dir)
          (exit 1))
        ;; Check/generate certificates
        (let ((certs-available (or (and (file-exists? cert-file) (file-exists? key-file))
                                  (begin
                                    (log-message "INFO" "Generating self-signed certificate...")
                                    (generate-self-signed-cert cert-file key-file)))))
          (if (not certs-available)
              (begin
                (log-message "ERROR" "Could not load or generate TLS certificates")
                (exit 1))
              ;; Start server loop
              (server-loop port static-dir cert-file key-file))))))

;;; Handle a single client connection
(define (handle-client client-session static-dir client-addr)
  (catch #t
    (lambda ()
      ;; Read request from client (up to 1024 bytes)
      (let ((request (read-line client-session)))
        (if (eof-object? request)
            (begin
              (log-message "INFO" "Client ~a disconnected without sending request" client-addr)
              #f)
            (begin
              (log-message "INFO" "Request from ~a: ~a" client-addr 
                          (string-take request (min 100 (string-length request))))
              (let ((response (process-request (string-append request "\r\n") static-dir)))
                ;; Send response to client
                (display response client-session)
                (force-output client-session)
                (let ((status-code (string-take response 2)))
                  (log-message "INFO" "Response to ~a: ~a ~a" client-addr status-code
                              (if (string=? status-code "20") "OK" "ERROR")))
                #t)))))
    (lambda (key . args)
      (log-message "ERROR" "Error handling client ~a: ~a ~a" client-addr key args)
      #f)))

;;; Main server loop
(define (server-loop port static-dir cert-file key-file)
  (catch #t
    (lambda ()
      ;; Set up TLS credentials
      (let ((cred (setup-tls-context cert-file key-file)))
        (if (not cred)
            (begin
              (log-message "ERROR" "Failed to set up TLS context")
              (exit 1))
            ;; Create server socket
            (let ((server-socket (socket PF_INET SOCK_STREAM 0)))
              ;; Set socket options
              (setsockopt server-socket SOL_SOCKET SO_REUSEADDR 1)
              
              ;; Bind to port
              (bind server-socket AF_INET INADDR_ANY port)
              
              ;; Start listening
              (listen server-socket 5)
              (log-message "INFO" "Server listening on port ~a" port)
              
              ;; Main accept loop
              (let loop ()
                (log-message "DEBUG" "Waiting for connections...")
                (let ((client-connection (accept server-socket)))
                  (let ((client-socket (car client-connection))
                        (client-address (cdr client-connection)))
                    (let ((client-addr (inet-ntoa (sockaddr:addr client-address))))
                      (log-message "INFO" "Client connected from ~a" client-addr)
                      
                      ;; Set up TLS session for this client
                      (catch #t
                        (lambda ()
                          (let ((session (make-session connection-end/server)))
                            ;; Configure TLS session
                            (set-session-transport-fd! session client-socket)
                            (set-session-credentials! session cred)
                            (set-session-dh-prime-bits! session 1024)
                            
                            ;; Perform TLS handshake
                            (handshake session)
                            (log-message "DEBUG" "TLS handshake completed with ~a" client-addr)
                            
                            ;; Handle the client request
                            (handle-client session static-dir client-addr)
                            
                            ;; Close TLS session
                            (bye session close-request/rdwr)
                            (close-port session)
                            (log-message "DEBUG" "Connection closed with ~a" client-addr)))
                        (lambda (key . args)
                          (log-message "ERROR" "TLS error with client ~a: ~a ~a" client-addr key args)
                          (close client-socket)))
                      
                      ;; Continue accepting new connections
                      (loop))))))))
    (lambda (key . args)
      (log-message "FATAL" "Server error: ~a ~a" key args)
      (exit 1))))

;;; When run as script
(when (batch-mode?)
  (main (command-line)))