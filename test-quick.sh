#!/bin/bash
#
# Quick Test - Fast validation of key functionality
#
# Runs a subset of tests for rapid feedback during development.
# Perfect for quick validation before commits or for debugging.
#

set -e

cd "$(dirname "$0")"

# Colors
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}⚡ Quick Test - Gemini Server${NC}"
echo "=============================="
echo

# Quick unit test check (just protocol parser)
echo -e "${BLUE}🧪 Protocol Parser Tests${NC}"
echo "========================"
cd server
if GUILE_LOAD_PATH=src:tests guile -c "(use-modules (tests protocol-parser))" 2>&1 | grep -E "(FAIL|unexpected failures)" | grep -q "unexpected failures"; then
    echo -e "${YELLOW}⚠️  Protocol tests have issues${NC}"
elif GUILE_LOAD_PATH=src:tests guile -c "(use-modules (tests protocol-parser))" 2>/dev/null | grep -q "expected passes"; then
    echo -e "${GREEN}✅ Core protocol tests passing${NC}"
else
    echo -e "${YELLOW}⚠️  Protocol tests have issues${NC}"
fi
cd ..

echo

# Quick connectivity test
echo -e "${BLUE}🔌 Basic Server Test${NC}"
echo "==================="

# Start server briefly
echo "Starting server for quick test..."
cd server
GUILE_LOAD_PATH=src timeout 5 guile src/gemini/server.scm -d "../static" > /dev/null 2>&1 &
SERVER_PID=$!
cd ..

sleep 2

# Quick test
if timeout 2 bash -c "</dev/tcp/localhost/1965" 2>/dev/null; then
    echo -e "${GREEN}✅ Server starts and accepts connections${NC}"
else
    echo -e "${YELLOW}⚠️  Server connectivity issue${NC}"
fi

# Cleanup
if kill -0 $SERVER_PID 2>/dev/null; then
    kill $SERVER_PID 2>/dev/null || true
    wait $SERVER_PID 2>/dev/null || true
fi

echo

echo -e "${GREEN}⚡ Quick test completed!${NC}"
echo
echo -e "${BLUE}💡 For comprehensive testing:${NC}"
echo "   ./run-unit-tests.sh      # All unit tests"
echo "   ./run-acceptance-tests.sh # Full acceptance tests"
echo "   ./run-all-tests.sh       # Complete test suite"