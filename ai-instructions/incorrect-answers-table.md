# Instructions: Creating Incorrect Answers Table

## Overview

Extract incorrect answer explanations from question files and create a unified markdown table showing:
- File name and metadata (epoch, chapter, difficulty)
- Question ID, text, and answer options
- Category (for hard questions) or CORRECT
- Comment/explanation for each incorrect answer

## Files to Process

Process all question files in `history-data/` subdirectories matching pattern: `*_questions_*.md`
- `*_questions_easy.md`
- `*_questions_medium.md`
- `*_questions_hard.md`

Skip files with `question_count: 0`.

## Output File

Create table at: `history-data/questions-table.md`

## Table Format

### Single Table with Metadata in Rows

The entire output is ONE table with the following columns:

| File | Metadata | Question text | Answer | Category | Comment |
|------|----------|---------------|--------|----------|---------|

**Column descriptions:**
- **File**: File name on metadata header row, empty for question rows
- **Metadata**: "Epoch: X, Chapter: Y, Difficulty: Z" on header row, empty for question rows
- **Question text**: Question text on first row for each question, empty for subsequent answer rows
- **Answer**: The full answer text (A. Answer text, B. Answer text, etc.)
- **Category**:
  - For correct answers: "CORRECT"
  - For incorrect answers with categorization: Extract text between "– " and ":"
  - For incorrect answers without categorization: Leave empty
- **Comment**:
  - For correct answers: Empty
  - For incorrect answers: Explanation text after the ":"

### Row Structure

**Metadata header row (one per file):**
```
| **File: filename** | **Epoch:** tech_name | **Chapter:** tech_name | **Difficulty:** easy/medium/hard | | |
```

**Question row with correct answer:**
```
| | | Question ID | Question text | A. Answer text | CORRECT | |
```

Wait, let me fix this. Looking at the script, the format is:

| File | Metadata | Question text | Answer | Category | Comment |
|------|----------|---------------|--------|----------|---------|

So the columns are:
1. File - filename on header row, Question ID on question rows
2. Metadata - epoch/chapter/difficulty on header row, Question text on question rows
3. Question text - Answer text
4. Answer - Category
5. Category - Comment
6. Comment - empty

Actually, looking at the script more carefully:

```python
out.write("| File | Metadata | Question text | Answer | Category | Comment |\n")
```

And the rows are:
```python
# Metadata header
rows.append(f"| **File: {filename}** | **Epoch:** {epoch_name} | **Chapter:** {chapter_name} | **Difficulty:** {difficulty} | | |")

# Question row
rows.append(f"| {question_id} | {question_text} | {correct_answer_text} | CORRECT | |")
```

So the actual format is:
| File | Metadata | Question text | Answer | Category | Comment |
|------|----------|---------------|--------|----------|---------|
| **File: name** | **Epoch:** X | **Chapter:** Y | **Difficulty:** Z | | |
| Q-ID | Question text | A. Answer | CORRECT | | |
| | | B. Answer | Category | Comment | |

Let me update the instructions to reflect this.

### Row Structure

**Metadata header row (one per file):**
```
| **File: filename** | **Epoch:** tech_name | **Chapter:** tech_name | **Difficulty:** easy/medium/hard | | |
```

**Question row with correct answer:**
```
| Question ID | Question text | A. Answer text | CORRECT | | |
```

**Incorrect answer rows:**
```
| | | B. Answer text | Category | Comment | |
```

**Note:** Leave File, Metadata, Question text empty for subsequent answer rows (same question).

## Extraction Rules

### 1. Identify Question Structure

**Medium/Easy questions typically use:**
```markdown
**Analiza odpowiedzi błędnych:**
- A. Answer text – explanation text
- B. Answer text – explanation text
```

**Hard questions typically use:**
```markdown
**Analiza odpowiedzi błędnych:**
- Odpowiedź A (Answer text) – context from Chapter (category): explanation text
- Odpowiedź B (Answer text) – context from Chapter (category): explanation text
```

### 2. Extract Answer Letter and Text

Extract the full answer line including letter and text:
- "A. Kazimierz Odnowiciel" (not just "Kazimierz Odnowiciel")
- "B. Konflikt o Żmudź..." (not just "Konflikt o Żmudź...")

### 3. Determine Correct Answer

Find the line with "**Prawidłowa odpowiedź:**" or "**Poprawna odpowiedź:**" and note the letter (A, B, C, or D).

### 4. Parse Incorrect Answers

For each incorrect answer in "**Analiza odpowiedzi błędnych:**" section:

**Format 1 - Without categorization (medium/easy):**
```
- A. Answer text – explanation text
```
- Category: Empty
- Comment: `explanation text` (everything after "– ")

**Format 2 - With categorization (hard):**
```
- Odpowiedź A (Answer text) – context from Chapter (category): explanation text
```
- Category: `context from Chapter (category)` (text between "– " and ":")
- Comment: `explanation text` (everything after ":")
- Remove leading "– " from explanation

### 5. Answer Letter Mapping

Map answer indicators to letters:
- "A. " or "Odpowiedź A" → A
- "B. " or "Odpowiedź B" → B
- "C. " or "Odpowiedź C" → C
- "D. " or "Odpowiedź D" → D
- "Odp A:" or "Odpowiedź A:" → A

## Examples

### Example 1: Medium Question (no categorization)

**Source:**
```markdown
**Question ID:** Q-P-EKSP-M-001
**Pytanie:** Który władca panował w latach 1025-1034?
**A.** Kazimierz Odnowiciel
**B.** Mieszko II
**Poprawna odpowiedź:** B
**Analiza odpowiedzi błędnych:**
- Odp A: Kazimierz Odnowiciel był synem Mieszka II
```

**Output:**
```markdown
| **File: ekspansja_questions_medium.md** | **Epoch:** piastowie | **Chapter:** ekspansja | **Difficulty:** medium | | |
| Q-P-EKSP-M-001 | Który władca panował w latach 1025-1034? | A. Kazimierz Odnowiciel | | Kazimierz Odnowiciel był synem Mieszka II |
| | | B. Mieszko II | CORRECT | |
```

### Example 2: Hard Question (with categorization)

**Source:**
```markdown
**Question ID:** Q-JAG-GRU-H-001
**Pytanie:** Dlaczego wybuchła wojna?
**A.** Konflikt o Żmudź
**B.** Spór o tron
**Poprawna odpowiedź:** A
**Analiza odpowiedzi błędnych:**
- Odpowiedź B (Spór o tron) – incorrect from Kazimierz Wielki: Kazimierz zmarł w 1370
```

**Output:**
```markdown
| **File: grunwald_questions_hard.md** | **Epoch:** jagiellonowie | **Chapter:** grunwald | **Difficulty:** hard | | |
| Q-JAG-GRU-H-001 | Dlaczego wybuchła wojna? | A. Konflikt o Żmudź | CORRECT | |
| | | B. Spór o tron | incorrect from Kazimierz Wielki | Kazimierz zmarł w 1370 |
```

## Processing Steps

1. **Find all question files**: Use glob pattern `history-data/**/*_questions_*.md`
2. **Read each file**: Check metadata for `question_count`
3. **Skip if 0 questions**: Don't add any rows for this file
4. **Extract questions**: Parse each question block
5. **Extract incorrect answer analysis**: Find "**Analiza odpowiedzi błędnych:**" section
6. **Parse each incorrect answer**: Extract category (if present) and comment
7. **Create table rows**: Format according to rules above
8. **Append to output file**: Add to `history-data/questions-table.md`
9. **Clean up question files**: Remove categorization text from original question files (see below)

## Post-Processing: Clean Up Question Files

After creating the table, remove categorization text from the original question files to keep them clean.

### What to Remove

Remove categorization text from "**Analiza odpowiedzi błędnych:**" sections:
- Pattern: ` – context from [Chapter] ([category]):`
- Pattern: ` – incorrect from [Chapter]:`
- Pattern: ` – no referenced answer:`
- Any similar categorization between "– " and ":"

### What to Keep

Keep the explanation text after the colon.

### Before and After Examples

**Before:**
```markdown
**Analiza odpowiedzi błędnych:**
- Odpowiedź A (Answer text) – context from Pradzieje (incorrect fact): explanation text here
- Odpowiedź B (Answer text) – incorrect from Kazimierz Wielki: explanation text here
```

**After:**
```markdown
**Analiza odpowiedzi błędnych:**
- Odpowiedź A (Answer text) – explanation text here
- Odpowiedź B (Answer text) – explanation text here
```

### Implementation

Use `sed` or similar tool to replace patterns:
```bash
# Remove categorization text (text between " – " and ":" followed by space)
sed -i 's/ – context from [^:]*: / – /g' [file]
sed -i 's/ – incorrect from [^:]*: / – /g' [file]
sed -i 's/ – no referenced answer: / – /g' [file]
```

Or more comprehensively:
```bash
# Remove any categorization pattern
sed -i 's/ – context from [^:]*: / – /g' [file]
sed -i 's/ – incorrect from [^:]*: / – /g' [file]
sed -i 's/ – no referenced answer: / – /g' [file]
```

### Order of Operations

1. Process all files and create the complete table in `questions-table.md`
2. After table is complete and verified, clean up each question file
3. Verify each file was correctly updated
4. Commit changes with message describing both operations

## Special Cases

### Files with No Questions
Don't add any rows to the table for files with `question_count: 0`.

### Multiple Answers per Question
- Correct answer gets "CORRECT" in Category, empty Comment
- Each incorrect answer gets its own row with extracted Category and Comment

### Empty Category Column
- Leave Category cell empty (not "N/A" or similar)
- This occurs when format doesn't include categorization (most medium/easy questions)

### Removing Leading Separators
- Remove leading "– " from Comment if present
- Remove leading "– " from Category if present
- Keep only the text content

## Validation

After processing each file, verify:
1. All questions from file are included
2. Correct answers have "CORRECT" in Category, empty Comment
3. Incorrect answers have Category (if format includes it) and Comment
4. Question ID and text are not repeated for subsequent answer rows
5. File metadata is correct in header row

## Common Patterns to Recognize

**Category types:**
- "incorrect from [Chapter]" - incorrect reference to another chapter/topic
- "context from [Chapter]" - contextual information from another chapter
- "incorrect [chronology/fact/generalization/uniqueness/causation]" - type of error
- "no referenced answer" - no specific reference provided

**Answer format variations:**
- "A. Answer text" (with dot and space)
- "Odpowiedź A (Answer text)" (with parentheses)
- "Odp A: Answer text" (colon format)
- Always preserve the full answer text as it appears in the question

## Tech Names Reference

Use `history-data/master-list.json` to get `epoch_tech_name` and `chapter_tech_name` for the metadata header.

Example:
```json
{
  "epoch": "Starożytność",
  "epoch_id": 1,
  "tech_name": "starozytnosc",
  "chapters": [
    {
      "chapter": "Pradzieje",
      "chapter_id": 1,
      "tech_name": "pradzieje"
    }
  ]
}
```

## Error Handling

If parsing fails:
1. Log the file and question ID
2. Skip to next question
3. Continue processing remaining files
4. Report errors at end

If format doesn't match expected patterns:
1. Extract what you can
2. Leave Category empty if categorization not found
3. Include full explanation in Comment
4. Note the anomaly in processing log
