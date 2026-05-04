# Testdziej Question Generation Scripts

This directory contains automation scripts for generating Polish history quiz questions.

## Available Scripts

### 🚀 run-single-iteration.sh
**Purpose:** Run a single iteration of the question generation workflow

**Usage:**
```bash
bash scripts/run-single-iteration.sh
```

**What it does:**
- Finds the next chapter needing questions
- Launches Claude Code to process one chapter
- Generates questions for ALL difficulties (easy, medium, hard) - 30 questions total
- Creates chapter summary and question files
- Commits changes to git
- Shows progress and files created

**When to use:**
- Testing the new workflow
- Manual question generation
- Debugging or development
- Processing specific chapters

**Output:** 30 questions (10 per difficulty) + chapter summary

---

### 🔄 run-autonomous-loop.sh
**Purpose:** Run continuous autonomous loop until all chapters are complete

**Usage:**
```bash
bash scripts/run-autonomous-loop.sh
```

**What it does:**
- Continuously runs iterations until all questions are generated
- 35-minute timeout per iteration
- 15-minute pause between iterations
- Automatic error recovery
- Logs to `logs/autonomous-loop-YYYYMMDD.log`

**When to use:**
- Batch processing multiple chapters
- Overnight/weekend generation
- Full project completion

**Output:** All questions for all chapters (750+ questions)

---

### 🔧 rebuild-tracker.sh
**Purpose:** Rebuild questions-tracker.json from existing question files

**Usage:**
```bash
bash scripts/rebuild-tracker.sh
```

**What it does:**
- Scans all question files in `history-data/`
- Rebuilds `history-data/questions-tracker.json` from scratch
- Shows summary of questions per epoch/chapter
- Supports both new and old file structures

**When to use:**
- Tracker file is corrupted or out of sync
- Migrating from old to new file structure
- Verifying question counts
- After manual file changes

**Output:** Updated `questions-tracker.json` with accurate counts

---

## Workflow Overview

### New Workflow (2026-05-04)

Each iteration processes **ONE chapter for ALL difficulties**:

```
1. Find next chapter needing questions
2. Research using MCP polish-history tools (unlimited)
3. Create chapter summary using chapter-summary skill
4. Generate 10 questions per difficulty (easy, medium, hard)
5. Validate with difficulty-reviewer skill
6. Check Polish grammar
7. Save to history-data/{epoch}/{chapter}/
8. Update state files and commit
```

### File Structure

```
history-data/
├── state.json                    # Current loop state
├── questions-tracker.json        # Progress tracking
├── master-list.json             # Epoch and chapter definitions
└── {epoch_id}-{epoch_tech_name}/
    └── {chapter_id}-{chapter_tech_name}/
        ├── {chapter}_summary.md
        ├── {chapter}_questions_easy.md
        ├── {chapter}_questions_medium.md
        └── {chapter}_questions_hard.md
```

## Script Exit Codes

- `0` - Success
- `1` - Error (check logs for details)

## Logs

All scripts write logs to `logs/` directory:
- `single-iteration-YYYYMMDD.log` - Single iteration logs
- `autonomous-loop-YYYYMMDD.log` - Autonomous loop logs
- `loop-YYYYMMDD.log` - Legacy controller logs (if any)

## Quick Start

```bash
# Run a single iteration (recommended for testing)
bash scripts/run-single-iteration.sh

# Run autonomous loop (for full processing)
bash scripts/run-autonomous-loop.sh

# Rebuild tracker if needed
bash scripts/rebuild-tracker.sh
```

## Troubleshooting

**Script won't run?**
- Make sure scripts are executable: `chmod +x scripts/*.sh`
- Check Claude Code is installed: `which claude`
- Verify state files exist: `ls history-data/*.json`

**Wrong chapter being processed?**
- Check tracker: `cat history-data/questions-tracker.json | jq`
- Rebuild tracker: `bash scripts/rebuild-tracker.sh`

**Questions not being generated?**
- Check logs: `tail -f logs/single-iteration-*.log`
- Verify Claude Code credentials
- Check MCP server is running

## Related Files

- **Workflow:** `.claude/instructions.md`
- **Validation:** `.claude/validation-rules.md`
- **Skills:** `.claude/skills/` (chapter-summary, difficulty-reviewer)
- **Data:** `history-data/`

---

**Last updated:** 2026-05-04
**Workflow version:** 2.0 (all difficulties per chapter)
