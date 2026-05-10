# Instructions: Standardize Incorrect Answer Headings

## Overview

Standardize all incorrect answer section headings across all question files to use a consistent format.

## Current Variations Found

1. `**Analiza odpowiedzi błędnych:**` (75 files) ✓ **STANDARD**
2. `**Analiza nieprawidłowych odpowiedzi:**` (22 files) ✗ Change to standard
3. `**Analiza niepoprawnych odpowiedzi:**` (25 files) ✗ Change to standard
4. `**Analiza odpowiedzi nieprawidłowych:**` (14 files) ✗ Change to standard
5. `**Analiza odpowiedzi niepoprawnych:**` (11 files) ✗ Change to standard
6. `**Analiza odpowiedzi:**` (2 files) ✗ Change to standard

**Total: 147 files with headings (74 need standardization)**

## Target Format

All files should use:
```
**Analiza odpowiedzi błędnych:**
```

## Files to Process

Find all files with non-standard headings:

```bash
cd /home/macryba/testdziej-questions
grep -rh "Analiza nieprawidłowych odpowiedzi:\|Analiza niepoprawnych odpowiedzi:\|Analiza odpowiedzi nieprawidłowych:\|Analiza odpowiedzi niepoprawnych:\|Analiza odpowiedzi:$" history-data --include="*_questions_*.md" -l
```

Expected: 74 files

## Replacement Rules

Replace the following patterns with `**Analiza odpowiedzi błędnych:**`:

1. `**Analiza nieprawidłowych odpowiedzi:**` → `**Analiza odpowiedzi błędnych:**`
2. `**Analiza niepoprawnych odpowiedzi:**` → `**Analiza odpowiedzi błędnych:**`
3. `**Analiza odpowiedzi nieprawidłowych:**` → `**Analiza odpowiedzi błędnych:**`
4. `**Analiza odpowiedzi niepoprawnych:**` → `**Analiza odpowiedzi błędnych:**`
5. `**Analiza odpowiedzi:**` → `**Analiza odpowiedzi błędnych:**`

## Implementation

Use sed to perform replacements:

```bash
# Navigate to project root
cd /home/macryba/testdziej-questions

# Replace each variation
find history-data -name "*_questions_*.md" -exec sed -i 's/\*\*Analiza nieprawidłowych odpowiedzi:\*\*/\*\*Analiza odpowiedzi błędnych:\*\*/g' {} +

find history-data -name "*_questions_*.md" -exec sed -i 's/\*\*Analiza niepoprawnych odpowiedzi:\*\*/\*\*Analiza odpowiedzi błędnych:\*\*/g' {} +

find history-data -name "*_questions_*.md" -exec sed -i 's/\*\*Analiza odpowiedzi nieprawidłowych:\*\*/\*\*Analiza odpowiedzi błędnych:\*\*/g' {} +

find history-data -name "*_questions_*.md" -exec sed -i 's/\*\*Analiza odpowiedzi niepoprawnych:\*\*/\*\*Analiza odpowiedzi błędnych:\*\*/g' {} +

find history-data -name "*_questions_*.md" -exec sed -i 's/\*\*Analiza odpowiedzi:\*\*/\*\*Analiza odpowiedzi błędnych:\*\*/g' {} +
```

## Verification

After making changes, verify:

```bash
cd /home/macryba/testdziej-questions

# Check that all files now use the standard heading
find history-data -name "*_questions_*.md" -exec grep -h "Analiza.*odpowiedzi\|Analiza.*niepoprawnych\|Analiza.*nieprawidłowych" {} \; | sort | uniq -c

# Should show:
#     149 **Analiza odpowiedzi błędnych:**

# Or count files with standard heading:
find history-data -name "*_questions_*.md" -exec grep -l "Analiza odpowiedzi błędnych:" {} \; | wc -l

# Should show: 149
```

## Important Notes

1. **Be precise**: Use exact string matching to avoid unintended replacements
2. **Test first**: Run sed on one file first to verify it works correctly
3. **Check for collateral**: Make sure no other text is accidentally modified
4. **Backup**: Git provides backup, but verify changes before committing

## Files Expected to Change

**74 files** will be modified (22 + 25 + 14 + 11 + 2).

## Order of Operations

1. List all affected files to verify count (should be 74)
2. Show sample changes from a few files before and after
3. Perform bulk replacements using sed commands above
4. Verify all files now use standard heading (should be 149 total)
5. Report completion with statistics:
   - Number of files modified
   - Before/after comparison
   - Any issues encountered

## Completion Criteria

- All 147 question files with headings use `**Analiza odpowiedzi błędnych:**`
- No other variations exist
- All 74 modified files verified correct
- Final count: 149 files with standard heading
