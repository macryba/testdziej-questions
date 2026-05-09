# Incorrect Answers Review System

## Overview

Automated system to review and validate incorrect answers in all Polish history quiz question files. The coordinator launches subagents to process each file, tracks progress for resumability, and generates a single commit at the end.

## Key Principles

- **Single source of truth:** Review report contains all details
- **Statistics counted once:** Coordinator counts from review report, not during processing
- **No duplicate work:** Progress tracking enables resume after interruption
- **One commit:** All changes committed together after all files processed

## Workflow

```
┌─ COORDINATOR START
│  └─ Creates progress.json (no stats field)
│
├─ FOR EACH FILE:
│  ├─ Coordinator: Updates progress.json (current_file = "path/to/file.md")
│  ├─ Coordinator: Launches SUBAGENT
│  │  │
│  │  ├─ Subagent: Reads question file
│  │  ├─ Subagent: Updates question file (adds analysis, reorders, etc.)
│  │  ├─ Subagent: Appends to logs/incorrect-answers-review-report.md
│  │  │               (detailed changes, NO statistics)
│  │  └─ Subagent: Returns completion to coordinator
│  │
│  └─ Coordinator: Marks file as completed (no counting)
│
├─ ALL FILES COMPLETE:
│  ├─ Coordinator: Reads logs/incorrect-answers-review-report.md
│  ├─ Coordinator: Counts all statistics systematically
│  └─ Coordinator: Creates commit with counted stats
│
└─ END: Single source of truth = review report
```

## What Gets Reviewed

For each question in each file:
- ✅ **Missing analysis:** Add "Analiza odpowiedzi błędnych" sections
- ✅ **Categorization:** Categorize incorrect answers (from other chapters, no reference, etc.)
- ✅ **Chronological order:** Reorder date-based answers
- ✅ **Distribution:** Redistribute correct answer positions (A, B, C, D)
- ✅ **Validation:** Check all validation rules from `.claude/validation-rules.md`

## Files

### Created by Coordinator
- **`logs/incorrect-answers-coordinator-progress.json`** - Progress tracking (resume capability)
- **`logs/incorrect-answers-coordinator-summary.md`** - Final summary with statistics
- **Git commit** - Single commit with all changes

### Created by Subagent (per file)
- **Question file** - Updated with corrections
- **`logs/incorrect-answers-review-report.md`** - Detailed changes (appended)

### Reference Files
- **`ai-instructions/incorrect-answers-review-coordinator.md`** - Coordinator instructions
- **`ai-instructions/incorrect-answers-reviewer.md`** - Subagent instructions
- **`ai-instructions/incorrect-answers-reviewer-prompt.md`** - Launch prompt
- **`.claude/validation-rules.md`** - Validation rules

## How to Use

### Launch the Coordinator

Copy the prompt from `ai-instructions/incorrect-answers-reviewer-prompt.md` and paste it into a new Claude Code session.

### Monitor Progress

```bash
# View progress log
cat logs/incorrect-answers-coordinator-progress.json | jq

# View completed files count
cat logs/incorrect-answers-coordinator-progress.json | jq '.completed_files'

# View completed files list
cat logs/incorrect-answers-coordinator-progress.json | jq '.completed'

# View failed files
cat logs/incorrect-answers-coordinator-progress.json | jq '.failed'

# View review report (for interim details)
tail -n 100 logs/incorrect-answers-review-report.md
```

### Resume After Interruption

If the coordinator stops (Ctrl+C, error, crash):
1. Just use the same prompt again
2. Coordinator reads `logs/incorrect-answers-coordinator-progress.json`
3. Continues from last completed file
4. No duplicate work

### Final Output

When all files complete:
- **`logs/incorrect-answers-coordinator-summary.md`** - Complete statistics
- **Git commit** - All changes with descriptive message
- Statistics broken down by epoch/chapter

## Statistics (Counted at End)

Coordinator counts these from the review report:
- Total questions reviewed
- Questions with missing analysis added
- Questions with answers reordered
- Questions with positions adjusted
- Total incorrect answers analyzed
- Incorrect answers from other chapters
- Incorrect answers with no reference
- Critical issues found

## Error Handling

- **Retry logic:** 3 attempts per failed file
- **Failed files:** Logged with error messages
- **Continues processing:** Doesn't stop on individual file failures
- **Manual review:** Failed files listed in final summary

## Example Review Report Structure

```markdown
# Incorrect Answers Review Report

## Piastowie - Chrystianizacja

**File Reviewed:** history-data/02-piastowie/01-chrystianizacja/chrystianizacja_questions_easy.md
**Date:** 2026-05-09T10:30:00Z

## Detailed Analysis Table

| Pytanie | Odpowiedź | Analiza |
|---------|-----------|---------|
| **Kto był pierwszym koronowanym królem Polski?** | **Bolesław Chrobry** | CORRECT ANSWER |
| | **Mieszko I** | correct for: Chrystianizacja ( był księciem, nie królem) |
| | **Władysław Łokietek** | incorrect from: Łokietek (inna epoka) |
| | **Kazimierz Wielki** | incorrect from: Kazimierz Wielki (inna epoka) |

## Changes Made

### Missing Analysis Added
Questions that received "Analiza odpowiedzi błędnych" sections:
- Question 1: Kto był pierwszym koronowanym królem Polski?
- Question 3: W którym roku odbyła się koronacja Chrobrego?

### Answer Reordering
Questions with answers reordered chronologically:
- Question 3: 960 → 992 → 1000 → 1025 (years)

### Correct Answer Redistribution
Questions with corrected answer positions adjusted:
- Question 7: original position B → new position D

---
```

## Validation Rules

See `.claude/validation-rules.md` for complete rules:
- Answer length variance (within 20%)
- Date presence rules
- No opposites (zyskała/utraciła)
- Historical accuracy
- Time period checks

## Quick Reference

**Start:** Copy prompt from `ai-instructions/incorrect-answers-reviewer-prompt.md`
**Stop:** Ctrl+C (progress saved)
**Resume:** Use same prompt again
**Check:** `cat logs/incorrect-answers-coordinator-progress.json | jq`
**Report:** `cat logs/incorrect-answers-review-report.md`
**Summary:** `cat logs/incorrect-answers-coordinator-summary.md` (after completion)
