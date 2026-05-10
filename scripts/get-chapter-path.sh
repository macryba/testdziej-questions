#!/bin/bash

# Path Construction Utility for Testdziej Project
# Demonstrates correct pattern for building paths to chapter directories
# Always read from master-list.json, never hardcode paths

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
MASTER_LIST="$PROJECT_DIR/history-data/master-list.json"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

usage() {
    echo "Usage: $0 <--list-epochs | --list-chapters EPOCH_ID | --epoch EPOCH_ID CHAPTER_ID>"
    echo ""
    echo "Examples:"
    echo "  $0 --list-epochs                                  # List all epochs"
    echo "  $0 --list-chapters 7                                 # List chapters in epoch 7"
    echo "  $0 --epoch 7 2                                       # Get path: epoch 7, chapter 2 (Okupacja)"
    echo ""
    echo -e "${YELLOW}IMPORTANT:${NC} Always construct paths dynamically from master-list.json"
    echo "Pattern: history-data/{epoch_id:02d}-{epoch_tech_name}/{chapter_id:02d}-{chapter_tech_name}/"
}

# List all epochs
if [ "$1" = "--list-epochs" ]; then
    echo -e "${BLUE}All Epochs in master-list.json:${NC}"
    jq -r '.epochs[] | "  \(.id): \(.short_name) [\(.tech_name)]"' "$MASTER_LIST"
    exit 0
fi

# List all chapters for an epoch
if [ "$1" = "--list-chapters" ] && [ -n "$2" ]; then
    echo -e "${BLUE}Chapters in Epoch $2:${NC}"
    jq -r --arg id "$2" \
      '.epochs[] | select(.id == ($id | tonumber)) | .chapters | to_entries[] |
      "  \(.key + 1): \(.value.short_name) [\(.value.tech_name)]"' "$MASTER_LIST"
    exit 0
fi

# Get the full path to a chapter directory
if [ "$1" = "--epoch" ] && [ -n "$2" ] && [ -n "$3" ]; then
    epoch_id=$2
    chapter_id=$3
    # chapter_id is 1-indexed, jq arrays are 0-indexed
    chapter_idx=$((chapter_id - 1))

    # Extract tech names using jq
    epoch_tech=$(jq -r --arg eid "$epoch_id" \
      '.epochs[] | select(.id == ($eid | tonumber)) | .tech_name' \
      "$MASTER_LIST")

    chapter_tech=$(jq -r --arg eid "$epoch_id" --argjson cidx "$chapter_idx" \
      '.epochs[] | select(.id == ($eid | tonumber)) | .chapters[$cidx].tech_name' \
      "$MASTER_LIST")

    # Build path with zero-padding (bash printf)
    epoch_padded=$(printf "%02d" "$epoch_id")
    chapter_padded=$(printf "%02d" "$chapter_id")

    result="history-data/${epoch_padded}-${epoch_tech}/${chapter_padded}-${chapter_tech}/"

    if [ -n "$result" ] && [ -d "$PROJECT_DIR/$result" ]; then
        echo "$result"
        exit 0
    else
        echo -e "${RED}Error:${NC} Chapter directory not found" >&2
        echo "Epoch: $epoch_id, Chapter: $chapter_id" >&2
        echo "Expected: $PROJECT_DIR/$result" >&2
        exit 1
    fi
fi

usage
exit 1
