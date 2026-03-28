# Consolidated Question File Format

## File Naming
- Format: `[epoch]-[chapter]-[difficulty].md`
- Example: `starozytnosc-pradzieje-easy.md`
- Contains: All 10 questions for that epoch-chapter-difficulty combination

## Structure

```markdown
Metadata
epoch: "[EPOCH NAME]"
epoch_id: [NUMBER]
chapter: "[CHAPTER NAME]"
chapter_id: [NUMBER]
difficulty: "[easy|medium|hard]"
question_count: 10
created_at: "[ISO TIMESTAMP]"
tokens_input: [ESTIMATE]
tokens_output: [ESTIMATE]
tokens_total: [SUM]
session_start: "[ISO TIMESTAMP]"
session_end: "[ISO TIMESTAMP]"

Summary: [EPOCH] - [CHAPTER] ([DIFFICULTY])
Historical Context

[2-3 paragraphs of historical context in Polish - SHARED for all questions]

Key Events

Section 1: [Topic 1]
[Content about topic 1]

Section 2: [Topic 2]
[Content about topic 2]

Section 3: [Topic 3]
[Content about topic 3]

================================================================================

## Question 1

Question
Question ID: Q-XXX-001
Question Type: multiple_choice
Difficulty: [easy|medium|hard]

Question Text
[Question in Polish]

Answer Options
A) [Option A]
B) [Option B]
C) [Option C]
D) [Option D]

Correct Answer
Answer: [A|B|C|D]

Explanation
[Simple explanation, max 2 sentences, easy to understand]

Validation Status
✓ Historical accuracy verified
✓ Incorrect answers are historically true but wrong context
✓ All answers have similar length
✓ No obvious opposites used
✓ Date rules followed

Sources
- [Source 1]
- [Source 2]

Incorrect Answers Analysis

Option [A/B/C/D]
Content: "[Content]"
Why it's incorrect: "[Reason]"
Verification: "[Historical verification]"

[... repeat for each option ...]

## Question 2
[... same format for all 10 questions ...]

## Question 10
[... last question ...]
```

## Key Points

1. **One file per chapter-difficulty**: Contains all 10 questions
2. **Shared historical context**: At the top of the file
3. **Separator**: `================================================================================` before first question
4. **Question headers**: `## Question N` for each question
5. **Metadata**: Includes `question_count: 10`
6. **File location**: `questions/validated/[epoch]-[chapter]-[difficulty].md`
