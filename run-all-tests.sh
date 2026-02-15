#!/bin/bash
#
# Run All Tests for Gemini Server
#
# This script runs both unit tests and acceptance tests in sequence.
# Perfect for CI/CD or comprehensive testing before deployment.
#

set -e

cd "$(dirname "$0")"

# Colors
BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}🎯 Running Complete Gemini Server Test Suite${NC}"
echo "=============================================="
echo

# Run unit tests
echo -e "${BLUE}Step 1: Unit Tests${NC}"
echo "==================="
if ./run-unit-tests.sh; then
    echo -e "${GREEN}✅ Unit tests passed${NC}"
    UNIT_RESULT="✅ PASS"
else
    echo -e "${RED}❌ Unit tests failed${NC}"
    UNIT_RESULT="❌ FAIL"
    UNIT_FAILED=1
fi

echo
echo

# Run acceptance tests
echo -e "${BLUE}Step 2: Acceptance Tests${NC}"
echo "========================="
if ./run-acceptance-tests.sh; then
    echo -e "${GREEN}✅ Acceptance tests passed${NC}"
    ACCEPTANCE_RESULT="✅ PASS"
else
    echo -e "${RED}❌ Acceptance tests failed${NC}"
    ACCEPTANCE_RESULT="❌ FAIL"
    ACCEPTANCE_FAILED=1
fi

echo
echo

# Summary
echo -e "${BLUE}📊 Test Suite Summary${NC}"
echo "======================"
echo -e "Unit Tests:       $UNIT_RESULT"
echo -e "Acceptance Tests: $ACCEPTANCE_RESULT"
echo

if [ -z "$UNIT_FAILED" ] && [ -z "$ACCEPTANCE_FAILED" ]; then
    echo -e "${GREEN}🎉 All tests passed! The Gemini server is working correctly.${NC}"
    exit 0
else
    echo -e "${RED}❌ Some tests failed. Check the output above for details.${NC}"
    exit 1
fi