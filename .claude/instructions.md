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

If state is empty/null, read history-data/questions-tracker.json to find the first combination where ANY difficulty has count < 10.

Use this jq command to find next combination:
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

**IMPORTANT**: Extract only the epoch and chapter from the result. The loop processes ALL difficulties for one chapter, not just one difficulty.

## 2. Determine Missing Questions
Check the current counts in history-data/questions-tracker.json for the selected chapter:
```bash
jq -r '.tracking["[EPOCH]"]["[CHAPTER]"]' history-data/questions-tracker.json
```

Calculate how many questions are needed per difficulty: 10 - current_count
- If ALL difficulties (easy, medium, hard) have count >= 10, skip to next chapter
- Generate exactly 10 questions per difficulty (30 total questions per chapter)

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
4. Establishes foundation for question generation

**Output location:**
```
history-data/{epoch_id}-{epoch_tech_name}/{chapter_id}-{chapter_tech_name}/{chapter_tech_name}_summary.md
```

**Example:**
```
history-data/02-piastowie/01-chrystianizacja/chrystianizacja_summary.md
```

**Use this summary as the historical context** for generating questions. Do NOT re-research for each difficulty - use the summary as the single source of truth for all three difficulty levels.

## 5. Generate Questions for ALL Difficulties
For the selected epoch-chapter, generate questions for ALL THREE difficulty levels (easy, medium, hard) in this single loop iteration.

**CRITICAL: FILE NAMING RULES**
- ✅ CORRECT: `{chapter_tech_name}_questions_easy.md` (one file containing ALL 10 easy questions)
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

### Question Creation Process (Repeat 10 times for EACH difficulty):

**A. Use Chapter Summary as Context**
- Read the `{chapter_tech_name}_summary.md` file created in Step 4
- Use the categorized topics as a guide for question difficulty
- Each question should focus on a different topic from the summary
- Rotate between: causes, effects, key figures, dates, locations, consequences

**B. Generate Question based on difficulty:**

**For EASY difficulty:**
- Simple factual questions (who, what, where, when)
- Well-known dates, names, events
- Primary school level
- Reference: EASY topics from chapter summary
- Use summary's "Postacie", "Wydarzenia", "Miejsca", "Pojęcia" sections

**For MEDIUM difficulty:**
- Causes and effects
- More detailed understanding
- Secondary school level (basic scope)
- Reference: MEDIUM topics from chapter summary
- Use summary's "Przyczyny wydarzeń", "Skutki historyczne", "Procesy", "Porównania" sections

**For HARD difficulty:**
- Analytical questions
- Complex relationships
- Extended matura level
- Reference: HARD topics from chapter summary
- Use summary's "Analiza", "Ocena z perspektywy", "Synteza", "Interpretacje" sections

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
You MUST create EXACTLY THREE files that contain ALL 10 questions for each difficulty level.
- Do NOT create 30 separate files
- Do NOT number your files (no -001, -002, etc.)
- Do NOT create multiple files for the same difficulty

**Create ONLY these THREE files:**
```
history-data/{epoch}/{chapter}/{chapter_tech_name}_questions_easy.md
history-data/{epoch}/{chapter}/{chapter_tech_name}_questions_medium.md
history-data/{epoch}/{chapter}/{chapter_tech_name}_questions_hard.md
```

Follow the template below for consolidated format:

```markdown
Metadata
epoch: "[EPOCH]"
epoch_id: [ID]
chapter: "[CHAPTER]"
chapter_id: [ID]
difficulty: "[DIFFICULTY]"
question_count: 10
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

[... continue for all 10 questions ...]
```

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
  "questions_generated_this_session": [N+30],
  "total_questions_generated": [TOTAL+30],
  "last_run": "[TIMESTAMP]",
  "status": "completed",
  "errors": [],
  "batch_size": 30
}
```

Also increment ALL difficulty counters in history-data/questions-tracker.json by 10 each:
```bash
jq --arg epoch "[CURRENT_EPOCH]" \
   --arg chapter "[CURRENT_CHAPTER]" \
   '.tracking[$epoch][$chapter]["easy"] += 10 |
    .tracking[$epoch][$chapter]["medium"] += 10 |
    .tracking[$epoch][$chapter]["hard"] += 10 |
    .last_updated = "[TIMESTAMP]"' \
   history-data/questions-tracker.json > history-data/questions-tracker.json.tmp && \
mv history-data/questions-tracker.json.tmp history-data/questions-tracker.json
```

IMPORTANT: Always generate exactly 10 questions per difficulty per chapter. No partial batches.

## 11. All Questions Saved to Chapter Folder
All 30 questions (10 per difficulty × 3 difficulties) are saved in THREE files in the chapter folder:
```
history-data/{epoch_id}-{epoch_tech_name}/{chapter_id}-{chapter_tech_name}/
  ├── {chapter_tech_name}_questions_easy.md
  ├── {chapter_tech_name}_questions_medium.md
  └── {chapter_tech_name}_questions_hard.md
```

**FINAL FILE CHECK - Before committing, verify:**
- [ ] Exactly THREE .md files were created for this epoch/chapter (one per difficulty)
- [ ] The filenames have NO numbers (no -001, -002, etc.)
- [ ] Each file contains ALL 10 questions for that difficulty
- [ ] Each question has a unique Question ID (Q-XXX-001 through Q-XXX-010)
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
git commit --no-verify -m "Add 30 questions for ${CURRENT_EPOCH}/${CURRENT_CHAPTER} (all difficulties: easy, medium, hard)"
```

**IMPORTANT:** Always use `--no-verify` flag to bypass any pre-commit hooks that might block automated commits. This ensures the loop can run fully autonomously.

**Commit message format:**
- Include epoch and chapter
- Include number of questions added (30 for all difficulties)
- Example: "Add 30 questions for Piastowie/Chrystianizacja (all difficulties: easy, medium, hard)"

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

1. **One loop per chapter, not per difficulty**: Generate all 30 questions (10 per difficulty × 3) in one iteration
2. **MCP tools only**: Use polish-history MCP tools instead of web search (unlimited usage)
3. **Chapter summary**: Created once and used as context for all difficulties
4. **Centralized storage**: All files in history-data/{epoch}/{chapter}/ directory
5. **Difficulty validation**: Use difficulty-reviewer skill to verify correct classification
6. **State location**: history-data/state.json (moved from .claude/)
