#!/bin/bash
#
# Help - Show all available commands
#
# Quick reference for all project scripts and commands
#

# Colors
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${BLUE}🚀 Gemini Toy Server - Available Commands${NC}"
echo "=========================================="
echo
echo -e "${GREEN}📋 Main Commands:${NC}"
echo -e "${CYAN}  ./start-server.sh${NC}          Start the Gemini server"
echo -e "${CYAN}  ./run-all-tests.sh${NC}        Run complete test suite"
echo -e "${CYAN}  ./test-quick.sh${NC}           Quick development test"
echo -e "${CYAN}  ./help.sh${NC}                 Show this help (you are here)"
echo

echo -e "${GREEN}🧪 Testing Commands:${NC}"
echo -e "${CYAN}  ./run-unit-tests.sh${NC}       Run unit tests only"
echo -e "${CYAN}  ./run-acceptance-tests.sh${NC} Run acceptance tests only"
echo -e "${CYAN}  ./test-quick.sh${NC}           Fast smoke test"
echo

echo -e "${GREEN}⚙️  Server Options:${NC}"
echo -e "${CYAN}  ./start-server.sh --help${NC}  Show server options"
echo -e "${CYAN}  ./start-server.sh -p 1966${NC} Start on different port"  
echo -e "${CYAN}  ./start-server.sh -d mydir${NC} Use custom static directory"
echo -e "${CYAN}  ./start-server.sh --verbose${NC} Start with verbose logging"
echo

echo -e "${GREEN}🔧 Manual Commands:${NC}"
echo -e "${CYAN}  cd server && GUILE_LOAD_PATH=src:tests guile run-unit-tests.scm${NC}"
echo "    └─ Run unit tests manually"
echo
echo -e "${CYAN}  cd server && GUILE_LOAD_PATH=src guile src/gemini/server.scm -d ../static${NC}"
echo "    └─ Start server manually"
echo
echo -e "${CYAN}  echo 'gemini://localhost:1965/' | openssl s_client -connect localhost:1965 -servername localhost -quiet${NC}"
echo "    └─ Test server manually"
echo

echo -e "${GREEN}📚 Documentation:${NC}"
echo -e "${CYAN}  README.md${NC}                 Main project documentation"
echo -e "${CYAN}  TESTING.md${NC}               Comprehensive testing guide"
echo -e "${CYAN}  server/README.md${NC}         Server architecture details"
echo

echo -e "${GREEN}📁 Important Directories:${NC}"
echo -e "${CYAN}  static/${NC}                  Default static content"
echo -e "${CYAN}  server/src/gemini/${NC}       Server source code"
echo -e "${CYAN}  server/tests/tests/${NC}      Unit test files"
echo -e "${CYAN}  acceptance-tests/${NC}        Acceptance test framework"
echo

echo -e "${YELLOW}💡 Quick Start:${NC}"
echo "   1. Run tests:     ${CYAN}./run-all-tests.sh${NC}"
echo "   2. Start server:  ${CYAN}./start-server.sh${NC}"
echo "   3. Test manually: ${CYAN}echo 'gemini://localhost:1965/' | openssl s_client -connect localhost:1965 -servername localhost -quiet${NC}"
echo

echo -e "${YELLOW}🆘 Troubleshooting:${NC}"
echo "   • Check prerequisites: ${CYAN}guile --version${NC} and ${CYAN}openssl version${NC}"
echo "   • Create static content: ${CYAN}mkdir -p static && echo '# Hello Gemini!' > static/index.gmi${NC}"
echo "   • View server logs: ${CYAN}tail -f server/server.log${NC}"
echo "   • Stop server: Find PID with ${CYAN}ps aux | grep guile${NC}, then ${CYAN}kill <PID>${NC}"