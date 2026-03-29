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
    # Check all combinations in questions-tracker.json
    INCOMPLETE=$(jq -r '
        [.tracking |
        to_entries[] |
        select(.key != "last_updated") |
        .key as $epoch |
        .value |
        to_entries[] |
        .key as $chapter |
        .value |
        to_entries[] |
        select(.value < 20)] |
        length
    ' /home/macryba/testdziej-questions/.claude/questions-tracker.json)

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
    claude --print "Execute question generation workflow:
1. Run: jq -r '.tracking | to_entries[] | select(.key != \"last_updated\") | .key as \$epoch | .value | to_entries[] | .key as \$chapter | .value | to_entries[] | select(.value < 20) | \"\(\$epoch)|\(\$chapter)|\(.key)\"' .claude/questions-tracker.json | head -1
2. For the target epoch/chapter/difficulty, generate 10 questions
3. Save to: questions/validated/[epoch]-[chapter]-[difficulty].md
4. Update both .claude/state.json and .claude/questions-tracker.json (+10)
5. Run: git add questions/validated/*.md .claude/*.json && git commit --no-verify -m \"Add 10 questions for EPOCH/CHAPTER (DIFFICULTY)\"

Complete ALL 5 steps including git commit before exiting." &
    CLAUDE_PID=$!

    log "Claude Code started (PID: $CLAUDE_PID)"
    log "Waiting for iteration to complete (max 35 minutes)..."

    # Wait for Claude to complete
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
    fi

    # Brief pause before next iteration
    log "Pausing for 10 seconds before next iteration..."
    sleep 10

    ITERATION=$((ITERATION + 1))
done

log "=========================================="
log "Autonomous loop finished"
log "=========================================="
