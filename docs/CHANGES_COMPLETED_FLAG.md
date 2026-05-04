# Completed Flag Implementation

## Problem

The loop was incorrectly re-processing chapters that had `easy: 0` questions (intentionally, because the topic is not covered by the primary school curriculum). The selection logic only checked if `count < 10`, which treated `0` as "needs work" even when it was intentionally completed.

## Solution

Added `_completed` flags to the tracking system for each difficulty level:

- `easy_completed`
- `medium_completed`
- `hard_completed`

These flags distinguish between:
- **Not started**: count: 0, completed: false → needs questions
- **Completed with 0 questions**: count: 0, completed: true → intentionally not in curriculum
- **Completed with questions**: count: 10, completed: true → done

## Files Changed

### 1. `scripts/run-single-iteration.sh`
**Updated selection logic** (lines 23-33 and 74-86):
```bash
# Old logic
select(.value.easy < 10 or .value.medium < 10 or .value.hard < 10)

# New logic
select(
  (.value.easy < 10 and (.value.easy_completed | not)) or
  (.value.medium < 10 and (.value.medium_completed | not)) or
  (.value.hard < 10 and (.value.hard_completed | not))
)
```

### 2. `scripts/run-autonomous-loop.sh`
**Updated completion check** (lines 18-39):
Now checks both count and `_completed` flag to determine if a difficulty level is truly incomplete.

### 3. `scripts/rebuild-tracker.sh`
**Updated to handle `_completed` flags**:
- Initialize `_completed: false` for all chapters when building from master-list.json
- Detect intentional "0 questions" files by checking for "Brak pytań" or "nie ujęty w podstawie programowej"
- Set `_completed: true` for files that exist (even with 0 questions)

### 4. `history-data/questions-tracker.json`
**Updated structure** with `_completed` flags:
```json
{
  "tracking": {
    "Piastowie": {
      "Łokietek": {
        "easy": 0,
        "easy_completed": true,  // ← NEW: Intentionally 0 (not in curriculum)
        "medium": 10,
        "medium_completed": true,
        "hard": 10,
        "hard_completed": true
      },
      "Kazimierz Wielki": {
        "easy": 0,
        "easy_completed": false,  // ← NEW: Not started
        "medium": 0,
        "medium_completed": false,
        "hard": 0,
        "hard_completed": false
      }
    }
  }
}
```

### 5. `.claude/instructions.md`
**Updated workflow documentation**:
- Section 1: Updated jq command to find next combination using new logic
- Section 2: Clarified how to determine missing questions with `_completed` flags
- Section 8: Added instructions for setting `_completed` flags when updating tracker

**Special case for EASY level when not in curriculum:**
```bash
# When EASY count is 0 (topic not in primary school curriculum)
jq --arg epoch "[CURRENT_EPOCH]" \
   --arg chapter "[CHAPTER]" \
   '.tracking[$epoch][$chapter]["easy_completed"] = true |
    .last_updated = "[TIMESTAMP]"' \
   history-data/questions-tracker.json > history-data/questions-tracker.json.tmp && \
mv history-data/questions-tracker.json.tmp history-data/questions-tracker.json
```

## Testing

Verified the updated logic works correctly:

**Before fix:**
```
Next target: Piastowie|Łokietek|easy:0 medium:10 hard:10
```
(Incorrectly picked completed chapter)

**After fix:**
```
Next target: Piastowie|Kazimierz Wielki|easy:0 medium:0 hard:0
```
(Correctly skipped completed chapter, picked next unstarted chapter)

## Usage Notes

1. **When generating questions with 0 count for EASY** (not in curriculum):
   - Create file with `question_count: 0`
   - Include explanation: "Temat nie ujęty w poziomie szkoły podstawowej"
   - Set `easy_completed: true` in tracker

2. **When updating tracker after generating questions**:
   - If count > 0, the completed flag is automatically set to true
   - If count = 0 (intentional), manually set the completed flag

3. **When rebuilding tracker**:
   - Run `scripts/rebuild-tracker.sh`
   - Automatically detects "0 questions" files and marks as completed
