Claude Code Loop Instructions for Testdziej Question Generation

# Overview
You are running in a loop to generate Polish history quiz questions for the Testdziej app. Each loop iteration generates TEN questions for the SAME epoch-chapter-difficulty combination. **All 10 questions are saved in ONE file per chapter-difficulty.**

## Automated Git Commits
**This loop automatically commits all work at the end of each iteration without requiring user approval.**

Required permissions for autonomous operation:
- `git add` - allowed without confirmation
- `git commit` - allowed without confirmation (use `--no-verify` flag)
- `git status` - for verification

All commits are LOCAL only. No pushing to remote repositories.

# Loop Workflow

## 1. Pick Epoch and Chapter
Read .claude/state.json to find:
- Current epoch
- Current chapter
- Current difficulty

If state is empty/null, read .claude/questions-tracker.json to find the first combination with count < 20.

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
  select(.value < 20) |
  "\($epoch)|\($chapter)|\(.key)"
' .claude/questions-tracker.json | head -1
```

## 2. Determine Missing Questions
Check the current count in questions-tracker.json for the selected combination:
```bash
jq -r '.tracking["[EPOCH]"]["[CHAPTER]"]["[DIFFICULTY]"]' .claude/questions-tracker.json
```

Calculate how many questions are needed: 20 - current_count
- If count >= 20, skip to next combination
- Generate MIN(10, 20 - current_count) questions this iteration

## 3. Research Sources (ONCE per iteration)
Use web tool to search for reliable Polish historical sources for this epoch/chapter:

**Priority sources:**

pl.wikipedia.org (Polish Wikipedia)
historiaposzkola.pl
dlaucznia.pl
bryk.pl
Polskie Radio - historiapolskich.pl

**Search query format:**

```text
site:pl.wikipedia.org [epoka] [rozdział] historia Polski
site:historiaposzkola.pl [wydarzenie] lekcja
```

## 4. Generate 10 Questions
For the selected epoch-chapter-difficulty, create 10 DIFFERENT questions in ONE file.

### Question Creation Process (Repeat 10 times in same file):

**A. Create Historical Summary**
- Research different aspects of the chapter
- Each question should focus on a different topic/event
- Rotate between: causes, effects, key figures, dates, locations, consequences

**B. Generate Question based on difficulty:**

**For EASY difficulty:**
- Simple factual questions (who, what, where, when)
- Well-known dates, names, events
- Primary school level

**For MEDIUM difficulty:**
- Causes and effects
- More detailed understanding
- Secondary school level

**For HARD difficulty:**
- Analytical questions
- Complex relationships
- Extended matura level

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

**D. Vary Question Topics:**
For 10 questions, ensure diversity:
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

**E. Create Question File**
Create file: questions/validated/[epoch]-[chapter]-[difficulty].md (contains ALL 10 questions)

**CRITICAL: ONE FILE per chapter-difficulty**
- All 10 questions go into ONE file
- File name format: [epoch]-[chapter]-[difficulty].md (no numbers)
- Example: starozytnosc-pradzieje-easy.md contains 10 questions

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

[Historical Context - shared for all questions]

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

## 5. Verify Questions
For each of the 10 questions, use web tool to verify:

```bash
# Example verification
# Search for the historical fact
"site:pl.wikipedia.org [event name] [year]"

# Verify each incorrect answer is historically true
"site:pl.wikipedia.org [incorrect answer event]"
```

## 6. Validate No Correct Answers in Incorrect Options
Run validation script for each question:

```bash
scripts/validate-question.sh [question-file.md]
```

Check that:
- Correct answer is actually correct
- Each incorrect answer is factually true (but wrong context)
- No answer contradicts another

## 7. Polish Language Validation
**CRITICAL:** Before saving questions to validated folder, run Polish language check using the polish-check skill:

```bash
# Invoke the Polish language checker skill
claude skill polish-check [question-file.md]
```

The skill will:
- Check grammar errors (verb conjugations, case endings, gender agreement)
- Check spelling mistakes (Polish characters: ą, ć, ę, ł, ń, ó, ś, ź, ż)
- Check punctuation (commas, periods, quotation marks)
- Check style issues (awkward phrasing, unclear expressions)
- Verify historical terminology is used correctly
- Ensure question clarity and unambiguous wording
- Check that answer options are parallel in structure

**If errors are found:**
- Review the corrections suggested by the skill
- Apply the corrections to the question file
- Re-run the polish-check skill to verify all issues are resolved
- Only proceed to step 8 when Polish language validation passes

**If no errors are found:**
- Confirm the text is grammatically correct
- Proceed to next step

## 8. Save Metadata for Each Question
At the top of EACH file, save:

created_at: [ISO 8601 timestamp]
session_start: [ISO 8601 timestamp when loop started]
session_end: [ISO 8601 timestamp]
tokens_input: [from API response or estimate]
tokens_output: [from API response or estimate]
tokens_total: [sum]

## 9. Update State File
Update .claude/state.json:

```json
{
  "current_epoch": "[CURRENT_EPOCH]",
  "current_chapter": "[CURRENT_CHAPTER]",
  "current_difficulty": "[CURRENT_DIFFICULTY]",
  "questions_generated_this_session": [N+10],
  "total_questions_generated": [TOTAL+10],
  "last_run": "[TIMESTAMP]",
  "status": "completed",
  "errors": []
}
```

Also increment the counter in .claude/questions-tracker.json by 10:
```bash
jq --arg epoch "[CURRENT_EPOCH]" \
   --arg chapter "[CURRENT_CHAPTER]" \
   --arg difficulty "[DIFFICULTY]" \
   '.tracking[$epoch][$chapter][$difficulty] += 10 | .last_updated = "[TIMESTAMP]"' \
   .claude/questions-tracker.json > .claude/questions-tracker.json.tmp && \
mv .claude/questions-tracker.json.tmp .claude/questions-tracker.json
```

IMPORTANT: If you generated fewer than 10 questions (because the combination was close to 20), increment by the actual number generated.

## 10. All Questions Saved to Validated
All 10 questions are saved in ONE file: questions/validated/[epoch]-[chapter]-[difficulty].md

## 11. Commit Work Automatically
After each successful iteration, commit all changes to git WITHOUT requiring user approval:

```bash
# Determine the file that was just created
QUESTION_FILE="questions/validated/$(echo ${CURRENT_EPOCH} | tr '[:upper:]' '[:lower:]' | tr ' ' '-')-$(echo ${CURRENT_CHAPTER} | tr '[:upper:]' '[:lower:]' | tr ' ' '-')-${CURRENT_DIFFICULTY}.md"

# Stage all changes (questions, state files, tracker)
git add questions/validated/*.md .claude/state.json .claude/questions-tracker.json

# Get actual question count from the file
QUESTION_COUNT=$(jq -r '.question_count // 10' "$QUESTION_FILE" 2>/dev/null || echo "10")

# Create commit with descriptive message
git commit --no-verify -m "Add ${QUESTION_COUNT} questions for ${CURRENT_EPOCH}/${CURRENT_CHAPTER} (${CURRENT_DIFFICULTY})"
```

**IMPORTANT:** Always use `--no-verify` flag to bypass any pre-commit hooks that might block automated commits. This ensures the loop can run fully autonomously.

**Commit message format:**
- Include epoch, chapter, and difficulty
- Include number of questions added
- Example: "Add 10 questions for Piastowie/Chrystianizacja (easy)"

**DO NOT push to remote** - only commit locally. Pushing can be done manually by the user.

# Loop Exit Conditions
Stop the loop if:

All epoch/chapter/difficulty combinations have 20 questions
10 consecutive errors occur
Token budget exceeded
User interrupts

# Error Handling
If error occurs:

- Log error to logs/errors.log
- Update state file with error message
- Skip to next combination
- If 3 consecutive errors, pause and notify

# Batch Generation Tips

To generate 10 different questions for one chapter:

1. **Vary the focus:**
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
