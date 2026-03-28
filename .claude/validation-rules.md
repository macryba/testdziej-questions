# Question Validation Rules

## Automatic Validation Checks

### 1. Answer Length Check
All four answers should be within 20% length variance.

```python
# Pseudo-code
lengths = [len(a) for a in answers]
max_length = max(lengths)
min_length = min(lengths)
variance = (max_length - min_length) / max_length
assert variance < 0.2, "Answer length variance too high"
```

### 2. Date Presence Check

If question contains a date (year), verify NO answers contain dates.

```python
import re
if re.search(r'\b(1[0-9]{3}|20[0-2][0-9])\b', question):
    for answer in answers:
        assert not re.search(r'\b(1[0-9]{3}|20[0-2][0-9])\b', answer), \
            "Answer contains date when question has date"
```

### 3. No Opposites Check
Verify no answer pairs are direct opposites.

```python
opposites = [
    ("zyskała", "utraciła"),
    ("zwycięstwo", "porażka"),
    ("rosną", "spadają"),
    ("wzrost", "spadek")
]
# Check no opposite pairs in answers
```

### 4. Historical Accuracy Check
Use web search to verify:

Correct answer is historically accurate
Incorrect answers reference real historical events

### 5. Time Period Check
For incorrect answers referencing different events:

Verify 50-150 year distance OR
Verify it's a different context entirely

## Manual Review Required
Questions flagged for manual review:

- Complex analytical questions (hard difficulty)
- Questions involving controversial historical interpretations
- Questions about recent history (III RP)
- Questions involving sensitive topics (WWII, Holocaust)

## Validation Script
Run: ./scripts/validate-question.sh [file]

Output:

✅ PASS - Question validated
⚠️ WARNING - Minor issues, needs review
❌ FAIL - Critical issues, must fix