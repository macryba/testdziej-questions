# Testdziej Question Generator

Automated Polish history quiz question generation system for the Testdziej app.

## What This Does

Generates **~750+ Polish history questions** covering:
- 9 historical epochs (Starożytność → III RP)
- ~50 chapters total
- 3 difficulty levels (easy, medium, hard)
- Target: 10 questions per epoch/chapter/difficulty combination

**New workflow (2026-05-04):** Each loop iteration generates **30 questions per chapter** (10 per difficulty level) plus a chapter summary.

## Quick Start

```bash
# Run a single iteration (recommended for testing)
./scripts/run-single-iteration.sh

# Or run continuous autonomous loop
./scripts/run-autonomous-loop.sh
```

Each iteration:
1. Finds the next chapter needing questions
2. Researches using **MCP polish-history tools** (unlimited usage)
3. Creates chapter summary using **chapter-summary skill**
4. Generates **10 questions for EACH difficulty** (easy, medium, hard) = 30 total
5. Validates with **difficulty-reviewer skill** and checks Polish grammar
6. Saves to `history-data/{epoch}/{chapter}/` (one file per difficulty)
7. Commits changes to git

**To stop autonomous loop:** Press `Ctrl+C`

## How It Works

The system uses **external launch** (not internal Claude Code loop):

```
Bash script → Claude Code → One iteration (30 questions) → Exit → Wait → Repeat
```

**Benefits:**
- Fresh Claude session each iteration (clean context)
- **3x faster**: One loop per chapter instead of three
- **Unlimited research**: MCP tools have no rate limits
- **Better context**: Chapter summary created once, used for all difficulties
- Automatic restarts if Claude crashes
- Built-in timeouts and monitoring
- Cooldown period between iterations

## Important Files

**Workflow documentation:**
- **`.claude/instructions.md`** - Complete loop workflow (SINGLE SOURCE OF TRUTH)
  - Question generation process
  - MCP tool usage (polish-history)
  - Chapter summary creation
  - Difficulty validation
  - Polish grammar checking
  - State management
  - File naming conventions

**Supporting files:**
- **`.claude/validation-rules.md`** - Critical rules for plausible incorrect answers
- **`history-data/master-list.json`** - All epochs and chapters structure
- **`CLAUDE.md`** - Technical reference for Claude Code (AI agent documentation)
- **`scripts/README.md`** - Scripts documentation

**State tracking:**
- **`history-data/questions-tracker.json`** - Progress per epoch/chapter/difficulty
- **`history-data/state.json`** - Current loop state

## Monitoring Progress

```bash
# Check overall progress
cat history-data/questions-tracker.json | jq

# View autonomous loop logs
tail -f logs/autonomous-loop-$(date +%Y%m%d).log

# Count generated questions (new structure)
find history-data/ -name "*_questions_*.md" | wc -l

# Find next chapter needing questions
jq -r '
  .tracking |
  to_entries[] |
  select(.key != "last_updated") |
  .key as $epoch |
  .value |
  to_entries[] |
  .key as $chapter |
  select(.value.easy < 10 or .value.medium < 10 or .value.hard < 10) |
  "\($epoch)/\($chapter): easy=\(.value.easy) medium=\(.value.medium) hard=\(.value.hard)"
' history-data/questions-tracker.json | head -1

# Check specific combination count
jq -r '.tracking["Piastowie"]["Chrystianizacja"]["easy"]' history-data/questions-tracker.json
```

## Question Format

Each chapter generates **3 files** (one per difficulty):

```
history-data/{epoch_id}-{epoch_tech_name}/{chapter_id}-{chapter_tech_name}/
  ├── {chapter}_summary.md              (chapter overview + topics by difficulty)
  ├── {chapter}_questions_easy.md       (10 easy questions)
  ├── {chapter}_questions_medium.md     (10 medium questions)
  └── {chapter}_questions_hard.md       (10 hard questions)
```

**Example:**
```
history-data/02-piastowie/05-zjednoczenie/
  ├── zjednoczenie_summary.md
  ├── zjednoczenie_questions_easy.md
  ├── zjednoczenie_questions_medium.md
  └── zjednoczenie_questions_hard.md
```

**Critical:** One file = 10 questions (NOT 10 separate files)

## New Workflow Details

### Research Phase (Using MCP Tools)

Instead of web search (limited), the system now uses **MCP polish-history tools**:

```bash
# Search for articles
mcp__polish-history__search_polish_history(
  query: "[epoch] [chapter]",
  domains: ["wikipedia", "dzieje"],
  limit: 10
)

# Extract article content
mcp__polish-history__extract_article(url: "...")
```

**Benefits:**
- Unlimited usage (hosted locally)
- Better Polish sources (Wikipedia Polska, Dzieje.pl)
- Optimized for historical research
- No rate limits

### Chapter Summary Creation

After research, a comprehensive summary is created:

```bash
skill: "chapter-summary"
args: "[chapter_tech_name]"
```

This creates:
- Historical overview (max 300 words)
- Topics categorized by difficulty (EASY, MEDIUM, HARD)
- Source links
- Foundation for question generation

### Question Generation

Using the chapter summary, questions are generated for **all three difficulties** in one loop:

- **EASY**: Simple facts (who, what, where, when) - primary school level
- **MEDIUM**: Causes and effects - secondary school level
- **HARD**: Analytical questions - extended matura level

### Validation

Each difficulty is validated using:

```bash
skill: "difficulty-reviewer"
args: "[question_file]"
```

Plus Polish grammar checking using the polish-grammar-checker subagent.

## Exit Conditions

The autonomous loop stops when:
- All epoch/chapter/difficulty combinations have 10 questions
- Manual interruption (Ctrl+C)
- 10 consecutive errors

## Git Workflow

Each iteration automatically commits:
- Chapter summary file
- 3 question files (easy, medium, hard)
- Updated state files (questions-tracker.json, state.json)
- Commit message: `"Add 30 questions for EPOCH/CHAPTER (all difficulties: easy, medium, hard)"`

**No AI attribution** in commits (this is a user repository).

## Troubleshooting

**Loop not starting?**
```bash
# Check Claude Code is installed
claude --version

# Verify API keys
cat ~/.claude/settings.json

# Check MCP server is running
# (should be configured in ~/.claude/settings.json)
```

**Wrong chapter being processed?**
```bash
# Rebuild tracker from actual files
./scripts/rebuild-tracker.sh

# Check what's next
cat history-data/questions-tracker.json | jq -r '...same as above...'
```

**Questions not validating correctly?**
- Read `.claude/validation-rules.md` for incorrect answer rules
- Review workflow in `.claude/instructions.md`
- Check difficulty-reviewer skill output

**Claude stuck or timed out?**
- Check logs: `tail -f logs/autonomous-loop-$(date +%Y%m%d).log`
- Script auto-kills after 35 minutes and retries

**MCP tools not working?**
- Verify MCP server is configured in `~/.claude/settings.json`
- Check MCP server is running: `ps aux | grep polish-history`
- Test manually: `mcp__polish-history__server_info`

## Project Structure

```
.claude/                    # Configuration and workflow
  ├── instructions.md       # ★ COMPLETE WORKFLOW (single source)
  └── validation-rules.md   # Incorrect answer rules

history-data/               # All historical data and state
  ├── master-list.json      # All epochs and chapters
  ├── state.json            # Current loop state
  ├── questions-tracker.json # Progress tracking
  ├── 01-starozytnosc/      # Epoch directories
  ├── 02-piastowie/
  └── ...

scripts/                    # Automation
  ├── README.md             # Scripts documentation
  ├── run-single-iteration.sh    # Single iteration (30 questions)
  ├── run-autonomous-loop.sh     # Continuous loop
  └── rebuild-tracker.sh         # Tracker repair utility

logs/                       # Execution logs
```

## Scripts Quick Reference

```bash
# Test the new workflow (recommended first step)
./scripts/run-single-iteration.sh

# Run full autonomous loop
./scripts/run-autonomous-loop.sh

# Rebuild tracker if needed
./scripts/rebuild-tracker.sh
```

See `scripts/README.md` for detailed script documentation.

## Language Context

- **Questions:** Polish
- **Historical sources:** MCP polish-history tools (Wikipedia Polska, Dzieje.pl)
- **Code/comments:** English
- **Epoch names:** Polish (Piastowie, Rzeczpospolita Obojga Narodów, etc.)

## For Workflow Details

**To understand or modify how questions are generated:**
→ Read `.claude/instructions.md`

This file is the **single source of truth** for:
- Question generation process
- MCP tool usage
- Chapter summary creation
- Difficulty validation
- Polish grammar checking
- State management
- File naming rules

When updating the workflow, only edit `.claude/instructions.md`.

## Migration Notes

**Changed in 2026-05-04:**
- ✅ State files moved to `history-data/`
- ✅ Questions now stored in `history-data/{epoch}/{chapter}/`
- ✅ One loop per chapter (all 3 difficulties)
- ✅ MCP tools replace web search
- ✅ Chapter summaries created automatically
- ✅ Difficulty validation with skills

**Old structure still supported:**
- Old question files in `questions/validated/` still work
- `rebuild-tracker.sh` handles both structures
