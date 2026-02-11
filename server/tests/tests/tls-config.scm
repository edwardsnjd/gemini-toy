;;; Unit Tests: TLS Configuration
;;; Tests for certificate handling and TLS setup

(add-to-load-path "../src")

(define-module (tests tls-config)
  #:use-module (srfi srfi-64)
  #:use-module (gemini tls-config)
  #:use-module (ice-9 ftw))

;;; Test suite for certificate validation and loading
(test-begin "certificate-validation")

(test-equal "valid certificate files can be loaded"
  #t
  (let ((cert-file "/tmp/test-cert.pem")
        (key-file "/tmp/test-key.pem"))
    ;; Create dummy cert and key files for testing
    (call-with-output-file cert-file
      (lambda (port)
        (display "-----BEGIN CERTIFICATE-----\nMIICXTCCAUUCAQAwDQYJKoZIhvcNAQELBQAwEjEQMA4GA1UEAwwHdGVzdC1jYTAe\n-----END CERTIFICATE-----\n" port)))
    (call-with-output-file key-file
      (lambda (port)
        (display "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQC+1234567890\n-----END PRIVATE KEY-----\n" port)))
    (let ((result (load-certificates cert-file key-file)))
      ;; Clean up test files
      (delete-file cert-file)
      (delete-file key-file)
      (if result #t #f))))

(test-equal "missing certificate file returns error"
  #f
  (load-certificates "/nonexistent/cert.pem" "/nonexistent/key.pem"))

(test-equal "certificate file without proper PEM format fails"
  #f
  (let ((cert-file "/tmp/invalid-cert.pem")
        (key-file "/tmp/invalid-key.pem"))
    ;; Create invalid cert and key files
    (call-with-output-file cert-file
      (lambda (port)
        (display "not a certificate" port)))
    (call-with-output-file key-file
      (lambda (port)
        (display "not a private key" port)))
    (let ((result (load-certificates cert-file key-file)))
      ;; Clean up test files
      (delete-file cert-file)
      (delete-file key-file)
      (if result #t #f))))

(test-equal "certificate file without matching key fails"
  #f
  (let ((cert-file "/tmp/test-cert.pem")
        (key-file "/tmp/wrong-key.pem"))
    ;; Create cert file and mismatched key file
    (call-with-output-file cert-file
      (lambda (port)
        (display "-----BEGIN CERTIFICATE-----\nMIICXTCCAUUCAQAwDQYJKoZIhvcNAQELBQAwEjEQMA4GA1UEAwwHdGVzdC1jYTAe\n-----END CERTIFICATE-----\n" port)))
    (call-with-output-file key-file
      (lambda (port)
        (display "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQC+9999999999\n-----END PRIVATE KEY-----\n" port)))
    (let ((result (load-certificates cert-file key-file)))
      ;; Clean up test files
      (delete-file cert-file)
      (delete-file key-file)
      (if result #t #f))))

(test-equal "directory path instead of file fails"
  #f
  (load-certificates "/tmp" "/tmp"))

(test-end "certificate-validation")

;;; Test suite for TLS context setup
(test-begin "tls-context")

(test-equal "TLS context setup with valid certificates succeeds"
  #t
  (let ((cert-file "/tmp/test-cert.pem")
        (key-file "/tmp/test-key.pem"))
    ;; Create dummy cert and key files
    (call-with-output-file cert-file
      (lambda (port)
        (display "-----BEGIN CERTIFICATE-----\nMIICXTCCAUUCAQAwDQYJKoZIhvcNAQELBQAwEjEQMA4GA1UEAwwHdGVzdC1jYTAe\n-----END CERTIFICATE-----\n" port)))
    (call-with-output-file key-file
      (lambda (port)
        (display "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQC+1234567890\n-----END PRIVATE KEY-----\n" port)))
    (let ((ctx (setup-tls-context cert-file key-file)))
      ;; Clean up test files
      (delete-file cert-file)
      (delete-file key-file)
      (if ctx #t #f))))

(test-equal "TLS context setup with missing files fails"
  #f
  (setup-tls-context "/nonexistent/cert.pem" "/nonexistent/key.pem"))

(test-equal "TLS context setup with invalid certificates fails"
  #f
  (let ((cert-file "/tmp/invalid-cert.pem")
        (key-file "/tmp/invalid-key.pem"))
    ;; Create invalid files
    (call-with-output-file cert-file
      (lambda (port)
        (display "not a certificate" port)))
    (call-with-output-file key-file
      (lambda (port)
        (display "not a private key" port)))
    (let ((ctx (setup-tls-context cert-file key-file)))
      ;; Clean up test files
      (delete-file cert-file)
      (delete-file key-file)
      (if ctx #t #f))))

(test-end "tls-context")

;;; Test suite for self-signed certificate generation
(test-begin "cert-generation")

(test-equal "self-signed certificate generation creates files"
  #t
  (let ((cert-file "/tmp/generated-cert.pem")
        (key-file "/tmp/generated-key.pem"))
    ;; Remove files if they exist
    (when (file-exists? cert-file) (delete-file cert-file))
    (when (file-exists? key-file) (delete-file key-file))
    (let ((result (generate-self-signed-cert cert-file key-file)))
      (let ((files-exist (and (file-exists? cert-file) (file-exists? key-file))))
        ;; Clean up generated files
        (when (file-exists? cert-file) (delete-file cert-file))
        (when (file-exists? key-file) (delete-file key-file))
        (and result files-exist)))))

(test-equal "certificate generation with invalid path fails"
  #f
  (generate-self-signed-cert "/invalid/path/cert.pem" "/invalid/path/key.pem"))

(test-equal "certificate generation overwrites existing files"
  #t
  (let ((cert-file "/tmp/existing-cert.pem")
        (key-file "/tmp/existing-key.pem"))
    ;; Create existing files with different content
    (call-with-output-file cert-file
      (lambda (port)
        (display "old certificate" port)))
    (call-with-output-file key-file
      (lambda (port)
        (display "old key" port)))
    (let ((result (generate-self-signed-cert cert-file key-file)))
      ;; Check if files were overwritten (should have different content)
      (let ((new-cert-content (call-with-input-file cert-file get-string-all))
            (new-key-content (call-with-input-file key-file get-string-all)))
        ;; Clean up
        (delete-file cert-file)
        (delete-file key-file)
        (and result 
             (not (string=? new-cert-content "old certificate"))
             (not (string=? new-key-content "old key")))))))

(test-end "cert-generation")

;;; Export for test runner
(define (run-tls-config-tests)
  (display "Running TLS config tests...\n")
  ;; Tests run when module is loaded
  )