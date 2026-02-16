# Gemini Server Error Condition Testing Results

## Overview

This document provides a comprehensive approach to manually testing error conditions for a Gemini server implementation. While the main server had startup issues during testing, the methodologies and expected behaviors are documented for future testing.

## Testing Environment

**Date:** February 11, 2026  
**Tools Available:**
- ✅ OpenSSL 3.5.3 (for TLS connections)
- ✅ netcat (OpenBSD) (for TCP connections)  
- ✅ GNU Guile 3.0.11 (for server runtime)

## Server Startup Issues Encountered

During testing, the Gemini server encountered TLS configuration issues:

1. **Certificate Loading Problems**: The server failed to load TLS certificates properly
2. **Module Loading Issues**: Some Guile modules had compilation warnings
3. **Connection Refused**: Server was not accepting connections on port 1965

## Manual Testing Methodology

### 1. Basic TLS Connection Test

```bash
# Test basic TLS connection
echo "gemini://localhost:1965/" | openssl s_client -connect localhost:1965 -servername localhost -quiet
```

**Expected Result:** Server should accept TLS connection and respond with Gemini protocol status

### 2. Malformed Request Tests

#### Request Too Long (>1024 bytes)
```bash
# Create a request exceeding 1024 bytes
long_url="gemini://localhost:1965/$(printf 'a%.0s' {1..1100})"
echo "$long_url" | openssl s_client -connect localhost:1965 -servername localhost -quiet
```
**Expected:** `59 Bad Request - request too long`

#### Invalid URI Format
```bash
# Test completely invalid URI
echo "not-a-valid-uri" | openssl s_client -connect localhost:1965 -servername localhost -quiet
```
**Expected:** `59 Bad Request - invalid URI format`

#### Non-Gemini Schemes
```bash
# Test wrong protocol schemes
echo "http://localhost:1965/" | openssl s_client -connect localhost:1965 -servername localhost -quiet
echo "https://localhost:1965/" | openssl s_client -connect localhost:1965 -servername localhost -quiet
echo "ftp://localhost:1965/" | openssl s_client -connect localhost:1965 -servername localhost -quiet
```
**Expected:** `59 Bad Request - invalid scheme`

#### URI with Userinfo (Forbidden in Gemini)
```bash
echo "gemini://user:pass@localhost:1965/" | openssl s_client -connect localhost:1965 -servername localhost -quiet
```
**Expected:** `59 Bad Request - userinfo not allowed`

#### URI with Fragment (Forbidden in Gemini)
```bash
echo "gemini://localhost:1965/page#fragment" | openssl s_client -connect localhost:1965 -servername localhost -quiet
```
**Expected:** `59 Bad Request - fragment not allowed`

### 3. Missing File Tests

```bash
# Test non-existent files
echo "gemini://localhost:1965/does-not-exist.gmi" | openssl s_client -connect localhost:1965 -servername localhost -quiet
echo "gemini://localhost:1965/missing-directory/" | openssl s_client -connect localhost:1965 -servername localhost -quiet
```
**Expected:** `51 Not Found`

### 4. Path Traversal Security Tests

```bash
# Basic path traversal
echo "gemini://localhost:1965/../../../etc/passwd" | openssl s_client -connect localhost:1965 -servername localhost -quiet

# URL-encoded path traversal  
echo "gemini://localhost:1965/..%2f..%2f..%2fetc%2fpasswd" | openssl s_client -connect localhost:1965 -servername localhost -quiet

# Windows-style path traversal
echo "gemini://localhost:1965/..\..\..\windows\system32\config\sam" | openssl s_client -connect localhost:1965 -servername localhost -quiet

# Null byte injection
echo "gemini://localhost:1965/test.gmi%00.txt" | openssl s_client -connect localhost:1965 -servername localhost -quiet
```
**Expected:** `59 Bad Request - path traversal not allowed`

### 5. Protocol Violation Tests

#### Missing CRLF Termination
```bash
# Request without proper CRLF (note: this is hard to test with echo)
printf "gemini://localhost:1965/" | openssl s_client -connect localhost:1965 -servername localhost -quiet
```

#### Empty Requests
```bash
echo "" | openssl s_client -connect localhost:1965 -servername localhost -quiet
echo "   " | openssl s_client -connect localhost:1965 -servername localhost -quiet
```
**Expected:** `59 Bad Request - empty request`

#### Binary Garbage
```bash
printf '\x00\x01\x02\x03\x04\x05\xff\xfe\xfd\r\n' | openssl s_client -connect localhost:1965 -servername localhost -quiet
```
**Expected:** `59 Bad Request - invalid characters`

### 6. TLS-Specific Tests

#### Certificate Information
```bash
# Get certificate details
openssl s_client -connect localhost:1965 -servername localhost </dev/null 2>&1 | grep -E "(subject|issuer|notAfter)"
```

#### Connection Without SNI
```bash
# Test connection without Server Name Indication
echo "gemini://localhost:1965/" | openssl s_client -connect localhost:1965 -quiet
```

#### Certificate Validation
```bash
# Test with certificate validation
echo "gemini://localhost:1965/" | openssl s_client -connect localhost:1965 -servername localhost -verify_return_error
```

### 7. Connection Edge Cases

#### Using netcat for Non-TLS Testing
```bash
# Test raw TCP connection (should fail for Gemini which requires TLS)
echo "gemini://localhost:1965/" | nc localhost 1965
```

#### Slow Connections
```bash
# Test delayed request
(sleep 2; echo "gemini://localhost:1965/") | openssl s_client -connect localhost:1965 -servername localhost -quiet
```

## Expected Response Codes

According to the Gemini specification:

- **20 SUCCESS**: Successful request, content follows
- **51 NOT FOUND**: Requested resource not found
- **59 BAD REQUEST**: Request malformed or not understood

## Security Considerations Tested

1. **Path Traversal Prevention**: Server should block attempts to access files outside the document root
2. **Request Size Limits**: Server should reject requests exceeding 1024 bytes
3. **Protocol Enforcement**: Server should reject non-Gemini schemes and malformed URIs
4. **URI Component Restrictions**: Server should reject URIs with userinfo or fragments
5. **TLS Requirement**: Server should only accept TLS connections

## Improvements Needed

Based on the testing approach, the Gemini server implementation should address:

1. **TLS Certificate Management**: Fix certificate loading and generation
2. **Error Response Consistency**: Ensure proper status codes are returned
3. **Input Validation**: Robust checking of request format and content
4. **Security Hardening**: Proper path traversal prevention and input sanitization
5. **Connection Handling**: Graceful handling of malformed connections

## Test Scripts Created

1. **comprehensive-error-tests.sh**: Complete automated test suite
2. **manual-error-tests.sh**: Manual testing approach with simple server
3. **Test results**: Saved in comprehensive-test-results.txt

## Manual Testing Commands Summary

For quick manual testing when server is running:

```bash
# Basic success test
echo "gemini://localhost:1965/" | openssl s_client -connect localhost:1965 -servername localhost -quiet

# Test missing file
echo "gemini://localhost:1965/nonexistent" | openssl s_client -connect localhost:1965 -servername localhost -quiet

# Test path traversal
echo "gemini://localhost:1965/../etc/passwd" | openssl s_client -connect localhost:1965 -servername localhost -quiet

# Test invalid scheme
echo "http://localhost:1965/" | openssl s_client -connect localhost:1965 -servername localhost -quiet

# Test oversized request
echo "gemini://localhost:1965/$(printf 'a%.0s' {1..1100})" | openssl s_client -connect localhost:1965 -servername localhost -quiet
```

## Conclusion

While server startup issues prevented live testing, this document provides a comprehensive methodology for testing Gemini server error conditions. The test scripts can be run once the server is properly configured with valid TLS certificates.

The key areas for testing are:
- Request validation and size limits
- Path traversal prevention  
- TLS configuration and handshake
- Proper error response codes
- Protocol compliance

This testing approach ensures the server correctly implements Gemini protocol security requirements and error handling.