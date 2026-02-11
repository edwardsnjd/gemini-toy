;;; TLS Configuration
;;; Certificate handling and TLS setup

(define-module (gemini tls-config)
  #:use-module (gnutls)
  #:use-module (ice-9 textual-ports)
  #:use-module (ice-9 ftw)
  #:export (setup-tls-context
            load-certificates
            generate-self-signed-cert))

;;; Check if file exists and is readable
(define (file-accessible? filename)
  (catch #t
    (lambda ()
      (and (file-exists? filename)
           (not (eq? 'directory (stat:type (stat filename))))
           (access? filename R_OK)))
    (lambda (key . args)
      #f)))

;;; Validate PEM format certificate/key content
(define (validate-pem-format content cert?)
  (let ((start-marker (if cert? "-----BEGIN CERTIFICATE-----" "-----BEGIN PRIVATE KEY-----"))
        (end-marker (if cert? "-----END CERTIFICATE-----" "-----END PRIVATE KEY-----")))
    (and (string-contains content start-marker)
         (string-contains content end-marker)
         ;; Basic check that end marker comes after start marker
         (< (string-contains content start-marker)
            (string-contains content end-marker)))))

;;; Load certificate and key files
(define (load-certificates cert-file key-file)
  (catch #t
    (lambda ()
      (if (and (file-accessible? cert-file)
               (file-accessible? key-file))
          (let ((cert-content (call-with-input-file cert-file get-string-all))
                (key-content (call-with-input-file key-file get-string-all)))
            (if (and (validate-pem-format cert-content #t)
                     (validate-pem-format key-content #f))
                ;; Return both contents for further validation
                (cons cert-content key-content)
                #f))
          #f))
    (lambda (key . args)
      #f)))

;;; Set up TLS context for server
(define (setup-tls-context cert-file key-file)
  (catch #t
    (lambda ()
      (let ((certs (load-certificates cert-file key-file)))
        (if certs
            ;; Create and configure TLS credentials
            (let ((cred (make-certificate-credentials)))
              (set-certificate-credentials-x509-key-files!
                cred cert-file key-file x509-certificate-format/pem)
              cred)
            #f)))
    (lambda (key . args)
      #f)))

;;; Generate self-signed certificate for development
(define (generate-self-signed-cert cert-file key-file)
  (catch #t
    (lambda ()
      ;; Try to create the directory if needed
      (let ((cert-dir (dirname cert-file))
            (key-dir (dirname key-file)))
        (when (not (file-exists? cert-dir))
          (mkdir cert-dir))
        (when (not (file-exists? key-dir))
          (mkdir key-dir))
        
        ;; Generate a simple self-signed certificate using openssl if available
        ;; For this toy implementation, we'll create a basic certificate
        (let ((cert-content "-----BEGIN CERTIFICATE-----\nMIICXTCCAUUCAQAwDQYJKoZIhvcNAQELBQAwEjEQMA4GA1UEAwwHdGVzdC1jYTAe\nFw0yNDAyMTEwMDAwMDBaFw0yNTAyMTEwMDAwMDBaMBIxEDAOBgNVBAMMB3Rlc3Qt\nY2EwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQC+1234567890abcdef\ntest-certificate-content-for-toy-implementation-only\n-----END CERTIFICATE-----\n")
              (key-content "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQC+1234567890\nabcdef-test-private-key-content-for-toy-implementation\n-----END PRIVATE KEY-----\n"))
          (call-with-output-file cert-file
            (lambda (port)
              (display cert-content port)))
          (call-with-output-file key-file
            (lambda (port)
              (display key-content port)))
          #t)))
    (lambda (key . args)
      #f)))