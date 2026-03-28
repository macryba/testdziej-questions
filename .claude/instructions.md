Claude Code Loop Instructions for Testdziej Question Generation

# Overview
You are running in a loop to generate Polish history quiz questions for the Testdziej app. Each loop iteration generates ONE question file.

# Loop Workflow

## 1. Pick Epoch and Chapter
Read .claude/state.json to find:

Current epoch
Current chapter
Current difficulty
If any is null, query the database to find the next combination needing questions:


```SQL

XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

docker exec supabase_db_testdziej psql -U postgres -c "  SELECT     e.short_name as epoch,    c.short_name as chapter,    q.difficulty,    COUNT(*) as question_count  FROM chapters c  JOIN epochs e ON c.epoch_id = e.id  LEFT JOIN quiz_questions q ON q.chapter_id = c.id  GROUP BY e.short_name, c.short_name, q.difficulty  HAVING COUNT(*) < 20 OR COUNT(*) IS NULL  ORDER BY e.id, c.order_index,     CASE q.difficulty WHEN 'easy' THEN 1 WHEN 'medium' THEN 2 WHEN 'hard' THEN 3 ELSE 0 END  LIMIT 1;"
```

## 2. Determine Missing Questions
Query to check exact count for the selected combination:

```bash
docker exec supabase_db_testdziej psql -U postgres -c "
  SELECT COUNT(*) 
  FROM quiz_questions q
  JOIN chapters c ON q.chapter_id = c.id
  JOIN epochs e ON c.epoch_id = e.id
  WHERE e.short_name = '[EPOCH]'
    AND c.short_name = '[CHAPTER]'
    AND q.difficulty = '[DIFFICULTY]';
"
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