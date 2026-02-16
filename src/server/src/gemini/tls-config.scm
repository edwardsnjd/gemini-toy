;;; TLS Configuration and Certificate Management
;;; TLS context setup and self-signed certificate generation for Gemini

(define-module (gemini tls-config)
  #:use-module (gnutls)
  #:use-module (ice-9 textual-ports)
  #:use-module (ice-9 ftw)
  #:use-module (srfi srfi-2)  ; for and-let*
  #:use-module (gemini utils)
  #:export (setup-tls-context
            load-certificates
            generate-self-signed-cert))

;;; Alias for imported file validation utility
(define certificate-file-accessible? file-is-readable-regular-file?)

;;; Validate PEM format certificate/key content
(define (validate-pem-format content cert?)
  (let* ((begin-marker (if cert? "-----BEGIN CERTIFICATE-----" "-----BEGIN PRIVATE KEY-----"))
         (end-marker (if cert? "-----END CERTIFICATE-----" "-----END PRIVATE KEY-----"))
         (begin-pos (string-contains content begin-marker))
         (end-pos (string-contains content end-marker)))
    (and begin-pos end-pos (< begin-pos end-pos))))

;;; Load and validate certificate and key files
(define (load-certificates cert-file key-file)
  (safe-operation
    (and (certificate-file-accessible? cert-file)
         (certificate-file-accessible? key-file)
         (and-let* ((cert-content (call-with-input-file cert-file get-string-all))
                    (key-content (call-with-input-file key-file get-string-all))
                    (_ (validate-pem-format cert-content #t))
                    (_ (validate-pem-format key-content #f)))
           (cons cert-content key-content)))))

;;; Set up TLS context for Gemini server
(define (setup-tls-context cert-file key-file)
  (safe-operation
    (and-let* ((certs (load-certificates cert-file key-file))
               (cred (make-certificate-credentials)))
      (set-certificate-credentials-x509-key-files!
        cred cert-file key-file x509-certificate-format/pem)
      cred)))

;;; Generate self-signed certificate for development and testing
(define (generate-self-signed-cert cert-file key-file)
  (safe-operation
    (ensure-certificate-directories cert-file key-file)
    (generate-openssl-certificate cert-file key-file)))

(define (ensure-certificate-directories cert-file key-file)
  (for-each ensure-directory-exists 
            (list (dirname cert-file) (dirname key-file))))

(define (ensure-directory-exists dir-path)
  (unless (file-exists? dir-path)
    (mkdir dir-path)))

(define (generate-openssl-certificate cert-file key-file)
  (zero? (system* "openssl" "req" "-x509" "-newkey" "rsa:2048"
                  "-keyout" key-file "-out" cert-file "-days" "365"
                  "-nodes" "-subj" "/CN=localhost" "-batch")))