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

    # Start Claude Code with loop command in background
    log "Starting Claude Code loop for iteration $ITERATION..."

    # Create a temporary tmux session for this iteration
    SESSION_NAME="testdziej-loop-iter-$ITERATION"
    tmux new-session -d -s "$SESSION_NAME" -c "$PROJECT_DIR"

    # Send commands to start Claude Code and run loop
    tmux send-keys -t "$SESSION_NAME" "claude" C-m
    sleep 3
    tmux send-keys -t "$SESSION_NAME" "/loop 30m .claude/instructions.md" C-m

    log "Claude Code loop started in session: $SESSION_NAME"
    log "Waiting for iteration to complete (max 35 minutes)..."

    # Wait for the iteration to complete
    # Check every 30 seconds if the session still exists
    WAIT_TIME=0
    MAX_WAIT=2100  # 35 minutes max per iteration

    while [ $WAIT_TIME -lt $MAX_WAIT ]; do
        if ! tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
            log "✓ Iteration $ITERATION completed (session closed)"
            break
        fi

        # Check if Claude Code is still running
        if ! tmux capture-pane -t "$SESSION_NAME" -p | grep -q "claude\|Claude"; then
            log "✓ Iteration $ITERATION completed (Claude Code exited)"
            # Clean up session
            tmux kill-session -t "$SESSION_NAME" 2>/dev/null || true
            break
        fi

        sleep 30
        WAIT_TIME=$((WAIT_TIME + 30))
        log "Still running... (${WAIT_TIME}s elapsed)"
    done

    if [ $WAIT_TIME -ge $MAX_WAIT ]; then
        log "⚠ Iteration $ITERATION timed out after 35 minutes"
        tmux kill-session -t "$SESSION_NAME" 2>/dev/null || true
    fi

    # Brief pause before next iteration
    log "Pausing for 10 seconds before next iteration..."
    sleep 10

    ITERATION=$((ITERATION + 1))
done

log "=========================================="
log "Autonomous loop finished"
log "=========================================="
