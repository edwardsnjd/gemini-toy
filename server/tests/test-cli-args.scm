;;; Unit Tests: Command Line Argument Parsing
;;; Tests for CLI argument handling and validation

(add-to-load-path "../src")

(define-module (tests cli-args)
  #:use-module (srfi srfi-64)
  #:use-module (gemini server))

;;; Test suite for command line argument parsing
(test-begin "cli-argument-parsing")

(test-equal "default values when no arguments provided"
  '((port . 1965) (static-dir . "./static") (cert . "server/certs/cert.pem") (key . "server/certs/key.pem"))
  (parse-cli-args '("server.scm")))

(test-equal "port argument parsing"
  1234
  (let ((args (parse-cli-args '("server.scm" "--port" "1234"))))
    (assq-ref args 'port)))

(test-equal "static directory argument parsing"
  "/custom/static"
  (let ((args (parse-cli-args '("server.scm" "--static-dir" "/custom/static"))))
    (assq-ref args 'static-dir)))

(test-equal "certificate file argument parsing"
  "/custom/cert.pem"
  (let ((args (parse-cli-args '("server.scm" "--cert" "/custom/cert.pem"))))
    (assq-ref args 'cert)))

(test-equal "private key file argument parsing"
  "/custom/key.pem"
  (let ((args (parse-cli-args '("server.scm" "--key" "/custom/key.pem"))))
    (assq-ref args 'key)))

(test-equal "multiple arguments parsing"
  '((port . 8080) (static-dir . "/var/www") (cert . "/etc/ssl/cert.pem") (key . "/etc/ssl/key.pem"))
  (parse-cli-args '("server.scm" "--port" "8080" "--static-dir" "/var/www" 
                    "--cert" "/etc/ssl/cert.pem" "--key" "/etc/ssl/key.pem")))

(test-equal "short argument forms work"
  '((port . 2020) (static-dir . "/tmp"))
  (let ((args (parse-cli-args '("server.scm" "-p" "2020" "-d" "/tmp"))))
    (list (cons 'port (assq-ref args 'port))
          (cons 'static-dir (assq-ref args 'static-dir)))))

(test-equal "help flag recognition"
  'help
  (parse-cli-args '("server.scm" "--help")))

(test-equal "version flag recognition"
  'version
  (parse-cli-args '("server.scm" "--version")))

(test-end "cli-argument-parsing")

;;; Test suite for argument validation
(test-begin "argument-validation")

(test-equal "valid port numbers accepted"
  #t
  (validate-cli-args '((port . 1965) (static-dir . "./static") (cert . "cert.pem") (key . "key.pem"))))

(test-equal "port number out of range rejected"
  #f
  (validate-cli-args '((port . 99999) (static-dir . "./static") (cert . "cert.pem") (key . "key.pem"))))

(test-equal "negative port number rejected"
  #f
  (validate-cli-args '((port . -1) (static-dir . "./static") (cert . "cert.pem") (key . "key.pem"))))

(test-equal "zero port number rejected"
  #f
  (validate-cli-args '((port . 0) (static-dir . "./static") (cert . "cert.pem") (key . "key.pem"))))

(test-equal "port 1024 and below require root privileges warning"
  'warning
  (validate-cli-args '((port . 80) (static-dir . "./static") (cert . "cert.pem") (key . "key.pem"))))

(test-equal "missing static directory rejected"
  #f
  (validate-cli-args '((port . 1965) (static-dir . #f) (cert . "cert.pem") (key . "key.pem"))))

(test-equal "empty certificate file path rejected"
  #f
  (validate-cli-args '((port . 1965) (static-dir . "./static") (cert . "") (key . "key.pem"))))

(test-equal "empty private key file path rejected"
  #f
  (validate-cli-args '((port . 1965) (static-dir . "./static") (cert . "cert.pem") (key . ""))))

(test-equal "same file for cert and key rejected"
  #f
  (validate-cli-args '((port . 1965) (static-dir . "./static") (cert . "same.pem") (key . "same.pem"))))

(test-end "argument-validation")

;;; Test suite for error handling
(test-begin "cli-error-handling")

(test-equal "invalid arguments return error message"
  'error
  (let ((result (catch #t
                  (lambda () (parse-cli-args '("server.scm" "--invalid-flag")))
                  (lambda (key . args) 'error))))
    result))

(test-equal "non-numeric port value returns error"
  'error
  (let ((result (catch #t
                  (lambda () (parse-cli-args '("server.scm" "--port" "not-a-number")))
                  (lambda (key . args) 'error))))
    result))

(test-equal "missing value for argument returns error"
  'error
  (let ((result (catch #t
                  (lambda () (parse-cli-args '("server.scm" "--port")))
                  (lambda (key . args) 'error))))
    result))

(test-end "cli-error-handling")

;;; Export for test runner
(define (run-cli-args-tests)
  (display "Running CLI arguments tests...\n")
  ;; Tests run when module is loaded
  )