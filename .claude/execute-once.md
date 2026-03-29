Your task: Generate 10 Polish history questions and commit to git.

STEP 1: Find next target
Run: jq -r '.tracking | to_entries[] | select(.key != "last_updated") | .key as $epoch | .value | to_entries[] | .key as $chapter | .value | to_entries[] | select(.value < 20) | "\($epoch)|\($chapter)|\(.key)"' .claude/questions-tracker.json | head -1

STEP 2: Generate 10 questions for that epoch/chapter/difficulty
- Create file: questions/validated/[epoch]-[chapter]-[difficulty].md
- Use template from templates/question-template.md
- Focus on different aspects per question (political, social, military, etc.)

STEP 3: Update state files
- jq '.tracking["EPOCH"]["CHAPTER"]["DIFFICULTY"] += 10' .claude/questions-tracker.json > tmp && mv tmp .claude/questions-tracker.json
- Update .claude/state.json with current values

STEP 4: Commit to git
git add questions/validated/*.md .claude/*.json
git commit --no-verify -m "Add 10 questions for EPOCH/CHAPTER (DIFFICULTY)"

DO ALL 4 STEPS before exiting. Verify git commit succeeded.
