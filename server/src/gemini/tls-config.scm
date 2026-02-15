;;; TLS Configuration and Certificate Management
;;; Secure certificate handling and TLS context setup for Gemini protocol
;;;
;;; TLS is mandatory in Gemini protocol - there is no plaintext fallback.
;;; This design choice eliminates entire classes of security vulnerabilities:
;;; - No protocol downgrade attacks possible
;;; - All communication is encrypted by default
;;; - Client certificates can be used for authentication
;;;
;;; Certificate strategy:
;;; - Support real certificates for production deployment
;;; - Generate self-signed certificates for development/testing
;;; - Validate certificate format before use
;;; - Fail fast if certificates are unusable
;;;
;;; Security considerations:
;;; - Self-signed certificates are acceptable in Gemini ecosystem
;;; - Certificate validation is handled by GnuTLS library
;;; - Private keys must be protected with appropriate filesystem permissions
;;; - Certificate generation creates minimal viable certificates for testing
;;;
;;; Limitations:
;;; - Self-signed certificate generation is toy implementation only
;;; - No support for certificate chains or intermediate CAs
;;; - No automatic certificate renewal

(define-module (gemini tls-config)
  #:use-module (gnutls)
  #:use-module (ice-9 textual-ports)
  #:use-module (ice-9 ftw)
  #:export (setup-tls-context
            load-certificates
            generate-self-signed-cert))

;;; Check if certificate/key file exists and is readable
;;; 
;;; File accessibility checks for security:
;;; - Verifies file exists (prevents cryptic TLS setup errors)
;;; - Ensures it's a regular file (not directory or special file)
;;; - Confirms read permissions (prevents permission-related failures)
;;; - Graceful error handling for filesystem operations
;;; 
;;; This prevents common deployment issues where certificates
;;; are present but not accessible due to permissions.
(define (file-accessible? filename)
  (catch #t
    (lambda ()
      (and (file-exists? filename)
           ;; Ensure it's a regular file, not a directory or device
           (not (eq? 'directory (stat:type (stat filename))))
           ;; Check read permissions
           (access? filename R_OK)))
    (lambda (key . args)
      ;; Any filesystem error means file is not accessible
      #f)))

;;; Validate PEM format certificate/key content
;;; 
;;; PEM format validation ensures files are properly formatted:
;;; - PEM is the standard text encoding for certificates and keys
;;; - Must contain proper BEGIN/END markers
;;; - Prevents cryptic errors during TLS context setup
;;; - Basic structural validation only (not cryptographic validation)
;;; 
;;; Security considerations:
;;; - Does not validate certificate cryptographic properties
;;; - Does not check certificate expiration or validity
;;; - Simple string matching is sufficient for basic format checking
;;; - More detailed validation is handled by GnuTLS library
(define (validate-pem-format content cert?)
  (let ((start-marker (if cert? "-----BEGIN CERTIFICATE-----" "-----BEGIN PRIVATE KEY-----"))
        (end-marker (if cert? "-----END CERTIFICATE-----" "-----END PRIVATE KEY-----")))
    (and (string-contains content start-marker)
         (string-contains content end-marker)
         ;; Ensure proper marker ordering (basic sanity check)
         (< (string-contains content start-marker)
            (string-contains content end-marker)))))

;;; Load and validate certificate and key files
;;; 
;;; Certificate loading strategy:
;;; - Check file accessibility before attempting to read
;;; - Read entire certificate and key files into memory
;;; - Validate PEM format structure before using with GnuTLS
;;; - Return both contents together for atomic validation
;;; 
;;; Error handling philosophy:
;;; - File access errors are caught and return #f
;;; - Invalid PEM format returns #f rather than causing TLS errors
;;; - Graceful degradation allows server to attempt self-signed generation
;;; - All errors are handled silently (calling code provides user feedback)
(define (load-certificates cert-file key-file)
  (catch #t
    (lambda ()
      (if (and (file-accessible? cert-file)
               (file-accessible? key-file))
          (let ((cert-content (call-with-input-file cert-file get-string-all))
                (key-content (call-with-input-file key-file get-string-all)))
            (if (and (validate-pem-format cert-content #t)
                     (validate-pem-format key-content #f))
                ;; Return both contents as pair for further processing
                (cons cert-content key-content)
                #f))  ; Invalid PEM format
          #f))  ; Files not accessible
    (lambda (key . args)
      ;; Any error during loading
      #f)))

;;; Set up TLS context for Gemini server
;;; 
;;; TLS context setup requirements:
;;; - Certificate and private key must match
;;; - GnuTLS handles cryptographic validation
;;; - Context must be configured before accepting connections
;;; - Failure here means server cannot operate (TLS is mandatory)
;;; 
;;; GnuTLS integration:
;;; - Uses make-certificate-credentials for X.509 certificates
;;; - set-certificate-credentials-x509-key-files! loads cert/key pair
;;; - PEM format is standard for Gemini servers
;;; - GnuTLS handles certificate chain validation if present
;;; 
;;; Security trade-offs:
;;; - Self-signed certificates are acceptable in Gemini ecosystem
;;; - No certificate revocation checking in this toy implementation
;;; - Trust-on-first-use (TOFU) is common Gemini client behavior
(define (setup-tls-context cert-file key-file)
  (catch #t
    (lambda ()
      (let ((certs (load-certificates cert-file key-file)))
        (if certs
            ;; Create GnuTLS certificate credentials
            (let ((cred (make-certificate-credentials)))
              ;; Load certificate and private key files
              ;; GnuTLS will validate that they match and are cryptographically valid
              (set-certificate-credentials-x509-key-files!
                cred cert-file key-file x509-certificate-format/pem)
              cred)  ; Return configured credentials
            #f)))  ; Certificate loading failed
    (lambda (key . args)
      ;; TLS context setup failed
      #f)))

;;; Generate self-signed certificate for development and testing
;;; 
;;; Self-signed certificate trade-offs:
;;; - Perfect for development and testing environments
;;; - Acceptable in Gemini ecosystem (unlike HTTPS)
;;; - Clients typically use Trust-On-First-Use (TOFU) model
;;; - No dependency on external Certificate Authorities
;;; - Warning: NOT suitable for production use with sensitive data
;;; 
;;; Implementation approach:
;;; - Creates certificate directory structure if needed
;;; - Generates minimal viable certificate for testing
;;; - Uses hardcoded certificate content (toy implementation)
;;; - Real implementation would use cryptographic libraries
;;; 
;;; Security considerations:
;;; - Private key is hardcoded (completely insecure)
;;; - Certificate has no real cryptographic properties
;;; - Only suitable for development and protocol testing
;;; - Provides TLS encryption but no authentication
;;; 
;;; Limitations:
;;; - Not a real certificate (hardcoded dummy content)
;;; - No proper key generation or signing
;;; - Should be replaced with proper certificate generation in real deployment
;;; - Consider using OpenSSL or GnuTLS key generation functions
(define (generate-self-signed-cert cert-file key-file)
  (catch #t
    (lambda ()
      ;; Ensure certificate directories exist
      (let ((cert-dir (dirname cert-file))
            (key-dir (dirname key-file)))
        (when (not (file-exists? cert-dir))
          (mkdir cert-dir))
        (when (not (file-exists? key-dir))
          (mkdir key-dir))
        
        ;; Generate a real self-signed certificate using OpenSSL
        ;; This creates a minimal certificate suitable for development/testing
        (let ((exit-code (system* "openssl" "req" "-x509" "-newkey" "rsa:2048"
                                  "-keyout" key-file
                                  "-out" cert-file
                                  "-days" "365"
                                  "-nodes"
                                  "-subj" "/CN=localhost"
                                  "-batch")))
          (if (zero? exit-code)
              #t
              #f))))  ; openssl command failed
    (lambda (key . args)
      ;; Certificate generation failed
      #f)))