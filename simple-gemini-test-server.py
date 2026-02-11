#!/usr/bin/env python3

"""
Simple Gemini Test Server for Error Condition Testing

This is a minimal Gemini server implementation designed specifically for testing
error conditions and protocol compliance. It demonstrates proper error handling
without the complexity of the full Guile implementation.

Note: This is for testing purposes only, not production use.
"""

import socket
import ssl
import threading
import sys
import os
import re
from urllib.parse import urlparse

class SimpleGeminiServer:
    def __init__(self, host='localhost', port=1966, static_dir='./test-content'):
        self.host = host
        self.port = port
        self.static_dir = static_dir
        
    def generate_self_signed_cert(self):
        """Generate a self-signed certificate for testing"""
        cert_file = 'test_cert.pem'
        key_file = 'test_key.pem'
        
        if not os.path.exists(cert_file) or not os.path.exists(key_file):
            print("Generating self-signed certificate for testing...")
            os.system(f'openssl req -x509 -newkey rsa:2048 -keyout {key_file} -out {cert_file} -days 365 -nodes -subj "/C=US/ST=Test/L=Test/O=TestGemini/CN=localhost"')
        
        return cert_file, key_file
    
    def validate_request(self, request):
        """Validate Gemini request and return appropriate response"""
        
        # Remove CRLF and check basic format
        request = request.rstrip('\r\n')
        
        # Check request length (max 1024 bytes per Gemini spec)
        if len(request.encode('utf-8')) > 1024:
            return "59 Bad Request - request too long\r\n"
        
        # Check for empty request
        if not request.strip():
            return "59 Bad Request - empty request\r\n"
        
        # Check if it's a valid URL
        try:
            parsed = urlparse(request)
        except Exception:
            return "59 Bad Request - invalid URI format\r\n"
        
        # Check scheme
        if parsed.scheme != 'gemini':
            return "59 Bad Request - invalid scheme, must be gemini\r\n"
        
        # Check for userinfo (forbidden in Gemini)
        if parsed.username or parsed.password:
            return "59 Bad Request - userinfo not allowed in Gemini\r\n"
        
        # Check for fragment (forbidden in Gemini)
        if parsed.fragment:
            return "59 Bad Request - fragment not allowed in Gemini\r\n"
        
        # Check for path traversal attempts
        path = parsed.path
        if '..' in path or path.startswith('/..') or '/../' in path:
            return "59 Bad Request - path traversal not allowed\r\n"
        
        # Check for null bytes or other problematic characters
        if '\x00' in path or any(ord(c) < 32 and c not in '\r\n\t' for c in path):
            return "59 Bad Request - invalid characters in path\r\n"
        
        # If we get here, it's a valid request
        return self.handle_valid_request(path)
    
    def handle_valid_request(self, path):
        """Handle a valid Gemini request"""
        
        # Default to index if path is empty or just /
        if path == '' or path == '/':
            path = '/index.gmi'
        
        # Construct file path
        file_path = os.path.join(self.static_dir, path.lstrip('/'))
        
        # Check if file exists
        if not os.path.exists(file_path):
            return "51 Not Found\r\n"
        
        # Check if it's a directory
        if os.path.isdir(file_path):
            # Look for index file
            index_path = os.path.join(file_path, 'index.gmi')
            if os.path.exists(index_path):
                file_path = index_path
            else:
                # Generate directory listing
                return self.generate_directory_listing(file_path, path)
        
        # Serve the file
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # Determine MIME type
            if file_path.endswith('.gmi') or file_path.endswith('.gemini'):
                mime_type = 'text/gemini'
            elif file_path.endswith('.txt'):
                mime_type = 'text/plain'
            else:
                mime_type = 'application/octet-stream'
            
            return f"20 {mime_type}\r\n{content}"
        
        except Exception as e:
            return "50 Internal Server Error\r\n"
    
    def generate_directory_listing(self, dir_path, url_path):
        """Generate a simple directory listing"""
        try:
            files = os.listdir(dir_path)
            content = f"# Directory Listing for {url_path}\n\n"
            
            if url_path != '/':
                content += "=> ../ Parent Directory\n"
            
            for file in sorted(files):
                file_path = os.path.join(dir_path, file)
                if os.path.isdir(file_path):
                    content += f"=> {file}/ {file}/\n"
                else:
                    content += f"=> {file} {file}\n"
            
            return f"20 text/gemini\r\n{content}"
        except Exception:
            return "51 Not Found\r\n"
    
    def handle_client(self, client_socket, client_addr):
        """Handle a client connection"""
        try:
            # Wrap socket with TLS
            cert_file, key_file = self.generate_self_signed_cert()
            context = ssl.create_default_context(ssl.Purpose.CLIENT_AUTH)
            context.load_cert_chain(cert_file, key_file)
            
            with context.wrap_socket(client_socket, server_side=True) as tls_socket:
                # Read request (with timeout)
                tls_socket.settimeout(10)
                request = tls_socket.recv(1024).decode('utf-8')
                
                print(f"[{client_addr[0]}] Request: {repr(request)}")
                
                # Validate and process request
                response = self.validate_request(request)
                
                print(f"[{client_addr[0]}] Response: {repr(response[:50])}...")
                
                # Send response
                tls_socket.send(response.encode('utf-8'))
        
        except ssl.SSLError as e:
            print(f"[{client_addr[0]}] TLS Error: {e}")
        except Exception as e:
            print(f"[{client_addr[0]}] Error: {e}")
        finally:
            try:
                client_socket.close()
            except:
                pass
    
    def start(self):
        """Start the test server"""
        print(f"Starting Gemini test server on {self.host}:{self.port}")
        print(f"Serving files from: {self.static_dir}")
        print("Note: This is a test server with self-signed certificates")
        print()
        
        # Create socket
        server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        server_socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        server_socket.bind((self.host, self.port))
        server_socket.listen(5)
        
        print(f"Server listening on {self.host}:{self.port}")
        print("Press Ctrl+C to stop")
        print()
        
        try:
            while True:
                client_socket, client_addr = server_socket.accept()
                print(f"Connection from {client_addr[0]}:{client_addr[1]}")
                
                # Handle client in a separate thread
                client_thread = threading.Thread(
                    target=self.handle_client,
                    args=(client_socket, client_addr)
                )
                client_thread.daemon = True
                client_thread.start()
                
        except KeyboardInterrupt:
            print("\nShutting down server...")
        finally:
            server_socket.close()

def create_test_content():
    """Create some test content for the server"""
    if not os.path.exists('test-content'):
        os.makedirs('test-content')
    
    # Create index.gmi
    with open('test-content/index.gmi', 'w') as f:
        f.write("""# Gemini Test Server

This is a test server for demonstrating Gemini protocol error handling.

## Test Links

=> /test.gmi Test Page
=> /missing.gmi Missing Page (should return 51)
=> /subdir/ Subdirectory

## Testing Commands

To test this server, use commands like:

```
echo 'gemini://localhost:1966/' | openssl s_client -connect localhost:1966 -servername localhost -quiet
```

""")
    
    # Create test.gmi
    with open('test-content/test.gmi', 'w') as f:
        f.write("""# Test Page

This page exists and should return status 20.

=> / Back to Index
""")
    
    # Create subdirectory with content
    if not os.path.exists('test-content/subdir'):
        os.makedirs('test-content/subdir')
    
    with open('test-content/subdir/page.gmi', 'w') as f:
        f.write("""# Subdirectory Page

This is a page in a subdirectory.

=> / Back to Root
""")
    
    print("Created test content in test-content/")

if __name__ == '__main__':
    # Create test content
    create_test_content()
    
    # Start server
    server = SimpleGeminiServer()
    server.start()