#!/bin/bash

# Comprehensive Gemini Server Error Condition Testing
# Tests various error conditions and documents findings

set -e

SERVER_HOST="localhost"
SERVER_PORT="1965"
TEST_RESULTS_FILE="comprehensive-test-results.txt"

echo "=== COMPREHENSIVE GEMINI SERVER ERROR CONDITION TESTING ===" | tee "$TEST_RESULTS_FILE"
echo "Testing against: gemini://$SERVER_HOST:$SERVER_PORT/" | tee -a "$TEST_RESULTS_FILE"
echo "Timestamp: $(date)" | tee -a "$TEST_RESULTS_FILE"
echo "" | tee -a "$TEST_RESULTS_FILE"

# Check available tools
echo "=== AVAILABLE TOOLS ===" | tee -a "$TEST_RESULTS_FILE"
command -v openssl >/dev/null 2>&1 && echo "✅ OpenSSL: $(openssl version)" | tee -a "$TEST_RESULTS_FILE" || echo "❌ OpenSSL not available" | tee -a "$TEST_RESULTS_FILE"
command -v nc >/dev/null 2>&1 && echo "✅ netcat: $(nc -h 2>&1 | head -1)" | tee -a "$TEST_RESULTS_FILE" || echo "❌ netcat not available" | tee -a "$TEST_RESULTS_FILE"
command -v guile >/dev/null 2>&1 && echo "✅ Guile: $(guile --version | head -1)" | tee -a "$TEST_RESULTS_FILE" || echo "❌ Guile not available" | tee -a "$TEST_RESULTS_FILE"
echo "" | tee -a "$TEST_RESULTS_FILE"

# Helper function to test connection with timeout and proper error handling
test_connection() {
    local test_name="$1"
    local request="$2"
    local expected_status="$3"
    local description="$4"
    local use_tls="${5:-true}"
    
    echo "--- Test: $test_name ---" | tee -a "$TEST_RESULTS_FILE"
    echo "Description: $description" | tee -a "$TEST_RESULTS_FILE"
    echo "Request: $request" | tee -a "$TEST_RESULTS_FILE"
    echo "Expected: $expected_status" | tee -a "$TEST_RESULTS_FILE"
    
    local response=""
    local connection_status=""
    
    if [[ "$use_tls" == "true" ]] && command -v openssl >/dev/null 2>&1; then
        echo "Method: OpenSSL TLS connection" | tee -a "$TEST_RESULTS_FILE"
        response=$(echo -e "$request" | timeout 10 openssl s_client -connect "$SERVER_HOST:$SERVER_PORT" -servername "$SERVER_HOST" -quiet -verify_return_error 2>/dev/null || echo "TLS_CONNECTION_FAILED")
        connection_status="TLS"
    elif command -v nc >/dev/null 2>&1; then
        echo "Method: netcat plain connection" | tee -a "$TEST_RESULTS_FILE"
        response=$(echo -e "$request" | timeout 10 nc "$SERVER_HOST" "$SERVER_PORT" 2>/dev/null || echo "TCP_CONNECTION_FAILED")
        connection_status="TCP"
    else
        echo "Method: No suitable connection tool available" | tee -a "$TEST_RESULTS_FILE"
        response="NO_CONNECTION_TOOL"
        connection_status="NONE"
    fi
    
    echo "Response: $response" | tee -a "$TEST_RESULTS_FILE"
    
    # Analyze response
    if [[ "$response" == *"_FAILED" ]] || [[ "$response" == "NO_CONNECTION_TOOL" ]]; then
        echo "❌ FAIL: Connection failed ($connection_status)" | tee -a "$TEST_RESULTS_FILE"
        echo "Analysis: Server may not be running or certificates invalid" | tee -a "$TEST_RESULTS_FILE"
    elif [[ -n "$expected_status" ]] && echo "$response" | grep -q "^$expected_status"; then
        echo "✅ PASS: Expected status $expected_status found" | tee -a "$TEST_RESULTS_FILE"
    elif [[ -n "$expected_status" ]]; then
        echo "⚠️  PARTIAL: Expected status $expected_status, got different response" | tee -a "$TEST_RESULTS_FILE"
        echo "Analysis: Server responded but not with expected status code" | tee -a "$TEST_RESULTS_FILE"
    else
        echo "ℹ️  INFO: Response recorded for analysis" | tee -a "$TEST_RESULTS_FILE"
    fi
    
    echo "" | tee -a "$TEST_RESULTS_FILE"
}

# Test server availability first
echo "=== 0. SERVER AVAILABILITY TEST ===" | tee -a "$TEST_RESULTS_FILE"
test_connection "Server Availability" "gemini://$SERVER_HOST:$SERVER_PORT/" "20" "Basic connectivity test"

# Test 1: Basic Valid Requests
echo "=== 1. BASIC VALID REQUEST TESTS ===" | tee -a "$TEST_RESULTS_FILE"
test_connection "Basic Valid Request" "gemini://$SERVER_HOST:$SERVER_PORT/\r\n" "20" "Standard valid Gemini request with CRLF"
test_connection "Root Directory Request" "gemini://$SERVER_HOST:$SERVER_PORT/\r\n" "20" "Request for root directory"

# Test 2: Malformed Requests
echo "=== 2. MALFORMED REQUEST TESTS ===" | tee -a "$TEST_RESULTS_FILE"

# Request too long (>1024 bytes)
long_request="gemini://$SERVER_HOST:$SERVER_PORT/$(printf 'a%.0s' {1..1100})\r\n"
test_connection "Request Too Long" "$long_request" "59" "Request exceeding 1024 byte limit per Gemini spec"

# Invalid URI format
test_connection "Invalid URI Format" "not-a-valid-uri\r\n" "59" "Completely invalid URI format"
test_connection "Missing Scheme" "/just-a-path\r\n" "59" "URI without scheme"
test_connection "Malformed URI" "gemini:///missing-host\r\n" "59" "URI with missing host"

# Non-gemini scheme
test_connection "HTTP Scheme" "http://$SERVER_HOST:$SERVER_PORT/\r\n" "59" "Wrong protocol scheme (HTTP)"
test_connection "HTTPS Scheme" "https://$SERVER_HOST:$SERVER_PORT/\r\n" "59" "Wrong protocol scheme (HTTPS)"
test_connection "FTP Scheme" "ftp://$SERVER_HOST:$SERVER_PORT/\r\n" "59" "Wrong protocol scheme (FTP)"

# URI with userinfo (should be rejected per spec)
test_connection "URI with Userinfo" "gemini://user:pass@$SERVER_HOST:$SERVER_PORT/\r\n" "59" "URI containing userinfo (forbidden in Gemini)"

# URI with fragment (should be rejected per spec)
test_connection "URI with Fragment" "gemini://$SERVER_HOST:$SERVER_PORT/page#fragment\r\n" "59" "URI containing fragment (forbidden in Gemini)"

# Test 3: Missing Files and Resources
echo "=== 3. MISSING FILE TESTS ===" | tee -a "$TEST_RESULTS_FILE"

test_connection "Non-existent File" "gemini://$SERVER_HOST:$SERVER_PORT/does-not-exist.gmi\r\n" "51" "Request for non-existent .gmi file"
test_connection "Non-existent Directory" "gemini://$SERVER_HOST:$SERVER_PORT/missing-directory/\r\n" "51" "Request for non-existent directory"
test_connection "Non-existent Deep Path" "gemini://$SERVER_HOST:$SERVER_PORT/a/b/c/d/e/f/g.txt\r\n" "51" "Request for deeply nested non-existent path"

# Test 4: Path Traversal Attacks
echo "=== 4. PATH TRAVERSAL SECURITY TESTS ===" | tee -a "$TEST_RESULTS_FILE"

test_connection "Directory Traversal 1" "gemini://$SERVER_HOST:$SERVER_PORT/../../../etc/passwd\r\n" "59" "Path traversal attempt (../../../etc/passwd)"
test_connection "Directory Traversal 2" "gemini://$SERVER_HOST:$SERVER_PORT/..%2f..%2f..%2fetc%2fpasswd\r\n" "59" "URL-encoded path traversal attempt"
test_connection "Directory Traversal 3" "gemini://$SERVER_HOST:$SERVER_PORT/..\..\..\windows\system32\config\sam\r\n" "59" "Windows-style path traversal"
test_connection "Relative Path Attack" "gemini://$SERVER_HOST:$SERVER_PORT/./../../secret.txt\r\n" "59" "Mixed relative path traversal"
test_connection "Null Byte Injection" "gemini://$SERVER_HOST:$SERVER_PORT/test.gmi%00.txt\r\n" "59" "Null byte injection attempt"

# Test 5: Protocol Violations
echo "=== 5. PROTOCOL VIOLATION TESTS ===" | tee -a "$TEST_RESULTS_FILE"

test_connection "Missing CRLF" "gemini://$SERVER_HOST:$SERVER_PORT/" "59" "Request without proper CRLF termination"
test_connection "Only LF" "gemini://$SERVER_HOST:$SERVER_PORT/\n" "59" "Request with LF only (should be CRLF)"
test_connection "Only CR" "gemini://$SERVER_HOST:$SERVER_PORT/\r" "59" "Request with CR only (should be CRLF)"
test_connection "Empty Request" "\r\n" "59" "Completely empty request"
test_connection "Whitespace Request" "   \r\n" "59" "Request with only whitespace"

# Binary/Invalid Data
printf -v binary_junk '%b' '\x00\x01\x02\x03\x04\x05\xff\xfe\xfd'
test_connection "Binary Junk" "${binary_junk}\r\n" "59" "Binary garbage data"

# Test 6: Large Request Handling
echo "=== 6. LARGE REQUEST HANDLING TESTS ===" | tee -a "$TEST_RESULTS_FILE"

# Create progressively larger requests
test_connection "1KB Request" "gemini://$SERVER_HOST:$SERVER_PORT/$(printf 'a%.0s' {1..1000})\r\n" "20 or 59" "Request at 1KB boundary"
test_connection "Max Valid Request" "gemini://$SERVER_HOST:$SERVER_PORT/$(printf 'a%.0s' {1..1020})\r\n" "20 or 59" "Request at maximum valid size"
test_connection "Over Limit Request" "gemini://$SERVER_HOST:$SERVER_PORT/$(printf 'a%.0s' {1..1030})\r\n" "59" "Request just over 1024 byte limit"

# Test 7: TLS-specific tests
echo "=== 7. TLS CONNECTION TESTS ===" | tee -a "$TEST_RESULTS_FILE"

if command -v openssl >/dev/null 2>&1; then
    echo "Testing TLS connection without SNI..." | tee -a "$TEST_RESULTS_FILE"
    tls_no_sni=$(timeout 10 openssl s_client -connect "$SERVER_HOST:$SERVER_PORT" -quiet 2>&1 || echo "TLS_FAILED")
    echo "TLS without SNI result: $tls_no_sni" | tee -a "$TEST_RESULTS_FILE"
    
    echo "Testing TLS connection info..." | tee -a "$TEST_RESULTS_FILE"
    tls_info=$(timeout 10 openssl s_client -connect "$SERVER_HOST:$SERVER_PORT" -servername "$SERVER_HOST" </dev/null 2>&1 | grep -E "(subject|issuer|notAfter|Protocol|Cipher)" || echo "TLS_INFO_FAILED")
    echo "TLS connection info: $tls_info" | tee -a "$TEST_RESULTS_FILE"
    
    echo "Testing certificate validation..." | tee -a "$TEST_RESULTS_FILE"
    cert_validation=$(timeout 10 openssl s_client -connect "$SERVER_HOST:$SERVER_PORT" -servername "$SERVER_HOST" -verify_return_error </dev/null 2>&1 | grep -i "verify" || echo "CERT_VALIDATION_FAILED")
    echo "Certificate validation: $cert_validation" | tee -a "$TEST_RESULTS_FILE"
else
    echo "OpenSSL not available for TLS testing" | tee -a "$TEST_RESULTS_FILE"
fi

# Test 8: Connection handling edge cases
echo "=== 8. CONNECTION HANDLING TESTS ===" | tee -a "$TEST_RESULTS_FILE"

echo "Testing immediate disconnect..." | tee -a "$TEST_RESULTS_FILE"
if command -v nc >/dev/null 2>&1; then
    disconnect_test=$(timeout 5 bash -c "echo '' | nc $SERVER_HOST $SERVER_PORT" 2>&1 || echo "DISCONNECT_TEST_FAILED")
    echo "Immediate disconnect result: $disconnect_test" | tee -a "$TEST_RESULTS_FILE"
    
    # Test slow connection
    echo "Testing slow connection..." | tee -a "$TEST_RESULTS_FILE"
    slow_test=$(timeout 10 bash -c "sleep 1; echo 'gemini://localhost:1965/' | nc $SERVER_HOST $SERVER_PORT" 2>&1 || echo "SLOW_CONNECTION_FAILED")
    echo "Slow connection result: $slow_test" | tee -a "$TEST_RESULTS_FILE"
else
    echo "netcat not available for connection testing" | tee -a "$TEST_RESULTS_FILE"
fi

# Test 9: Edge case URIs
echo "=== 9. EDGE CASE URI TESTS ===" | tee -a "$TEST_RESULTS_FILE"

test_connection "Very Long Host" "gemini://$(printf 'a%.0s' {1..100}).example.com:$SERVER_PORT/\r\n" "59" "URI with very long hostname"
test_connection "Unicode in Path" "gemini://$SERVER_HOST:$SERVER_PORT/🚀test.gmi\r\n" "59 or 20" "URI with Unicode characters"
test_connection "Percent Encoding" "gemini://$SERVER_HOST:$SERVER_PORT/test%20file.gmi\r\n" "20 or 51" "URI with percent-encoded spaces"
test_connection "Multiple Slashes" "gemini://$SERVER_HOST:$SERVER_PORT//double//slash//path\r\n" "20 or 59" "URI with multiple consecutive slashes"

echo "" | tee -a "$TEST_RESULTS_FILE"
echo "=== TEST SUMMARY ===" | tee -a "$TEST_RESULTS_FILE"

# Count results
pass_count=$(grep -c "✅ PASS" "$TEST_RESULTS_FILE" || echo 0)
fail_count=$(grep -c "❌ FAIL" "$TEST_RESULTS_FILE" || echo 0)
partial_count=$(grep -c "⚠️  PARTIAL" "$TEST_RESULTS_FILE" || echo 0)
info_count=$(grep -c "ℹ️  INFO" "$TEST_RESULTS_FILE" || echo 0)
total_tests=$((pass_count + fail_count + partial_count + info_count))

echo "Total tests: $total_tests" | tee -a "$TEST_RESULTS_FILE"
echo "Passed: $pass_count" | tee -a "$TEST_RESULTS_FILE"
echo "Failed: $fail_count" | tee -a "$TEST_RESULTS_FILE"
echo "Partial: $partial_count" | tee -a "$TEST_RESULTS_FILE"
echo "Info: $info_count" | tee -a "$TEST_RESULTS_FILE"

echo "" | tee -a "$TEST_RESULTS_FILE"
echo "=== RECOMMENDATIONS ===" | tee -a "$TEST_RESULTS_FILE"

if [ "$fail_count" -gt 0 ]; then
    echo "⚠️  Server connectivity issues detected:" | tee -a "$TEST_RESULTS_FILE"
    echo "   - Verify server is running on port $SERVER_PORT" | tee -a "$TEST_RESULTS_FILE"
    echo "   - Check TLS certificate configuration" | tee -a "$TEST_RESULTS_FILE"
    echo "   - Verify no firewall blocking connections" | tee -a "$TEST_RESULTS_FILE"
fi

echo "" | tee -a "$TEST_RESULTS_FILE"
echo "=== WHAT TO LOOK FOR ===" | tee -a "$TEST_RESULTS_FILE"
echo "✅ Expected behaviors:" | tee -a "$TEST_RESULTS_FILE"
echo "   - Status 20: Successful responses for valid requests" | tee -a "$TEST_RESULTS_FILE"
echo "   - Status 51: Not Found for missing resources" | tee -a "$TEST_RESULTS_FILE"
echo "   - Status 59: Bad Request for malformed/invalid requests" | tee -a "$TEST_RESULTS_FILE"
echo "   - Path traversal attempts should be blocked (status 59)" | tee -a "$TEST_RESULTS_FILE"
echo "   - Request size limits should be enforced" | tee -a "$TEST_RESULTS_FILE"
echo "   - Invalid schemes/URIs should be rejected" | tee -a "$TEST_RESULTS_FILE"

echo "" | tee -a "$TEST_RESULTS_FILE"
echo "Full results saved to: $TEST_RESULTS_FILE"
echo "For manual testing with working server, run individual commands like:"
echo "echo 'gemini://localhost:1965/' | openssl s_client -connect localhost:1965 -servername localhost -quiet"