# 2. Single-threaded synchronous request handling

Date: 2026-02-16

## Status

Accepted

## Context

This is a toy implementation of the Gemini protocol server. We need to decide between a simple synchronous model or a more complex concurrent model for handling client requests.

## Decision

Process requests synchronously in a single thread. Only one client can be served at a time.

## Consequences

- **Simpler**: Easy to reason about and test
- **Predictable**: No race conditions or concurrency bugs
- **Limited**: Can't serve multiple clients simultaneously
- **Acceptable for toy project**: Appropriate for educational purposes
