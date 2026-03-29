Execute the question generation workflow from .claude/instructions.md exactly once.

CRITICAL: You MUST complete ALL steps including the final git commit before exiting!

Read the instructions file and follow these steps in order:
1. Find next epoch/chapter/difficulty combination needing questions
2. Research sources using web search (if available)
3. Generate 10 questions (save to ONE file in questions/validated/)
4. Update .claude/state.json with new values
5. Update .claude/questions-tracker.json (+10 questions)
6. Commit changes to git with --no-verify flag
7. EXIT immediately after commit

Do NOT exit before completing the git commit. Verify the commit succeeded before exiting.

Generate ALL 10 questions, update BOTH state files, AND commit to git before you exit.
