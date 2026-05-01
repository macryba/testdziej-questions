# Testdziej Question Generator

Automated Polish history quiz question generation system for the Testdziej app.

## What This Does

Generates **~750+ Polish history questions** covering:
- 9 historical epochs (Starożytność → III RP)
- ~50 chapters total
- 3 difficulty levels (easy, medium, hard)
- Target: 10 questions per epoch/chapter/difficulty combination

## Quick Start

```bash
# Run the autonomous loop
./scripts/run-autonomous-loop.sh
```

This script:
1. Launches Claude Code for one iteration
2. Generates 10 questions for target epoch/chapter/difficulty
3. Waits for completion, exits Claude
4. Pauses 15 minutes
5. Repeats until all questions generated

**To stop:** Press `Ctrl+C`

## How It Works

The system uses **external launch** (not internal Claude Code loop):

```
Bash script → Claude Code → One iteration → Exit → Wait → Repeat
```

Each iteration:
- Reads `.claude/questions-tracker.json` to find next target
- Researches historical sources online
- Generates 10 questions following workflow in `.claude/instructions.md`
- Validates questions and checks Polish grammar
- Saves questions to `questions/validated/`
- Commits changes to git
- Exits and waits 15 minutes before next iteration

**Benefits:**
- Fresh Claude session each iteration (clean context)
- Automatic restarts if Claude crashes
- Built-in timeouts and monitoring
- Cooldown period between iterations

## Important Files

**Workflow documentation:**
- **`.claude/instructions.md`** - Complete loop workflow (SINGLE SOURCE OF TRUTH)
  - Question generation process
  - Validation rules
  - Polish grammar checking
  - State management
  - File naming conventions

**Supporting files:**
- **`.claude/validation-rules.md`** - Critical rules for plausible incorrect answers
- **`epochs/master-list.json`** - All epochs and chapters structure
- **`CLAUDE.md`** - Technical reference for Claude Code (AI agent documentation)

**State tracking:**
- **`.claude/questions-tracker.json`** - Progress per epoch/chapter/difficulty
- **`.claude/state.json`** - Current loop state

## Monitoring Progress

```bash
# Check overall progress
cat .claude/questions-tracker.json | jq

# View autonomous loop logs
tail -f logs/autonomous-loop-$(date +%Y%m%d).log

# Count generated questions
find questions/validated/ -name "*.md" | wc -l

# Find next combination needing questions
jq -r '
  to_entries[] |
  select(.key != "last_updated") |
  .key as $epoch |
  .value |
  to_entries[] |
  .key as $chapter |
  .value |
  to_entries[] |
  select(.value < 10) |
  "\($epoch)|\(.chapter)|\(.key)|\(.value)"
' .claude/questions-tracker.json | head -1

# Check specific combination count
jq -r '.tracking["Piastowie"]["Chrystianizacja"]["easy"]' .claude/questions-tracker.json
```

## Question Format

Each file contains **10 questions**:
- Filename: `[epoch]-[chapter]-[difficulty].md`
- Example: `starozytnosc-pradzieje-easy.md`
- Location: `questions/validated/`

**Critical:** One file = 10 questions (NOT 10 separate files)

## Exit Conditions

The autonomous loop stops when:
- All epoch/chapter/difficulty combinations have 10 questions
- Manual interruption (Ctrl+C)

## Git Workflow

Each iteration automatically commits:
- Generated question files
- Updated state files (questions-tracker.json, state.json)
- Commit message: `"Add 10 questions for EPOCH/CHAPTER (DIFFICULTY)"`

**No AI attribution** in commits (this is a user repository).

## Troubleshooting

**Loop not starting?**
```bash
# Check Claude Code is installed
claude --version

# Verify API keys
cat ~/.claude/settings.json
```

**Questions not validating correctly?**
- Read `.claude/validation-rules.md` for incorrect answer rules
- Review workflow in `.claude/instructions.md`

**Need to rebuild tracker from actual questions?**
```bash
./scripts/rebuild-tracker.sh
```

**Claude stuck or timed out?**
- Check logs: `tail -f logs/autonomous-loop-$(date +%Y%m%d).log`
- Script auto-kills after 35 minutes and retries

## Project Structure

```
.claude/                    # Configuration and workflow
  ├── instructions.md       # ★ COMPLETE WORKFLOW (single source)
  ├── validation-rules.md   # Incorrect answer rules
  ├── questions-tracker.json # Progress tracking
  └── state.json            # Current state

epochs/                     # Historical structure
  └── master-list.json      # All epochs and chapters

questions/                  # Generated questions
  └── validated/            # Completed question sets (10 per file)

scripts/                    # Automation
  ├── run-autonomous-loop.sh # ★ Main entry point
  ├── validate-question.sh   # Validation script
  └── rebuild-tracker.sh     # Tracker repair utility

logs/                       # Execution logs
```

## Language Context

- **Questions:** Polish
- **Historical sources:** Polish Wikipedia (pl.wikipedia.org), historiaposzkola.pl, dlaucznia.pl
- **Code/comments:** English
- **Epoch names:** Polish (Piastowie, Rzeczpospolita Obojga Narodów, etc.)

## For Workflow Details

**To understand or modify how questions are generated:**
→ Read `.claude/instructions.md`

This file is the **single source of truth** for:
- Question generation process
- Validation workflow
- Polish grammar checking
- State management
- File naming rules

When updating the workflow, only edit `.claude/instructions.md`.
