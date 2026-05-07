# Question Migration Instruction

**Purpose:** Migrate valuable questions from old format (`questions/validated/`) to new structured format (`history-data/{epoch}/{chapter}/`)

**Key Principle:** Migrate one complete **chapter** (all 3 difficulties: easy, medium, hard) in a single session to leverage common historical context and research.

---

## Quick Reference

**When to use this agent:**
- User requests migration of old format questions to new format
- System identifies questions in `questions/validated/` that need migration

**What this agent does:**
- Reads old format questions for one chapter (easy, medium, hard)
- Identifies valuable questions not duplicating new format content
- Validates historical accuracy using MCP polish-history tools
- Converts to new format with proper structure
- Validates Polish grammar using polish-grammar-checker subagent
- Validates difficulty level using difficulty-reviewer skill
- Updates state files (questions-tracker.json, state.json)
- Deletes old files
- Creates git commit

**Output:** Migrated chapter with 3 files (easy, medium, hard) in new format

---

## Complete Workflow

### Phase 1: Preparation and Analysis

#### Step 1: Identify Chapter to Migrate

**Input:** User provides chapter name or you identify next chapter needing migration

**Example:** `piastowie-ekspansja` (means easy, medium, and hard all for Ekspansja chapter)

**Action:**
```bash
# List old format files for the chapter
ls -1 questions/validated/{epoch}-{chapter}-{easy,medium,hard}.md

# Check if new format files exist
ls -1 history-data/{epoch_id}-{epoch}/{chapter_id}-{chapter}/
```

#### Step 2: Read All Old Format Files

**Read all 3 difficulty files:**
```bash
# Example for piastowie-ekspansja
questions/validated/piastowie-ekspansja-easy.md
questions/validated/piastowie-ekspansja-medium.md
questions/validated/piastowie-ekspansja-hard.md
```

**For each file, extract:**
- Question count
- Question topics
- Question IDs (old format)
- Question content (text, answers, explanations)

#### Step 3: Read All New Format Files

**Read all 3 new format files:**
```bash
# Example for piastowie-ekspansja
history-data/02-piastowie/02-ekspansja/ekspansja_questions_easy.md
history-data/02-piastowie/02-ekspansja/ekspansja_questions_medium.md
history-data/02-piastowie/02-ekspansja/ekspansja_questions_hard.md
```

**For each file, identify:**
- Current question count
- Existing topics covered
- Question ID sequence (last question number)

#### Step 4: Identify Valuable Questions to Migrate

**For each difficulty level:**

**Criteria for migration:**
1. **Curriculum alignment:** Question covers topics in curriculum standards
2. **Non-duplication:** Topic not already well-covered in new format
3. **Historical accuracy:** Factually correct (verify with MCP tools)
4. **Appropriate difficulty:** Matches designated difficulty level
5. **Value added:** Provides analytical depth or unique perspective

**Red flags (DO NOT migrate):**
- Anachronistic content (wrong time period)
- Duplicate of existing new format question
- Too simplistic for difficulty level
- Historically inaccurate
- Poor quality explanations

**Output:** List of questions to migrate for each difficulty

**Example:**
```
EASY: Migrate 5 questions (Q-PI-EXP-E-003, 007, 012, 015, 019)
- Topics: Mieszko I's western expansion, conquest of Silesia, etc.

MEDIUM: Migrate 4 questions (Q-PI-EXP-M-002, 008, 014, 018)
- Topics: Causes of expansion, administrative changes, etc.

HARD: Migrate 6 questions (Q-PI-EXP-H-001, 005, 011, 013, 017, 020)
- Topics: Geopolitical context, long-term consequences, etc.
```

---

### Phase 2: Historical Validation

**IMPORTANT:** Validate historical facts BEFORE converting to new format.

#### Step 5: Research Topics Using MCP Polish-History Tools

**For each unique topic/question:**

**Search for information:**
```python
# Use MCP tool
mcp__polish-history__search_polish_history(
  query: "[event/person] [year]",
  domains: ["wikipedia", "dzieje"],
  limit: 5
)
```

**Extract full article content:**
```python
mcp__polish-history__extract_article(
  url: "[relevant URL from search]"
)
```

**Verify:**
- Names and dates are correct
- Events happened in stated sequence
- Causal relationships are accurate
- Geographic information is correct
- Institutional details are correct

**If errors found:**
- Correct in conversion to new format
- Note: "Historically corrected from old format"
- If major inaccuracy, DO NOT migrate that question

---

### Phase 3: Question Conversion

#### Step 6: Convert Questions to New Format

**For EACH difficulty level separately:**

**New format structure:**
```markdown
---
epoch: "[Epoch name]"
epoch_id: [number]
chapter: "[Chapter name]"
chapter_id: [number]
difficulty: "[easy/medium/hard]"
question_count: [updated count]
created_at: "[original creation date]"
session_start: "[original session start]"
session_end: "[current timestamp]"
tokens_input: [original + new]
tokens_output: [original + new]
tokens_total: [original + new]
migration_source: "questions/validated/[old-filename].md"
migration_details: "[description of migrated questions]"
---

# [Chapter name]: [Historical period]

[Chapter summary - 2-3 paragraphs about the chapter context]

## Pytanie [number]

**Question ID:** Q-[CHAPTER_CODE]-[DIFFICULTY_LETTER][number]

**Pytanie:** [Question text in Polish]

**A)** [Answer option A]
**B)** [Answer option B]
**C)** [Answer option C]
**D)** [Answer option D]

**Prawidłowa odpowiedź:** [letter]

**Wyjaśnienie:** [Simple, 2-3 sentence explanation in Polish]

**Źródła:**
- [URL from MCP research]
- [Additional URLs if applicable]

**Analiza nieprawidłowych odpowiedzi:**
- A) [Concise analysis of why this is wrong]
- B) [Concise analysis]
- C) [Concise analysis]
```

**Key transformations from old to new format:**

1. **Question ID:**
   - Old: `Q-PI-EXP-E-003`
   - New: `Q-EXP-E03` (or sequential number)

2. **Metadata:** Move to YAML frontmatter
   - Remove: `Type`, `Focus`, `verified`, `verification_note`
   - Add: `migration_source`, `migration_details`

3. **Explanation:** Simplify to 2-3 sentences maximum
   - Old: Long multi-paragraph explanation
   - New: Concise, simple language

4. **Sources:** Add URLs from MCP research
   - Old: General references
   - New: Specific URLs from research

5. **Answer analysis:** Convert to bullet points
   - Old: Long paragraphs
   - New: Concise bullet points

**Update YAML frontmatter:**
- `question_count`: old count + migrated count
- `session_end`: current timestamp
- `tokens_*`: recalculate (old + new)
- Add `migration_source` and `migration_details`

**Example YAML update:**
```yaml
epoch: "Piastowie"
epoch_id: 2
chapter: "Ekspansja"
chapter_id: 2
difficulty: "easy"
question_count: 10  # was 5, adding 5
created_at: "2026-05-05T21:00:00Z"
session_start: "2026-05-05T20:00:00Z"
session_end: "2026-05-07T15:30:00Z"  # updated
tokens_input: 5800  # update
tokens_output: 12400  # update
tokens_total: 18200  # update
migration_source: "questions/validated/piastowie-ekspansja-easy.md"
migration_details: "Migrated 5 questions from old format focusing on Mieszko I's western expansion and administrative organization."
```

#### Step 7: Append Converted Questions

**Add questions after existing questions in each file:**

**Example:**
- If easy file has Q-EXP-E01 through Q-EXP-E05
- Add new questions as Q-EXP-E06 through Q-EXP-E10

**Ensure:**
- Sequential Question IDs
- Proper markdown formatting
- All 4 answer options present
- Correct answer letter specified
- Sources included
- Answer analysis in bullet format

---

### Phase 4: Quality Validation

#### Step 8: Polish Grammar Validation

**For EACH difficulty file:**

**Launch polish-grammar-checker subagent:**
```python
Agent(
  subagent_type="polish-grammar-checker",
  prompt="Check the Polish grammar of the newly added questions in [file_path] and report any errors found."
)
```

**If errors found:**
- Apply all corrections
- Re-run grammar check
- Only proceed when 0 errors

**Common grammar fixes:**
- Spelling corrections (e.g., "Richeza" → "Rycheza")
- Capitalization (e.g., "królową Polską" → "królową polską")
- Punctuation (comma removal/addition)
- Word separation (e.g., "delaicyzacji" → "de laicyzacji")
- Grammatical forms (e.g., "użyłym" → "użytym")

#### Step 9: Difficulty Level Validation

**For EACH difficulty file:**

**Launch difficulty-reviewer skill:**
```python
Skill(
  skill="difficulty-reviewer",
  args="[file_path]"
)
```

**Verification process:**
1. Skill reads curriculum files for appropriate difficulty level
2. Analyzes question pattern (who/what vs why/analyze)
3. Checks answer length and complexity
4. Verifies against curriculum requirements
5. Returns verdict with justification

**If questions fail validation:**
- Review verdict
- Adjust questions if needed
- Or reclassify to correct difficulty level
- Re-run difficulty-reviewer

**Difficulty level reference:**
- **EASY (primary school):** Concrete facts, who/what/where/when, one word/date answers
- **MEDIUM (high school basic):** Causes and effects, why/how, 2-3 sentence answers
- **HARD (high school extended):** Analysis/synthesis, evaluate/compare, paragraph+ answers

**Curriculum files:**
- EASY: `history-data/podstawa/szkola_podstawowa_zpe.md`
- MEDIUM: `history-data/podstawa/liceum_technikum_zpe.md` → ZAKRES PODSTAWOWY
- HARD: `history-data/podstawa/liceum_technikum_zpe.md` → ZAKRES ROZSZERZONY

---

### Phase 5: State Management

#### Step 10: Update questions-tracker.json

**For each difficulty:**
```bash
jq --arg epoch "[Epoch]" \
   --arg chapter "[Chapter]" \
   --arg diff "[easy|medium|hard]" \
   --argjson count [new_total] \
   '.tracking[$epoch][$chapter][$diff] = $count |
    .last_updated = "[timestamp]"' \
   history-data/questions-tracker.json > history-data/questions-tracker.json.tmp && \
mv history-data/questions-tracker.json.tmp history-data/questions-tracker.json
```

**Example:**
```bash
jq '.tracking.Piastowie.Ekspansja.easy = 10 |
     .tracking.Piastowie.Ekspansja.medium = 12 |
     .tracking.Piastowie.Ekspansja.hard = 10 |
     .last_updated = "2026-05-07T15:30:00Z"' \
   history-data/questions-tracker.json > tmp && mv tmp history-data/questions-tracker.json
```

#### Step 11: Update state.json

**Update with migration details:**
```bash
jq '.current_epoch = "[Epoch]" |
    .current_chapter = "[Chapter]" |
    .current_difficulty = "all" |
    .questions_generated_this_session = [total migrated] |
    .last_run = "[timestamp]" |
    .status = "migration_completed" |
    .migration_source = "questions/validated/[file]" |
    .migration_details = {
      "easy": {"questions_added": [n], "original": [orig], "new": [new]},
      "medium": {"questions_added": [n], "original": [orig], "new": [new]},
      "hard": {"questions_added": [n], "original": [orig], "new": [new]}
    } |
    .summary.easy = [new easy total] |
    .summary.medium = [new medium total] |
    .summary.hard = [new hard total] |
    .summary.total = [new total]' \
   history-data/state.json > history-data/state.json.tmp && \
mv history-data/state.json.tmp history-data/state.json
```

---

### Phase 6: Cleanup and Commit

#### Step 12: Delete Old Files

**Remove all 3 old format files:**
```bash
rm questions/validated/{epoch}-{chapter}-easy.md
rm questions/validated/{epoch}-{chapter}-medium.md
rm questions/validated/{epoch}-{chapter}-hard.md
```

#### Step 13: Git Commit

**Stage all changes:**
```bash
git add history-data/{epoch_id}-{epoch}/{chapter_id}-{chapter}/
git add history-data/questions-tracker.json
git add history-data/state.json
git add questions/validated/{epoch}-{chapter}-easy.md
git add questions/validated/{epoch}-{chapter}-medium.md
git add questions/validated/{epoch}-{chapter}-hard.md
```

**Create commit with descriptive message:**
```bash
git commit --no-verify -m "Migrate X questions from old format to new format - [EPOCH]/[CHAPTER] (easy: N, medium: N, hard: N total after migration)

Migrated questions from old format:
- EASY (X questions): [brief list of topics]
- MEDIUM (X questions): [brief list of topics]
- HARD (X questions): [brief list of topics]

Grammar corrections: [list of key corrections]
Difficulty verification: All questions confirmed per curriculum standards

Total questions for chapter: easy=[N], medium=[N], hard=[N]"
```

**Commit message guidelines:**
- NO "Co-Authored-By: Claude" or similar
- Simple, direct description of what changed
- Focus on chapter and counts
- Mention any notable corrections or verifications

---

## Complete Example: Migrating piastowie-ekspansja

### Input
User requests: "Migrate piastowie-ekspansja chapter"

### Phase 1: Preparation

**Read old files:**
- `questions/validated/piastowie-ekspansja-easy.md` (15 questions)
- `questions/validated/piastowie-ekspansja-medium.md` (12 questions)
- `questions/validated/piastowie-ekspansja-hard.md` (10 questions)

**Read new files:**
- `history-data/02-piastowie/02-ekspansja/ekspansja_questions_easy.md` (5 questions)
- `history-data/02-piastowie/02-ekspansja/ekspansja_questions_medium.md` (8 questions)
- `history-data/02-piastowie/02-ekspansja/ekspansja_questions_hard.md` (4 questions)

**Analyze and select:**
- EASY: Migrate 5 questions (topics: Mieszko's conquests, administrative reforms)
- MEDIUM: Migrate 4 questions (topics: causes of expansion, foreign policy)
- HARD: Migrate 6 questions (topics: geopolitical context, long-term impact)

### Phase 2: Historical Validation

**Research topics:**
```python
# For each topic
mcp__polish-history__search_polish_history(
  query="Mieszko I ekspansja na zachód Pomorze",
  domains=["wikipedia", "dzieje"],
  limit=5
)

# Extract articles
mcp__polish-history__extract_article(
  url="https://pl.wikipedia.org/wiki/Mieszko_I"
)
```

**Verify facts and correct errors**

### Phase 3: Conversion

**Convert questions for each difficulty:**
- Update YAML frontmatter
- Transform to new format structure
- Add sources from research
- Simplify explanations to 2-3 sentences
- Convert answer analysis to bullet points

**Append to existing files:**
- Easy: Add Q-EXP-E06 through Q-EXP-E10
- Medium: Add Q-EXP-M09 through Q-EXP-M12
- Hard: Add Q-EXP-H05 through Q-EXP-H10

### Phase 4: Validation

**Polish grammar check:**
```python
# Check each file
Agent polish-grammar-checker "Check grammar of history-data/02-piastowie/02-ekspansja/ekspansja_questions_easy.md"
Agent polish-grammar-checker "Check grammar of history-data/02-piastowie/02-ekspansja/ekspansja_questions_medium.md"
Agent polish-grammar-checker "Check grammar of history-data/02-piastowie/02-ekspansja/ekspansja_questions_hard.md"
```

**Apply corrections and re-verify**

**Difficulty validation:**
```python
Skill difficulty-reviewer "history-data/02-piastowie/02-ekspansja/ekspansja_questions_easy.md"
Skill difficulty-reviewer "history-data/02-piastowie/02-ekspansja/ekspansja_questions_medium.md"
Skill difficulty-reviewer "history-data/02-piastowie/02-ekspansja/ekspansja_questions_hard.md"
```

**Verify all questions match difficulty level**

### Phase 5: State Updates

**Update questions-tracker.json:**
```bash
jq '.tracking.Piastowie.Ekspansja.easy = 10 |
     .tracking.Piastowie.Ekspansja.medium = 12 |
     .tracking.Piastowie.Ekspansja.hard = 10 |
     .last_updated = "2026-05-07T15:30:00Z"'
```

**Update state.json:**
```bash
jq '.current_epoch = "Piastowie" |
    .current_chapter = "Ekspansja" |
    .current_difficulty = "all" |
    .questions_generated_this_session = 15 |
    .last_run = "2026-05-07T15:30:00Z" |
    .status = "migration_completed" |
    .migration_source = "questions/validated/piastowie-ekspansja-{easy,medium,hard}.md" |
    .migration_details = {
      "easy": {"questions_added": 5, "original": 5, "new": 10},
      "medium": {"questions_added": 4, "original": 8, "new": 12},
      "hard": {"questions_added": 6, "original": 4, "new": 10}
    } |
    .summary.easy = 10 |
    .summary.medium = 12 |
    .summary.hard = 10 |
    .summary.total = 32'
```

### Phase 6: Cleanup

**Delete old files:**
```bash
rm questions/validated/piastowie-ekspansja-easy.md
rm questions/validated/piastowie-ekspansja-medium.md
rm questions/validated/piastowie-ekspansja-hard.md
```

**Git commit:**
```bash
git add history-data/02-piastowie/02-ekspansja/
git add history-data/questions-tracker.json
git add history-data/state.json
git add questions/validated/piastowie-ekspansja-*.md

git commit --no-verify -m "Migrate 15 questions from old format to new format - Piastowie/Ekspansja (easy: 10, medium: 12, hard: 10 total after migration)

Migrated questions:
- EASY (5): Mieszko's western conquests, administrative organization, conquest of Silesia, relations with empire, military campaigns
- MEDIUM (4): Causes of expansionary policy, administrative reforms, foreign policy shifts, consequences of expansion
- HARD (6): Geopolitical context of 10th century Europe, long-term territorial consequences, impact on state structure, relations with neighbors, succession implications, synthesis of expansion period

Grammar corrections: 3 spelling, 2 punctuation
Difficulty verification: All questions confirmed per liceum_technikum_zpe.md standards"
```

---

## Critical Rules

### ALWAYS DO:

1. **Validate historical accuracy** BEFORE converting questions
2. **Use MCP polish-history tools** for research (unlimited usage)
3. **Check Polish grammar** for all migrated questions
4. **Verify difficulty level** matches curriculum standards
5. **Update state files** (questions-tracker.json AND state.json)
6. **Delete old files** after successful migration
7. **Create git commit** with descriptive message
8. **Process all 3 difficulties** for one chapter in single session

### NEVER DO:

1. **Migrate questions without** validating historical accuracy
2. **Skip grammar checking** - all errors must be corrected
3. **Skip difficulty validation** - all questions must match level
4. **Migrate duplicate content** - only add unique value
5. **Migrate anachronistic content** - wrong time period
6. **Use "Co-Authored-By"** in git commits
7. **Leave old files** - always delete after migration
8. **Process partial chapters** - always complete all 3 difficulties

---

## Error Handling

### If grammar check fails:
- Apply corrections
- Re-run grammar check
- Only proceed when 0 errors

### If difficulty validation fails:
- Review specific questions that failed
- Adjust question content OR reclassify difficulty
- Re-run difficulty-reviewer
- Get approval before proceeding

### If historical validation fails:
- If minor error: Correct in conversion
- If major inaccuracy: DO NOT migrate that question
- Note in migration details: "X questions rejected due to historical inaccuracies"

### If MCP tools fail:
- Try alternative search terms
- Use web search as backup
- Note in sources: "Verified via multiple sources"

---

## Tools Reference

### MCP Polish-History Tools (Unlimited Usage)

**Search for information:**
```python
mcp__polish-history__search_polish_history(
  query: "[search terms]",
  domains: ["wikipedia", "dzieje"],
  limit: 5-10
)
```

**Extract article content:**
```python
mcp__polish-history__extract_article(
  url: "[URL from search results]"
)
```

**Quick Wikipedia search:**
```python
mcp__polish-history__search_wikipedia(
  query: "[search terms]",
  max_results: 5
)
```

### Subagents

**Polish grammar checker:**
```python
Agent(
  subagent_type="polish-grammar-checker",
  prompt="[instructions]"
)
```

### Skills

**Difficulty reviewer:**
```python
Skill(
  skill="difficulty-reviewer",
  args="[file_path]"
)
```

---

## Reference Documents

**Main workflow:** `.claude/instructions.md`
- Complete question generation workflow
- Validation rules and processes
- File naming conventions
- State management

**Validation rules:** `.claude/validation-rules.md`
- Rules for incorrect answers
- All 4 answers similar length
- Incorrect answers historically TRUE but wrong context
- No direct opposites

**Curriculum files:**
- `history-data/podstawa/szkola_podstawowa_zpe.md` (EASY level)
- `history-data/podstawa/liceum_technikum_zpe.md` (MEDIUM/HARD levels)
  - ZAKRES PODSTAWOWY → MEDIUM
  - ZAKRES ROZSZERZONY → HARD

**Chapter mapping:** `history-data/master-list.json`
- Epoch names and IDs
- Chapter names and IDs
- Year ranges

---

## Success Criteria

Migration successful when:
1. ✅ All selected questions added to new format files
2. ✅ Historical accuracy verified via MCP tools
3. ✅ Polish grammar validation passes (0 errors)
4. ✅ Difficulty reviewer confirms all levels correct
5. ✅ YAML frontmatter updated (question_count, timestamps, tokens)
6. ✅ Each question has source links from research
7. ✅ Answer analysis in bullet-point format
8. ✅ Explanations simplified to 2-3 sentences
9. ✅ questions-tracker.json updated (all 3 difficulties)
10. ✅ state.json updated with migration details
11. ✅ Old files deleted (all 3)
12. ✅ Git commit created with descriptive message

---

## Output Format

**After successful migration, report to user:**

```
✅ Migration complete: [EPOCH]/[CHAPTER]

Summary:
- EASY: [N] questions ([X] migrated, [Y] total)
- MEDIUM: [N] questions ([X] migrated, [Y] total)
- HARD: [N] questions ([X] migrated, [Y] total)

Grammar corrections: [count] errors corrected
Difficulty verification: All questions confirmed

Files updated:
- history-data/[epoch_id]-[epoch]/[chapter_id]-[chapter]/*_questions_*.md
- history-data/questions-tracker.json
- history-data/state.json

Files deleted:
- questions/validated/[epoch]-[chapter]-easy.md
- questions/validated/[epoch]-[chapter]-medium.md
- questions/validated/[epoch]-[chapter]-hard.md

Git commit: [commit hash]
```

---

**Version:** 1.0
**Created:** 2026-05-07
**Reference:** `.claude/instructions.md`
