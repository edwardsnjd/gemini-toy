;;; Test Utilities and Fixtures
;;; Common macros and helpers for test setup/teardown

(define-module (tests test-utils)
  #:use-module (srfi srfi-64)
  #:use-module (ice-9 textual-ports)
  #:use-module (ice-9 ftw)  ; for scandir
  #:export (with-temp-cert-files
            with-temp-cert-files-invalid
            with-test-static-dir
            with-test-static-file
            with-test-directory
            generate-test-certs
            rm-rf
            create-test-file))

;;; Generate real test certificates using openssl
(define (generate-test-certs cert-file key-file)
  (zero? (system* "openssl" "req" "-x509" "-newkey" "rsa:2048"
                   "-keyout" key-file "-out" cert-file
                   "-days" "1" "-nodes" "-subj" "/CN=test"
                   "-batch")))

;;; Recursively delete directory and contents
(define (rm-rf path)
  (when (file-exists? path)
    (if (file-is-directory? path)
        (begin
          (for-each (lambda (entry)
                      (unless (member entry '("." ".."))
                        (rm-rf (string-append path "/" entry))))
                    (scandir path))
          (rmdir path))
        (delete-file path))))

;;; Create a test file with content
(define (create-test-file path content)
  (let ((dir (dirname path)))
    (unless (file-exists? dir)
      (mkdir dir)))
  (call-with-output-file path
    (lambda (port)
      (display content port))))

;;; Macro: with-temp-cert-files - setup/teardown for valid cert tests
(define-syntax with-temp-cert-files
  (syntax-rules ()
    ((with-temp-cert-files (cert-var key-var) body ...)
     (let ((cert-var "/tmp/test-cert.pem")
           (key-var "/tmp/test-key.pem"))
       (dynamic-wind
         (lambda () (generate-test-certs cert-var key-var))
         (lambda () body ...)
         (lambda ()
           (when (file-exists? cert-var) (delete-file cert-var))
           (when (file-exists? key-var) (delete-file key-var))))))))

;;; Macro: with-temp-cert-files-invalid - setup/teardown for invalid cert tests
(define-syntax with-temp-cert-files-invalid
  (syntax-rules ()
    ((with-temp-cert-files-invalid (cert-var key-var cert-content key-content) body ...)
     (let ((cert-var "/tmp/invalid-cert.pem")
           (key-var "/tmp/invalid-key.pem"))
       (dynamic-wind
         (lambda ()
           (call-with-output-file cert-var
             (lambda (port) (display cert-content port)))
           (call-with-output-file key-var
             (lambda (port) (display key-content port))))
         (lambda () body ...)
         (lambda ()
           (when (file-exists? cert-var) (delete-file cert-var))
           (when (file-exists? key-var) (delete-file key-var))))))))

;;; Macro: with-test-static-dir - setup/teardown for static file tests
(define-syntax with-test-static-dir
  (syntax-rules ()
    ((with-test-static-dir (dir-var) body ...)
     (let ((dir-var "/tmp/test-static"))
       (dynamic-wind
         (lambda ()
           (when (file-exists? dir-var) (rm-rf dir-var))
           (mkdir dir-var))
         (lambda () body ...)
         (lambda () (rm-rf dir-var)))))))

;;; Macro: with-test-static-file - create single file in temp directory
(define-syntax with-test-static-file
  (syntax-rules ()
    ((with-test-static-file (dir-var file-path content) body ...)
     (let ((dir-var "/tmp/test-static"))
       (dynamic-wind
         (lambda ()
           (when (file-exists? dir-var) (rm-rf dir-var))
           (mkdir dir-var)
           (create-test-file (string-append dir-var file-path) content))
         (lambda () body ...)
         (lambda () (rm-rf dir-var)))))))

;;; Macro: with-test-directory - create directory structure
(define-syntax with-test-directory
  (syntax-rules ()
    ((with-test-directory (dir-var sub-dir) body ...)
     (let ((dir-var "/tmp/test-static"))
       (dynamic-wind
         (lambda ()
           (when (file-exists? dir-var) (rm-rf dir-var))
           (mkdir dir-var)
           (mkdir (string-append dir-var sub-dir)))
         (lambda () body ...)
         (lambda () (rm-rf dir-var)))))))
