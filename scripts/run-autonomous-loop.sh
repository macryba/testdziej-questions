#!/bin/bash

# Testdziej Autonomous Loop Runner
# Runs Claude Code continuously with automatic restarts

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
LOG_DIR="$PROJECT_DIR/logs"

mkdir -p "$LOG_DIR"

log() {
    echo "[$(TZ='Europe/Warsaw' date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_DIR/autonomous-loop-$(TZ='Europe/Warsaw' date +%Y%m%d).log"
}

check_completion() {
    # Check if any chapter has incomplete questions
    INCOMPLETE=$(jq -r '
        [.tracking |
        to_entries[] |
        select(.key != "last_updated") |
        .key as $epoch |
        .value |
        to_entries[] |
        .key as $chapter |
        .value |
        select(
            (.easy < 10 or .easy_completed != true) or
            (.medium < 10 or .medium_completed != true) or
            (.hard < 10 or .hard_completed != true)
        )] |
        length
    ' /home/macryba/testdziej-questions/history-data/questions-tracker.json)

    if [ "$INCOMPLETE" -eq 0 ]; then
        return 0  # Complete
    else
        return 1  # Not complete
    fi
}

log "=========================================="
log "Starting Testdziej Autonomous Loop"
log "=========================================="

ITERATION=1
while true; do
    log "=== Iteration $ITERATION ==="

    # Check if all questions are generated
    if check_completion; then
        log "✓✓✓ All questions generated! Autonomous loop complete."
        break
    fi

    # Start Claude Code with direct execution
    log "Starting Claude Code for iteration $ITERATION..."

    cd "$PROJECT_DIR"
    claude --print "Follow the complete workflow in .claude/instructions.md to generate questions.

Key steps:
1. Find next target epoch/chapter from questions-tracker.json
2. Research chapter using MCP polish-history tools
3. Create chapter summary using chapter-summary skill
4. Generate questions for ALL difficulties (easy, medium, hard) - 10 questions each = 30 total
5. Validate questions with difficulty-reviewer skill and check Polish grammar
6. Save to history-data/{epoch}/{chapter}/ directory (one file per difficulty)
7. Update state files and commit changes

Complete ALL steps in .claude/instructions.md before exiting." &
    CLAUDE_PID=$!

    log "Claude Code started (PID: $CLAUDE_PID)"
    log "Waiting for iteration to complete (max 35 minutes)..."

    # Wait for Claude to complete - MUST finish before next iteration
    WAIT_TIME=0
    MAX_WAIT=2100  # 35 minutes

    while [ $WAIT_TIME -lt $MAX_WAIT ]; do
        if ! kill -0 $CLAUDE_PID 2>/dev/null; then
            log "✓ Iteration $ITERATION completed (Claude exited)"
            break
        fi

        sleep 30
        WAIT_TIME=$((WAIT_TIME + 30))
        log "Still running... (${WAIT_TIME}s elapsed)"
    done

    if [ $WAIT_TIME -ge $MAX_WAIT ]; then
        log "⚠ Iteration $ITERATION timed out after 35 minutes"
        kill $CLAUDE_PID 2>/dev/null || true
        # Wait a bit for the kill to take effect
        sleep 5
    fi

    # Ensure Claude is fully stopped before proceeding
    log "Verifying no Claude processes remain..."
    while pgrep -f "claude.*--print" > /dev/null 2>&1; do
        log "Waiting for Claude processes to exit..."
        sleep 5
    done
    log "✓ All Claude processes stopped"

    # Pause before next iteration (minimum 15 minutes)
    log "Pausing for 15 minutes before next iteration..."
    sleep 900

    ITERATION=$((ITERATION + 1))
done

log "=========================================="
log "Autonomous loop finished"
log "=========================================="
