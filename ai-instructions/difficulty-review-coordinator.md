# Difficulty Review Coordinator Agent Instructions

**Purpose:** Coordinate automated difficulty level review across ALL chapters by launching subagents sequentially, tracking progress, and maintaining a complete audit log.

**Mode:** Autonomous overnight execution - runs until all chapters completed or stopped.

**Reference:** `ai-instructions/difficulty-reviewer.md` (subagent instructions)

---

## Coordinator Workflow

### Phase 1: Initialization

#### Step 1: Read Master List

**Read:** `history-data/master-list.json`

**Extract:**
- All epochs with their chapters
- Chapter technical names and display names
- Total chapter count

**Build chapter list:**
```
Format: {epoch_id}-{epoch_tech}/{chapter_id}-{chapter_tech}

Example list:
- 01-starozytnosc/01-pradzieje
- 01-starozytnosc/02-slowianie
- 02-piastowie/01-chrystianizacja
- ... (continue for all chapters)
```

#### Step 2: Initialize Progress Tracking

**Read:** `logs/difficulty-review-report.md` (if exists)

**If file exists:**
- Parse completed chapters from log
- Identify last completed chapter
- Resume from next chapter (skip completed)

**If file doesn't exist:**
- Create directory: `logs/` (if needed)
- Start from first chapter

**Progress tracking structure:**
```markdown
# Difficulty Review Progress Log

**Started:** [TIMESTAMP]
**Status:** IN_PROGRESS

## Completion Summary

- Total Chapters: [N]
- Completed: [N]
- Remaining: [N]
- Errors: [N]

## Chapter Progress

### ✅ Completed
- [CHAPTER] - [TIMESTAMP] - [COMMIT_HASH]
- [CHAPTER] - [TIMESTAMP] - [COMMIT_HASH]

### 🔄 In Progress
- [CHAPTER] - Started: [TIMESTAMP]

### ⏳ Pending
- [CHAPTER]
- [CHAPTER]

### ❌ Errors
- [CHAPTER] - [ERROR_MESSAGE] - [TIMESTAMP]

## Detailed Logs

### Chapter: [CHAPTER]

**Started:** [TIMESTAMP]
**Completed:** [TIMESTAMP]
**Status:** ✅ SUCCESS | ❌ FAILED

**Changes Made:**
- Moved X questions from EASY → MEDIUM
- Moved Y questions from MEDIUM → EASY
- Moved Z questions from MEDIUM → HARD
- Moved W questions from HARD → MEDIUM
- Resolved D duplicates

**Final Counts:**
- EASY: [count] (was [count])
- MEDIUM: [count] (was [count])
- HARD: [count] (was [count])

**Classification Accuracy:** [X]%

**Git Commit:** [COMMIT_HASH]

**Files Modified:**
- [file1]
- [file2]

---
(Repeat for each chapter)
```

---

### Phase 2: Chapter Processing Loop

#### Step 3: Launch Subagent for Each Chapter

**For each chapter in master list:**

**Check if already completed:**
- If chapter in "✅ Completed" list → SKIP
- If chapter in "❌ Errors" list → RETRY (max 3 retries)
- If chapter in "🔄 In Progress" → SKIP (might be running from previous session)

**Launch subagent:**
```python
Agent(
  subagent_type="general-purpose",
  prompt=f"""
You are a Difficulty Reviewer agent.
Follow instructions in: ai-instructions/difficulty-reviewer.md (version 2.3)

Your input chapter: {chapter_path}

CRITICAL: Complete ALL tasks including:
1. Detect and resolve duplicates
2. Correct difficulty levels
3. Update all files
4. Update questions-tracker.json
5. Create git commit
6. Report completion status

Execute full workflow and report back when done.
""",
  description="Difficulty review for {chapter_name}"
)
```

**Wait for completion:**
- Monitor subagent output
- Capture completion report
- Check for errors

#### Step 4: Process Subagent Results

**If subagent succeeded:**

1. **Extract from completion report:**
   - Changes made (moves, duplicates)
   - Final counts
   - Classification accuracy
   - Git commit hash
   - Files modified

2. **Update progress log:**
   - Add to "✅ Completed" list
   - Add detailed log entry
   - Update completion count
   - Update remaining count

3. **Verify git commit:**
   ```bash
   git log -1 --oneline
   ```
   - Confirm commit was created
   - Record commit hash

4. **Continue to next chapter**

**If subagent failed:**

1. **Identify error type:**
   - File read error → SKIP chapter (report issue)
   - Git commit failed → Retry once (if commit failed, changes may be staged)
   - Subagent crash → Retry (max 3 times)
   - Validation errors → Report and SKIP (manual review needed)

2. **Update progress log:**
   - Add to "❌ Errors" list with error message
   - Add timestamp
   - Note retry count

3. **Decision:**
   - If retry count < 3 → Retry same chapter
   - If retry count >= 3 → Skip to next chapter, log for manual review

#### Step 5: Continue Loop

**Repeat Steps 3-4 for each chapter:**
- Process sequentially (one at a time)
- Do not launch in parallel (avoid conflicts)
- Wait for each to complete before starting next
- Update log after each completion

**Stop conditions:**
- ✅ All chapters completed
- ⚠️ User interruption (Ctrl+C)
- ❌ Critical error (stop processing)
- 🌙 Time limit reached (optional)

---

### Phase 3: Completion and Summary

#### Step 6: Generate Final Summary

**When all chapters completed or stopped:**

**Update progress log:**
```markdown
## Final Summary

**Completed:** [TIMESTAMP]
**Status:** ✅ ALL_COMPLETED | ⚠️ PARTIALLY_COMPLETED | ❌ STOPPED

**Statistics:**
- Total Chapters: [N]
- Successfully Completed: [N] ([X]%)
- Failed: [N]
- Skipped: [N]

**Questions Processed:**
- Total Questions Analyzed: [N]
- Questions Moved: [N]
- Duplicates Resolved: [N]
- Average Classification Accuracy: [X]%

**Time Metrics:**
- Started: [TIMESTAMP]
- Completed: [TIMESTAMP]
- Duration: [X hours, Y minutes]
- Average Time per Chapter: [X minutes]

**Git Commits:**
- Total Commits: [N]
- First Commit: [HASH]
- Last Commit: [HASH]

**Errors Requiring Manual Review:**
- [List of chapters with errors]
- [Error descriptions]
- [Recommendations for resolution]
```

#### Step 7: Save Final Report

**Save:** `logs/difficulty-review-report.md`

**Verify:**
- All chapters logged
- Completion status accurate
- All commit hashes recorded
- Errors documented

---

## Error Handling

### Subagent Crash

**Symptoms:**
- Subagent stops unexpectedly
- No completion report
- Partial file changes

**Recovery:**
1. Check git status for staged changes
2. If changes staged → Attempt to commit manually
3. Mark chapter as "❌ FAILED" in log
4. Note: "Subagent crashed - manual review needed"
5. Continue to next chapter

### Git Commit Failures

**Symptoms:**
- Subagent reports "git commit failed"
- Changes staged but not committed

**Recovery:**
1. Check git status
2. If changes are staged:
   ```bash
   git status --short
   ```
3. Attempt manual commit:
   ```bash
   git commit --no-verify -m "[AUTO-RECOVERY] Difficulty level corrections: [CHAPTER]"
   ```
4. If manual commit succeeds → Log as completed with recovered commit
5. If manual commit fails → Log as failed, leave changes staged

### File Read Errors

**Symptoms:**
- Chapter files missing
- Curriculum files missing
- Master list parsing errors

**Recovery:**
1. Log specific error
2. Mark chapter as "❌ FILE_READ_ERROR"
3. Skip to next chapter
4. Do not retry (persistent issue)

### Validation Failures

**Symptoms:**
- Subagent reports validation errors
- Grammar check failures
- Difficulty verification failures

**Recovery:**
1. Log validation error details
2. Mark chapter as "❌ VALIDATION_ERROR"
3. Note specific validation issues
4. Skip to next chapter
5. Flag for manual review

---

## Resume Capability

### Starting from Mid-Point

**When coordinator starts:**

1. **Read existing progress log:**
   - Parse "✅ Completed" chapters
   - Parse "🔄 In Progress" chapters
   - Parse "❌ Errors" chapters

2. **Determine starting point:**
   - Find last completed chapter
   - Start with NEXT chapter in list
   - Skip all completed chapters

3. **Handle "In Progress" chapters:**
   - Check if git commit exists
   - If commit exists → Move to completed
   - If no commit → Log as failed, retry

4. **Handle error chapters:**
   - Check retry count
   - If < 3 → Retry
   - If >= 3 → Skip

**Example resume:**
```
Log shows:
- ✅ 01-starozytnosc/01-pradzieje (completed)
- ✅ 01-starozytnosc/02-slowianie (completed)
- ❌ 02-piastowie/01-chrystianizacja (2 retries, max 3)

Coordinator action:
- Start with: 02-piastowie/01-chrystianizacja (retry #3)
- If fails → Skip and log for manual review
- Continue with: 02-piastowie/02-ekspansja
```

---

## Time and Session Management

### Overnight Execution

**Recommended settings:**
- Run from: Evening (e.g., 10 PM)
- Expected duration: 6-10 hours (depending on chapter count)
- Checkpoint: Every chapter completion (log updated)

**Interruption handling:**
- If interrupted → Resume capability ensures no work lost
- Progress log shows exactly where to resume
- Git commits provide rollback capability

**Monitoring:**
- Check `logs/difficulty-review-report.md` for progress
- Check `git log --oneline` for recent commits
- No real-time output needed (agent logs progress)

---

## Coordination Commands

### Start Coordinator

**Launch with:**
```
"Run difficulty review coordinator agent following ai-instructions/difficulty-review-coordinator.md.
Process all chapters in master-list.json sequentially.
Update logs/difficulty-review-report.md after each chapter.
Run overnight until all chapters completed or interrupted.
Resume from existing progress if log exists."
```

### Check Progress

**While running:**
```bash
# Check progress log
tail -n 50 logs/difficulty-review-report.md

# Check recent commits
git log --oneline -10

# Check git status
git status --short
```

### Stop Coordinator

**Graceful stop:**
- Send interruption signal (Ctrl+C)
- Coordinator will:
  - Finish current chapter
  - Update progress log
  - Save current state
  - Exit cleanly

**Force stop:**
- Kill process
- Progress log shows last completed chapter
- Next run resumes from next chapter

---

## Output Format

### Progress Log Structure

**File:** `logs/difficulty-review-report.md`

**Structure:**
```markdown
# Difficulty Review Progress Log

**Session Started:** 2026-05-07 22:00:00 UTC
**Coordinator Version:** 1.0
**Status:** IN_PROGRESS | COMPLETED | STOPPED

## Quick Stats

- Total Chapters: 48
- Completed: 12 (25%)
- Remaining: 36
- Errors: 0

## Progress by Epoch

### Starożytność (2 chapters)
- ✅ 01-pradzieje - 2026-05-07 22:15 - b25ef81
- ✅ 02-slowianie - 2026-05-07 22:45 - 49ae7d2
- **Progress:** 2/2 (100%) ✅

### Piastowie (6 chapters)
- ✅ 01-chrystianizacja - 2026-05-07 23:20 - abc1234
- 🔄 02-ekspansja - Started: 2026-05-07 23:55
- ⏳ 03-rozbicie-dzielnicowe-i
- ⏳ 04-najazd-mongolski
- ⏳ 05-lokietek
- ⏳ 06-kazimierz-wielki
- **Progress:** 1/6 (17%)

... (continue for all epochs)

## Detailed Logs

### Chapter: 01-starozytnosc/01-pradzieje
**Started:** 2026-05-07 22:10:00 UTC
**Completed:** 2026-05-07 22:15:00 UTC
**Duration:** 5 minutes
**Status:** ✅ SUCCESS

**Changes Made:**
- Moved 10 questions from EASY → MEDIUM (topic not in primary curriculum)
- Resolved 3 duplicate questions in MEDIUM

**Final Counts:**
- EASY: 0 (was 10)
- MEDIUM: 21 (was 24)
- HARD: 3 (unchanged)

**Classification Accuracy:** 100%

**Git Commit:** b25ef81

**Files Modified:**
- pradzieje_questions_easy.md
- pradzieje_questions_medium.md
- questions-tracker.json

---
(Repeat for each chapter)
```

---

## Success Criteria

**Coordinator successful when:**
1. ✅ All chapters processed OR stopped gracefully
2. ✅ Progress log updated after each chapter
3. ✅ All successful chapters have git commits
4. ✅ All errors documented with details
5. ✅ Resume capability functional
6. ✅ Final summary generated

**Quality metrics:**
- Average classification accuracy: ≥ 95%
- Duplicate resolution rate: ≥ 90%
- Git commit success rate: ≥ 98%
- Error rate: ≤ 5%

---

## Version History

**v1.0** (2026-05-07) - Initial coordinator implementation
- Sequential chapter processing
- Progress tracking and logging
- Resume capability
- Error handling and recovery
- Git commit verification

---

**Coordinator Reference:** ai-instructions/difficulty-reviewer.md
**Subagent Reference:** ai-instructions/difficulty-reviewer.md
**Master List:** history-data/master-list.json
**Progress Log:** logs/difficulty-review-report.md
