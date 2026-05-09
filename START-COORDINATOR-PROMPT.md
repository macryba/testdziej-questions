# START-COORDINATOR-PROMPT

Copy and paste this prompt in your next clean Claude Code session:

---

## Difficulty Review Coordinator - Start Overnight Automation

I want you to act as a **Difficulty Review Coordinator** and autonomously process ALL chapters by launching difficulty reviewer subagents.

### Context:

You are working on a Polish history quiz question database. There are ~48 chapters across 9 historical epochs that need difficulty level review and correction.

**Previous Progress (2 chapters completed):**
- ✅ 01-starozytnosc/01-pradzieje (commit: b25ef81)
- ✅ 01-starozytnosc/02-slowianie (commit: 49ae7d2)

**Progress Log:** `logs/difficulty-review-report.md` already tracks these 2 completed chapters.

### Your Task:

**Read the coordinator instructions:** `ai-instructions/difficulty-review-coordinator.md`

**Execute the following workflow:**

1. **Initialize:**
   - Read `history-data/master-list.json` to get all chapters
   - Read `logs/difficulty-review-report.md` to see what's completed
   - Start from the first uncompleted chapter

2. **Process Each Chapter:**
   - Launch a Difficulty Reviewer subagent
   - Subagent follows: `ai-instructions/difficulty-reviewer.md` (v2.3)
   - Wait for subagent to complete
   - Subagent will: detect duplicates, correct levels, update files, create git commit
   - Parse subagent's completion report
   - Update `logs/difficulty-review-report.md` with results

3. **Continue Loop:**
   - Move to next chapter
   - Repeat until ALL chapters completed
   - Or until I stop you

4. **Handle Errors:**
   - If subagent fails: retry up to 3 times
   - After 3 failures: log error and skip to next chapter
   - Always update progress log

5. **Generate Summary:**
   - When all chapters done: create final summary
   - Save to `logs/difficulty-review-report.md`

### Important:

- **Work sequentially** (one chapter at a time)
- **Update log after EVERY chapter** (not just at end)
- **Create git commits automatically** (subagent does this)
- **Run autonomously** overnight until done or stopped
- **Resume capability:** If interrupted, I'll restart you with same prompt and you'll continue from where you left off

### Check Progress:

While you're running, I can check:
```bash
tail -n 50 logs/difficulty-review-report.md
git log --oneline -20
```

---

**Start processing NOW from the first uncompleted chapter. Run autonomously until all chapters are completed or I stop you.**