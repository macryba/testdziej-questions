# 🚀 Next Session - Quick Start Guide

## What to do in your next clean Claude Code session:

### Step 1: Open Claude Code
Start a new clean session

### Step 2: Copy and paste this prompt:

```
## Difficulty Review Coordinator - Start Overnight Automation

I want you to act as a Difficulty Review Coordinator and autonomously process ALL chapters by launching difficulty reviewer subagents.

### Context:
Working on Polish history quiz database with ~48 chapters across 9 epochs.

**Previous Progress (2 completed):**
- ✅ 01-starozytnosc/01-pradzieje (commit: b25ef81)
- ✅ 01-starozytnosc/02-slowianie (commit: 49ae7d2)

**Progress Log:** `log/difficulty-review-report.md`

### Your Task:

1. Read: `ai-instructions/difficulty-review-coordinator.md`
2. Read: `log/difficulty-review-report.md` (to see progress)
3. Start from first uncompleted chapter
4. Launch Difficulty Reviewer subagent for each chapter (following: `ai-instructions/difficulty-reviewer.md`)
5. Wait for completion, parse results, update log
6. Continue until ALL chapters done or I stop you

### Important:
- Work sequentially (one chapter at a time)
- Update log after EVERY chapter
- Run autonomously overnight
- Resume capability: if interrupted, restart with this prompt

**Start processing NOW from first uncompleted chapter.**
```

### Step 3: Go to sleep 😴
The coordinator will run autonomously overnight.

### Step 4: Check progress in the morning:
```bash
tail -n 100 log/difficulty-review-report.md
git log --oneline -20
```

---

## 📁 Files Created (All Committed):

✅ **START-COORDINATOR-PROMPT.md** - The prompt above (ready to copy-paste)
✅ **ai-instructions/difficulty-review-coordinator.md** - Full coordinator logic
✅ **log/difficulty-review-report.md** - Progress tracking (2 chapters done)
✅ **ai-instructions/difficulty-reviewer.md** - Subagent instructions (v2.3)
✅ **history-data/podstawa/klasyfikacja.md** - Updated classification rules

---

## 📊 Current Status:

**Completed:** 2/48 chapters (4%)
**Remaining:** ~46 chapters
**Estimated Time:** ~13 hours
**Commits:** 2 (b25ef81, 49ae7d2)

---

## 🎯 That's It!

Just **copy the prompt above** and paste it in your next Claude Code session.

The coordinator will:
✅ Process all ~46 remaining chapters
✅ Create git commits automatically
✅ Update progress log after each chapter
✅ Handle errors with retries
✅ Resume if interrupted
✅ Generate final summary

**See you in the morning with completed work!** 🌙
