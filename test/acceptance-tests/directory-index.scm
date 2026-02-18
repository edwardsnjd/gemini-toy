;;; Acceptance Test: Directory Index Handling
;;; Black-box tests for directory index file serving

(define-module (directory-index)
  #:use-module (srfi srfi-64)
  #:use-module (lib))

(test-begin "directory-index")

(test-begin "root directory serves index.gmi")
(with-gemini-request "/"
  (lambda (response)
    (assert-status response 20 "root index status")
    (assert-mime-type response "text/gemini; charset=utf-8" "root index content type")
    (assert-body-contains response "Gemini Test Server" "root index body contains header")))
(test-end)

(test-begin "root without trailing slash serves index.gmi")
(with-gemini-request ""
  (lambda (response)
    (assert-status response 20 "no-slash index status")
    (assert-mime-type response "text/gemini; charset=utf-8" "no-slash index content type")
    (assert-body-contains response "Gemini Test Server" "no-slash index body contains header")))
(test-end)

(test-begin "subdirectory with index.gmi")
(with-gemini-request "/subdir/"
  (lambda (response)
    (assert-status response 20 "subdir index status")
    (assert-mime-type response "text/gemini; charset=utf-8" "subdir index content type")))
(test-end)

(test-begin "subdirectory without index file returns 51 (Not Found)")
(with-gemini-request "/empty-dir/"
  (lambda (response)
    (assert-status response 51 "empty dir status")
    (assert-meta-contains response "not found" "not found meta contains error")))
(test-end)

(test-end "directory-index")
