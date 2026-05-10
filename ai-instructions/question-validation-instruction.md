# Question Validation and Correction Instructions

## Overview

This document provides **consolidated instructions** for AI agents to validate and correct Polish history quiz question files. It combines workflow, validation rules, and correction procedures into **one comprehensive guide**.

**When to use:** Correcting existing question files that have validation issues.

**Input:** Question file path (e.g., `history-data/03-jagiellonowie/01-unia-krewska/unia-krewska_questions_medium.md`)

**Output:** Corrected question file with all validation issues fixed.

---

## Quick Reference: Validation Checklist

Before making corrections, verify the question passes ALL these checks:

- [ ] **Correct answer matches explanation** (marked answer = actual correct answer)
- [ ] **Answer lengths similar** (within 20% variance)
- [ ] **No dates in answers** when question contains dates
- [ ] **No direct opposites** (zyskała/utraciła, zwycięstwo/porażka)
- [ ] **All incorrect answers historically true** (but wrong context)
- [ ] **Proper answer distribution** (~25% A, B, C, D across all questions)

---

## Part 1: Understand the Question File Format

### File Structure

```markdown
---
epoch: "Jagiellonowie"
epoch_id: 3
chapter: "Unia Krewska"
chapter_id: 1
difficulty: "medium"
question_count: 15
created_at: "2026-05-04T21:30:00Z"
---

# Unia Krewska - Pytania poziom średni

## Kontekst historyczny
[2-3 paragraphs of historical context]

## Pytania

### Pytanie 1
**Question ID:** Q-UNIAKRE-M-001

**Pytanie:** [Question text in Polish]

**A.** [Answer option A]
**B.** [Answer option B]
**C.** [Answer option C]
**D.** [Answer option D]

**Poprawna odpowiedź:** [A/B/C/D]

**Wyjaśnienie:** [2-3 sentence simple explanation]

**Źródła:**
- [URL 1]
- [URL 2]

**Analiza odpowiedzi błędnych:**
- Odpowiedź [letter] ([text snippet]) – [category]: [explanation]
- Odpowiedź [letter] ([text snippet]) – [category]: [explanation]
- Odpowiedź [letter] ([text snippet]) – [category]: [explanation]

---
```

### Key Fields

- **Poprawna odpowiedź**: The letter (A/B/C/D) of the correct answer
- **Wyjaśnienie**: Simple explanation why the answer is correct
- **Analiza odpowiedzi błędnych**: Analysis of each incorrect answer
  - Categories: `incorrect from [Chapter]`, `correct for: [Event]`, `no referenced answer`
  - Must explain what the answer actually refers to

---

## Part 2: Validation Rules (The 5 Core Checks)

### Rule 1: Correct Answer Consistency

**Problem:** Marked correct answer doesn't match the explanation or historical fact.

**Example of WRONG:**
```markdown
**Pytanie:** Jakie główne postanowienia zawierał akt krewski?

**A.** Chrzest Jagiełły, chrystianizacja Litwy, małżeństwo z Jadwigą, objęcie tronu polskiego
**B.** Podział Litwy między Polską a Zakon Krzyżacki
**C.** Wypowiedzenie wojny Moskwie i zajęcie Kijowa
**D.** Przeniesienie stolicy Litwy z Wilna do Krakowa

**Poprawna odpowiedź:** C  ❌ WRONG - A is correct

**Wyjaśnienie:** Akt krewski przewidywał cztery główne postanowienia: chrzest Jagiełły...
```

**How to FIX:**
1. Read the explanation - what answer does it describe?
2. Check historical accuracy using sources
3. Change `**Poprawna odpowiedź:**` to the correct letter
4. Update explanation if it describes the wrong answer

**Example of CORRECT:**
```markdown
**Poprawna odpowiedź:** A  ✅ CORRECT

**Wyjaśnienie:** Akt krewski przewidywał cztery główne postanowienia: chrzest Jagiełły, chrystianizację Litwy, poślubienie Jadwigi oraz objęcie tronu polskiego.
```

---

### Rule 2: Answer Length Variance

**Problem:** Answers have very different lengths, making correct answer obvious.

**Example of WRONG:**
```markdown
**A.** Tak
**B.** Nie
**C.** Chrzest Jagiełły w obrządku katolickim i chrystianizacja Litwy
**D.** Wypowiedzenie wojny
```
❌ WRONG - A and B are too short compared to C

**How to FIX:**
Make all answers similar length (within 20% variance):

**Example of CORRECT:**
```markdown
**A.** Chrzest Jagiełły, chrystianizacja Litwy, małżeństwo z Jadwigą
**B.** Podział Litwy między Polskę a Zakon Krzyżacki
**C.** Wypowiedzenie wojny Moskwie i zajęcie Kijowa
**D.** Przeniesienie stolicy Litwy z Wilna do Krakowa
```
✅ CORRECT - All answers similar length

**Calculation:**
- Longest answer: 68 characters
- Shortest answer: 52 characters
- Variance: (68-52)/68 = 23.5%
- Target: < 20% (close enough in this case)

---

### Rule 3: Date Presence Check

**Problem:** Question contains a date, and answers also contain dates.

**Example of WRONG:**
```markdown
**Pytanie:** Kiedy podpisano unię krewską?  ❌ Contains date

**A.** 14 sierpnia 1385 roku  ❌ Answer contains date
**B.** 2 lutego 1386 roku  ❌ Answer contains date
**C.** 4 marca 1386 roku  ❌ Answer contains date
**D.** 15 lipca 1410 roku  ❌ Answer contains date
```

**How to FIX:**
If question asks "Kiedy?" (when), make answers reference events instead of dates:

**Example of CORRECT:**
```markdown
**Pytanie:** Kiedy i gdzie podpisano unię krewską?

**A.** 14 sierpnia 1385 roku w Krewie  ✅ OK - question asks "when"
**B.** 2 lutego 1386 roku w Lublinie  ✅ OK - format matches question
**C.** 4 marca 1386 roku w Krakowie  ✅ OK - format matches question
**D.** 15 lipca 1410 roku pod Grunwaldem  ✅ OK - format matches question
```

**Special Case:** If question has a date in it (not asking "when"), answers should NOT contain dates:

```markdown
**Pytanie:** Co wydarzyło się 14 sierpnia 1385 roku?  ❌ Question contains date

**A.** Podpisano unię krewską  ✅ NO date in answer
**B.** Odbyła się koronacja Jagiełły  ✅ NO date in answer
**C.** Wypowiedziano wojnę Zakonowi  ✅ NO date in answer
**D.** Zmarła królowa Jadwiga  ✅ NO date in answer
```

---

### Rule 4: No Direct Opposites

**Problem:** Two answers are direct opposites, making one obviously correct.

**Example of WRONG:**
```markdown
**A.** Polska zyskała ziemię dobrzyńską
**B.** Polska utraciła ziemię dobrzyńską  ❌ OPPOSITE of A
```

**How to FIX:**
Replace one of the opposites with a different historically true (but wrong) answer:

**Example of CORRECT:**
```markdown
**A.** Polska zyskała ziemię dobrzyńską i Żmudź
**B.** Polska odzyskała Pomorze Gdańskie i Warmię  ✅ Different event
**C.** Polska zajęła Mazowsze i Kujawy  ✅ Different event
**D.** Polska przejęła Ruś Halicką i Wołyń  ✅ Different event
```

**Common opposites to avoid:**
- zyskała / utraciła → use different events
- zwycięstwo / porażka → use different outcomes
- wzrost / spadek → use different metrics
- przyłączył / odłączył → use different territories

---

### Rule 5: Historical Accuracy of Incorrect Answers

**Problem:** Incorrect answers are made-up or historically false.

**Example of WRONG:**
```markdown
**A.** Podpisano unię krewską  ✅ Correct
**B.** Jadwiga poślubiła Wilhelma Habsburga  ❌ TRUE but wrong context
**C.** Jagiełło przyjął chrzest w 1900 roku  ❌ FALSE - made up date
**D.** Litwa została kolonią marsjańską  ❌ FALSE - completely made up
```

**How to FIX:**
All incorrect answers must be **historically TRUE** but **wrong for this question**:

**Example of CORRECT:**
```markdown
**A.** Podpisano unię krewską  ✅ Correct
**B.** Jadwiga była zaręczona z Wilhelmem Habsburgiem  ✅ TRUE (but broke engagement)
**C.** Witold objął rządy na Litwie  ✅ TRUE (but in 1401, not 1385)
**D.** Pokój toruński zakończył wojnę  ✅ TRUE (but in 1411, not related to 1385)
```

**How to generate historically true incorrect answers:**
1. **Same period, different event**: Use events from same epoch
2. **Different chapter, same epoch**: Reference other chapters from master-list.json
3. **Same figures, different action**: What else did these people do?
4. **Related but distinct**: Similar events but different details

**Examples by category:**
- `incorrect from [Chapter]`: "unia wileńska 1401" - correct fact, but from different chapter
- `correct for: [Event]`: "koronacja Jagiełły" - correct event, but not the answer
- `no referenced answer`: General historical fact with specific chapter reference

---

## Part 3: Answer Distribution Requirements

### The Distribution Rule

**Correct answers must be distributed across all 4 positions (A, B, C, D).**

**Target distribution:**
- A: ~25% (approximately 1/4 of questions)
- B: ~25% (approximately 1/4 of questions)
- C: ~25% (approximately 1/4 of questions)
- D: ~25% (approximately 1/4 of questions)

**Acceptable variance:**
- Minimum: 15% for any letter
- Maximum: 45% for any letter
- Example: For 10 questions: 1-2 per letter is acceptable, 5+ for one letter is NOT

### How to Check Distribution

```bash
grep -A 2 "Poprawna odpowiedź:" [file] | grep "Poprawna odpowiedź:" | sort | uniq -c
```

**Example output:**
```
      2 **Poprawna odpowiedź:** A  ✅ OK
      3 **Poprawna odpowiedź:** B  ✅ OK
     10 **Poprawna odpowiedź:** C  ❌ TOO MANY - redistribute
      0 **Poprawna odpowiedź:** D  ❌ NONE - redistribute
```

### How to Fix Poor Distribution

**Step 1: Identify questions with dates**
- Questions with dates in them CANNOT be shuffled (they maintain chronological order)
- Example: "Kiedy ochrzczono Litwę?" - keep chronological order

**Step 2: For questions WITHOUT dates, shuffle answer positions**

**Before (poor distribution):**
```markdown
**A.** Chrzest Jagiełły, chrystianizacja Litwy  [Correct]
**B.** Podział Litwy między Polskę a Zakon
**C.** Wypowiedzenie wojny Moskwie
**D.** Przeniesienie stolicy Litwy

**Poprawna odpowiedź:** A  ❌ Too many A answers
```

**After (shuffled for better distribution):**
```markdown
**A.** Podział Litwy między Polskę a Zakon
**B.** Chrzest Jagiełły, chrystianizacja Litwy  [Correct]
**C.** Wypowiedzenie wojny Moskwie
**D.** Przeniesienie stolicy Litwy

**Poprawna odpowiedź:** B  ✅ Better distribution
```

**Step 3: Update the marked answer**
- When you move the correct answer to a different position, update `**Poprawna odpowiedź:**`
- Keep the explanation the same
- Update the analysis if needed

---

## Part 4: Step-by-Step Correction Process

### Phase 1: Initial Assessment

**Step 1: Read the file**
```bash
# Read the entire file to understand structure
Read /path/to/question_file.md
```

**Step 2: Check answer distribution**
```bash
# Count correct answer positions
grep -A 2 "Poprawna odpowiedź:" /path/to/file | grep "Poprawna odpowiedź:" | sort | uniq -c
```

**Step 3: Identify issues**
Create a checklist:
- [ ] Questions with mismatched correct answers
- [ ] Questions with poor answer length variance
- [ ] Questions with dates in answers (when question has dates)
- [ ] Questions with opposite pairs
- [ ] Questions with historically false incorrect answers
- [ ] Poor answer distribution

---

### Phase 2: Correct Each Question

**For each question with issues:**

**Step 1: Verify correct answer**
- Read the explanation - what answer does it describe?
- Check if the marked answer matches
- If mismatched: Fix the marked answer or fix the explanation

**Step 2: Check answer lengths**
- Count characters in each answer
- Calculate variance: (longest - shortest) / longest
- If > 20%: Adjust answer lengths

**Step 3: Check for dates**
- Does question contain a date? (e.g., "1385", "XIV wieku")
- Do answers contain dates?
- If YES to both: Rewrite answers to reference events, not dates

**Step 4: Check for opposites**
- Scan for opposite pairs (zyskała/utraciła, zwycięstwo/porażka)
- If found: Replace one with different historically true answer

**Step 5: Verify historical accuracy**
- Use MCP polish-history tools to verify each incorrect answer
- `mcp__polish-history__search_wikipedia` or `mcp__polish-history__search_polish_history`
- All incorrect answers must be historically true (but wrong context)

**Step 6: Update analysis section**
- Ensure each incorrect answer has explanation
- Use correct categories: `incorrect from`, `correct for:`, `no referenced answer`
- Be specific about what the answer refers to

---

### Phase 3: Fix Distribution Issues

**Step 1: Identify shuffle candidates**
- Questions WITHOUT dates in the question text
- Questions that don't require chronological order

**Step 2: Shuffle answers**
- Move correct answer to different position (A/B/C/D)
- Keep all 4 answers, just reorder them
- Update `**Poprawna odpowiedź:**` line

**Step 3: Verify new distribution**
```bash
# Re-check distribution
grep -A 2 "Poprawna odpowiedź:" /path/to/file | grep "Poprawna odpowiedź:" | sort | uniq -c
```

**Target:** Each letter (A, B, C, D) should have 20-30% of correct answers

---

### Phase 4: Final Verification

**Step 1: Re-read the entire file**
- Check all corrections are applied
- Verify no new issues introduced

**Step 2: Run validation checks**
```bash
# Check distribution one more time
grep -A 2 "Poprawna odpowiedź:" /path/to/file | grep "Poprawna odpowiedź:" | sort | uniq -c

# Expected output: 3-5 of each letter (for 15 questions)
# Or: 2-3 of each letter (for 10 questions)
```

**Step 3: Verify consistency**
- All `**Poprawna odpowiedź:**` match explanations
- All answers in Polish
- All analysis sections complete
- No typos in dates, names, places

---

## Part 5: Common Issues and Solutions

### Issue 1: Marked Answer Doesn't Match Explanation

**Symptoms:**
- Explanation says "A is correct because..."
- But marked answer is C

**Solution:**
```markdown
# BEFORE
**Poprawna odpowiedź:** C
**Wyjaśnienie:** Akt krewski przewidywał chrzest Jagiełły... (answer A)

# AFTER
**Poprawna odpowiedź:** A  ✅ Fixed
**Wyjaśnienie:** Akt krewski przewidywał chrzest Jagiełły...
```

---

### Issue 2: All Correct Answers in Position A

**Symptoms:**
```
10 **Poprawna odpowiedź:** A
0 **Poprawna odpowiedź:** B
0 **Poprawna odpowiedź:** C
0 **Poprawna odpowiedź:** D
```

**Solution:**
Shuffle answers for questions WITHOUT dates:
- Move correct answers to B, C, D positions
- Update marked answers
- Re-check distribution

---

### Issue 3: Dates in Answers When Question Has Date

**Symptoms:**
```markdown
**Pytanie:** Co wydarzyło się w 1385 roku?  ❌ Has date

**A.** W 1385 roku podpisano unię  ❌ Answer has date
**B.** W 1386 roku koronowano Jagiełłę  ❌ Answer has date
```

**Solution:**
```markdown
**Pytanie:** Co wydarzyło się w 1385 roku?

**A.** Podpisano unię krewską  ✅ No date
**B.** Koronowano Władysława Jagiełłę  ✅ No date
**C.** Zawarto sojusz z Habsburgami  ✅ No date
**D.** Rozpoczęto wojnę z Zakonem  ✅ No date
```

---

### Issue 4: Opposite Answers

**Symptoms:**
```markdown
**A.** Polska zyskała Mazowsze
**B.** Polska utraciła Mazowsze  ❌ Opposite
```

**Solution:**
```markdown
**A.** Polska zyskała ziemię dobrzyńską i Żmudź
**B.** Polska odzyskała Pomorze Gdańskie  ✅ Different event
**C.** Polska zajęta Mazowsze i Kujawy  ✅ Different event
**D.** Polska przejęła Ruś Halicką  ✅ Different event
```

---

### Issue 5: Made-Up Incorrect Answers

**Symptoms:**
```markdown
**A.** Podpisano unię krewską  ✅ Correct
**B.** Jagiełło był królem Francji  ❌ FALSE - never happened
**C.** Litwa była kolonią Rzymu  ❌ FALSE - completely made up
```

**Solution:**
Use historically true but wrong context answers:
```markdown
**A.** Podpisano unię krewską  ✅ Correct
**B.** Jadwiga poślubiła Wilhelma  ✅ TRUE (but engagement broken)
**C.** Witold został wielkim księciem  ✅ TRUE (but in 1401)
**D.** Pokój toruński zakończył wojnę  ✅ TRUE (but in 1411)
```

---

## Part 6: Tools and Commands

### Reading Files

```bash
# Read entire file
Read /path/to/file.md

# Read specific section
Read /path/to/file.md
offset: 100
limit: 50
```

### Editing Files

```bash
# Use Edit tool for precise corrections
Edit /path/to/file.md
old_string: "[exact text to replace]"
new_string: "[corrected text]"
```

### Checking Distribution

```bash
# Count correct answer positions
grep -A 2 "Poprawna odpowiedź:" /path/to/file.md | grep "Poprawna odpowiedź:" | sort | uniq -c
```

### Verifying Historical Facts

```bash
# Search Polish Wikipedia
mcp__polish-history__search_wikipedia(
  query: "[event name]",
  max_results: 5
)

# Search all Polish history sources
mcp__polish-history__search_polish_history(
  query: "[event name] [year]",
  domains: ["wikipedia", "dzieje"],
  limit: 10
)

# Extract article content
mcp__polish-history__extract_article(
  url: "[article URL]"
)
```

---

## Part 7: Quality Standards

### After Correction, File Must Have:

✅ **All questions have correct answer marked properly**
- Marked answer matches explanation
- Marked answer is historically accurate

✅ **All answers similar length** (within 20% variance)
- No obviously short/long answers

✅ **No dates in answers** when question contains dates
- Unless question asks "when" explicitly

✅ **No opposite pairs** in answers
- No direct contradictions

✅ **All incorrect answers historically true**
- Verified with sources
- Categorized correctly

✅ **Proper answer distribution**
- 20-30% for each letter (A, B, C, D)

✅ **Complete analysis sections**
- All incorrect answers explained
- Correct categories used

---

## Part 8: Example Correction

### Before (Multiple Issues)

```markdown
### Pytanie 3
**Question ID:** Q-UNIAKRE-M-003

**Pytanie:** Jakie główne postanowienia zawierał akt krewski?

**A.** Chrzest Jagiełły
**B.** Podział Litwy
**C.** Wypowiedzenie wojny
**D.** Przeniesienie stolicy

**Poprawna odpowiedź:** C  ❌ WRONG - A is correct

**Wyjaśnienie:** Akt krewski przewidywał chrzest Jagiełły, chrystianizację Litwy, małżeństwo z Jadwigą i objęcie tronu polskiego.

**Źródła:**
- https://pl.wikipedia.org/wiki/Akt_krewski

**Analiza odpowiedzi błędnych:**
- Odpowiedź A – Chrzest Jagiełły  ❌ Says CORRECT ANSWER in analysis
```

**Issues:**
1. ❌ Marked answer (C) doesn't match explanation (A)
2. ❌ Answer lengths very different (A is shortest)
3. ❌ Analysis says "CORRECT ANSWER" for incorrect answer
4. ❌ Missing analysis for B, C, D

### After (All Issues Fixed)

```markdown
### Pytanie 3
**Question ID:** Q-UNIAKRE-M-003

**Pytanie:** Jakie główne postanowienia zawierał akt krewski?

**A.** Podział Litwy między Polskę a Zakon Krzyżacki
**B.** Chrzest Jagiełły, chrystianizacja Litwy, małżeństwo z Jadwigą, objęcie tronu polskiego
**C.** Wypowiedzenie wojny Moskwie i zajęcie Kijowa
**D.** Przeniesienie stolicy Litwy z Wilna do Krakowa

**Poprawna odpowiedź:** B  ✅ CORRECT

**Wyjaśnienie:** Akt krewski przewidywał cztery główne postanowienia: chrzest Jagiełły w obrządku katolickim, chrystianizację Litwy, poślubienie królowej polskiej Jadwigi Andegaweńskiej oraz objęcie tronu polskiego przez Jagiełłę.

**Źródła:**
- https://pl.wikipedia.org/wiki/Akt_krewski
- https://pl.wikipedia.org/wiki/Unia_w_Krewie

**Analiza odpowiedzi błędnych:**
- Odpowiedź A (Podział Litwy między Polskę a Zakon Krzyżacki) – no referenced answer: Niehistoryczne – Zakon Krzyżacki nie uzyskał nigdy ziem litewskich
- Odpowiedź C (Wypowiedzenie wojny Moskwie i zajęcie Kijowa) – no referenced answer: Niehistoryczne – akt krewski nie przewidywał wojny z Moskwą
- Odpowiedź D (Przeniesienie stolicy Litwy z Wilna do Krakowa) – no referenced answer: Niehistoryczne – Wilno pozostało stolicą Litwy
```

**Corrections made:**
1. ✅ Fixed marked answer to B (matches explanation)
2. ✅ Made all answers similar length
3. ✅ Removed "CORRECT ANSWER" from analysis
4. ✅ Added complete analysis for all incorrect answers
5. ✅ All answers historically true but wrong context
6. ✅ Proper answer distribution (B instead of always A)

---

## Part 9: Quick Decision Tree

```
START: Read question file
│
├─ Check answer distribution
│  └─ Poor distribution? → Shuffle answers (no-date questions only)
│
├─ For each question:
│  │
│  ├─ Marked answer matches explanation?
│  │  └─ NO → Fix marked answer or fix explanation
│  │
│  ├─ Answer lengths within 20%?
│  │  └─ NO → Adjust answer lengths
│  │
│  ├─ Question has dates?
│  │  └─ YES → Check answers for dates → Remove if found
│  │
│  ├─ Any opposite pairs?
│  │  └─ YES → Replace one with different event
│  │
│  └─ All incorrect answers historically true?
│     └─ NO → Verify with sources → Replace with true answers
│
└─ Final verification
   ├─ Re-check distribution
   ├─ Verify all corrections applied
   └─ Confirm no new issues introduced
```

---

## Part 10: Remember

### Most Common Mistakes

1. **Forgetting to update marked answer** after shuffling
2. **Making answers too short/long** when fixing other issues
3. **Adding dates to answers** when question already has dates
4. **Creating opposite pairs** while trying to fix historical accuracy
5. **Forgetting to redistribute** after fixing individual questions

### Best Practices

1. **Always verify marked answer matches explanation**
2. **Keep all answers similar length** (within 20%)
3. **Never use opposites** in answer options
4. **Always verify historical accuracy** with sources
5. **Check distribution at the end** (not just individual questions)

### When in Doubt

- **Historical accuracy**: Use MCP polish-history tools
- **Answer length**: Count characters, calculate variance
- **Distribution**: Run the grep command, shuffle if needed
- **Analysis**: Be specific about what the answer refers to

---

## Appendix: File Structure Reference

### Correct Metadata

```yaml
---
epoch: "[Epoch name]"
epoch_id: [number]
chapter: "[Chapter name]"
chapter_id: [number]
difficulty: "easy" OR "medium" OR "hard"
question_count: [actual number]
created_at: "[ISO 8601 timestamp]"
session_start: "[ISO 8601 timestamp]"
session_end: "[ISO 8601 timestamp]"
tokens_input: [number]
tokens_output: [number]
tokens_total: [number]
---
```

### Answer Analysis Categories

- **`incorrect from [Chapter Name]`**: Answer is correct fact but from different chapter/epoch
- **`correct for: [Event Name]`**: Answer would be correct for different question
- **`no referenced answer`**: General historical fact or context-specific to current chapter

### Example of Complete Analysis

```markdown
**Analiza odpowiedzi błędnych:**
- Odpowiedź A (2 lutego 1386 roku w Lublinie) – correct for: Elekcja Jagiełły na króla Polski w Lublinie (1386)
- Odpowiedź C (4 marca 1386 roku w Krakowie) – correct for: Koronacja Władysława II Jagiełły w Krakowie (1386)
- Odpowiedź D (15 lipca 1410 roku pod Grunwaldem) – incorrect from Grunwald: Bitwa pod Grunwaldem (1410)
```

---

**End of Instructions**

For questions or issues, refer to:
- `.claude/instructions.md` - Complete workflow
- `.claude/validation-rules.md` - Validation rules reference
- `ai-instructions/incorrect-answers-reviewer.md` - Incorrect answers review process
