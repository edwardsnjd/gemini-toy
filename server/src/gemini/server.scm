#!/usr/bin/env guile
!#

;;; Gemini Static Server
;;; Main entry point and socket handling

(define-module (gemini server)
  ;; Note: socket functions available as built-ins
  #:use-module (gnutls)
  #:use-module (ice-9 textual-ports)
  #:use-module (ice-9 getopt-long)
  #:use-module (ice-9 threads)
  #:use-module (ice-9 format)
  #:use-module (srfi srfi-1)  ; List utilities
  #:use-module (srfi srfi-2)  ; and-let*
  #:use-module (srfi srfi-9)  ; Records  
  #:use-module (srfi srfi-14) ; char-set for string-trim-right
  #:use-module (srfi srfi-19) ; Time/date formatting
  #:use-module (web uri)
  #:use-module (gemini protocol)
  #:use-module (gemini file-handler)
  #:use-module (gemini tls-config)
  #:use-module (gemini mime-types)
  #:use-module (gemini utils)
  #:export (main parse-cli-args validate-cli-args process-request server-loop log-message
            ;; Backward compatibility for tests
            config-to-alist))

;;; Logging utility
(define (log-message level message . args)
  (let ((timestamp (strftime "%Y-%m-%d %H:%M:%S" (localtime (time-second (current-time time-utc)))))
        (formatted-msg (apply format #f message args)))
    (display (format #f "[~a] ~a: ~a\n" timestamp level formatted-msg))
    (force-output)))

;;; Server configuration record
(define-record-type <server-config>
  (make-server-config port static-dir cert-file key-file)
  server-config?
  (port config-port)
  (static-dir config-static-dir)
  (cert-file config-cert-file)
  (key-file config-key-file))

;;; Configuration specification with defaults and validators
(define config-spec
  `((port (default . 1965)
          (parser . ,string->number)
          (validator . ,valid-port?))
    (static-dir (default . "./static")
                (validator . ,non-empty-string?))
    (cert (default . "server/certs/cert.pem")
           (validator . ,non-empty-string?))
    (key (default . "server/certs/key.pem")
          (validator . ,non-empty-string?))))

;;; Command line option specification
(define option-spec
  '((port (single-char #\p) (value #t))
    (static-dir (single-char #\d) (value #t))
    (cert (single-char #\c) (value #t))
    (key (single-char #\k) (value #t))
    (help (single-char #\h) (value #f))
    (version (single-char #\v) (value #f))))

;;; Parse and validate command line arguments  
(define (parse-cli-args args)
  (catch #t
    (lambda ()
      (let ((options (getopt-long args option-spec)))
        (cond
          ((option-ref options 'help #f) 'help)
          ((option-ref options 'version #f) 'version)
          (else 
           (let ((config (build-and-validate-config options)))
             (or config 'error))))))
    (lambda (key . rest) 'error)))

;;; Build configuration from parsed options  
(define (build-and-validate-config options)
  (let ((config-values (extract-config-values options)))
    (and (validate-config-values config-values)
         (let ((port (assq-ref config-values 'port))
               (static-dir (assq-ref config-values 'static-dir))
               (cert-file (assq-ref config-values 'cert))
               (key-file (assq-ref config-values 'key)))
           (and (not (string=? cert-file key-file))
                ;; Return alist for backward compatibility with existing tests
                config-values)))))

;;; Extract configuration values from parsed options
(define (extract-config-values options)
  (map (lambda (spec)
         (let* ((field (car spec))
                (spec-data (cdr spec))
                (default (assq-ref spec-data 'default))
                (parser (assq-ref spec-data 'parser))
                (raw-value (option-ref options field (if default (format #f "~a" default) #f))))
           (cons field 
                 (if parser 
                     (let ((parsed (parser raw-value)))
                       (if parsed parsed (error "Invalid value for" field)))
                     raw-value))))
       config-spec))

;;; Validate all configuration values
(define (validate-config-values config-values)
  (every (lambda (spec)
           (let* ((field (car spec))
                  (validator (assq-ref (cdr spec) 'validator))
                  (value (assq-ref config-values field)))
             (if validator (validator value) #t)))
         config-spec))

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
  (let ((result (parse-cli-args args)))
    (cond
      ((eq? result 'help)
       (show-help)
       (exit 0))
      ((eq? result 'version)
       (show-version) 
       (exit 0))
      ((not result)
       (display "Error: Invalid command line arguments\n")
       (show-help)
       (exit 1))
      ((list? result)  ; Config alist returned
       (let ((port (assq-ref result 'port)))
         (when (<= port 1024)
           (display "Warning: Running on privileged port, may require root privileges\n"))
         (start-server result)))
      (else
        (display "Error: Configuration validation failed\n")
        (exit 1)))))

;;; Handler 1: Request validation with specific error responses
(define (validate-request-handler request static-dir)
  (cond
    ((not (validate-request request))
     (cond
       ((> (string-length request) 1024) "59 Request too long\r\n")
       ((non-gemini-scheme? request) "59 Only gemini:// URIs supported\r\n")
       (else "59 Bad Request\r\n")))
    (else #f))) ; Continue to next handler

;;; Handler 2: URI parsing with error detection
(define (parse-uri-handler request static-dir)
  (let ((uri (parse-gemini-request request)))
    (cond
      ((not uri)
       (if (non-gemini-scheme? request)
           "59 Only gemini:// URIs supported\r\n"
           "59 Bad Request\r\n"))
      ((path-traversal-attempt? (uri-path uri)) "59 Bad Request\r\n")
      (else #f)))) ; Continue to next handler

;;; Handler 3: File serving with proper error handling
(define (serve-file-handler request static-dir)
  (error-or "40 Temporary Failure\r\n"
    (and-let* ((uri (parse-gemini-request request))
               (safe-path (resolve-file-path static-dir (uri-path uri)))
               (final-path (resolve-directory-index safe-path))
               (content (read-file-content final-path))
               (mime-type (get-mime-type final-path)))
      (format-gemini-response 20 mime-type content))))

;;; Helper predicates for clean request analysis
(define (non-gemini-scheme? request)
  (safe-operation
    (let ((uri (string->uri (string-trim-right request (char-set #\newline #\return)))))
      (and uri (uri-scheme uri) (not (equal? (uri-scheme uri) 'gemini))))))

(define (path-traversal-attempt? path)
  (string-contains path ".."))

(define (resolve-directory-index path)
  (if (file-is-directory? path)
      (or (find-index-file path) #f)
      path))

;;; Backward compatibility function for tests
(define (config-to-alist config)
  "Convert server config record to association list for test compatibility"
  (if (server-config? config)
      `((port . ,(config-port config))
        (static-dir . ,(config-static-dir config))
        (cert . ,(config-cert-file config))
        (key . ,(config-key-file config)))
      config))

;;; Backward compatibility: validate CLI args (tests expect this function)
(define (validate-cli-args args)
  "Validate parsed CLI arguments - backward compatibility for tests"
  (if (eq? args 'error) #f
      (let ((port (assq-ref args 'port))
            (static-dir (assq-ref args 'static-dir))
            (cert-file (assq-ref args 'cert))
            (key-file (assq-ref args 'key)))
        (and (valid-port? port)
             (non-empty-string? static-dir)
             (non-empty-string? cert-file)
             (non-empty-string? key-file)
             (not (string=? cert-file key-file))
             (if (<= port 1024) 'warning #t)))))

;;; Request processing pipeline - handlers return response or #f to continue
(define request-handlers
  (list validate-request-handler
        parse-uri-handler
        serve-file-handler))

;;; Process a single Gemini request using composable handlers
(define (process-request request-line static-dir)
  (or-map-handlers request-handlers request-line static-dir))

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
      (let ((request (get-line client-session)))
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
                    (let ((client-addr "unknown"))
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
                       (loop)))))))))
    (lambda (key . args)
      (log-message "FATAL" "Server error: ~a ~a" key args)
      (exit 1))))

;;; When run as script (not when loaded as a module by tests)
(when (and (batch-mode?)
           (let ((script (car (command-line))))
             (string-suffix? "server.scm" script)))
  (main (command-line)))
