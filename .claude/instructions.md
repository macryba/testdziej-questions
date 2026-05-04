Claude Code Loop Instructions for Testdziej Question Generation

# Overview
You are running in a loop to generate Polish history quiz questions for the Testdziej app. Each loop iteration generates questions for the SAME epoch-chapter combination for ALL difficulty levels (easy, medium, hard). **All 30 questions are saved in the history-data chapter folder: one file per difficulty (3 files total).**

## Automated Git Commits
**This loop automatically commits all work at the end of each iteration without requiring user approval.**

Required permissions for autonomous operation:
- `git add` - allowed without confirmation
- `git commit` - allowed without confirmation (use `--no-verify` flag)
- `git status` - for verification

All commits are LOCAL only. No pushing to remote repositories.

# Loop Workflow

## 1. Pick Epoch and Chapter
Read history-data/state.json to find:
- Current epoch
- Current chapter

If state is empty/null, read history-data/questions-tracker.json to find the first combination where ANY difficulty has count < 10 **and is not marked as completed**.

Use this jq command to find next combination:
```bash
jq -r '
  .tracking |
  to_entries[] |
  select(.key != "last_updated") |
  .key as $epoch |
  .value |
  to_entries[] |
  .key as $chapter |
  select(
    (.value.easy < 10 and (.value.easy_completed | not)) or
    (.value.medium < 10 and (.value.medium_completed | not)) or
    (.value.hard < 10 and (.value.hard_completed | not))
  ) |
  "\($epoch)|\($chapter)|easy:\(.value.easy) medium:\(.value.medium) hard:\(.value.hard)"
' history-data/questions-tracker.json | head -1
```

**IMPORTANT**: Extract only the epoch and chapter from the result. The loop processes ALL difficulties for one chapter, not just one difficulty.

**CRITICAL**: The `_completed` flag distinguishes between:
- Not started (count: 0, completed: false) → needs questions
- Completed with 0 questions (count: 0, completed: true) → intentionally not in curriculum
- Completed with questions (count: 10, completed: true) → done

## 2. Determine Missing Questions
Check the current counts in history-data/questions-tracker.json for the selected chapter:
```bash
jq -r '.tracking["[EPOCH]"]["[CHAPTER]"]' history-data/questions-tracker.json
```

Calculate how many questions are needed per difficulty:
- For each difficulty level (easy, medium, hard):
  - Check if `[difficulty]_completed` flag is true → skip this difficulty
  - Check if count < 10 → need 10 - current_count questions
  - If count >= 10 and completed is true → skip this difficulty

**Important rules:**
- If ALL difficulties have count >= 10 OR completed=true, skip to next chapter
- If EASY is not in curriculum: Create file with question_count=0 and set easy_completed=true
- Generate appropriate number of questions per difficulty based on curriculum coverage

## 3. Research Chapter Content (ONCE per iteration)
Use MCP polish-history tools to search for reliable Polish historical sources for this epoch/chapter.

**Step 3a: Search for articles**
```bash
mcp__polish-history__search_polish_history(
  query: "[EPOCH] [CHAPTER] historia Polski",
  domains: ["wikipedia", "dzieje"],
  limit: 10
)
```

**Step 3b: Extract article content**
For the most relevant URLs from the search results:
```bash
mcp__polish-history__extract_article(
  url: "[URL from search results]"
)
```

**Why MCP tools?**
- Unlimited usage (hosted locally, no rate limits)
- Better Polish sources (Wikipedia Polska, Dzieje.pl)
- More reliable than web scraping
- Optimized for Polish historical research

**DO NOT use:**
- WebSearch tool (not needed)
- mcp__web_reader__webReader (limited usage, use MCP polish-history instead)

## 4. Create Chapter Summary
After researching the chapter, create a comprehensive summary using the chapter-summary skill.

```bash
skill: "chapter-summary"
args: "[chapter_tech_name]"
```

**What this does:**
1. Creates a summary file with historical context
2. Categorizes topics by difficulty level (EASY, MEDIUM, HARD)
3. Provides source links
4. **Verifies EASY topics against primary school curriculum**
5. **Recommends EASY question count based on curriculum coverage**

**Output location:**
```
history-data/{epoch_id}-{epoch_tech_name}/{chapter_id}-{chapter_tech_name}/{chapter_tech_name}_summary.md
```

**Example:**
```
history-data/02-piastowie/01-chrystianizacja/chrystianizacja_summary.md
```

**Curriculum Verification for EASY Level:**

The summary includes a section "## Tematy poziom EASY (szkoła podstawowa)" which will indicate:

1. **If topic IS in primary school curriculum:**
   - Lists specific topics covered (Postacie, Wydarzenia, Miejsca, Pojęcia)
   - Notes if coverage is limited (e.g., "Temat ograniczony w podstawie programowej")
   - May recommend reduced question count (e.g., "Zalecana liczba pytań EASY: 3")

2. **If topic is NOT in primary school curriculum:**
   - States: "Temat nie ujęty w poziomie szkoły podstawowej"
   - No EASY topics listed
   - EASY questions file should only contain a statement (see Step 5)

**Use this summary as the historical context** for generating questions. Do NOT re-research for each difficulty - use the summary as the single source of truth for all three difficulty levels.

## 5. Generate Questions for ALL Difficulties
For the selected epoch-chapter, generate questions for ALL THREE difficulty levels (easy, medium, hard) in this single loop iteration.

**CRITICAL: FILE NAMING RULES**
- ✅ CORRECT: `{chapter_tech_name}_questions_easy.md` (one file containing ALL easy questions)
- ✅ CORRECT: `{chapter_tech_name}_questions_medium.md` (one file containing ALL 10 medium questions)
- ✅ CORRECT: `{chapter_tech_name}_questions_hard.md` (one file containing ALL 10 hard questions)
- ❌ WRONG: `chrystianizacja-easy-001.md`, `chrystianizacja-easy-002.md`, etc. (NEVER create separate numbered files!)

**The file names MUST be exactly:**
- `{chapter_tech_name}_questions_easy.md`
- `{chapter_tech_name}_questions_medium.md`
- `{chapter_tech_name}_questions_hard.md`

**File location:**
```
history-data/{epoch_id}-{epoch_tech_name}/{chapter_id}-{chapter_tech_name}/
  ├── {chapter_tech_name}_summary.md
  ├── {chapter_tech_name}_questions_easy.md
  ├── {chapter_tech_name}_questions_medium.md
  └── {chapter_tech_name}_questions_hard.md
```

### Step 5a: Check EASY Level Curriculum Coverage

**BEFORE generating EASY questions, read the chapter summary and check:**

```bash
grep -A 10 "## Tematy poziom EASY" history-data/{epoch}/{chapter}/{chapter_tech_name}_summary.md
```

**Three possible outcomes:**

1. **Topic NOT in primary school curriculum:**
   - Summary states: "Temat nie ujęty w poziomie szkoły podstawowej"
   - **ACTION:** Create EASY file with statement only (see Step 5b Special Case 1)
   - **Question count:** 0 (mark as "N/A" in metadata)

2. **Topic HAS limited curriculum coverage:**
   - Summary lists some topics but notes "Temat ograniczony"
   - Summary may recommend: "Zalecana liczba pytań EASY: X"
   - **ACTION:** Generate only the recommended number of EASY questions (e.g., 3-5 instead of 10)
   - **Question count:** Use recommended number from summary

3. **Topic HAS full curriculum coverage:**
   - Summary lists comprehensive EASY topics
   - **ACTION:** Generate full 10 EASY questions
   - **Question count:** 10

### Step 5b: Generate Questions for Each Difficulty

**A. Use Chapter Summary as Context**
- Read the `{chapter_tech_name}_summary.md` file created in Step 4
- Use the categorized topics as a guide for question difficulty
- Each question should focus on a different topic from the summary
- Rotate between: causes, effects, key figures, dates, locations, consequences

**B. Generate Question based on difficulty:**

**For EASY difficulty:**

**Special Case 1 - Topic NOT in curriculum:**
```markdown
---
epoch: "[EPOCH]"
epoch_id: [ID]
chapter: "[CHAPTER]"
chapter_id: [ID]
difficulty: "easy"
question_count: 0
created_at: "[TIMESTAMP]"
---

# Pytania poziom łatwy - Brak pytań

**Temat nie ujęty w poziomie szkoły podstawowej.**

Ten rozdział wykracza poza zakres podstawy programowej szkoły podstawowej. Pytania na poziomie łatwym dotyczą tylko tematów ujętych w podstawie programowej dla klas IV-VIII szkoły podstawowej.

Zgodnie z podstawą programową (Dział IV: Postacie i wydarzenia o doniosłym znaczeniu), temat ten nie jest objęty wymaganiami dla szkoły podstawowej.

**Uwaga:** Proste pytania faktyczne (Kto? Co? Gdzie? Kiedy?) z tego rozdziału znajdują się w pytaniach poziomu średniego (MEDIUM).

---
**Brak pytań do wyświetlenia.**
```

**Special Case 2 - Topic HAS limited coverage:**
- Generate ONLY the recommended number of questions (e.g., 3-5)
- Set `question_count` to actual number generated
- Use only EASY topics listed in the summary

**Normal Case - Full coverage:**
- Simple factual questions (who, what, where, when)
- Well-known dates, names, events
- Primary school level
- Reference: EASY topics from chapter summary
- Use summary's "Postacie", "Wydarzenia", "Miejsca", "Pojęcia" sections
- Generate up to 10 questions

**For MEDIUM difficulty:**

**IMPORTANT:** MEDIUM level includes BOTH simple factual questions AND analytical questions:

1. **Simple factual questions (Kto? Co? Gdzie? Kiedy?):**
   - These are NOT exclusive to EASY level
   - When EASY is not covered by curriculum, these questions belong in MEDIUM
   - All curriculum-covered simple factual questions should be here
   - Reference: EASY topics from chapter summary (if EASY not in curriculum)

2. **Analytical questions (Dlaczego? Jakie skutki?):**
   - Causes and effects
   - More detailed understanding
   - Secondary school level (basic scope)
   - Reference: MEDIUM topics from chapter summary
   - Use summary's "Przyczyny wydarzeń", "Skutki historyczne", "Procesy", "Porównania" sections

3. **Question count guidance:**
   - **Target: 10-15 questions** (flexible based on content)
   - Use common sense - if topic has many important facts/events, generate more
   - If EASY not in curriculum: Include 3-5 simple factual + 7-10 analytical = 10-15 total
   - If EASY in curriculum: Focus on analytical questions, 10 total

**For HARD difficulty:**

**IMPORTANT:** HARD level should only be generated if the summary identifies appropriate analytical topics:
- Target: **0-5 questions maximum**
- Only generate if summary has clear HARD-level topics (analiza, ocena, synteza)
- If summary lacks HARD topics, set count to 0

**Question types at HARD level:**
1. **Analytical questions** (when available):
   - Analysis and synthesis
   - Complex relationships
   - Extended matura level
   - Reference: HARD topics from chapter summary
   - Use summary's "Analiza", "Ocena z perspektywy", "Synteza", "Interpretacje" sections

2. **Specialized factual questions** (NEW):
   - Simple question types (Kto? Co? Gdzie? Kiedy?) for topics NOT in curriculum
   - Events, places, figures outside standard curriculum coverage
   - More obscure but historically significant details
   - Examples: minor figures, specific locations, detailed dates not in liceum_technikum_zpe.md

**When to include factual questions in HARD:**
- Summary mentions places/events/figures not covered in curriculum
- Content is historically important but not in standard educational scope
- Factual content provides context for analytical questions

**Question count guidance:**
- **0 questions:** If summary has no HARD topics and no specialized factual content
- **3-5 questions:** If summary has analytical topics OR specialized factual content
- Prioritize analytical over factual when both exist

### Question Creation Process

Repeat the following for each question needed (adjusted count for EASY if limited):

**C. Create Incorrect Answers**

**CRITICAL RULES for incorrect answers:**

- All answers must be similar length - not always the correct one is shortest
- Incorrect answers must be:
  - Historically TRUE facts
  - BUT not related to the question asked
  - OR from events 50-150 years different
- INCORRECT answers must NOT be:
  - Total opposites (Poland gained vs Poland lost)
  - Obvious historical errors
  - Too short or too long compared to correct
- If question contains a date:
  - Incorrect answers must NOT contain dates
  - All answers should reference events only

See `.claude/validation-rules.md` for complete rules and examples.

**D. Vary Question Topics:**
For 10 questions per difficulty, ensure diversity:
1. Question about causes
2. Question about immediate effects
3. Question about key figures
4. Question about dates/timeline
5. Question about geography/locations
6. Question about long-term consequences
7. Question about related events
8. Question about political aspects
9. Question about social/cultural aspects
10. Question about comparisons/relationships

**E. Create Question Files**

**STOP! READ THIS BEFORE CREATING ANY FILE!**
You MUST create EXACTLY THREE files (one per difficulty level).
- EASY file may contain 0, 3-5, or 10 questions (based on curriculum coverage)
- MEDIUM file must contain 10 questions
- HARD file must contain 10 questions
- Do NOT create 30 separate files
- Do NOT number your files (no -001, -002, etc.)
- Do NOT create multiple files for the same difficulty

**Create ONLY these THREE files:**
```
history-data/{epoch}/{chapter}/{chapter_tech_name}_questions_easy.md
history-data/{epoch}/{chapter}/{chapter_tech_name}_questions_medium.md
history-data/{epoch}/{chapter}/{chapter_tech_name}_questions_hard.md
```

**Question counts by difficulty:**
- **EASY:** 0 (if not in curriculum) OR recommended count (3-5 if limited) OR up to 10 (if full coverage)
- **MEDIUM:** 10-15 questions (flexible based on curriculum coverage and content)
  - If EASY not in curriculum: Include simple factual questions + analytical questions
  - If EASY in curriculum: Focus on analytical questions
- **HARD:** 0-5 questions maximum
  - Only if summary identifies HARD-level analytical topics
  - OR if summary has specialized factual content outside curriculum
  - If summary has neither: Set to 0

**Important:** Question counts are guidelines, not hard rules. Use common sense:
- Rich historical periods may need more questions
- Limited curriculum topics may need fewer
- Priority: Cover the topic completely over hitting an exact number
- HARD is optional - only generate if content warrants it

Follow the template below for consolidated format:

```markdown
Metadata
epoch: "[EPOCH]"
epoch_id: [ID]
chapter: "[CHAPTER]"
chapter_id: [ID]
difficulty: "[DIFFICULTY]"
question_count: [ACTUAL_COUNT]
created_at: "[TIMESTAMP]"
...

[Historical Context - use from chapter summary]

Question 1
Question ID: Q-XXX-001
...
[Full question details]

Question 2
Question ID: Q-XXX-002
...
[Full question details]

[... continue for all questions in this difficulty ...]
```

**Special handling for EASY with 0 questions:**
- Use the template shown in Step 5b Special Case 1
- Set `question_count: 0`
- Include statement: "Temat nie ujęty w poziomie szkoły podstawowej"

**Special handling for HARD with 0 questions:**
- If summary has no HARD topics and no specialized factual content
- Create HARD file with statement:
```markdown
---
epoch: "[EPOCH]"
epoch_id: [ID]
chapter: "[CHAPTER]"
chapter_id: [ID]
difficulty: "hard"
question_count: 0
created_at: "[TIMESTAMP]"
---

# Pytania poziom trudny - Brak pytań

**Temat nie zawiera wystarczającej liczby tematów na poziomie rozszerzonym.**

Ten rozdział, chociaż ważny z historycznego punktu widzenia, nie zawiera tematów wymagających analizy na poziomie rozszerzonym (liceum - zakres rozszerzony). Wszystkie istotne zagadnienia z tego okresu zostały objęte pytaniami na poziomie podstawowym (MEDIUM).

Zgodnie z podstawą programową dla liceum (zakres rozszerzony), ten temat nie wymaga pytań typu analitycznego, syntetycznego lub oceny z perspektywy.

---
**Brak pytań do wyświetlenia.**
```
- Set `question_count: 0`

**CRITICAL: Explanation Requirements**
- Explanations must be SIMPLE and EASY to understand
- Maximum 2 sentences per explanation
- Use basic language, avoid academic terms
- Focus on answering "why" in plain Polish
- Example: "X wydarzyło się w tym roku, ponieważ Y. To było ważne, bo Z."

## 6. Verify Questions
For each of the 30 questions, verify historical accuracy using the MCP polish-history tools:

```bash
# Search for the historical fact
mcp__polish-history__search_polish_history(
  query: "[event name] [year]",
  limit: 5
)

# Verify each incorrect answer is historically true
mcp__polish-history__search_polish_history(
  query: "[incorrect answer event]",
  limit: 5
)
```

## 7. Validate Difficulty Levels
**CRITICAL:** After generating questions for each difficulty, validate the difficulty classification using the difficulty-reviewer skill.

For each difficulty file:
```bash
skill: "difficulty-reviewer"
args: "history-data/{epoch}/{chapter}/{chapter_tech_name}_questions_easy.md"
```

The difficulty reviewer will:
- Verify questions are correctly classified as EASY, MEDIUM, or HARD
- Check against curriculum standards
- Return verdict with reasoning

**If questions fail validation:**
- Review the verdict provided by the difficulty reviewer
- Adjust the questions or reclassify them
- Re-run the difficulty reviewer to verify corrections
- Only proceed to step 8 when all questions pass validation

**If questions pass validation:**
- Confirm the difficulty levels are correct
- Proceed to next step

## 8. Polish Language Validation
**CRITICAL:** Before saving questions to final location, run Polish language check using the polish-grammar-checker subagent:

For each difficulty file:
```bash
# Use the Agent tool to invoke the Polish grammar checker subagent
Agent polish-grammar-checker "Check the Polish grammar of the questions in history-data/{epoch}/{chapter}/{chapter_tech_name}_questions_[difficulty].md and report any errors found"
```

The subagent will:
- Check grammar errors using LanguageTool (verb conjugations, case endings, gender agreement)
- Check spelling mistakes (Polish characters: ą, ć, ę, ł, ń, ó, ś, ź, ż)
- Check typography errors (hyphens vs em dashes, spacing around punctuation)
- Check punctuation (commas, periods, quotation marks)
- Provide specific error locations with rule IDs and replacement suggestions
- Generate a structured report with error counts by type

**If errors are found:**
- Review the error report provided by the subagent
- Apply the corrections suggested by the grammar checker
- Re-run the polish-grammar-checker subagent to verify all issues are resolved
- Only proceed to step 9 when Polish language validation passes (0 errors)

**If no errors are found:**
- Confirm the text is grammatically correct
- Proceed to next step

**Note:** The polish-grammar-checker subagent uses actual LanguageTool grammar rules and is more reliable than AI-only checking. It focuses on grammar, spelling, and typography - historical accuracy verification should be done separately.

## 9. Save Metadata for Each File
At the top of EACH file, save:

created_at: [ISO 8601 timestamp]
session_start: [ISO 8601 timestamp when loop started]
session_end: [ISO 8601 timestamp]
tokens_input: [from API response or estimate]
tokens_output: [from API response or estimate]
tokens_total: [sum]

## 10. Update State Files
Update history-data/state.json:

```json
{
  "current_epoch": "[CURRENT_EPOCH]",
  "current_chapter": "[CURRENT_CHAPTER]",
  "current_difficulty": "all",
  "questions_generated_this_session": [N + EASY_COUNT + MEDIUM_COUNT + HARD_COUNT],
  "total_questions_generated": [TOTAL + EASY_COUNT + MEDIUM_COUNT + HARD_COUNT],
  "last_run": "[TIMESTAMP]",
  "status": "completed",
  "errors": [],
  "batch_size": [EASY_COUNT + MEDIUM_COUNT + HARD_COUNT]
}
```

**Important:** The batch size varies based on actual question counts:
- EASY: 0, 3-5, or up to 10
- MEDIUM: 10-15 (includes simple factual + analytical)
- HARD: 0-5 (only if content warrants it)
- Total: Typically 10-30 questions per chapter

Also increment difficulty counters and set completed flags in history-data/questions-tracker.json:
```bash
jq --arg epoch "[CURRENT_EPOCH]" \
   --arg chapter "[CHAPTER]" \
   --arg easycount [EASY_COUNT] \
   --arg mediumcount [MEDIUM_COUNT] \
   --arg hardcount [HARD_COUNT] \
   '.tracking[$epoch][$chapter]["easy"] += $easycount |
    .tracking[$epoch][$chapter]["easy_completed"] |= (. or ($easycount > 0)) |
    .tracking[$epoch][$chapter]["medium"] += $mediumcount |
    .tracking[$epoch][$chapter]["medium_completed"] |= (. or ($mediumcount > 0)) |
    .tracking[$epoch][$chapter]["hard"] += $hardcount |
    .tracking[$epoch][$chapter]["hard_completed"] |= (. or ($hardcount > 0)) |
    .last_updated = "[TIMESTAMP]"' \
   history-data/questions-tracker.json > history-data/questions-tracker.json.tmp && \
mv history-data/questions-tracker.json.tmp history-data/questions-tracker.json
```

**CRITICAL for EASY level when not in curriculum:**
If EASY count is 0 because topic is not in primary school curriculum, you must explicitly set the completed flag:
```bash
jq --arg epoch "[CURRENT_EPOCH]" \
   --arg chapter "[CHAPTER]" \
   '.tracking[$epoch][$chapter]["easy_completed"] = true |
    .last_updated = "[TIMESTAMP]"' \
   history-data/questions-tracker.json > history-data/questions-tracker.json.tmp && \
mv history-data/questions-tracker.json.tmp history-data/questions-tracker.json
```

**Replace counts with actual numbers:**
- `[EASY_COUNT]`: 0 (not in curriculum - set completed=true), 3-5 (limited), or up to 10 (full)
- `[MEDIUM_COUNT]`: 10-15 (based on content coverage)
- `[HARD_COUNT]`: 0-5 (only if summary has HARD topics or specialized factual content)

IMPORTANT: Question counts are flexible guidelines. Use common sense to cover each topic completely. HARD is optional - only generate if content warrants it.

## 11. All Questions Saved to Chapter Folder
All questions are saved in THREE files in the chapter folder:
- EASY: Contains 0, 3-5, or up to 10 questions (based on curriculum coverage)
- MEDIUM: Contains 10-15 questions (simple factual + analytical)
- HARD: Contains 0-5 questions (only if content warrants analytical depth)

Total: 10-30 questions per chapter (variable based on curriculum and content)

```
history-data/{epoch_id}-{epoch_tech_name}/{chapter_id}-{chapter_tech_name}/
  ├── {chapter_tech_name}_questions_easy.md (0, 3-5, or up to 10 questions)
  ├── {chapter_tech_name}_questions_medium.md (10-15 questions)
  └── {chapter_tech_name}_questions_hard.md (0-5 questions)
```

**FINAL FILE CHECK - Before committing, verify:**
- [ ] Exactly THREE .md files were created for this epoch/chapter (one per difficulty)
- [ ] The filenames have NO numbers (no -001, -002, etc.)
- [ ] EASY file contains appropriate count based on curriculum (0, 3-5, or up to 10)
- [ ] MEDIUM file contains 10-15 questions (includes simple factual if EASY not in curriculum)
- [ ] HARD file contains 0-5 questions (only if summary had HARD topics or specialized content)
- [ ] Each question has a unique Question ID
- [ ] Summary file exists from Step 4

If you see multiple numbered files (like `file-001.md`, `file-002.md`), **STOP** and consolidate them into the correct THREE files before committing.

## 12. Commit Work Automatically
After each successful iteration, commit all changes to git WITHOUT requiring user approval:

```bash
# Determine the chapter directory that was just created/updated
CHAPTER_DIR="history-data/$(echo ${CURRENT_EPOCH_ID} | tr '[:upper:]' '[:lower:]' | tr ' ' '-')-$(echo ${CURRENT_EPOCH_TECH} | tr '[:upper:]' '[:lower:]' | tr ' ' '-')/$(echo ${CURRENT_CHAPTER_ID} | tr '[:upper:]' '[:lower:]' | tr ' ' '-')-$(echo ${CURRENT_CHAPTER_TECH} | tr '[:upper:]' '[:lower:]' | tr ' ' '-')"

# Stage all changes (chapter directory, state files, tracker)
git add "${CHAPTER_DIR}" history-data/state.json history-data/questions-tracker.json

# Create commit with descriptive message
git commit --no-verify -m "Add [TOTAL_COUNT] questions for ${CURRENT_EPOCH}/${CURRENT_CHAPTER} (easy: [EASY_COUNT], medium: [MEDIUM_COUNT], hard: [HARD_COUNT])"
```

**IMPORTANT:** Always use `--no-verify` flag to bypass any pre-commit hooks that might block automated commits. This ensures the loop can run fully autonomously.

**Commit message format:**
- Include epoch and chapter
- Include total questions added and breakdown by difficulty
- Examples:
  - "Add 25 questions for Piastowie/Chrystianizacja (easy: 10, medium: 10, hard: 5)"
  - "Add 20 questions for Piastowie/Zjednoczenie (easy: 0, medium: 15, hard: 5)" [simple factual moved to MEDIUM]
  - "Add 15 questions for Piastowie/[CHAPTER] (easy: 3, medium: 12, hard: 0)" [no HARD topics]

**DO NOT push to remote** - only commit locally. Pushing can be done manually by the user.

# Loop Exit Conditions
Stop the loop if:

All epoch/chapter/difficulty combinations have 10 questions
10 consecutive errors occur
Token budget exceeded
User interrupts

# Error Handling
If error occurs:

- Log error to logs/errors.log
- Update state file with error message
- Skip to next chapter
- If 3 consecutive errors, pause and notify

# Batch Generation Tips

To generate 30 different questions for one chapter (10 per difficulty):

1. **Vary the focus within each difficulty:**
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

2. **Vary question types within each difficulty:**
   - Who questions (people)
   - What questions (events)
   - When questions (dates)
   - Where questions (places)
   - Why questions (causes)
   - How questions (consequences)
   - Which questions (choices)

3. **Rotate answer positions:**
   - Ensure correct answer is A, B, C, or D evenly across the 10 questions
   - Don't make correct answer always the same position

4. **Use different events from the chapter:**
   - Early period events
   - Middle period events
   - Late period events
   - Background causes
   - Immediate effects
   - Long-term consequences

5. **Align with chapter summary topics:**
   - Use EASY topics for easy questions
   - Use MEDIUM topics for medium questions
   - Use HARD topics for hard questions
   - This ensures questions match curriculum standards

# Key Differences from Previous Workflow

1. **One loop per chapter, not per difficulty**: Generate all questions for all difficulties in one iteration
2. **Curriculum-based EASY questions**: EASY question count varies (0, 3-5, or up to 10) based on primary school curriculum coverage
   - Chapter summary verifies topic against curriculum
   - If not in curriculum: EASY file contains only statement
   - If limited coverage: Generate recommended count (3-5)
   - If full coverage: Generate up to 10 questions
3. **MEDIUM includes simple factual questions**: Simple question types (Kto? Co? Gdzie? Kiedy?) are NOT exclusive to EASY level
   - When EASY is not in curriculum, these questions move to MEDIUM level
   - MEDIUM covers both simple factual AND analytical questions
   - This ensures all curriculum content is covered at appropriate level
4. **HARD is optional and limited**: 0-5 questions maximum
   - Only generate if summary identifies HARD-level analytical topics
   - Can include specialized factual questions for content outside curriculum
   - If summary lacks appropriate topics: HARD file contains statement only
5. **Flexible question counts**: Question counts are guidelines, not hard rules
   - Use common sense based on actual curriculum coverage and content
   - EASY: 0, 3-5, or up to 10
   - MEDIUM: 10-15 (includes simple factual + analytical)
   - HARD: 0-5 (only if content warrants it)
   - Total per chapter: 10-30 questions (variable)
6. **MCP tools only**: Use polish-history MCP tools instead of web search (unlimited usage)
7. **Chapter summary with curriculum verification**: Created once, includes EASY curriculum assessment and question count recommendation
8. **Centralized storage**: All files in history-data/{epoch}/{chapter}/ directory
9. **Difficulty validation**: Use difficulty-reviewer skill to verify correct classification
10. **State location**: history-data/state.json (moved from .claude/)
