#!/bin/bash

# ╔══════════════════════════════════════════════════════════════╗
# ║     TraceMail Forensics AI — One-Click Setup Script         ║
# ║     SIH Problem 26106                                       ║
# ╚══════════════════════════════════════════════════════════════╝

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

echo ""
echo -e "${CYAN}╔══════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║  ${BOLD}TraceMail Forensics AI — Setup${NC}${CYAN}                 ║${NC}"
echo -e "${CYAN}║  AI-Powered Email Threat Detection Platform     ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════╝${NC}"
echo ""

# ─── Step 1: Check if Node.js is installed ───
echo -e "${YELLOW}[1/3]${NC} Checking Node.js..."

if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version)
    echo -e "  ${GREEN}✔${NC} Node.js found: ${BOLD}${NODE_VERSION}${NC}"
else
    echo -e "  ${RED}✖${NC} Node.js not found!"
    echo ""
    echo -e "  ${BOLD}Node.js install karne ke liye neeche se koi ek tarika choose karo:${NC}"
    echo ""
    echo -e "  ${CYAN}Option 1: Official Website (Recommended)${NC}"
    echo -e "    1. Open: ${BOLD}https://nodejs.org${NC}"
    echo -e "    2. Download LTS version (green button)"
    echo -e "    3. Install the .pkg file"
    echo -e "    4. Restart terminal"
    echo -e "    5. Run this script again: ${BOLD}bash setup.sh${NC}"
    echo ""
    echo -e "  ${CYAN}Option 2: Homebrew${NC}"
    echo -e "    ${BOLD}brew install node${NC}"
    echo ""
    echo -e "  ${CYAN}Option 3: nvm (Node Version Manager)${NC}"
    echo -e "    ${BOLD}curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash${NC}"
    echo -e "    Then restart terminal and run:"
    echo -e "    ${BOLD}nvm install 20${NC}"
    echo ""
    echo -e "  Install karne ke baad yeh script dubara run karo:"
    echo -e "  ${BOLD}bash setup.sh${NC}"
    echo ""
    exit 1
fi

# Check npm
if ! command -v npm &> /dev/null; then
    echo -e "  ${RED}✖${NC} npm not found! Node.js ke saath npm aata hai."
    echo -e "  Node.js dubara install karo: ${BOLD}https://nodejs.org${NC}"
    exit 1
fi

NPM_VERSION=$(npm --version)
echo -e "  ${GREEN}✔${NC} npm found: ${BOLD}v${NPM_VERSION}${NC}"

# ─── Step 2: Install dependencies ───
echo ""
echo -e "${YELLOW}[2/3]${NC} Installing dependencies (npm install)..."
echo ""

npm install

echo ""
echo -e "  ${GREEN}✔${NC} Dependencies installed successfully!"

# ─── Step 3: Start dev server ───
echo ""
echo -e "${YELLOW}[3/3]${NC} Starting development server..."
echo ""
echo -e "╔══════════════════════════════════════════════════╗"
echo -e "║                                                  ║"
echo -e "║   ${GREEN}${BOLD}App ready! Open in browser:${NC}                    ║"
echo -e "║                                                  ║"
echo -e "║   ${CYAN}${BOLD}➜  http://localhost:5173${NC}                       ║"
echo -e "║                                                  ║"
echo -e "║   ${YELLOW}Test kaise karein:${NC}                              ║"
echo -e "║   1. Demo buttons pe click karo                  ║"
echo -e "║   2. Ya test-emails/ folder se .eml upload karo  ║"
echo -e "║   3. Ya 'Paste Raw Email' tab me paste karo      ║"
echo -e "║                                                  ║"
echo -e "║   ${RED}Server band karne ke liye: Ctrl + C${NC}            ║"
echo -e "║                                                  ║"
echo -e "╚══════════════════════════════════════════════════╝"
echo ""

npm run dev
