#!/bin/bash

# Testdziej Single Iteration Runner
# Runs Claude Code for ONE iteration of question generation

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
LOG_DIR="$PROJECT_DIR/logs"

mkdir -p "$LOG_DIR"

log() {
    echo "[$(TZ='Europe/Warsaw' date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_DIR/single-iteration-$(TZ='Europe/Warsaw' date +%Y%m%d).log"
}

log "=========================================="
log "Starting Single Question Generation Iteration"
log "=========================================="

# Check which chapter will be processed
NEXT_TARGET=$(jq -r '
  .tracking |
  to_entries[] |
  select(.key != "last_updated") |
  .key as $epoch |
  .value |
  to_entries[] |
  .key as $chapter |
  select(.value.easy < 10 or .value.medium < 10 or .value.hard < 10) |
  "\($epoch)|\($chapter)|easy:\(.value.easy) medium:\(.value.medium) hard:\(.value.hard)"
' "$PROJECT_DIR/history-data/questions-tracker.json" | head -1)

if [ -n "$NEXT_TARGET" ]; then
    log "Next target: $NEXT_TARGET"
else
    log "✓ All chapters complete! No questions to generate."
    exit 0
fi

# Start Claude Code
log "Starting Claude Code..."
cd "$PROJECT_DIR"

claude --print "Follow the complete workflow in .claude/instructions.md to generate questions.

Key steps:
1. Find next target epoch/chapter from questions-tracker.json
2. Research chapter using MCP polish-history tools (search_polish_history, extract_article)
3. Create chapter summary using chapter-summary skill
4. Generate questions for ALL difficulties (easy, medium, hard) - 10 questions each = 30 total
5. Validate questions with difficulty-reviewer skill and check Polish grammar
6. Save to history-data/{epoch}/{chapter}/ directory (one file per difficulty)
7. Update state files and commit changes

Complete ALL steps in .claude/instructions.md before exiting."

CLAUDE_EXIT_CODE=$?

log "=========================================="
if [ $CLAUDE_EXIT_CODE -eq 0 ]; then
    log "✓ Iteration completed successfully"
else
    log "⚠ Claude exited with code: $CLAUDE_EXIT_CODE"
fi
log "=========================================="

# Show what was created
log "Files created/modified in this iteration:"
git diff --name-only HEAD@{1} HEAD 2>/dev/null || echo "No git changes detected"

# Show current progress
log ""
log "Current progress:"
cat "$PROJECT_DIR/history-data/questions-tracker.json" | jq -r '
  .tracking |
  to_entries[] |
  select(.key != "last_updated") |
  .key as $epoch |
  .value |
  to_entries[] |
  .key as $chapter |
  select(.value.easy < 10 or .value.medium < 10 or .value.hard < 10) |
  "  \($epoch)/\($chapter): easy=\(.value.easy) medium=\(.value.medium) hard=\(.value.hard)"
' | head -5

exit $CLAUDE_EXIT_CODE
