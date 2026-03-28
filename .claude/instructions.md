Claude Code Loop Instructions for Testdziej Question Generation

# Overview
You are running in a loop to generate Polish history quiz questions for the Testdziej app. Each loop iteration generates ONE question file.

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

If count >= 20, skip to next combination.

## 3. Analyze Sources
Use web tool to search for reliable Polish historical sources:

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

## 4. Create Summary File
Create file: questions/pending/[epoch]-[chapter]-[difficulty].md

Follow the template in templates/question-template.md

The summary should:

Be in Polish
Cover the historical context of the chapter
Be divided into 3-5 sections (potential question topics)
Each section: 1-3 sentences max

## 5. Generate Question and Answer
Based on the summary, create a question:

**For EASY difficulty:**

Simple factual questions (who, what, where, when)
Well-known dates, names, events
Primary school level

**For MEDIUM difficulty:**

Causes and effects
More detailed understanding
Secondary school level

**For HARD difficulty:**

Analytical questions
Complex relationships
Extended matura level


## 6. Create Incorrect Answers

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

## 7. Verify Question
Use web tool to verify:

```bash
# Example verification
# Search for the historical fact
"site:pl.wikipedia.org [event name] [year]"

# Verify each incorrect answer is historically true
"site:pl.wikipedia.org [incorrect answer event]"
```

## 8. Validate No Correct Answers in Incorrect Options
Run validation script:

```bash
scripts/validate-question.sh [question-file.md]
```

Check that:
- Correct answer is actually correct
- Each incorrect answer is factually true (but wrong context)
- No answer contradicts another

## 9. Save Metadata
At the top of the file, save:

created_at: [ISO 8601 timestamp]
session_start: [ISO 8601 timestamp when loop started]
session_end: [ISO 8601 timestamp]
tokens_input: [from API response]
tokens_output: [from API response]
tokens_total: [sum]

## 10. Update State File
Update .claude/state.json:

```json
{
  "current_epoch": "[CURRENT_EPOCH]",
  "current_chapter": "[CURRENT_CHAPTER]",
  "current_difficulty": "[CURRENT_DIFFICULTY]",
  "questions_generated_this_session": [N+1],
  "total_questions_generated": [TOTAL+1],
  "last_run": "[TIMESTAMP]",
  "status": "completed",
  "errors": []
}
```

Also increment the counter in .claude/questions-tracker.json:
```bash
jq --arg epoch "[CURRENT_EPOCH]" \
   --arg chapter "[CURRENT_CHAPTER]" \
   --arg difficulty "[DIFFICULTY]" \
   '.tracking[$epoch][$chapter][$difficulty] += 1 | .last_updated = "[TIMESTAMP]"' \
   .claude/questions-tracker.json > .claude/questions-tracker.json.tmp && \
mv .claude/questions-tracker.json.tmp .claude/questions-tracker.json
```

## 11. Move to Validated
After successful validation:

```bash

mv questions/pending/[file].md \
   questions/validated/
```

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