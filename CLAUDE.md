# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This repository generates Polish history quiz questions for the Testdziej app. The system runs in a loop (typically via Claude Code `/loop` command) directly on the host OS to automatically create and validate questions, storing them locally as markdown files.

**Target:** 20 questions per epoch/chapter/difficulty combination (9 epochs × ~50 chapters × 3 difficulties = ~1,500+ questions needed).

**Batch size:** Each loop iteration generates 10 questions for the same epoch/chapter/difficulty combination.

**IMPORTANT:** This version operates on local files ONLY. No database or Docker container is required.

## Architecture

### Directory Structure

```
.claude/               # Claude Code configuration and state
  ├── instructions.md       # Main loop workflow instructions
  ├── validation-rules.md   # Question validation rules
  └── state.json            # Current loop state (epoch, chapter, difficulty)
epochs/               # Epoch definitions and chapter mappings
  └── master-list.json      # All epochs with chapters and year ranges
chapters/             # Chapter source materials (empty - use web sources)
questions/            # Generated questions
  ├── pending/             # Questions being generated
  └── validated/           # Questions that passed validation
scripts/              # Automation scripts
  ├── loop-controller.sh   # Main loop entry point
  └── validate-question.sh # Question validation (TODO)
templates/            # Question templates
  └── question-template.md # Question file format
logs/                 # Loop execution logs
```

### Key Files

- **`epochs/master-list.json`**: Defines 9 historical epochs (Starożytność → III RP) with ~50 chapters total
- **`.claude/state.json`**: Tracks current progress (current_epoch, current_chapter, current_difficulty)
- **`.claude/questions-tracker.json`**: Tracks question counts per epoch/chapter/difficulty combination
- **`.claude/instructions.md`**: Complete loop workflow - read this before generating questions
- **`.claude/validation-rules.md`**: Critical rules for creating plausible incorrect answers

## Common Commands

### Initial Setup (one-time)

```bash
# Install Claude Code and dependencies on host OS
source claude_code_zai_env.sh
```

This script installs:
- Node.js (v22+)
- Claude Code CLI via npm
- Configures API keys

### Running the Loop

```bash
# Start Claude Code
claude

# Within Claude Code, the loop follows .claude/instructions.md:
# 1. Read questions-tracker.json to find next epoch/chapter/difficulty needing questions
# 2. Research historical sources using WebSearch
# 3. Generate question following templates and validation rules
# 4. Validate and save to questions/validated/
# 5. Update counters in both state.json and questions-tracker.json
```

### Monitoring Progress

```bash
# View current state
cat .claude/state.json | jq

# View questions tracker
cat .claude/questions-tracker.json | jq

# View loop logs
tail -f logs/loop-$(date +%Y%m%d).log

# Count generated questions
find questions/validated/ -name "*.md" | wc -l

# Rebuild tracker from actual validated questions (if out of sync)
./scripts/rebuild-tracker.sh
```

### File-based Queries

**Find next epoch/chapter needing questions:**
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
  select(.value < 20) |
  "\($epoch)|\($chapter)|\(.key)|\(.value)"
' .claude/questions-tracker.json | head -1
```

**Check specific combination count:**
```bash
jq -r '.tracking["Piastowie"]["Chrystianizacja"]["easy"]' .claude/questions-tracker.json
```

**Recount all questions from validated folder:**
```bash
# This script scans all validated questions and rebuilds the tracker
for file in questions/validated/*.md; do
  epoch=$(grep '^epoch:' "$file" | cut -d':' -f2 | xargs)
  chapter=$(grep '^chapter:' "$file" | cut -d':' -f2 | xargs)
  difficulty=$(grep '^difficulty:' "$file" | cut -d':' -f2 | xargs)
  echo "$epoch $chapter $difficulty"
done | sort | uniq -c
```

## Question Generation Workflow

When the loop runs, each iteration generates **10 questions** for the same epoch/chapter/difficulty combination:

1. **Identify target:** Read questions-tracker.json for next epoch/chapter/difficulty with < 20 questions
2. **Research:** Use WebSearch tool to find Polish historical sources (pl.wikipedia.org, historiaposzkola.pl, etc.)
3. **Create summary:** Write 2-3 paragraphs of historical context in Polish
4. **Generate question:** Based on difficulty level:
   - **Easy:** Simple facts (who, what, where, when) - primary school level
   - **Medium:** Causes and effects - secondary school level
   - **Hard:** Analytical questions - extended matura level
5. **Create incorrect answers:** Follow strict validation rules (see below)
6. **Validate:** Verify historical accuracy and answer plausibility
7. **Save:** Save ALL 10 questions in ONE file to `questions/validated/[epoch]-[chapter]-[difficulty].md`
   - ✅ CORRECT: `starozytnosc-pradzieje-easy.md` (one file with all 10 questions)
   - ❌ WRONG: `pradzieje-easy-001.md`, `pradzieje-easy-002.md`, etc. (separate numbered files)
8. **Update state:** Write progress to both `.claude/state.json` and `.claude/questions-tracker.json`

## Critical Validation Rules for Incorrect Answers

When generating incorrect answers, follow these rules **exactly**:

1. **All 4 answers must have similar length** (within 20% variance)
2. **Incorrect answers must be:**
   - Historically TRUE facts (not made up)
   - From different time periods (50-150 years difference) OR different contexts
3. **Incorrect answers must NOT be:**
   - Direct opposites of the correct answer (e.g., "zyskała" vs "utraciła")
   - Obviously wrong historical errors
4. **Date rule:** If the question contains a year/date, **no answers should contain dates**
5. **Position:** Correct answer should not always be in the same position

Example for "W którym roku Polska odzyskała niepodległość w 1918?":
- ❌ Bad: "W 1918", "W 1939", "W 1945", "W 1989" (all dates, question has date)
- ✅ Good: "Po zakończeniu I wojny światowej", "Po upadku komunizmu", "Po II wojnie światowej", "Po trzecim rozbiorze"

## State File Format

`.claude/state.json` tracks loop progress:

```json
{
  "current_epoch": "Piastowie",
  "current_chapter": "Chrystianizacja",
  "current_difficulty": "easy",
  "questions_generated_this_session": 5,
  "total_questions_generated": 42,
  "last_run": "2026-03-28T12:00:00Z",
  "status": "completed",
  "errors": []
}
```

## Environment Variables

- `CLAUDE_API_KEY`: Configured via `claude_code_zai_env.sh` or in `~/.claude/settings.json`

## Question File Format

Follow `templates/question-template.md`. Key sections:
- Metadata header (epoch, chapter, difficulty, timestamps, token counts)
- Historical summary (Polish, 2-3 paragraphs)
- Question text (Polish)
- 4 answer options (A, B, C, D)
- Correct answer letter
- Explanation (1-3 sentences)
- Validation checklist
- Sources (URLs)
- Incorrect answers analysis (why each is plausible but wrong)

## Loop Exit Conditions

Stop generation when:
- All epoch/chapter/difficulty combinations have 20 questions
- 10 consecutive errors occur
- User interrupts (Ctrl+C)
- Token budget exceeded (if configured)

## Language Context

- **Questions:** Polish
- **Historical sources:** Prioritize Polish Wikipedia (pl.wikipedia.org), historiaposzkola.pl, dlaucznia.pl
- **Comments:** English (this repo)
- **Epoch names:** Polish (e.g., "Piastowie", "Rzeczpospolita Obojga Narodów")

## Batch Generation Strategy

Each loop iteration generates **10 questions** for the same epoch/chapter/difficulty:

1. **Vary topics across the 10 questions:**
   - Political events
   - Social changes
   - Economic factors
   - Cultural developments
   - Military conflicts
   - Diplomatic relations
   - Key biographies
   - Geographic aspects
   - Chronological milestones
   - Cause-effect relationships

2. **Vary question types:**
   - Who (people/figures)
   - What (events/actions)
   - When (dates/timeline)
   - Where (places/locations)
   - Why (causes/reasons)
   - How (consequences/methods)

3. **Rotate answer positions:**
   - Ensure correct answer appears as A, B, C, and D evenly across the 10 questions
   - Don't make correct answer always the same position

## Git Conventions

**CRITICAL: Commit Message Format**
- NEVER add "Co-Authored-By: Claude", "Authored-By: Claude", or similar attributions
- Use simple, direct commit messages
- Focus on what changed and why
- Example: "Add batch question generation for Piastowie epoch"
- Example: "Update validation rules for incorrect answer generation"

This is a user repository - commits should not include AI/assistant attribution.
