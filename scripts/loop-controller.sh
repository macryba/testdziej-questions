#!/bin/bash

# Testdziej Question Generation Loop Controller
# This script manages the Claude Code /loop automation

set -e

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

STATE_FILE="$PROJECT_DIR/.claude/state.json"
MASTER_LIST="$PROJECT_DIR/epochs/master-list.json"
LOG_DIR="$PROJECT_DIR/logs"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log() {
    echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_DIR/loop-$(date +%Y%m%d).log"
}

log "${BLUE}========================================${NC}"
log "${BLUE}Testdziej Question Generation Loop${NC}"
log "${BLUE}========================================${NC}"

# Check if state file exists
if [ ! -f "$STATE_FILE" ]; then
    log "${RED}ERROR: State file not found at $STATE_FILE${NC}"
    exit 1
fi

# Check if master list exists
if [ ! -f "$MASTER_LIST" ]; then
    log "${RED}ERROR: Master list not found at $MASTER_LIST${NC}"
    exit 1
fi

# Get current state
CURRENT_EPOCH=$(jq -r '.current_epoch // empty' "$STATE_FILE")
CURRENT_CHAPTER=$(jq -r '.current_chapter // empty' "$STATE_FILE")
CURRENT_DIFFICULTY=$(jq -r '.current_difficulty // empty' "$STATE_FILE")

log "${GREEN}Current State:${NC}"
log "  Epoch: ${CURRENT_EPOCH:-'Not set'}"
log "  Chapter: ${CURRENT_CHAPTER:-'Not set'}"
log "  Difficulty: ${CURRENT_DIFFICULTY:-'Not set'}"

# Function to get next epoch/chapter/difficulty combination
get_next_combination() {
    # This will be called by Claude to determine what to work on next
    # Returns JSON with next epoch, chapter, difficulty
    jq -c '
        # Find first epoch that needs questions
        .epochs[] | 
        # Find first chapter that needs questions
        .chapters[] |
        # Return this combination
        {epoch: .parent.short_name, chapter: .short_name, difficulties: ["easy", "medium", "hard"]}
    ' "$MASTER_LIST" 2>/dev/null | head -1
}

log "${YELLOW}Ready for Claude Code to execute loop...${NC}"
log "Run: claude code /loop"

exit 0