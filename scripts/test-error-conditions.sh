#!/bin/bash

# Gemini Server Error Condition Testing Script
# Tests various error conditions to verify proper server behavior

set -e

SERVER_HOST="localhost"
SERVER_PORT="1965"
TEST_RESULTS_FILE="test-results.txt"

echo "=== GEMINI SERVER ERROR CONDITION TESTING ===" | tee "$TEST_RESULTS_FILE"
echo "Testing against: gemini://$SERVER_HOST:$SERVER_PORT/" | tee -a "$TEST_RESULTS_FILE"
echo "Timestamp: $(date)" | tee -a "$TEST_RESULTS_FILE"
echo "" | tee -a "$TEST_RESULTS_FILE"

# Helper function to test connection
test_connection() {
    local test_name="$1"
    local request="$2"
    local expected_status="$3"
    local description="$4"
    
    echo "--- Test: $test_name ---" | tee -a "$TEST_RESULTS_FILE"
    echo "Description: $description" | tee -a "$TEST_RESULTS_FILE"
    echo "Request: $request" | tee -a "$TEST_RESULTS_FILE"
    
    if command -v openssl >/dev/null 2>&1; then
        echo "Using openssl for TLS connection..." | tee -a "$TEST_RESULTS_FILE"
        response=$(echo "$request" | timeout 10 openssl s_client -connect "$SERVER_HOST:$SERVER_PORT" -servername "$SERVER_HOST" -quiet -verify_return_error 2>/dev/null || echo "CONNECTION_FAILED")
    else
        echo "OpenSSL not available, using nc..." | tee -a "$TEST_RESULTS_FILE"
        response=$(echo "$request" | timeout 10 nc "$SERVER_HOST" "$SERVER_PORT" 2>/dev/null || echo "CONNECTION_FAILED")
    fi
    
    echo "Response: $response" | tee -a "$TEST_RESULTS_FILE"
    
    if [[ "$response" == "CONNECTION_FAILED" ]]; then
        echo "❌ FAIL: Connection failed" | tee -a "$TEST_RESULTS_FILE"
    elif [[ -n "$expected_status" ]] && echo "$response" | grep -q "^$expected_status"; then
        echo "✅ PASS: Expected status $expected_status found" | tee -a "$TEST_RESULTS_FILE"
    elif [[ -n "$expected_status" ]]; then
        echo "❌ FAIL: Expected status $expected_status, got different response" | tee -a "$TEST_RESULTS_FILE"
    else
        echo "ℹ️  INFO: Response recorded for analysis" | tee -a "$TEST_RESULTS_FILE"
    fi
    
    echo "" | tee -a "$TEST_RESULTS_FILE"
}

# Test 1: Basic connection test
echo "=== 1. BASIC CONNECTION TEST ===" | tee -a "$TEST_RESULTS_FILE"
test_connection "Basic Valid Request" "gemini://$SERVER_HOST:$SERVER_PORT/" "20" "Test basic valid Gemini request"

# Test 2: Malformed Requests
echo "=== 2. MALFORMED REQUEST TESTS ===" | tee -a "$TEST_RESULTS_FILE"

# Request too long (>1024 bytes)
long_request="gemini://$SERVER_HOST:$SERVER_PORT/$(printf 'a%.0s' {1..1100})"
test_connection "Request Too Long" "$long_request" "59" "Request exceeding 1024 byte limit"

# Invalid URI format
test_connection "Invalid URI Format" "not-a-valid-uri" "59" "Completely invalid URI format"

# Non-gemini scheme
test_connection "Non-Gemini Scheme" "http://$SERVER_HOST:$SERVER_PORT/" "59" "Wrong protocol scheme"

# URI with userinfo
test_connection "URI with Userinfo" "gemini://user:pass@$SERVER_HOST:$SERVER_PORT/" "59" "URI containing userinfo (should be rejected)"

# URI with fragment
test_connection "URI with Fragment" "gemini://$SERVER_HOST:$SERVER_PORT/page#fragment" "59" "URI containing fragment (should be rejected)"

# Test 3: Missing Files
echo "=== 3. MISSING FILE TESTS ===" | tee -a "$TEST_RESULTS_FILE"

test_connection "Non-existent File" "gemini://$SERVER_HOST:$SERVER_PORT/does-not-exist.gmi" "51" "Request for non-existent file"
test_connection "Non-existent Directory" "gemini://$SERVER_HOST:$SERVER_PORT/missing-directory/" "51" "Request for non-existent directory"

# Test 4: Path Traversal Attacks
echo "=== 4. PATH TRAVERSAL TESTS ===" | tee -a "$TEST_RESULTS_FILE"

test_connection "Directory Traversal 1" "gemini://$SERVER_HOST:$SERVER_PORT/../../../etc/passwd" "59" "Path traversal attempt (../../../etc/passwd)"
test_connection "Directory Traversal 2" "gemini://$SERVER_HOST:$SERVER_PORT/..%2f..%2f..%2fetc%2fpasswd" "59" "URL-encoded path traversal attempt"
test_connection "Directory Traversal 3" "gemini://$SERVER_HOST:$SERVER_PORT/..\..\..\windows\system32\config\sam" "59" "Windows-style path traversal"

# Test 5: Protocol Violations
echo "=== 5. PROTOCOL VIOLATION TESTS ===" | tee -a "$TEST_RESULTS_FILE"

test_connection "Missing CRLF" "gemini://$SERVER_HOST:$SERVER_PORT/" "" "Request without proper CRLF termination (raw)"
test_connection "Empty Request" "" "59" "Completely empty request"
test_connection "Binary Junk" "$(echo -e '\x00\x01\x02\x03\x04\x05')" "59" "Binary garbage data"

# Test 6: TLS-specific tests
echo "=== 6. TLS CONNECTION TESTS ===" | tee -a "$TEST_RESULTS_FILE"

if command -v openssl >/dev/null 2>&1; then
    echo "Testing TLS connection without SNI..." | tee -a "$TEST_RESULTS_FILE"
    tls_no_sni=$(echo "gemini://$SERVER_HOST:$SERVER_PORT/" | timeout 10 openssl s_client -connect "$SERVER_HOST:$SERVER_PORT" -quiet 2>&1 || echo "TLS_FAILED")
    echo "TLS without SNI result: $tls_no_sni" | tee -a "$TEST_RESULTS_FILE"
    
    echo "Testing TLS connection info..." | tee -a "$TEST_RESULTS_FILE"
    tls_info=$(timeout 10 openssl s_client -connect "$SERVER_HOST:$SERVER_PORT" -servername "$SERVER_HOST" </dev/null 2>&1 | grep -E "(Protocol|Cipher|Verify)" || echo "TLS_INFO_FAILED")
    echo "TLS connection info: $tls_info" | tee -a "$TEST_RESULTS_FILE"
else
    echo "OpenSSL not available for TLS testing" | tee -a "$TEST_RESULTS_FILE"
fi

# Test 7: Connection handling
echo "=== 7. CONNECTION HANDLING TESTS ===" | tee -a "$TEST_RESULTS_FILE"

echo "Testing immediate disconnect..." | tee -a "$TEST_RESULTS_FILE"
if command -v nc >/dev/null 2>&1; then
    disconnect_test=$(timeout 5 bash -c "echo '' | nc $SERVER_HOST $SERVER_PORT" 2>&1 || echo "DISCONNECT_TEST_FAILED")
    echo "Immediate disconnect result: $disconnect_test" | tee -a "$TEST_RESULTS_FILE"
else
    echo "netcat not available for disconnect testing" | tee -a "$TEST_RESULTS_FILE"
fi

echo "" | tee -a "$TEST_RESULTS_FILE"
echo "=== TEST SUMMARY ===" | tee -a "$TEST_RESULTS_FILE"
pass_count=$(grep -c "✅ PASS" "$TEST_RESULTS_FILE" || echo 0)
fail_count=$(grep -c "❌ FAIL" "$TEST_RESULTS_FILE" || echo 0)
total_tests=$((pass_count + fail_count))

echo "Total tests: $total_tests" | tee -a "$TEST_RESULTS_FILE"
echo "Passed: $pass_count" | tee -a "$TEST_RESULTS_FILE"
echo "Failed: $fail_count" | tee -a "$TEST_RESULTS_FILE"

if [ "$fail_count" -eq 0 ]; then
    echo "🎉 All tests passed!" | tee -a "$TEST_RESULTS_FILE"
else
    echo "⚠️  Some tests failed - review results above" | tee -a "$TEST_RESULTS_FILE"
fi

echo "" | tee -a "$TEST_RESULTS_FILE"
echo "Full results saved to: $TEST_RESULTS_FILE"