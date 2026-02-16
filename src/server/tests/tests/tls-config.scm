;;; Unit Tests: TLS Configuration
;;; Tests for certificate handling and TLS setup

(define-module (tests tls-config)
  #:use-module (srfi srfi-64)
  #:use-module (ice-9 textual-ports)  ; For get-string-all
  #:use-module (gemini tls-config)
  #:use-module (ice-9 ftw)
  #:use-module (tests test-utils))

;;; Test suite for certificate validation and loading
(test-begin "certificate-validation")

(test-assert "valid certificate files can be loaded"
  (with-temp-cert-files (cert key)
    (load-certificates cert key)))

(test-equal "missing certificate file returns error"
  #f
  (load-certificates "/nonexistent/cert.pem" "/nonexistent/key.pem"))

(test-equal "certificate file without proper PEM format fails"
  #f
  (with-temp-cert-files-invalid (cert key "not a certificate" "not a private key")
    (load-certificates cert key)))

(test-equal "directory path instead of file fails"
  #f
  (load-certificates "/tmp" "/tmp"))

(test-end "certificate-validation")

;;; Test suite for TLS context setup
(test-begin "tls-context")

(test-assert "TLS context setup with valid certificates succeeds"
  (with-temp-cert-files (cert key)
    (setup-tls-context cert key)))

(test-equal "TLS context setup with missing files fails"
  #f
  (setup-tls-context "/nonexistent/cert.pem" "/nonexistent/key.pem"))

(test-equal "TLS context setup with invalid certificates fails"
  #f
  (with-temp-cert-files-invalid (cert key "not a certificate" "not a private key")
    (setup-tls-context cert key)))

(test-end "tls-context")

;;; Test suite for self-signed certificate generation
(test-begin "cert-generation")

(test-assert "self-signed certificate generation creates files"
  (let ((cert-file "/tmp/generated-cert.pem")
        (key-file "/tmp/generated-key.pem"))
    (dynamic-wind
      (lambda ()
        (when (file-exists? cert-file) (delete-file cert-file))
        (when (file-exists? key-file) (delete-file key-file)))
      (lambda ()
        (let ((result (generate-self-signed-cert cert-file key-file)))
          (and result (file-exists? cert-file) (file-exists? key-file))))
      (lambda ()
        (when (file-exists? cert-file) (delete-file cert-file))
        (when (file-exists? key-file) (delete-file key-file))))))

(test-equal "certificate generation with invalid path fails"
  #f
  (generate-self-signed-cert "/invalid/path/cert.pem" "/invalid/path/key.pem"))

(test-assert "certificate generation overwrites existing files"
  (let ((cert-file "/tmp/existing-cert.pem")
        (key-file "/tmp/existing-key.pem"))
    (dynamic-wind
      (lambda ()
        (call-with-output-file cert-file (lambda (p) (display "old certificate" p)))
        (call-with-output-file key-file (lambda (p) (display "old key" p))))
      (lambda ()
        (let ((result (generate-self-signed-cert cert-file key-file)))
          (and result 
               (not (string=? (call-with-input-file cert-file get-string-all) "old certificate"))
               (not (string=? (call-with-input-file key-file get-string-all) "old key")))))
      (lambda ()
        (delete-file cert-file)
        (delete-file key-file)))))

(test-end "cert-generation")

;;; Export for test runner
(define (run-tls-config-tests)
  (display "Running TLS config tests...\n")
  ;; Tests run when module is loaded
  )
