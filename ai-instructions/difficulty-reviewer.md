# Difficulty Reviewer Agent Instructions

**Purpose:** Review and correct difficulty level classification for historical quiz questions in a given chapter.

**Input:** Chapter identifier (e.g., "02-piastowie/04-najazd-mongolski")

**Output:**
1. **Automatic correction of all misclassified questions** - move questions between difficulty level files
2. Update all metadata (question_count, timestamps, etc.)
3. Brief summary of changes made (for git commit message)

---

## Phase 1: Preparation and Context Understanding

### Step 1: Read Classification Rules

**Read:** `history-data/podstawa/klasyfikacja.md`

**Key concepts to understand:**
- Difficulty levels are NOT mutually exclusive
- Simple factual questions (Kto? Co? Gdzie? Kiedy?) can be EASY or MEDIUM depending on curriculum
- EASY only for topics in primary school curriculum
- MEDIUM includes both analytical AND simple factual (if EASY not in curriculum)
- HARD includes advanced analytical AND specialized factual (not in standard curriculum)
- All quiz answers must be SHORT (1 sentence maximum) - this is a quiz, not an essay
- Question counts are LOWER BOUND recommendations, not upper limits

**Critical rule:**
> If topic IS in primary school curriculum → Simple factual can be EASY
> If topic NOT in primary school curriculum → Simple factual must be MEDIUM

---

### Step 1.5: Read Master List for Chapter Names

**Read:** `history-data/master-list.json`

**Extract for this chapter:**
- Epoch name (display name)
- Chapter name (display name)
- Epoch technical name
- Chapter technical name
- Year ranges (if applicable)

**Use this information to:**
- Properly name chapters in file metadata
- Ensure consistency across files
- Validate chapter identification

**Example:**
```json
{
  "id": "1",
  "name": "Starożytność",
  "tech_name": "starozytnosc",
  "chapters": [
    {
      "id": "1",
      "name": "Pradzieje",
      "tech_name": "pradzieje",
      "years": "do 966 r."
    }
  ]
}
```

---

### Step 2: Read Curriculum Files

**Read:** `history-data/podstawa/szkola_podstawowa_zpe.md`
- This defines EASY level (primary school, grades IV-VIII)
- Key sections: Dział IV (17 postacie), treści dodatkowe
- Look for: names, events, places, dates listed

**Read:** `history-data/podstawa/liceum_technikum_zpe.md`
- This defines MEDIUM (ZAKRES PODSTAWOWY) and HARD (ZAKRES ROZSZERZONY)
- Look for: chapter topics, historical periods, key events
- Note which topics are in basic vs extended scope

**For this chapter, identify:**
1. Which topics/people/events are in primary school curriculum? (EASY candidates)
2. Which topics are in high school basic scope? (MEDIUM candidates)
3. Which topics require extended scope analysis? (HARD candidates)

---

### Step 3: Read Chapter Files

**Input format:** `{epoch_id}-{epoch_tech_name}/{chapter_id}-{chapter_tech_name}`

**Read all files in that directory:**
1. `{chapter_tech_name}_summary.md` - chapter overview and topic categorization
2. `{chapter_tech_name}_questions_easy.md` - easy questions
3. `{chapter_tech_name}_questions_medium.md` - medium questions
4. `{chapter_tech_name}_questions_hard.md` - hard questions

**Extract from each question file:**
- All questions with full content (question text, answers, correct answer, explanation)
- Current difficulty level
- Question type (factual vs analytical)

**If any file is missing:**
- Note it in report
- Continue with available files

---

## Phase 2: Duplicate Detection and Resolution

### Step 3.5: Identify Duplicate Questions

**Before analyzing difficulty levels, check for duplicates:**

#### 3.5a: Find Potential Duplicates

For each question, compare against ALL other questions in the same chapter (across all difficulty levels).

**Duplicate indicators:**
- Same question text (exact match)
- Similar question text (minor wording differences)
- Same topic + same question type
- Same answer options (or very similar)
- Covering the same historical fact/event

**Example duplicates:**
```
Q1: "Kiedy rozpoczęły się pradzieje ziem polskich?"
Q2: "Od kiedy trwają pradzieje na ziemiach polskich?"
→ SAME TOPIC + SAME TYPE (factual WHEN) → DUPLICATE

Q3: "Gdzie została zbudowana słynna osada obronna z epoki żelaza?"
Q4: "Jak nazywała się słynna osada obronna z epoki żelaza?"
→ SAME TOPIC + SIMILAR FOCUS → DUPLICATE
```

#### 3.5b: Compare Duplicate Quality

For each duplicate set, evaluate which question is BETTER:

**Quality criteria:**
1. **Clarity:** Which question is clearer and less ambiguous?
2. **Quiz format:** Which has better formatted answers (A/B/C/D)?
3. **Answer quality:** Which has more plausible incorrect answers?
4. **Explanation quality:** Which has better explanation?
5. **Historical accuracy:** Both should be accurate, but verify
6. **Language:** Which has better Polish grammar/style?
7. **Difficulty appropriateness:** Which is better suited for its level?

**Scoring system (0-5 points each):**
```
Question A: Clarity=5, Format=4, Answers=5, Explanation=4, Language=5 → Total: 23
Question B: Clarity=4, Format=5, Answers=4, Explanation=5, Language=4 → Total: 22
→ Question A wins (23 > 22)
```

#### 3.5c: Resolution Strategy

**If one question is clearly better (score difference ≥ 3):**
- **KEEP:** The better question
- **REMOVE:** The weaker question entirely
- **NO MERGE:** Don't try to combine, just keep the winner

**If questions are similar quality (score difference < 3):**
- **MERGE:** Create optimal question combining best elements:
  - Best question text (clearest wording)
  - Best answer options (most plausible distractors)
  - Best explanation (clearest, most accurate)
  - Best sources (most relevant URLs)
- **REMOVE:** Both original questions
- **ADD:** The merged question

**If questions cover slightly different aspects:**
- **KEEP BOTH** if they ask different things:
  ```
  Q1: "Kiedy odbyła się bitwa pod Legnicą?" (WHEN)
  Q2: "Kto poległ w bitwie pod Legnicą?" (WHO)
  → Different question types - KEEP BOTH
  ```
- **MERGE** if they're essentially the same:
  ```
  Q1: "Kiedy rozpoczęły się pradzieje ziem polskich?"
  Q2: "Od kiedy trwają pradzieje na ziemiach polskich?"
  → Same question - MERGE
  ```

#### 3.5d: Create Merged Questions (when needed)

**When merging, create optimal question:**

```markdown
### Pytanie [NUMBER]

**Question ID:** Q-[CODE]-[LEVEL][NUMBER]

**Pytanie:** [BEST question text from either question]

**A)** [Best answer option A]
**B)** [Best answer option B]
**C)** [Best answer option C]
**D)** [Best answer option D]

**Prawidłowa odpowiedź:** [letter]

**Wyjaśnienie:** [Best explanation - clear, accurate, 2-3 sentences max]

**Źródła:**
- [Most relevant sources from either question]
- [Additional sources if needed for verification]

**Analiza nieprawidłowych odpowiedzi:**
- A) [Concise explanation]
- B) [Concise explanation]
- C) [Concise explanation]
```

**Merging guidelines:**
- Use the clearest, most precise question wording
- Select the 4 most plausible incorrect answers (similar lengths, historically true but wrong context)
- Choose the best explanation (simple, accurate, 1-2 sentences)
- Combine sources if needed
- Ensure all answers meet validation rules (similar length, historically true, no opposites)

**Example merge:**
```
ORIGINAL Q1:
"Kiedy rozpoczęły się pradzieje ziem polskich?"
A. 1 tysiąc lat temu
B. 100 tysięcy lat temu
C. 500 tysięcy lat temu
D. 2 miliony lat temu

ORIGINAL Q2:
"Od kiedy trwają pradzieje na ziemiach polskich?"
A. Od około 1 tysiąca lat
B. Od około 100 tysięcy lat
C. Od około pół miliona lat
D. Od około 2 milionów lat

MERGED (BEST):
"Kiedy rozpoczęły się pradzieje ziem polskich?"
A. około 1 tysiąca lat temu
B. około 100 tysięcy lat temu
C. około 500 tysięcy lat temu
D. około 2 milionów lat temu

Improvements:
- Better wording from Q1 ("Kiedy rozpoczęły się" vs "Od kiedy trwają")
- Better format from Q2 ("około" for all options)
- More consistent answer structure
```

#### 3.5e: Update Question IDs After Removal

When questions are removed, renumber remaining questions:
- Keep sequential numbering
- Update Question IDs to reflect new numbers
- Update metadata (question_count)

---

## Phase 3: Question-by-Question Analysis

### Step 4: Analyze Each Question

For **EACH question** across all difficulty levels, perform this analysis:

#### 4a. Determine Question Type

**Is it Factual (Kto/Co/Gdzie/Kiedy)?**
- Asks for a specific name, date, place, event
- Answer is one word or short phrase
- Examples: "Kto poległ pod Legnicą?", "W którym roku...", "Jak nazywała się..."

**Is it Analytical (Dlaczego/Jakie skutki)?**
- Asks for causes, effects, comparisons, explanations
- Answer requires understanding relationships
- Examples: "Jaka była przyczyna...", "Jakie były skutki...", "Czym różnił się..."

#### 4b. Check Curriculum Coverage

**For Factual questions:**
- Check if topic/person/event is in `szkola_podstawowa_zpe.md`
  - Look in Dział IV (17 postacie)
  - Look in treści dodatkowe
  - Look in specific sections for the epoch

**For Analytical questions:**
- Check if topic is in `liceum_technikum_zpe.md`
  - In ZAKRES PODSTAWOWY → MEDIUM
  - In ZAKRES ROZSZERZONY → HARD

#### 4c. Determine Correct Level

**Decision Matrix:**

| Question Type | In Primary Curriculum? | In High School Basic? | In High School Extended? | Correct Level |
|---------------|------------------------|------------------------|--------------------------|---------------|
| Factual | YES | - | - | **EASY** |
| Factual | NO | YES | - | **MEDIUM** |
| Factual | NO | NO | YES | **HARD** (specialized) |
| Analytical (simple) | - | YES | - | **MEDIUM** |
| Analytical (complex) | - | - | YES | **HARD** |

**Special Cases:**
- If EASY file has `question_count: 0` (topic not in primary curriculum) → all factual must be MEDIUM or HARD
- If question requires synthesis/evaluation → HARD (even if short answer)
- If question is very simple but topic NOT in primary curriculum → MEDIUM

#### 4d. Make Judgement

**If question is at CORRECT level:**
- Mark: "KEEP - [level]"
- Justify: "Topic [is/is not] in primary curriculum. Question type is [factual/analytical]."

**If question is at WRONG level:**
- Mark: "MOVE [current_level] → [correct_level]"
- Justify: "Topic [is/is not] in primary curriculum. Question type is [type]. Currently at [level] but should be [level] because [reason]."

---

## Phase 4: Curriculum Coverage Assessment

### Step 5: Assess Curriculum Coverage for Each Level

After analyzing all questions, assess how well the questions cover the curriculum:

#### 5a: EASY Level Coverage

**Reference:** `szkola_podstawowa_zpe.md`

**Identify topics that SHOULD be covered:**
- List all people, events, places, dates from primary curriculum for this chapter
- Check chapter summary: look for "## Tematy poziom EASY" section

**Calculate coverage:**
```
% Coverage = (Topics covered by questions / Topics in curriculum) × 100
```

**If EASY count is 0 (topic not in primary curriculum):**
- Coverage: N/A
- Note: "Temat nie ujęty w podstawie programowej szkoły podstawowej"

#### 5b: MEDIUM Level Coverage

**Reference:** `liceum_technikum_zpe.md` (ZAKRES PODSTAWOWY)

**Identify topics that SHOULD be covered:**
- List all requirements from basic scope for this chapter
- Check chapter summary: look for "## Tematy poziom MEDIUM" section

**Calculate coverage:**
```
% Coverage = (Requirements covered / Requirements in curriculum) × 100
```

**Note:** MEDIUM should cover both analytical AND simple factual (if EASY not in curriculum)

#### 5c: HARD Level Coverage

**Reference:** `liceum_technikum_zpe.md` (ZAKRES ROZSZERZONY)

**Identify topics that SHOULD be covered:**
- List all extended scope requirements for this chapter
- Check chapter summary: look for "## Tematy poziom HARD" section

**Calculate coverage:**
```
% Coverage = (Extended topics covered / Extended topics in curriculum) × 100
```

**Note:** HARD is optional - low coverage may be acceptable if topic lacks analytical depth

---

## Phase 5: Resolve Duplicates

### Step 6: Apply Duplicate Resolution

**Apply all duplicate resolutions determined in Phase 2:**

#### 5a: Remove Weaker Questions

For each duplicate set where one question is clearly better:
1. **DELETE** the weaker question from its file
2. **KEEP** the better question unchanged
3. **UPDATE** question_count in metadata
4. **RENUMBER** remaining questions if needed (keep sequential)

#### 5b: Replace with Merged Questions

For each duplicate set where questions are similar quality:
1. **DELETE** both original questions
2. **CREATE** new merged question (using best elements)
3. **ADD** merged question to appropriate file
4. **UPDATE** question_count in metadata
5. **ASSIGN** new Question ID (sequential)
6. **RENUMBER** other questions if needed

#### 5c: Verify After Duplicate Resolution

**Check each file:**
- No duplicate questions remain
- Question IDs are sequential
- question_count matches actual number of questions
- All questions have unique content
- No gaps in numbering

**Example verification:**
```bash
# Before duplicate resolution:
MEDIUM: 24 questions (including 3 duplicates)

# After duplicate resolution:
MEDIUM: 21 questions (3 duplicates removed/merged)
```

---

## Phase 6: Apply Difficulty Level Changes

**IMPORTANT:** Apply ALL changes automatically. Git will track what changed.

#### 7a: Build Question Lists

Create lists for each difficulty level (AFTER duplicate resolution):
- **EASY_keep:** Questions that stay at EASY
- **EASY_move_to_MEDIUM:** Questions to move from EASY to MEDIUM
- **EASY_move_to_HARD:** Questions to move from EASY to HARD
- **MEDIUM_keep:** Questions that stay at MEDIUM
- **MEDIUM_move_to_EASY:** Questions to move from MEDIUM to EASY
- **MEDIUM_move_to_HARD:** Questions to move from MEDIUM to HARD
- **HARD_keep:** Questions that stay at HARD
- **HARD_move_to_EASY:** Questions to move from HARD to EASY
- **HARD_move_to_MEDIUM:** Questions to move from HARD to MEDIUM

#### 7b: Update EASY File

**Read:** `{chapter}_questions_easy.md`

**Questions to include:**
- All EASY_keep questions
- All questions moved FROM MEDIUM to EASY
- All questions moved FROM HARD to EASY

**If result is 0 questions:**
- Replace with special template (see below)

**If result has questions:**
- Keep all existing questions (EASY_keep)
- Add moved questions at the end
- Update question_count in metadata
- Update session_end timestamp

**Update Question IDs:**
- If question moved from MEDIUM: Change Q-XXX-M### to Q-XXX-E###
- If question moved from HARD: Change Q-XXX-H### to Q-XXX-E###

**0 Questions Template:**
```markdown
---
epoch: "[EPOCH]"
epoch_id: [ID]
chapter: "[CHAPTER]"
chapter_id: [ID]
difficulty: "easy"
question_count: 0
created_at: "[ORIGINAL_TIMESTAMP]"
session_start: "[ORIGINAL_TIMESTAMP]"
session_end: "[CURRENT_TIMESTAMP]"
tokens_input: [ORIGINAL]
tokens_output: [ORIGINAL]
tokens_total: [ORIGINAL]
corrected_at: "[CURRENT_TIMESTAMP]"
correction_reason: "Topic not in primary school curriculum"
---

# Pytania poziom łatwy - Brak pytań

**Temat nie ujęty w poziomie szkoły podstawowej.**

Ten rozdział wykracza poza zakres podstawy programowej szkoły podstawowej. Pytania na poziomie łatwym dotyczą tylko tematów ujętych w podstawie programowej dla klas IV-VIII szkoły podstawowej.

Zgodnie z podstawą programową (Dział IV: Postacie i wydarzenia o doniosłym znaczeniu), temat ten nie jest objęty wymaganiami dla szkoły podstawowej.

**Uwaga:** Proste pytania faktograficzne (Kto? Co? Gdzie? Kiedy?) z tego rozdziału znajdują się w pytaniach poziomu średniego (MEDIUM).

---
**Brak pytań do wyświetlenia.**
```

#### 7c: Update MEDIUM File

**Read:** `{chapter}_questions_medium.md`

**Questions to include:**
- All MEDIUM_keep questions
- All questions moved FROM EASY to MEDIUM
- All questions moved FROM HARD to MEDIUM

**Update:**
- Keep all existing questions (MEDIUM_keep)
- Add moved questions at the end (organize: factual first, then analytical)
- Update question_count in metadata
- Update session_end timestamp

**Update Question IDs:**
- If question moved from EASY: Change Q-XXX-E### to Q-XXX-M###
- If question moved from HARD: Change Q-XXX-H### to Q-XXX-M###

**Reorganize questions:**
- Factual questions first (Kto/Co/Gdzie/Kiedy)
- Analytical questions second (Dlaczego/Jakie skutki)
- This makes the file more logical

#### 7d: Update HARD File

**Read:** `{chapter}_questions_hard.md`

**Questions to include:**
- All HARD_keep questions
- All questions moved FROM EASY to HARD
- All questions moved FROM MEDIUM to HARD

**If result is 0 questions:**
- Replace with special template (see below)

**If result has questions:**
- Keep all existing questions (HARD_keep)
- Add moved questions at the end
- Update question_count in metadata
- Update session_end timestamp

**Update Question IDs:**
- If question moved from EASY: Change Q-XXX-E### to Q-XXX-H###
- If question moved from MEDIUM: Change Q-XXX-M### to Q-XXX-H###

**0 Questions Template:**
```markdown
---
epoch: "[EPOCH]"
epoch_id: [ID]
chapter: "[CHAPTER]"
chapter_id: [ID]
difficulty: "hard"
question_count: 0
created_at: "[ORIGINAL_TIMESTAMP]"
session_start: "[ORIGINAL_TIMESTAMP]"
session_end: "[CURRENT_TIMESTAMP]"
tokens_input: [ORIGINAL]
tokens_output: [ORIGINAL]
tokens_total: [ORIGINAL]
corrected_at: "[CURRENT_TIMESTAMP]"
correction_reason: "No HARD-level topics in this chapter"
---

# Pytania poziom trudny - Brak pytań

**Temat nie zawiera wystarczającej liczby tematów na poziomie rozszerzonym.**

Ten rozdział, chociaż ważny z historycznego punktu widzenia, nie zawiera tematów wymagających analizy na poziomie rozszerzonym (liceum - zakres rozszerzony). Wszystkie istotne zagadnienia z tego okresu zostały objęte pytaniami na poziomie podstawowym (MEDIUM).

Zgodnie z podstawą programową dla liceum (zakres rozszerzony), ten temat nie wymaga pytań typu analitycznego, syntetycznego lub oceny z perspektywy.

---
**Brak pytań do wyświetlenia.**
```

#### 7e: Save Updated Files

**Save all three files:**
- `{chapter}_questions_easy.md` (updated)
- `{chapter}_questions_medium.md` (updated)
- `{chapter}_questions_hard.md` (updated)

**Verify:**
- All files are valid markdown
- YAML frontmatter is correct
- Question IDs are sequential within each file
- Question counts match actual number of questions

#### 7f: Update questions-tracker.json

**Read:** `history-data/questions-tracker.json`

**Update counts for this chapter:**

```bash
# Use jq to update the tracker
jq --arg epoch "[EPOCH_NAME]" \
   --arg chapter "[CHAPTER_NAME]" \
   --arg easycount [EASY_COUNT] \
   --arg mediumcount [MEDIUM_COUNT] \
   --arg hardcount [HARD_COUNT] \
   '.tracking[$epoch][$chapter]["easy"] = $easycount |
    .tracking[$epoch][$chapter]["medium"] = $mediumcount |
    .tracking[$epoch][$chapter]["hard"] = $hardcount |
    if $easycount == 0 then .tracking[$epoch][$chapter]["easy_completed"] = true else . end |
    if $mediumcount > 0 then .tracking[$epoch][$chapter]["medium_completed"] = true else . end |
    if $hardcount > 0 then .tracking[$epoch][$chapter]["hard_completed"] = true else . end |
    .last_updated = "[CURRENT_TIMESTAMP_UTC]"' \
   history-data/questions-tracker.json > history-data/questions-tracker.json.tmp && \
mv history-data/questions-tracker.json.tmp history-data/questions-tracker.json
```

**Example:**
```bash
jq '.tracking.Starożytność.Pradzieje.easy = 0 |
     .tracking.Starożytność.Pradzieje.medium = 24 |
     .tracking.Starożytność.Pradzieje.hard = 3 |
     .tracking.Starożytność.Pradzieje.easy_completed = true |
     .tracking.Starożytność.Pradzieje.medium_completed = true |
     .tracking.Starożytność.Pradzieje.hard_completed = true |
     .last_updated = "2026-05-07T20:00:00Z"' \
   history-data/questions-tracker.json > tmp && mv tmp history-data/questions-tracker.json
```

**CRITICAL:**
- Use the EPOCH and CHAPTER names from master-list.json (not technical names)
- Set `easy_completed = true` if easy_count = 0 (topic not in curriculum)
- Set `*_completed = true` if count > 0 (questions exist)
- Update `last_updated` to current timestamp in UTC format
- Preserve all other data in the tracker

**Verify tracker was updated:**
```bash
# Check the update was successful
jq ".tracking.[\"[EPOCH_NAME]\"].[\"[CHAPTER_NAME]\"]" history-data/questions-tracker.json
```

---

## Phase 7: Generate Brief Summary

### Step 9: Create Brief Summary for Git Commit

**Generate a brief summary of changes:**

```markdown
Difficulty Level Corrections: [EPOCH]/[CHAPTER]

Changes Made:
- Moved X questions from EASY → MEDIUM (reason: [brief reason])
- Moved Y questions from MEDIUM → EASY (reason: [brief reason])
- Moved Z questions from MEDIUM → HARD (reason: [brief reason])
- Moved W questions from HARD → MEDIUM (reason: [brief reason])
- Resolved D duplicates: D removed, M merged (improved quality)

Files Modified:
- [chapter]_questions_easy.md
- [chapter]_questions_medium.md
- [chapter]_questions_hard.md
- questions-tracker.json (updated counts)

Final Counts:
- EASY: [count] (was X)
- MEDIUM: [count] (was Y)
- HARD: [count] (was Z)

Classification Accuracy: [X]%

Curriculum Coverage:
- EASY: [X]% or N/A
- MEDIUM: [X]%
- HARD: [X]%

Duplicate Resolution: Yes (D duplicates removed/merged)
Tracker Updated: Yes (counts and completion flags)
```

**This summary is for:**
- User to understand what changed
- Git commit message
- Quick reference without reading full diff

**DO NOT generate full report** - git diff shows all changes, user can review with git tools.

---

## Phase 8: Git Commit and Completion Report

### Step 10: Create Git Commit

**Stage all modified files:**

```bash
# Stage chapter question files
git add "history-data/[epoch_id]-[epoch_tech]/[chapter_id]-[chapter_tech]/*_questions_*.md"

# Stage tracker file
git add "history-data/questions-tracker.json"

# Stage summary if modified
git add "history-data/[epoch_id]-[epoch_tech]/[chapter_id]-[chapter_tech]/*_summary.md" 2>/dev/null || true
```

**Verify staged files:**
```bash
# Check what will be committed
git status --short
```

**Create git commit with descriptive message:**

```bash
git commit --no-verify -m "Difficulty level corrections: [EPOCH]/[CHAPTER]

Changes Made:
- Moved X questions from EASY → MEDIUM (reason: [brief reason])
- Moved Y questions from MEDIUM → EASY (reason: [brief reason])
- Moved Z questions from MEDIUM → HARD (reason: [brief reason])
- Moved W questions from HARD → MEDIUM (reason: [brief reason])
- Resolved D duplicates: D removed, M merged

Final Counts:
- EASY: [count] (was X)
- MEDIUM: [count] (was Y)
- HARD: [count] (was Z)

Classification Accuracy: [X]%

Curriculum Coverage:
- EASY: [X]% or N/A
- MEDIUM: [X]%
- HARD: [X]%

Tracker updated: Yes (counts and completion flags)"
```

**Commit message guidelines:**
- **NO "Co-Authored-By: Claude" or similar**
- Simple, direct description
- Focus on chapter and counts
- Mention key changes (moves, duplicates)
- Include accuracy and coverage metrics

**Example commit message:**
```
Difficulty level corrections: Starożytność/Pradzieje

Changes Made:
- Moved 10 questions from EASY → MEDIUM (topic not in primary curriculum)
- Resolved 3 duplicates: 2 removed, 1 merged

Final Counts:
- EASY: 0 (was 10)
- MEDIUM: 21 (was 15)
- HARD: 3 (unchanged)

Classification Accuracy: 100%

Curriculum Coverage:
- EASY: N/A (topic not in primary curriculum)
- MEDIUM: 100%
- HARD: 100%

Tracker updated: Yes
```

**Verify commit was created:**
```bash
# Check commit was created successfully
git log -1 --oneline
```

**IMPORTANT:** Always use `--no-verify` flag to bypass any pre-commit hooks that might block automated commits.

---

### Step 11: Report Completion to Main Agent

**After successful git commit, report completion:**

```markdown
## Task Completion Report

**Chapter:** [EPOCH]/[CHAPTER]
**Status:** ✅ COMPLETED SUCCESSFULLY

### Summary of Actions:

1. **Duplicate Detection:** ✅
   - Found D duplicate sets
   - Resolved: R removed, M merged

2. **Difficulty Analysis:** ✅
   - Analyzed N questions total
   - Identified M misclassified questions

3. **File Updates:** ✅
   - Updated [chapter]_questions_easy.md
   - Updated [chapter]_questions_medium.md
   - Updated [chapter]_questions_hard.md

4. **Tracker Update:** ✅
   - Updated questions-tracker.json
   - Set completion flags as needed

5. **Git Commit:** ✅
   - Commit created: [commit_hash]
   - All changes committed

### Final Statistics:

**Question Counts:**
- EASY: [count] (changed from X)
- MEDIUM: [count] (changed from Y)
- HARD: [count] (changed from Z)

**Quality Metrics:**
- Classification Accuracy: [X]%
- Duplicate Resolution: [D] duplicates handled
- Curriculum Coverage: EASY=[X]%, MEDIUM=[X]%, HARD=[X]%

**Files Modified:** [N] files
**Questions Analyzed:** [N] questions
**Questions Moved:** [N] questions
**Duplicates Resolved:** [N] sets

### Git Commit Details:

```
[commit_hash] Difficulty level corrections: [EPOCH]/[CHAPTER]

[brief summary of changes]
```

### Task Status: COMPLETE ✅

All changes have been automatically applied and committed to git.
The chapter [EPOCH]/[CHAPTER] has been successfully reviewed and corrected.
```

**If any errors occurred:**
```markdown
## Task Completion Report

**Chapter:** [EPOCH]/[CHAPTER]
**Status:** ❌ COMPLETED WITH ERRORS

### Actions Completed:
- [List of successful actions]

### Errors Encountered:
- [Error 1]: [description]
- [Error 2]: [description]

### Recovery Actions:
- [What was done to recover]

### Files Status:
- [File 1]: [status]
- [File 2]: [status]

### Recommendation:
[What should be done next]

### Task Status: PARTIALLY COMPLETE ⚠️
```

**Critical Error Handling:**
- If git commit fails: Report error, keep changes as unstaged
- If file write fails: Rollback all changes, report error
- If tracker update fails: Report but continue (tracker can be updated manually)
- If duplicate detection fails: Continue with difficulty analysis

**ALWAYS report completion status** - never leave the main agent wondering if the task succeeded.

---

## Examples

### Example 1: Correct Classification

**Question:** "Kto był pierwszym królem Polski?"
**Current:** EASY
**Analysis:**
- Type: Factual (KTO)
- Topic: Bolesław Chrobry
- Curriculum check: ✓ Listed in szkola_podstawowa_zpe.md (Dział IV)
**Decision:** KEEP - EASY
**Reason:** Topic is in primary school curriculum. Question is simple factual.

**From master-list.json:**
```json
{
  "epoch": "Piastowie",
  "chapter": "Państwo pierwszych Piastów",
  "tech_name": "panstwo-pierwszych-piastow"
}
```

---

### Example 2: Incorrect Classification - EASY → MEDIUM

**Question:** "Który książę polski poległ w bitwie pod Legnicą 9 kwietnia 1241 roku?"
**Current:** EASY
**Analysis:**
- Type: Factual (KTO)
- Topic: Henryk II Pobożny, bitwa pod Legnicą
- Curriculum check: ✗ NOT in szkola_podstawowa_zpe.md (Dział IV does not include 13th century figures)
- Curriculum check: ✓ IS in liceum_technikum_zpe.md (ZAKRES PODSTAWOWY)
**Decision:** MOVE EASY → MEDIUM
**Reason:** Topic is NOT in primary school curriculum. Simple factual question belongs in MEDIUM when not covered by primary curriculum.

**From master-list.json:**
```json
{
  "epoch": "Piastowie",
  "chapter": "Najazd mongolski",
  "tech_name": "najazd-mongolski"
}
```

**Tracker update:**
```json
{
  "tracking": {
    "Piastowie": {
      "Najazd mongolski": {
        "easy": 0,
        "medium": 22,  // increased from 12
        "hard": 5,
        "easy_completed": true  // because easy = 0
      }
    }
  }
}
```

---

### Example 3: Incorrect Classification - MEDIUM → EASY

**Question:** "W którym roku odbyła się chrystianizacja Polski?"
**Current:** MEDIUM
**Analysis:**
- Type: Factual (KIEDY)
- Topic: Chrystianizacja Polski, 966
- Curriculum check: ✓ Listed in szkola_podstawowa_zpe.md (Dział IV includes key dates)
**Decision:** MOVE MEDIUM → EASY
**Reason:** Topic IS in primary school curriculum. Simple factual question should be in EASY.

---

### Example 4: Correct Classification - HARD

**Question:** "Jakie było długoterminowe znaczenie chrystianizacji dla suwerenności Polski?"
**Current:** HARD
**Analysis:**
- Type: Analytical (requires synthesis/evaluation)
- Topic: Long-term impact of chrystianizacja
- Curriculum check: Extended scope requires evaluation of long-term consequences
**Decision:** KEEP - HARD
**Reason:** Question requires synthesis and evaluation from long-term perspective, which is in extended scope.

---

## Important Notes

1. **AUTOMATIC EXECUTION:** This agent AUTOMATICALLY applies all changes to files. No approval needed.
2. **DUPLICATE DETECTION:** Agent identifies and resolves duplicate questions before difficulty analysis.
3. **MERGING ALLOWED:** Agent can merge similar questions to create optimal version (best of both).
4. **CONTENT IMPROVEMENTS:** Agent may adjust question text, answers, or explanations to improve quality.
5. **Quiz Format:** All questions are quiz format (A/B/C/D answers). Difficulty comes from interpretation required, not answer length.
6. **Curriculum is Key:** Primary school curriculum determines if factual questions can be EASY.
7. **Flexibility:** Question counts are recommendations, not strict limits.
8. **Context Matters:** Consider the chapter summary and historical context.
9. **Git Tracks Changes:** Do not generate detailed report - git diff shows what changed.
10. **Preserve Question Intent:** When merging, keep the core meaning and historical accuracy.

---

## Error Handling

**If curriculum files are missing:**
- Log error but continue with general historical knowledge assessment
- Note in summary: "Curriculum files missing - used general knowledge"

**If question files are missing:**
- Create missing file with appropriate template
- Log warning: "Created missing file: [filename]"

**If unable to determine correct level:**
- Use best judgment based on:
  - Question type (factual vs analytical)
  - General curriculum knowledge
  - Historical context
- Add note in question metadata: `classification_uncertain: true`
- Flag in summary for human review

**If file write fails:**
- Retry once with backup filename
- If still fails, abort and report error
- Do not leave files in partial state

**CRITICAL:** If any error occurs during file modification:
1. Rollback all changes
2. Restore original files from backup
3. Report error with details
4. Do NOT commit partial changes

---

**Version:** 2.3
**Created:** 2026-05-07
**Updated:** 2026-05-07
**Purpose:** Automated difficulty level review and CORRECTION for historical quiz questions
**Mode:** Automatic file modification (changes applied directly to files) + Git commit
**Reference:** `history-data/podstawa/klasyfikacja.md`

**Key Changes from v2.2:**
- Agent now creates git commit automatically when done
- Agent reports completion status back to main agent
- Full task completion report with statistics and git commit details

**Key Changes from v2.1:**
- Agent now detects and resolves duplicate questions
- Merges similar questions to create optimal version
- Removes weaker duplicates, keeps better versions
- Can adjust questions and answers to improve quality

**Key Changes from v2.0:**
- Agent now reads `master-list.json` to get proper chapter names
- Agent updates `questions-tracker.json` with corrected counts and completion flags
- Ensures consistency between question files and tracker

**Key Change from v1.0:** Agent now automatically applies all changes to files instead of just generating a report. Git diff provides change tracking.
