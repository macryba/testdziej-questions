# Migration to Local-Only Operation

This document describes the changes made to operate the Testdziej question generation system without a database.

## Summary of Changes

### New Files Created

1. **`.claude/questions-tracker.json`**
   - Tracks question counts for each epoch/chapter/difficulty combination
   - Replaces database queries for finding gaps
   - Updated automatically during question generation

2. **`scripts/rebuild-tracker.sh`**
   - Helper script to rebuild the tracker from actual validated questions
   - Useful if tracker gets out of sync with file system
   - Run: `./scripts/rebuild-tracker.sh`

### Files Updated

1. **`.claude/instructions.md`**
   - Removed all Docker/psql database commands
   - Replaced with jq commands to read questions-tracker.json
   - Added instructions for updating tracker after question generation

2. **`.claude/validation-rules.md`**
   - Updated script path from absolute to relative path

3. **`CLAUDE.md`**
   - Updated project overview to emphasize local-only operation
   - Replaced "Database Queries" section with "File-based Queries"
   - Updated workflow descriptions
   - Removed database environment variables
   - Added rebuild-tracker.sh to monitoring commands

### Key Commands

**Find next combination needing questions:**
```bash
jq -r '
  to_entries[] |
  select(.key != "last_updated") |
  .key as $epoch |
  .value |
  to_entries[] |
  .key as $chapter |
  .value |
  to_entries[] |
  select(.value < 20) |
  "\($epoch)|\($chapter)|\(.key)"
' .claude/questions-tracker.json | head -1
```

**Check specific combination count:**
```bash
jq -r '.tracking["Piastowie"]["Chrystianizacja"]["easy"]' .claude/questions-tracker.json
```

**Increment counter after generating question:**
```bash
jq --arg epoch "[CURRENT_EPOCH]" \
   --arg chapter "[CURRENT_CHAPTER]" \
   --arg difficulty "[DIFFICULTY]" \
   '.tracking[$epoch][$chapter][$difficulty] += 1 | .last_updated = "[TIMESTAMP]"' \
   .claude/questions-tracker.json > .claude/questions-tracker.json.tmp && \
mv .claude/questions-tracker.json.tmp .claude/questions-tracker.json
```

## How It Works Now

1. Claude Code reads `.claude/questions-tracker.json` to find the next epoch/chapter/difficulty with < 20 questions
2. Generates a question and saves it to `questions/validated/`
3. Updates both `.claude/state.json` and `.claude/questions-tracker.json`
4. If tracker gets out of sync, run `./scripts/rebuild-tracker.sh` to rebuild from actual files

## Advantages of Local-Only Operation

- No database setup required
- No Docker container dependencies
- Questions are human-readable markdown files
- Easy to version control
- Can be synced to database later if needed
- Simpler debugging and inspection

## Future Database Sync

When ready to sync to a database:
1. All questions are already in `questions/validated/`
2. Each question file has complete metadata
3. Can create a simple import script to read all .md files and insert into database
4. The `sync-to-db.sh` script can be implemented at that time
