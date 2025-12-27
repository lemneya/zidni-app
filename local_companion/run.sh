#!/bin/bash
#
# Zidni Local Companion Server - Run Script
#
# Usage:
#   ./run.sh              # Run with defaults (port 8787)
#   PORT=9000 ./run.sh    # Run on custom port
#

set -e

# Default configuration
HOST="${HOST:-0.0.0.0}"
PORT="${PORT:-8787}"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔═══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║           Zidni Local Companion Server                    ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check Python
if ! command -v python3 &> /dev/null; then
    echo "Error: Python 3 is required but not installed."
    exit 1
fi

# Check if virtual environment exists
if [ -d "venv" ]; then
    echo -e "${GREEN}Activating virtual environment...${NC}"
    source venv/bin/activate
fi

# Check dependencies
if ! python3 -c "import flask" 2>/dev/null; then
    echo "Installing dependencies..."
    pip3 install -r requirements.txt
fi

# Get local IP
LOCAL_IP=$(hostname -I 2>/dev/null | awk '{print $1}' || echo "localhost")

echo ""
echo -e "${GREEN}Starting server...${NC}"
echo ""
echo "  Local:   http://localhost:${PORT}"
echo "  Network: http://${LOCAL_IP}:${PORT}"
echo ""
echo "Enter this URL in Zidni Offline Settings:"
echo -e "  ${GREEN}http://${LOCAL_IP}:${PORT}${NC}"
echo ""

# Run server
HOST=$HOST PORT=$PORT python3 server.py
