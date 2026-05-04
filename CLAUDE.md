# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Automated Polish history quiz question generation for the Testdziej app. The system generates **~750+ questions** (10 per epoch/chapter/difficulty combination) covering 9 historical epochs from Starożytność to III RP.

**Execution method:** External bash script launches Claude Code for one iteration, then exits. Process repeats until all questions generated.

**Target:** 10 questions per epoch/chapter/difficulty (9 epochs × ~50 chapters × 3 difficulties = ~750+ questions).

**New workflow (2026-05-04):** Each loop iteration processes ONE chapter for ALL difficulties (easy, medium, hard) - generating 30 questions total per chapter + chapter summary. Uses MCP polish-history tools (unlimited) instead of web search.

**New workflow (2026-05-04):** Each loop iteration processes ONE chapter for ALL difficulties (easy, medium, hard) - generating 30 questions total per chapter. Questions are stored in history-data/{epoch}/{chapter}/ alongside the chapter summary.

## Workflow Instructions - SINGLE SOURCE OF TRUTH

**IMPORTANT:** The complete loop workflow is in `.claude/instructions.md`

**ALWAYS read and follow `.claude/instructions.md` when:**
- Generating questions
- Validating answers
- Checking Polish grammar
- Managing state files
- Creating commits

**That file contains:**
- Step-by-step question generation process
- Validation workflow with Polish grammar checking
- File naming rules (ONE file = 10 questions)
- State management (questions-tracker.json, state.json)
- Git commit conventions
- Exit conditions

**When updating the workflow:** Only edit `.claude/instructions.md` - it is the authoritative source.

## Architecture

### Directory Structure

```
.claude/                    # Claude Code configuration and workflow
  ├── instructions.md       # ★ COMPLETE WORKFLOW (read this first)
  └── validation-rules.md   # Incorrect answer validation rules

history-data/               # Historical data and state management
  ├── master-list.json      # All epochs with chapters and year ranges
  ├── state.json            # Current loop state
  ├── questions-tracker.json # Progress per epoch/chapter/difficulty
  ├── 01-starozytnosc/      # Epoch directories with chapter subdirectories
  ├── 02-piastowie/
  └── ...

scripts/                    # Automation scripts
  ├── README.md             # Scripts documentation
  ├── run-single-iteration.sh # Single iteration (30 questions + summary)
  ├── run-autonomous-loop.sh  # Continuous autonomous loop
  └── rebuild-tracker.sh      # Rebuild tracker from question files

templates/                  # Question templates
  └── question-template.md   # Question file format reference

logs/                       # Loop execution logs
```

### Key Files

**Workflow:**
- **`.claude/instructions.md`** - Complete loop workflow (SINGLE SOURCE OF TRUTH)
- **`.claude/validation-rules.md`** - Rules for creating plausible incorrect answers

**Data:**
- **`history-data/master-list.json`** - Defines 9 epochs with ~50 chapters
- **`history-data/questions-tracker.json`** - Tracks progress per combination
- **`history-data/state.json`** - Tracks current epoch/chapter

**Execution:**
- **`scripts/run-autonomous-loop.sh`** - External launch script (main entry point)

## Question File Format

Generated questions follow `templates/question-template.md`:

**Metadata:**
- `epoch`, `chapter`, `difficulty` - Classification
- `question_count` - Always 10 per file
- `created_at`, `session_start`, `session_end` - Timestamps
- `tokens_input`, `tokens_output`, `tokens_total` - Token usage

**Content:**
- Historical summary (Polish, 2-3 paragraphs)
- 10 questions with:
  - Question text (Polish)
  - 4 answer options (A, B, C, D)
  - Correct answer letter
  - Explanation (1-3 sentences, simple language)
  - Sources (URLs)
  - Incorrect answers analysis

**File naming:** `[epoch]-[chapter]-[difficulty].md`
- ✅ CORRECT: `starozytnosc-pradzieje-easy.md` (one file with 10 questions)
- ❌ WRONG: `pradzieje-easy-001.md`, `pradzieje-easy-002.md` (separate numbered files)

## New Workflow Features (2026-05-04)

### MCP Polish-History Tools

**Unlimited usage** (hosted locally) instead of web search:

- `mcp__polish-history__search_polish_history()` - Search Polish Wikipedia and Dzieje.pl
- `mcp__polish-history__extract_article()` - Extract full article content
- `mcp__polish-history__search_wikipedia()` - Quick Wikipedia searches

**Benefits:**
- No rate limits
- Better Polish sources
- Optimized for historical research
- More reliable than web scraping

### Skills

Two specialized skills for quality control:

**chapter-summary skill:**
- Creates comprehensive chapter overview (max 300 words)
- Categorizes topics by difficulty (EASY, MEDIUM, HARD)
- Provides source links
- Creates foundation for question generation

**difficulty-reviewer skill:**
- Validates questions are correctly classified by difficulty
- Checks against curriculum standards
- Returns verdict with reasoning

**Usage:**
```bash
skill: "chapter-summary"
args: "[chapter_tech_name]"

skill: "difficulty-reviewer"
args: "[question_file]"
```

### File Storage

**New structure:**
```
history-data/{epoch_id}-{epoch_tech_name}/{chapter_id}-{chapter_tech_name}/
  ├── {chapter}_summary.md
  ├── {chapter}_questions_easy.md
  ├── {chapter}_questions_medium.md
  └── {chapter}_questions_hard.md
```

**Old structure still supported:** `questions/validated/[epoch]-[chapter]-[difficulty].md`

## Validation Rules

**CRITICAL:** When generating incorrect answers, follow rules in `.claude/validation-rules.md`

**Key rules:**
1. All 4 answers similar length (within 20% variance)
2. Incorrect answers must be historically TRUE but wrong context
3. No direct opposites (zyskała/utraciła)
4. If question has date, no answers should contain dates
5. Vary correct answer position (A, B, C, D)

**Validation process:**
- MCP polish-history tools to verify historical accuracy
- difficulty-reviewer skill to verify difficulty classification
- Polish grammar checking via polish-grammar-checker subagent
- Plausibility review of incorrect answers

See `.claude/validation-rules.md` for complete rules and examples.

## State Files

### `history-data/questions-tracker.json`

Tracks progress per epoch/chapter/difficulty combination:

```json
{
  "tracking": {
    "Piastowie": {
      "Chrystianizacja": {
        "easy": 10,
        "medium": 10,
        "hard": 10
      }
    }
  },
  "last_updated": "2026-05-04T12:00:00Z"
}
```

**Used by:**
- Scripts to find next target chapter
- Workflow to determine what to generate next
- `rebuild-tracker.sh` to verify progress

### `history-data/state.json`

Tracks current loop iteration:

```json
{
  "current_epoch": "Piastowie",
  "current_chapter": "Chrystianizacja",
  "current_difficulty": "all",
  "questions_generated_this_session": 30,
  "total_questions_generated": 120,
  "last_run": "2026-05-04T12:00:00Z",
  "status": "completed",
  "errors": [],
  "batch_size": 30
}
```

**Note:** `current_difficulty` is now "all" (instead of "easy"/"medium"/"hard") since one loop processes all difficulties.

**Updated after:** Each iteration completes

## Common Commands (for Claude)

**Find next combination needing questions:**
```bash
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
  "\($epoch)|\($chapter)|\(.key)"
' history-data/questions-tracker.json | head -1
```

**Check specific combination count:**
```bash
jq -r '.tracking["Piastowie"]["Chrystianizacja"]["easy"]' history-data/questions-tracker.json
```

**View current state:**
```bash
cat history-data/state.json | jq
```

**Count generated questions:**
```bash
find history-data/ -name "*_questions_*.md" | wc -l
```

## Difficulty Levels

Questions vary by difficulty:

- **Easy:** Simple facts (who, what, where, when) - primary school level
- **Medium:** Causes and effects - secondary school level
- **Hard:** Analytical questions - extended matura level

See `.claude/instructions.md` for detailed difficulty guidelines.

## Environment Variables

- `CLAUDE_API_KEY` - Configured in `~/.claude/settings.json`
- No additional environment variables required

## Git Conventions

**CRITICAL:** Commit message format
- NEVER add "Co-Authored-By: Claude", "Authored-By: Claude", or similar
- Use simple, direct messages: `"Add 10 questions for EPOCH/CHAPTER (DIFFICULTY)"`
- Focus on what changed and why

**Auto-commit workflow:**
- Each iteration commits: question files + state files
- Uses `--no-verify` flag to bypass hooks
- Local commits only (no automatic push)

## Language Context

- **Questions:** Polish
- **Historical sources:** Polish Wikipedia (pl.wikipedia.org), historiaposzkola.pl, dlaucznia.pl
- **Code/comments:** English
- **Epoch names:** Polish (Piastowie, Rzeczpospolita Obojga Narodów, etc.)

## For Complete Workflow

**ALL workflow details are in:** `.claude/instructions.md`

When working on this project:
1. Read `.claude/instructions.md` for the complete workflow
2. Reference `.claude/validation-rules.md` for answer validation
3. Use this file (CLAUDE.md) for technical reference only

**To modify workflow:** Only edit `.claude/instructions.md`
