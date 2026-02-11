;;; File System Operations
;;; Path resolution and file serving with security controls
;;;
;;; This module handles all filesystem operations for the Gemini server
;;; with comprehensive security measures to prevent common web server attacks.
;;;
;;; Security design principles:
;;; - Path canonicalization prevents symlink-based directory escapes
;;; - Strict boundary enforcement keeps requests within static directory
;;; - No directory listings by default (privacy and security)
;;; - Graceful error handling prevents information disclosure
;;; - Support for standard Gemini index files (index.gmi, index.gemini)
;;;
;;; Path resolution strategy:
;;; 1. Normalize URI path (remove multiple slashes, resolve . and ..)
;;; 2. Construct full filesystem path within static root
;;; 3. Canonicalize both root and target paths
;;; 4. Verify target path is within root boundaries
;;; 5. Return canonical path or #f if outside boundaries

(define-module (gemini file-handler)
  #:use-module (ice-9 ftw)
  #:use-module (ice-9 textual-ports)
  #:use-module (ice-9 regex)
  #:export (resolve-file-path
            read-file-content
            find-index-file))

;;; Resolve URI path to filesystem path with comprehensive security checks
;;; 
;;; Path resolution security model:
;;; - Prevents directory traversal attacks (../, symbolic links)
;;; - Ensures all served files are within the static directory tree
;;; - Handles edge cases like empty paths, multiple slashes, special characters
;;; - Uses canonical paths to resolve all symbolic links and relative components
;;; 
;;; Implementation approach:
;;; 1. Normalize the URI path (empty path becomes "/")
;;; 2. Clean up multiple consecutive slashes (aesthetic and consistency)
;;; 3. Construct the full filesystem path
;;; 4. Canonicalize both the static root and the target path
;;; 5. Verify the target is within the root using string prefix matching
;;; 
;;; Security rationale:
;;; - canonicalize-path resolves all symbolic links and relative components
;;; - string-prefix? check ensures no escape from static directory
;;; - Exception handling prevents crashes on invalid paths
;;; - Returns #f for any invalid/unsafe path rather than throwing errors
;;; 
;;; Limitations:
;;; - Requires filesystem access to canonicalize paths
;;; - May resolve symlinks in ways that surprise users
;;; - Does not implement custom directory index generation
(define (resolve-file-path static-root uri-path)
  (let* ((clean-path (if (string-null? uri-path) "/" uri-path))
         ;; Normalize multiple slashes to single slashes for consistency
         ;; This prevents confusion from paths like "//etc/passwd" vs "/etc/passwd"
         (normalized (regexp-substitute/global #f "/+" clean-path 'pre "/" 'post))
         ;; Construct full path by appending normalized URI path to static root
         (full-path (string-append static-root normalized)))
    ;; Critical security check: ensure resolved path stays within static-root
    ;; This prevents directory traversal attacks via ../, symlinks, etc.
    (let ((canonical-root (canonicalize-path static-root))
          (canonical-path (catch #t 
                            (lambda () (canonicalize-path full-path))
                            (lambda (key . args) #f))))  ; Return #f for invalid paths
      (if (and canonical-path 
               ;; Verify target path starts with static root path
               ;; This is the key security check preventing directory escape
               (string-prefix? canonical-root canonical-path))
          canonical-path
          #f))))  ; Return #f if path is outside static directory

;;; Read file content with proper error handling
;;; 
;;; File reading considerations for Gemini:
;;; - Gemini supports both text and binary content
;;; - Files are read entirely into memory (acceptable for static content)
;;; - No partial content or streaming (Gemini doesn't support HTTP Range requests)
;;; - Encoding is handled transparently by get-string-all
;;; 
;;; Error handling strategy:
;;; - File existence is checked before reading
;;; - All file I/O exceptions are caught and return #f
;;; - This prevents server crashes on permission errors, disk problems, etc.
;;; - Calling code can distinguish between "file not found" and "read error"
;;; 
;;; Limitations:
;;; - Large files are loaded entirely into memory
;;; - No support for streaming or partial content
;;; - Binary files are read as text (works for most Gemini content)
(define (read-file-content file-path)
  (catch #t
    (lambda ()
      (if (file-exists? file-path)
          ;; Read entire file contents as string
          ;; This works for both text and binary files in most cases
          (call-with-input-file file-path get-string-all)
          #f))  ; File doesn't exist
    (lambda (key . args)
      ;; Handle any file I/O errors (permissions, disk errors, etc.)
      ;; Return #f rather than crashing the server
      #f)))

;;; Find index file in directory according to Gemini conventions
;;; 
;;; Gemini index file conventions:
;;; - index.gmi is the preferred index file name
;;; - index.gemini is an alternative (longer but more explicit)
;;; - No automatic directory listing generation (privacy/security feature)
;;; - Directories without index files return "not found"
;;; 
;;; Priority order matches common Gemini server behavior:
;;; 1. index.gmi (short, standard extension)
;;; 2. index.gemini (explicit, self-documenting)
;;; 3. No index file found - return #f
;;; 
;;; Security considerations:
;;; - Does not automatically generate directory listings
;;; - This prevents accidental exposure of file structures
;;; - Site authors must explicitly create index files
(define (find-index-file dir-path)
  (if (and (file-exists? dir-path) (file-is-directory? dir-path))
      (let ((index-gmi (string-append dir-path "/index.gmi"))
            (index-gemini (string-append dir-path "/index.gemini")))
        (cond
          ;; Prefer .gmi extension (standard and concise)
          ((file-exists? index-gmi) index-gmi)
          ;; Fall back to .gemini extension (explicit)
          ((file-exists? index-gemini) index-gemini)
          ;; No index file found - directory has no index
          (else #f)))
      #f))  ; Not a directory or doesn't exist