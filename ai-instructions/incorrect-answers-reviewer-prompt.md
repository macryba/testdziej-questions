# Prompt for Next Session - Incorrect Answers Review Coordinator

**Copy and paste this prompt in your next clean session to launch the autonomous coordinator agent:**

---

## 🚀 Incorrect Answers Review Coordinator - Autonomous Execution

I want you to act as an **Incorrect Answers Review Coordinator** that will autonomously process ALL question files by launching subagents sequentially.

### Your Mission:

Launch and manage incorrect answers review subagents for ALL question files in `history-data/`. Each subagent will:
1. Review incorrect answers in the question file
2. Add missing "Analiza odpowiedzi błędnych" sections
3. Categorize incorrect answers using Gnosis search
4. Reorder answers chronologically if needed
5. Redistribute correct answer positions if needed
6. Update the question file with all improvements
7. Create a review report in `logs/incorrect-answers-review-report.md`
8. Report completion status to coordinator

### Your Workflow:

**1. Initialize:**
- Find all question files: `find history-data/ -name "*_questions_*.md" -type f | sort`
- Read `logs/incorrect-answers-coordinator-progress.json` if it exists (to resume)
- Create/initialize progress tracking JSON file
- Identify starting point (first file not in completed list)

**2. Process Files Sequentially:**
- For each question file in the list:
  - Skip if already in `completed` array in progress log
  - Skip if in `failed` array with 3+ retry attempts
  - Update progress log (set `current_file`, save checkpoint)
  - Launch an Incorrect Answers Reviewer subagent following `ai-instructions/incorrect-answers-reviewer.md`
  - Wait for subagent to complete
  - Verify file was updated and report was created
  - Update progress log (add to `completed` or `failed` with retry count)
  - Continue to next file

**3. Error Handling:**
- If subagent fails: log error, increment retry count
- If retry count < 3: retry the same file
- If retry count >= 3: mark as permanently failed, skip to next file
- Always update progress log after each file (success or failure)
- Never lose progress - save after EACH file

**4. Count Statistics (AFTER all files complete):**
- Read `logs/incorrect-answers-review-report.md`
- Count all entries systematically:
  - Total questions reviewed
  - Questions with missing analysis added
  - Questions with answers reordered
  - Questions with positions adjusted
  - Total incorrect answers analyzed
  - Incorrect answers from other chapters
  - Incorrect answers with no reference
  - Critical issues found
- Group by epoch for breakdown statistics

**5. Create Git Commit (AFTER all files complete):**
- **DO NOT** create commits during processing
- **ONLY** create commit after ALL files are processed
- Stage all modified question files + reports + progress log
- Create single comprehensive commit with counted statistics

**5. Resume Capability:**
- If interrupted, you can resume from where you left off
- Read progress log to find last completed file
- Continue with next unprocessed file
- No duplicate work on completed files

**6. Run Until:**
- ✅ All files processed, OR
- ⚠️ I stop you manually (Ctrl+C), OR
- ❌ Critical error occurs

### Critical Instructions:

- **Create `logs/` directory** if it doesn't exist
- **Update progress log** after EVERY file (not just at end)
- **Wait for each subagent** before starting next (no parallel processing)
- **DO NOT create commits** during processing (only one commit at end)
- **Log ALL errors** with file path, error message, retry count, and timestamp
- **Generate final summary** when all files done
- **Verify all files** are properly staged before final commit

### Progress Log Format:

Maintain `logs/incorrect-answers-coordinator-progress.json` with:

```json
{
  "started_at": "2026-05-09T10:00:00Z",
  "last_updated": "2026-05-09T12:30:00Z",
  "total_files": 150,
  "completed_files": 75,
  "failed_files": 2,
  "skipped_files": 0,
  "current_file": null,
  "completed": [
    "history-data/01-starozytnosc/01-pradzieje/pradzieje_questions_easy.md",
    "history-data/01-starozytnosc/01-pradzieje/pradzieje_questions_medium.md",
    ...
  ],
  "failed": [
    {
      "file": "history-data/02-piastowie/01-chrystianizacja/chrystianizacja_questions_hard.md",
      "error": "Subagent timeout after 3 retries",
      "timestamp": "2026-05-09T11:45:00Z",
      "retries": 3
    }
  ],
  "skipped": []
}
```

### Final Summary Format:

Create `logs/incorrect-answers-coordinator-summary.md` with:
- Overall statistics (total, completed, failed, success rate)
- Question statistics (reviewed, analyzed, categorized)
- Breakdown by epoch
- Lists of completed, failed, and skipped files
- Git commit hash
- Recommendations for manual review

### Start Processing Now:

Begin processing question files. If `logs/incorrect-answers-coordinator-progress.json` exists, resume from last completed file. Update progress log after each file completion.

Run autonomously until all files are processed or I stop you.

---

## 📋 Expected Output:

**While running:**
- Progress log updates after each file
- Brief status messages (e.g., "Processing file 15/150...")
- Error messages if files fail

**When complete:**
- Final summary in `logs/incorrect-answers-coordinator-summary.md`
- Single git commit with all changes
- Statistics counted from review report (questions, changes, issues)
- List of any files requiring manual review (failed)

**Check progress anytime:**
```bash
# View progress log
cat logs/incorrect-answers-coordinator-progress.json | jq

# View completed files count
cat logs/incorrect-answers-coordinator-progress.json | jq '.completed_files'

# View completed files list
cat logs/incorrect-answers-coordinator-progress.json | jq '.completed'

# View failed files
cat logs/incorrect-answers-coordinator-progress.json | jq '.failed'

# View review report (for interim statistics)
tail -n 100 logs/incorrect-answers-review-report.md
```

---

**Ready to start? Begin autonomous execution now.** 🚀

---

## 🔧 If Something Goes Wrong:

**Stop the coordinator:**
- Send Ctrl+C to gracefully stop
- Progress is saved in log file
- Can resume in next session

**Resume in new session:**
- Use same prompt
- Coordinator reads progress log
- Continues from where it stopped
- Skips all completed files

**Manual intervention:**
- If coordinator stops on error
- Fix the issue (file permissions, disk space, etc.)
- Restart coordinator (will resume from last completed)
- Failed files will be retried up to 3 times

---

## Files Created/Used:

**Coordinator files:**
- `ai-instructions/incorrect-answers-review-coordinator.md` - Full coordinator instructions
- `ai-instructions/incorrect-answers-reviewer-prompt.md` - This prompt file

**Subagent files:**
- `ai-instructions/incorrect-answers-reviewer.md` - Subagent instructions

**Output files (created by coordinator):**
- `logs/incorrect-answers-coordinator-progress.json` - Progress tracking (resume capability)
- `logs/incorrect-answers-review-report.md` - Detailed review reports (appended by subagents)
- `logs/incorrect-answers-coordinator-summary.md` - Final summary (created at end)

**Previous work:**
- Based on difficulty reviewer coordinator pattern
- Adapted for incorrect answers review workflow
- Progress tracking for resumability
- Single commit at end (not per file)

---

**This coordinator will:**
✅ Process all question files sequentially
✅ Track progress for resume capability
✅ Handle errors with retry logic
✅ Create one git commit at the end
✅ Generate comprehensive summary report
✅ Allow manual review of failed files

---

**Start the coordinator now by following the workflow above.**
