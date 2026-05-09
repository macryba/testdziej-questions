# Incorrect Answers Review Coordinator - Full Instructions

## Overview

You are a **Coordinator Agent** responsible for managing the incorrect answers review process across all question files. Your job is to:
1. Find all question files in the history-data directory
2. Launch subagents sequentially to review each file
3. Track progress in a log file (resume capability)
4. Create a single git commit after all files are processed
5. Generate a final summary report

## Your Mission

Autonomously process ALL question files by launching Incorrect Answers Reviewer subagents sequentially.

### Step 1: Initialize

**Read progress log:**
```bash
# Check if progress log exists
cat logs/incorrect-answers-coordinator-progress.json 2>/dev/null || echo "{}"
```

**Find all question files:**
```bash
find history-data/ -name "*_questions_*.md" -type f | sort
```

**Create progress tracking structure:**
```json
{
  "started_at": "ISO timestamp",
  "last_updated": "ISO timestamp",
  "total_files": 0,
  "completed_files": 0,
  "failed_files": 0,
  "skipped_files": 0,
  "current_file": null,
  "completed": [],
  "failed": [],
  "skipped": []
}
```

### Step 2: Process Files Sequentially

**For each question file:**

1. **Check if already completed:**
   - Read progress log
   - Skip if file path is in `completed` array
   - Skip if in `failed` array with 3+ retry attempts

2. **Update current status:**
   - Set `current_file` to file path
   - Update `last_updated` timestamp

3. **Save progress checkpoint** (before launching subagent):
   ```bash
   # Write to logs/incorrect-answers-coordinator-progress.json
   ```

4. **Launch subagent:**
   - Use Agent tool with subagent type
   - Provide file path as input
   - Follow instructions in `ai-instructions/incorrect-answers-reviewer.md`

5. **Wait for completion:**
   - Monitor subagent output
   - Capture summary report
   - Check for errors

6. **Process results:**
   - Verify subagent completed successfully
   - Check that the file was updated (git diff shows changes)
   - Verify the review report was created/updated

7. **Update progress:**
   - Add file to `completed` array (success) or `failed` array (with error)
   - Clear `current_file`
   - Save progress log

### Step 3: Error Handling

**If subagent fails:**
- Log error with timestamp and error message
- Increment retry count for that file
- If retry count < 3: retry the same file
- If retry count >= 3: mark as permanently failed, skip to next file
- Always save progress log after error

**Error logging format:**
```json
"failed": [
  {
    "file": "path/to/file.md",
    "error": "error message",
    "timestamp": "ISO timestamp",
    "retries": 3
  }
]
```

### Step 4: Count Statistics (After All Files Complete)

**Read the review report and count all statistics:**

```bash
# Read the full review report
cat logs/incorrect-answers-review-report.md
```

**Count the following:**
1. **Total files processed:** Count of completed files in progress log
2. **Total questions reviewed:** Count all question entries in the report
3. **Questions with missing analysis added:** Count "Missing Analysis Added" sections
4. **Questions with answers reordered:** Count "Answer Reordering" entries
5. **Questions with positions adjusted:** Count "Correct Answer Redistribution" entries
6. **Total incorrect answers analyzed:** Count all incorrect answer explanations
7. **Incorrect answers from other chapters:** Count "incorrect from" entries
8. **Incorrect answers with no reference:** Count "no referenced answer" entries
9. **Critical issues found:** Count "Critical Issues" entries

**Parse the report systematically:**
- Use grep or manual counting to extract counts
- Group by epoch/chapter for breakdown statistics
- Verify counts match the number of questions (10 per file)

### Step 5: Create Git Commit (After All Files)

**IMPORTANT:** Only create commit AFTER all files are processed successfully.

**Do NOT create commits during processing** - wait until all subagents complete.

**Commit process:**
```bash
# Stage all modified question files
git add history-data/**/*_questions_*.md

# Stage the review report
git add logs/incorrect-answers-review-report.md

# Stage the progress log
git add logs/incorrect-answers-coordinator-progress.json

# Create commit with counted statistics
git commit -m "Review incorrect answers across all question files

- Files processed: [count]
- Questions reviewed: [count]
- Incorrect answers analyzed: [count]
- Answers from other chapters: [count]
- Answers with no reference: [count]
- Questions with missing analysis added: [count]
- Questions with answers reordered: [count]
- Questions with positions adjusted: [count]
- Critical issues found: [count]"
```

### Step 6: Generate Final Summary

**Create `logs/incorrect-answers-coordinator-summary.md`:**

```markdown
# Incorrect Answers Review Coordinator - Final Summary

**Execution Period:** [start] to [end]
**Total Duration:** [time]

## Overall Statistics

- **Total files found:** [count]
- **Files successfully processed:** [count]
- **Files failed:** [count]
- **Success rate:** [percentage]%

## Question Statistics (Counted from Review Report)

- **Total questions reviewed:** [count]
- **Total incorrect answers analyzed:** [count]
- **Incorrect answers from other chapters:** [count]
- **Incorrect answers with no reference:** [count]

## Changes Made (Counted from Review Report)

- **Questions with missing analysis added:** [count]
- **Questions with answers reordered:** [count]
- **Questions with positions adjusted:** [count]
- **Total corrections made:** [count]

## Breakdown by Epoch

| Epoch | Files | Questions | Incorrect Answers | Analysis Added | Reordered | Adjusted |
|-------|-------|-----------|-------------------|----------------|-----------|----------|
| [Epoch 1] | [n] | [n] | [n] | [n] | [n] | [n] |
| [Epoch 2] | [n] | [n] | [n] | [n] | [n] | [n] |

## Files Processed

### Successfully Completed ([count])
- [List of files]

### Failed (Requires Manual Review) ([count])
- [List of files with error messages]

## Git Commit

**Commit hash:** [hash]

## Recommendations

- [Any recommendations for manual review of failed files]
- [Any recommendations for improving the review process]

## Log Files

- Progress tracking: `logs/incorrect-answers-coordinator-progress.json`
- Detailed review reports: `logs/incorrect-answers-review-report.md`
```

## Resume Capability

**If coordinator is interrupted:**

1. Read `logs/incorrect-answers-coordinator-progress.json`
2. Find `last_updated` timestamp and `current_file`
3. If `current_file` is not null: that file may be in progress, check if modified
4. Skip all files in `completed` array
5. Retry files in `failed` array (if retry count < 3)
6. Continue with next unprocessed file

**Resume logic:**
```python
# Pseudocode
progress = load_progress_log()
completed_files = set(progress['completed'])
failed_files = {f['file']: f for f in progress['failed']}

all_files = find_all_question_files()

for file in all_files:
    if file in completed_files:
        continue  # Skip completed

    if file in failed_files:
        if failed_files[file]['retries'] >= 3:
            continue  # Skip permanently failed
        # Retry this file

    process_file(file)
```

## Progress Tracking

**Update progress log after EACH file** (not just at end):

**Before launching subagent:**
```json
{
  "current_file": "path/to/file.md",
  "last_updated": "2026-05-09T10:30:00Z"
}
```

**After subagent completes:**
```json
{
  "current_file": null,
  "last_updated": "2026-05-09T10:35:00Z",
  "completed_files": 15,
  "completed": ["path/to/file.md", ...]
}
```

**This ensures:**
- Progress is not lost if coordinator crashes
- Can resume from last completed file
- No duplicate work on interrupted files

## Subagent Communication

**When launching subagent:**
- Provide clear file path
- Reference `ai-instructions/incorrect-answers-reviewer.md`
- Set expectations for return value

**When receiving subagent report:**
- Parse the summary statistics
- Extract any critical issues
- Verify the review report was created
- Check that the original file was updated

**Example subagent launch:**
```
Launch Incorrect Answers Reviewer subagent for file: [path]

Follow instructions in: ai-instructions/incorrect-answers-reviewer.md

Expected output:
- Updated question file with incorrect answer analysis
- Review report appended to logs/incorrect-answers-review-report.md
- Summary statistics (questions reviewed, changes made, issues found)
```

## Termination Conditions

**Stop when:**
- ✅ All files processed successfully
- ⚠️ User manually stops (Ctrl+C)
- ❌ Critical error prevents continuation (e.g., git repository locked)

**On user stop:**
- Save current progress
- Close open files
- Report progress so far
- Can resume in next session

## Quality Assurance

**Verify before commit:**
- All `completed` files have corresponding entries in review report
- All modified files are staged for commit
- Progress log is complete and accurate
- No files are left in `current_file` state (dangling)

**Final checks before git commit:**
```bash
# Check for uncommitted changes
git status --short

# Verify all completed files are tracked
comm -23 <(git diff --name-only | sort) <(cat progress.json | jq -r '.completed[]' | sort)

# Count files processed
echo "Files completed: $(cat progress.json | jq '.completed | length')"
```

## File Locations

**Input files:**
- Question files: `history-data/{epoch}/{chapter}/*_questions_*.md`

**Output files:**
- Progress log: `logs/incorrect-answers-coordinator-progress.json`
- Review reports: `logs/incorrect-answers-review-report.md`
- Final summary: `logs/incorrect-answers-coordinator-summary.md`

**Reference files:**
- Subagent instructions: `ai-instructions/incorrect-answers-reviewer.md`
- Validation rules: `.claude/validation-rules.md`
- Master list: `history-data/master-list.json`
