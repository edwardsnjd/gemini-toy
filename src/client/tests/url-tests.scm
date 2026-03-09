(define-module (tests url)
  #:use-module (srfi srfi-64)
  #:use-module (client url))

(test-begin "url-parsing")

(test-equal "parse simple URL without port and path"
  '("example.com" 1965 "/")
  (parse-url "gemini://example.com"))

(test-equal "parse URL with trailing slash"
  '("example.com" 1965 "/")
  (parse-url "gemini://example.com/"))

(test-equal "parse URL with port and path"
  '("example.com" 1234 "/foo?bar=baz")
  (parse-url "gemini://example.com:1234/foo?bar=baz"))

(test-equal "invalid scheme should raise error"
  'error
  (let ((result (catch #t
                  (lambda () (parse-url "http://example.com"))
                  (lambda (key . args) 'error))))
    result))

(test-end "url-parsing")
