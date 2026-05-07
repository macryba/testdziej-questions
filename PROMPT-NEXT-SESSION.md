# Prompt for Next Session - Difficulty Review Coordinator

**Copy and paste this prompt in your next clean session to launch the autonomous coordinator agent:**

---

## 🚀 Difficulty Review Coordinator - Overnight Execution

I want you to act as a **Difficulty Review Coordinator** that will autonomously process ALL chapters in the master list by launching subagents sequentially.

### Your Mission:

Launch and manage difficulty review subagents for ALL chapters in `history-data/master-list.json`. Each subagent will:
1. Detect and resolve duplicate questions
2. Correct misclassified difficulty levels
3. Update all question files
4. Update questions-tracker.json
5. Create git commit with changes
6. Report completion status

### Your Workflow:

**1. Initialize:**
- Read `history-data/master-list.json` to get all chapters
- Read `log/difficulty-review-report.md` if it exists (to resume)
- Identify starting point (first chapter not completed)

**2. Process Chapters Sequentially:**
- For each chapter in the list:
  - Skip if already marked "✅ Completed" in progress log
  - Launch a Difficulty Reviewer subagent following `ai-instructions/difficulty-reviewer.md`
  - Wait for subagent to complete
  - Parse completion report (changes, counts, accuracy, commit hash)
  - Update `log/difficulty-review-report.md` with results
  - Continue to next chapter

**3. Error Handling:**
- If subagent fails: retry up to 3 times
- If still failing after 3 retries: log error and skip to next chapter
- Always update progress log after each chapter (success or failure)

**4. Resume Capability:**
- If interrupted, you can resume from where you left off
- Read `log/difficulty-review-report.md` to find last completed chapter
- Continue with next chapter

**5. Run Until:**
- ✅ All chapters completed, OR
- ⚠️ I stop you manually, OR
- ❌ Critical error occurs

### Critical Instructions:

- **Create `log/` directory** if it doesn't exist
- **Update progress log** after EVERY chapter (not just at end)
- **Wait for each subagent** before starting next (no parallel processing)
- **Verify git commits** were created after each chapter
- **Log ALL errors** with chapter name, error message, and timestamp
- **Generate final summary** when all chapters done

### Progress Log Format:

Maintain `log/difficulty-review-report.md` with:
- Quick stats (total, completed, remaining, errors)
- Progress by epoch
- Detailed logs for each chapter with:
  - Timestamps (started, completed, duration)
  - Changes made (moves, duplicates)
  - Final counts
  - Classification accuracy
  - Git commit hash
  - Files modified

### Start Processing Now:

Begin processing chapters from master list. If `log/difficulty-review-report.md` exists, resume from last completed chapter. Update progress log after each chapter completion.

Run autonomously until all chapters are completed or I stop you.

---

## 📋 Expected Output:

**While running:**
- Silent processing (no verbose output needed)
- Progress log updates after each chapter
- Git commits created as chapters complete

**When complete:**
- Final summary in progress log
- Statistics: total processed, accuracy, errors
- List of any chapters requiring manual review

**Check progress anytime:**
```bash
# View progress
tail -n 100 log/difficulty-review-report.md

# View recent commits
git log --oneline -20

# Check status
git status --short
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

**Manual intervention:**
- If coordinator stops on error
- Fix the issue (file permissions, etc.)
- Restart coordinator (will resume from last completed)

---

**Files Created:**
- `ai-instructions/difficulty-review-coordinator.md` - Full coordinator instructions
- `log/difficulty-review-report.md` - Progress tracking (created by coordinator)

**Previous Work Completed (2/48 chapters):**
- ✅ 01-starozytnosc/01-pradzieje (commit: b25ef81)
- ✅ 01-starozytnosc/02-slowianie (commit: 49ae7d2)

**Remaining:** ~46 chapters to process
