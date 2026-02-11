#!/bin/bash

# Manual Error Condition Testing for Gemini Server
# This script tests error conditions manually without requiring the full server to be running

set -e

echo "=== GEMINI SERVER ERROR CONDITION TESTING (Manual Mode) ==="
echo "Testing Gemini protocol error conditions"
echo "Timestamp: $(date)"
echo ""

# Test if we have the necessary tools
echo "Checking available tools:"
command -v openssl >/dev/null 2>&1 && echo "✅ OpenSSL available" || echo "❌ OpenSSL not available"
command -v nc >/dev/null 2>&1 && echo "✅ netcat available" || echo "❌ netcat not available"
command -v guile >/dev/null 2>&1 && echo "✅ Guile available" || echo "❌ Guile not available"
echo ""

# Create a simple test server if the main server isn't working
echo "=== Creating a simple test server for manual testing ==="

cat > simple-test-server.scm << 'EOF'
#!/usr/bin/env guile
!#

;;; Simple Gemini test server for error condition testing
(use-modules (ice-9 textual-ports)
             (ice-9 format))

;; Simple socket server that accepts connections and responds with Gemini protocol
(define (handle-request request)
  "Process a Gemini request and return appropriate response"
  (cond
    ;; Empty request
    ((string=? request "") "59 Bad Request - empty request\r\n")
    
    ;; Request too long (>1024 bytes)
    ((> (string-length request) 1024) "59 Bad Request - request too long\r\n")
    
    ;; Invalid URI format
    ((not (string-prefix? "gemini://" request)) "59 Bad Request - invalid scheme\r\n")
    
    ;; Path traversal attempts
    ((string-contains request "..") "59 Bad Request - path traversal not allowed\r\n")
    
    ;; URI with userinfo
    ((string-match "gemini://[^/]*@" request) "59 Bad Request - userinfo not allowed\r\n")
    
    ;; URI with fragment
    ((string-contains request "#") "59 Bad Request - fragment not allowed\r\n")
    
    ;; Non-existent file
    ((string-suffix? "/does-not-exist.gmi" request) "51 Not Found\r\n")
    
    ;; Default success response
    (else "20 text/gemini\r\n# Test Page\n=> /test.gmi Test link\n")))

;; For testing purposes, we'll create a simple HTTP server that responds with Gemini-like responses
;; since setting up TLS in a simple script is complex

(define (start-simple-server port)
  "Start a simple server for testing (without TLS for simplicity)"
  (let ((server-sock (socket PF_INET SOCK_STREAM 0)))
    (setsockopt server-sock SOL_SOCKET SO_REUSEADDR 1)
    (bind server-sock AF_INET INADDR_ANY port)
    (listen server-sock 5)
    
    (format #t "Simple test server listening on port ~a~%" port)
    (format #t "Note: This is a plain TCP server (no TLS) for testing protocol logic~%")
    
    (let loop ()
      (let* ((client-sock (accept server-sock))
             (client-conn (car client-sock)))
        (catch #t
          (lambda ()
            (let ((request (get-line (car (fdopen client-conn "r+")))))
              (if (not (eof-object? request))
                  (let ((response (handle-request (string-trim-right request))))
                    (display response (cdr (fdopen client-conn "r+")))
                    (force-output (cdr (fdopen client-conn "r+")))))))
          (lambda (key . args)
            (format #t "Error handling client: ~a ~a~%" key args)))
        
        (close client-conn)
        (loop)))))

;; Start server on port 1966 (different from standard Gemini port)
(start-simple-server 1966)
EOF

echo "Created simple test server script"
echo ""

# Function to test with simple server
test_simple_server() {
    local test_name="$1"
    local request="$2"
    local description="$3"
    
    echo "--- Test: $test_name ---"
    echo "Description: $description"
    echo "Request: $request"
    
    response=$(echo -e "$request" | timeout 5 nc localhost 1966 2>/dev/null || echo "CONNECTION_FAILED")
    echo "Response: $response"
    echo ""
}

# Start the simple server in background
echo "Starting simple test server on port 1966..."
nohup guile simple-test-server.scm > simple-server.log 2>&1 &
SIMPLE_SERVER_PID=$!
echo "Simple server started with PID: $SIMPLE_SERVER_PID"

# Wait for server to start
sleep 3

echo "=== TESTING PROTOCOL ERROR CONDITIONS ==="

# Test 1: Valid request
test_simple_server "Valid Request" "gemini://localhost:1966/" "Basic valid Gemini request"

# Test 2: Empty request
test_simple_server "Empty Request" "" "Empty request should return 59 error"

# Test 3: Request too long
long_path=$(printf 'a%.0s' {1..1100})
test_simple_server "Request Too Long" "gemini://localhost:1966/$long_path" "Request exceeding 1024 bytes"

# Test 4: Invalid scheme
test_simple_server "Invalid Scheme" "http://localhost:1966/" "Non-gemini scheme should be rejected"

# Test 5: Path traversal
test_simple_server "Path Traversal" "gemini://localhost:1966/../../../etc/passwd" "Path traversal attempt"

# Test 6: URI with userinfo
test_simple_server "URI with Userinfo" "gemini://user:pass@localhost:1966/" "URI with userinfo should be rejected"

# Test 7: URI with fragment
test_simple_server "URI with Fragment" "gemini://localhost:1966/page#fragment" "URI with fragment should be rejected"

# Test 8: Non-existent file
test_simple_server "Non-existent File" "gemini://localhost:1966/does-not-exist.gmi" "Request for non-existent file"

# Test 9: Binary junk
test_simple_server "Binary Junk" "$(echo -e '\x00\x01\x02\x03\x04\x05')" "Binary garbage data"

echo "=== TESTING WITH OPENSSL (if available) ==="

if command -v openssl >/dev/null 2>&1; then
    echo "Testing TLS connection behavior (will fail as expected since our test server doesn't use TLS):"
    
    echo "--- TLS Connection Test ---"
    echo "Attempting TLS connection to localhost:1965 (should fail if no proper server running):"
    openssl_result=$(timeout 5 openssl s_client -connect localhost:1965 -servername localhost 2>&1 || echo "TLS_CONNECTION_FAILED")
    echo "OpenSSL result: $openssl_result"
    echo ""
    
    echo "--- Certificate Information Test ---"
    echo "Checking if we can get certificate info from running server:"
    cert_info=$(timeout 5 openssl s_client -connect localhost:1965 -servername localhost </dev/null 2>&1 | grep -E "(subject|issuer|notAfter)" || echo "NO_CERT_INFO")
    echo "Certificate info: $cert_info"
else
    echo "OpenSSL not available - skipping TLS tests"
fi

echo ""
echo "=== ADVANCED PROTOCOL TESTS ==="

# Test malformed requests that should trigger specific errors
echo "Testing malformed protocol requests:"

test_simple_server "Missing CRLF" "gemini://localhost:1966/test" "Request without proper CRLF termination"

test_simple_server "Double Slash" "gemini://localhost:1966//double-slash" "URI with double slashes"

test_simple_server "Invalid Characters" "gemini://localhost:1966/test with spaces" "URI with spaces (should be encoded)"

# Clean up
echo "=== CLEANUP ==="
echo "Stopping simple test server (PID: $SIMPLE_SERVER_PID)..."
kill $SIMPLE_SERVER_PID 2>/dev/null || echo "Server already stopped"

echo ""
echo "=== TEST SUMMARY ==="
echo "Manual error condition testing completed."
echo "Key findings:"
echo "- Protocol validation can be tested independently of TLS"
echo "- Error responses should follow Gemini spec (status codes 59, 51, etc.)"
echo "- Path traversal, userinfo, and fragment handling is critical"
echo "- Request length limits must be enforced"
echo ""
echo "For full TLS testing, ensure the main Gemini server is running with valid certificates."
echo "Simple server log: simple-server.log"