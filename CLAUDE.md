# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This repository generates Polish history quiz questions for the Testdziej app. The system runs in a loop (typically via Claude Code `/loop` command) directly on the host OS to automatically create, validate, and sync questions to a Supabase database.

**Target:** 20 questions per epoch/chapter/difficulty combination (9 epochs × ~50 chapters × 3 difficulties = ~1,500+ questions needed).

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
  ├── validated/           # Questions that passed validation
  └── archived/            # Questions synced to database
scripts/              # Automation scripts
  ├── loop-controller.sh   # Main loop entry point
  ├── validate-question.sh # Question validation (TODO)
  └── sync-to-db.sh        # Database sync (TODO)
templates/            # Question templates
  └── question-template.md # Question file format
logs/                 # Loop execution logs
```

### Key Files

- **`epochs/master-list.json`**: Defines 9 historical epochs (Starożytność → III RP) with ~50 chapters total
- **`.claude/state.json`**: Tracks current progress (current_epoch, current_chapter, current_difficulty)
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
# 1. Query database for next epoch/chapter/difficulty needing questions
# 2. Research historical sources using WebSearch
# 3. Generate question following templates and validation rules
# 4. Validate and save to questions/validated/
# 5. Update state in .claude/state.json
```

### Monitoring Progress

```bash
# View current state
cat .claude/state.json | jq

# View loop logs
tail -f logs/loop-$(date +%Y%m%d).log

# Count generated questions
find questions/validated/ -name "*.md" | wc -l
```

### Database Queries

**Find next epoch/chapter needing questions:**
```bash
docker exec supabase_db_testdziej psql -U postgres -c "
  SELECT
    e.short_name as epoch,
    c.short_name as chapter,
    q.difficulty,
    COUNT(*) as question_count
  FROM chapters c
  JOIN epochs e ON c.epoch_id = e.id
  LEFT JOIN quiz_questions q ON q.chapter_id = c.id
  GROUP BY e.short_name, c.short_name, q.difficulty
  HAVING COUNT(*) < 20 OR COUNT(*) IS NULL
  ORDER BY e.id, c.order_index,
    CASE q.difficulty WHEN 'easy' THEN 1 WHEN 'medium' THEN 2 WHEN 'hard' THEN 3 END
  LIMIT 1;
"
```

**Check specific combination count:**
```bash
docker exec supabase_db_testdziej psql -U postgres -c "
  SELECT COUNT(*)
  FROM quiz_questions q
  JOIN chapters c ON q.chapter_id = c.id
  JOIN epochs e ON c.epoch_id = e.id
  WHERE e.short_name = 'Piastowie'
    AND c.short_name = 'Chrystianizacja'
    AND q.difficulty = 'easy';
"
```

## Question Generation Workflow

When the loop runs, each iteration generates **one** question file:

1. **Identify target:** Query database for next epoch/chapter/difficulty with < 20 questions
2. **Research:** Use WebSearch tool to find Polish historical sources (pl.wikipedia.org, historiaposzkola.pl, etc.)
3. **Create summary:** Write 2-3 paragraphs of historical context in Polish
4. **Generate question:** Based on difficulty level:
   - **Easy:** Simple facts (who, what, where, when) - primary school level
   - **Medium:** Causes and effects - secondary school level
   - **Hard:** Analytical questions - extended matura level
5. **Create incorrect answers:** Follow strict validation rules (see below)
6. **Validate:** Verify historical accuracy and answer plausibility
7. **Save:** Move from `questions/pending/` to `questions/validated/`
8. **Update state:** Write progress to `.claude/state.json`

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
- Database access: Requires ability to connect to Supabase (via `docker exec` if Supabase is in Docker, or direct `psql` connection)

Note: If Supabase runs in Docker, the database commands still use `docker exec supabase_db_testdziej psql ...`

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
