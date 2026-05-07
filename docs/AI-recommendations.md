I apologize for the delay. Let me provide you with the comprehensive step-by-step instructions now based on my analysis of your attached files.

---

# Claude Code Automation Setup for Testdziej Questions

## Executive Summary

Based on my analysis, you need to generate **thousands of questions** to fill the gaps in your database. The current state shows:
- 114 active questions total
- Many epoch/chapter/difficulty combinations have 0 questions
- Goal: 20 questions per epoch/chapter/difficulty combination

---

## Part 1: Repository Setup

### Step 1: Initialize Project Repository

```bash
# On Ubuntu 24 server
sudo mkdir -p /srv/testdziej-questions
sudo chown $USER:$USER /srv/testdziej-questions
cd /srv/testdziej-questions

# Initialize git repository
git init
git config user.email "ai@testdziej.pl"
git config user.name "Claude AI"

# Create directory structure
mkdir -p {epochs,chapters,questions,scripts,templates,logs,.claude}
```

### Step 2: Create Project Structure

```bash
# Create the following structure
/srv/testdziej-questions/
├── .claude/
│   ├── instructions.md          # Main loop instructions
│   ├── validation-rules.md      # Question validation rules
│   └── state.json               # Loop state tracking
├── epochs/
│   └── master-list.json         # All epochs with chapter mappings
├── chapters/
│   └── *.md                     # Chapter source materials
├── questions/
│   ├── pending/                 # Questions waiting validation
│   ├── validated/               # Validated questions
│   └── archived/                # Completed questions
├── scripts/
│   ├── loop-controller.sh       # Main loop script
│   ├── validate-question.sh     # Question validator
│   └── sync-to-db.sh           # Database sync
├── templates/
│   └── question-template.md     # Question file template
├── logs/
│   └── loop-*.log              # Execution logs
└── README.md
```

### Step 3: Create Master List File

Create `/srv/testdziej-questions/epochs/master-list.json`:

```json
{
  "epochs": [
    {
      "id": 1,
      "short_name": "Starożytność",
      "long_name": "Starożytność do 966",
      "is_international": true,
      "chapters": [
        {"short_name": "Pradzieje", "long_name": "Pradzieje ziem polskich", "start_year": null, "end_year": 500},
        {"short_name": "Słowianie", "long_name": "Początki Słowian", "start_year": 500, "end_year": 966}
      ],
      "questions_needed": {"easy": 20, "medium": 20, "hard": 20}
    },
    {
      "id": 2,
      "short_name": "Piastowie",
      "long_name": "Dynastia Piastów (966-1370)",
      "is_international": false,
      "chapters": [
        {"short_name": "Chrystianizacja", "long_name": "Państwo Gnieźnieńskie i chrystianizacja", "start_year": 960, "end_year": 1025},
        {"short_name": "Ekspansja", "long_name": "Ekspansja i struktura państwa", "start_year": 1025, "end_year": 1138},
        {"short_name": "Rozbicie dzielnicowe I", "long_name": "Rozbicie dzielnicowe - początek", "start_year": 1138, "end_year": 1241},
        {"short_name": "Najazd mongolski", "long_name": "Najazd mongolski i jego skutki", "start_year": 1241, "end_year": 1275},
        {"short_name": "Zjednoczenie", "long_name": "Zjednoczenie w Księstwie Wielkopolskim", "start_year": 1275, "end_year": 1306},
        {"short_name": "Łokietek", "long_name": "Władysław Łokietek - odnowienie królestwa", "start_year": 1306, "end_year": 1333},
        {"short_name": "Kazimierz Wielki", "long_name": "Kazimierz Wielki - wielkie reformy", "start_year": 1333, "end_year": 1370}
      ],
      "questions_needed": {"easy": 20, "medium": 20, "hard": 20}
    },
    {
      "id": 3,
      "short_name": "Jagiellonowie",
      "long_name": "Dynastia Jagiellonów (1386-1572)",
      "is_international": false,
      "chapters": [
        {"short_name": "Unia Krewska", "long_name": "Unia Krewska i Jagiełło", "start_year": 1385, "end_year": 1434},
        {"short_name": "Grunwald", "long_name": "Bitwa pod Grunwaldem", "start_year": 1410, "end_year": 1411},
        {"short_name": "Warneńczyk", "long_name": "Władysław Warneńczyk", "start_year": 1434, "end_year": 1444},
        {"short_name": "Kazimierz Jagiellończyk", "long_name": "Kazimierz Jagiellończyk", "start_year": 1447, "end_year": 1492},
        {"short_name": "Wojna trzynastoletnia", "long_name": "Wojna trzynastoletnia", "start_year": 1454, "end_year": 1466},
        {"short_name": "Zygmunt Stary", "long_name": "Zygmunt I Stary", "start_year": 1506, "end_year": 1548},
        {"short_name": "Zygmunt August", "long_name": "Zygmunt II August", "start_year": 1548, "end_year": 1572}
      ],
      "questions_needed": {"easy": 20, "medium": 20, "hard": 20}
    },
    {
      "id": 4,
      "short_name": "Rzeczpospolita",
      "long_name": "Rzeczpospolita Obojga Narodów",
      "is_international": false,
      "chapters": [
        {"short_name": "Unia Lubelska", "long_name": "Unia Lubelska i Złota Era", "start_year": 1569, "end_year": 1586},
        {"short_name": "Wazowie", "long_name": "Dynastia Wazów - wstęp", "start_year": 1587, "end_year": 1632},
        {"short_name": "Wojny polsko-tureckie", "long_name": "Konflikt polsko-turecki 1620-1699", "start_year": 1620, "end_year": 1699},
        {"short_name": "Potop", "long_name": "Potop szwedzki", "start_year": 1655, "end_year": 1660},
        {"short_name": "Sobieski", "long_name": "Jan III Sobieski", "start_year": 1669, "end_year": 1696},
        {"short_name": "Czasy saskie", "long_name": "Czasy saskie", "start_year": 1697, "end_year": 1763},
        {"short_name": "Oświecenie", "long_name": "Oświecenie i reformy", "start_year": 1764, "end_year": 1791},
        {"short_name": "Upadek", "long_name": "Upadek państwa", "start_year": 1792, "end_year": 1795}
      ],
      "questions_needed": {"easy": 20, "medium": 20, "hard": 20}
    },
    {
      "id": 5,
      "short_name": "Rozbiory",
      "long_name": "Rozbiory (1795-1918)",
      "is_international": false,
      "chapters": [
        {"short_name": "Rozbiory", "long_name": "Trzy rozbiory Polski", "start_year": 1772, "end_year": 1795},
        {"short_name": "Insurekcja", "long_name": "Insurekcja Kościuszkowska", "start_year": 1794, "end_year": 1794},
        {"short_name": "Księstwo Warszawskie", "long_name": "Księstwo Warszawskie", "start_year": 1807, "end_year": 1815},
        {"short_name": "Kongresówka", "long_name": "Królestwo Kongresowe", "start_year": 1815, "end_year": 1831},
        {"short_name": "Powstanie listopadowe", "long_name": "Powstanie listopadowe", "start_year": 1830, "end_year": 1831},
        {"short_name": "Wiosna Ludów", "long_name": "Wiosna Ludów", "start_year": 1846, "end_year": 1849},
        {"short_name": "Powstanie styczniowe", "long_name": "Powstanie styczniowe", "start_year": 1863, "end_year": 1864},
        {"short_name": "Praca organiczna", "long_name": "Praca organiczna", "start_year": 1864, "end_year": 1918}
      ],
      "questions_needed": {"easy": 20, "medium": 20, "hard": 20}
    },
    {
      "id": 6,
      "short_name": "Międzywojnie",
      "long_name": "Międzywojnie (1918-1939)",
      "is_international": false,
      "chapters": [
        {"short_name": "Odrodzenie", "long_name": "Odrodzenie Polski", "start_year": 1918, "end_year": 1921},
        {"short_name": "Wojna bolszewicka", "long_name": "Wojna polsko-bolszewicka", "start_year": 1919, "end_year": 1921},
        {"short_name": "Budowa państwa", "long_name": "Budowa II RP", "start_year": 1921, "end_year": 1926},
        {"short_name": "Przewrót majowy", "long_name": "Przewrót majowy", "start_year": 1926, "end_year": 1935},
        {"short_name": "Sanacja", "long_name": "Rządy sanacji", "start_year": 1926, "end_year": 1939},
        {"short_name": "Zagrożenie", "long_name": "Zagrożenie wojną", "start_year": 1933, "end_year": 1939}
      ],
      "questions_needed": {"easy": 20, "medium": 20, "hard": 20}
    },
    {
      "id": 7,
      "short_name": "II WŚ",
      "long_name": "II Wojna Światowa (1939-1945)",
      "is_international": false,
      "chapters": [
        {"short_name": "Kampania wrześniowa", "long_name": "Kampania wrześniowa", "start_year": 1939, "end_year": 1939},
        {"short_name": "Okupacja", "long_name": "Okupacja niemiecka i sowiecka", "start_year": 1939, "end_year": 1945},
        {"short_name": "Ruch oporu", "long_name": "Polskie Państwo Podziemne", "start_year": 1939, "end_year": 1945},
        {"short_name": "Powstanie warszawskie", "long_name": "Powstanie warszawskie", "start_year": 1944, "end_year": 1944},
        {"short_name": "Holocaust", "long_name": "Holocaust na ziemiach polskich", "start_year": 1939, "end_year": 1945},
        {"short_name": "Wyzwolenie", "long_name": "Wyzwolenie i koniec wojny", "start_year": 1944, "end_year": 1945}
      ],
      "questions_needed": {"easy": 20, "medium": 20, "hard": 20}
    },
    {
      "id": 8,
      "short_name": "PRL",
      "long_name": "PRL (1945-1989)",
      "is_international": false,
      "chapters": [
        {"short_name": "Początki PRL", "long_name": "Początki PRL", "start_year": 1945, "end_year": 1956},
        {"short_name": "Stalinizm", "long_name": "Okres stalinizmu", "start_year": 1948, "end_year": 1956},
        {"short_name": "Październik 56", "long_name": "Październik 1956", "start_year": 1956, "end_year": 1956},
        {"short_name": "Gomułka", "long_name": "Rządy Gomułki", "start_year": 1956, "end_year": 1970},
        {"short_name": "Grudzień 70", "long_name": "Grudzień 1970", "start_year": 1970, "end_year": 1970},
        {"short_name": "Gierek", "long_name": "Rządy Gierka", "start_year": 1970, "end_year": 1980},
        {"short_name": "Solidarność", "long_name": "Narodziny Solidarności", "start_year": 1980, "end_year": 1981},
        {"short_name": "Stan wojenny", "long_name": "Stan wojenny", "start_year": 1981, "end_year": 1989},
        {"short_name": "Okrągły Stół", "long_name": "Okrągły Stół", "start_year": 1989, "end_year": 1989}
      ],
      "questions_needed": {"easy": 20, "medium": 20, "hard": 20}
    },
    {
      "id": 9,
      "short_name": "III RP",
      "long_name": "III RP (1989-obecnie)",
      "is_international": false,
      "chapters": [
        {"short_name": "Transformacja", "long_name": "Transformacja ustrojowa", "start_year": 1989, "end_year": 1993},
        {"short_name": "Balcerowicz", "long_name": "Plan Balcerowicza", "start_year": 1989, "end_year": 1991},
        {"short_name": "Rządy III RP", "long_name": "Rządy III RP", "start_year": 1993, "end_year": 2020},
        {"short_name": "Integracja", "long_name": "Integracja z UE i NATO", "start_year": 1999, "end_year": 2004}
      ],
      "questions_needed": {"easy": 20, "medium": 20, "hard": 20}
    }
  ]
}
```

### Step 4: Create State Tracking File

Create `/srv/testdziej-questions/.claude/state.json`:

```json
{
  "current_epoch": null,
  "current_chapter": null,
  "current_difficulty": null,
  "questions_generated_this_session": 0,
  "total_questions_generated": 0,
  "last_run": null,
  "status": "ready",
  "errors": []
}
```

### Step 5: Create Question Template

Create `/srv/testdziej-questions/templates/question-template.md`:

```markdown
---
# Metadata
epoch: "[EPOCH_NAME]"
epoch_id: [EPOCH_ID]
chapter: "[CHAPTER_NAME]"
chapter_id: [CHAPTER_ID]
difficulty: "[easy|medium|hard]"
created_at: "[TIMESTAMP]"
tokens_input: [COUNT]
tokens_output: [COUNT]
tokens_total: [COUNT]
session_start: "[TIMESTAMP]"
session_end: "[TIMESTAMP]"
---

# Summary: [EPOCH_NAME] - [CHAPTER_NAME] ([DIFFICULTY])

## Historical Context

[2-3 paragraphs summarizing the historical context of this chapter/epoch]

## Key Events

### Section 1: [Event Name]
[1-3 sentences explaining the event - this becomes the explanation]

### Section 2: [Event Name]
[1-3 sentences explaining the event - this becomes the explanation]

### Section 3: [Event Name]
[1-3 sentences explaining the event - this becomes the explanation]

---

# Question

**Question ID:** Q-[XXXXX]
**Question Type:** multiple_choice
**Difficulty:** [easy|medium|hard]

## Question Text
[Question text in Polish]

## Answer Options
A) [Incorrect answer]
B) [Correct answer]
C) [Incorrect answer]
D) [Incorrect answer]

## Correct Answer
**Answer:** [B]

## Explanation
[1-3 sentences explaining why this is the correct answer]

## Validation Status
- [ ] Historical accuracy verified
- [ ] Incorrect answers are historically true but wrong context
- [ ] All answers have similar length
- [ ] No obvious opposites used
- [ ] Date rules followed (if applicable)

## Sources
1. [Source name](url)
2. [Source name](url)

## Incorrect Answers Analysis

### Option A
- **Content:** [Incorrect answer text]
- **Why it's incorrect:** [Historical fact from different time period or context]
- **Verification:** [Verified as historically true but wrong context]

### Option C
- **Content:** [Incorrect answer text]
- **Why it's incorrect:** [Historical fact from different time period or context]
- **Verification:** [Verified as historically true but wrong context]

### Option D
- **Content:** [Incorrect answer text]
- **Why it's incorrect:** [Historical fact from different time period or context]
- **Verification:** [Verified as historically true but wrong context]
```

### Step 6: Create Loop Controller Script

Create `/srv/testdziej-questions/scripts/loop-controller.sh`:

```bash
#!/bin/bash

# Testdziej Question Generation Loop Controller
# This script manages the Claude Code /loop automation

set -e

PROJECT_DIR="/srv/testdziej-questions"
STATE_FILE="$PROJECT_DIR/.claude/state.json"
MASTER_LIST="$PROJECT_DIR/epochs/master-list.json"
LOG_DIR="$PROJECT_DIR/logs"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log() {
    echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_DIR/loop-$(date +%Y%m%d).log"
}

log "${BLUE}========================================${NC}"
log "${BLUE}Testdziej Question Generation Loop${NC}"
log "${BLUE}========================================${NC}"

# Check if state file exists
if [ ! -f "$STATE_FILE" ]; then
    log "${RED}ERROR: State file not found at $STATE_FILE${NC}"
    exit 1
fi

# Check if master list exists
if [ ! -f "$MASTER_LIST" ]; then
    log "${RED}ERROR: Master list not found at $MASTER_LIST${NC}"
    exit 1
fi

# Get current state
CURRENT_EPOCH=$(jq -r '.current_epoch // empty' "$STATE_FILE")
CURRENT_CHAPTER=$(jq -r '.current_chapter // empty' "$STATE_FILE")
CURRENT_DIFFICULTY=$(jq -r '.current_difficulty // empty' "$STATE_FILE")

log "${GREEN}Current State:${NC}"
log "  Epoch: ${CURRENT_EPOCH:-'Not set'}"
log "  Chapter: ${CURRENT_CHAPTER:-'Not set'}"
log "  Difficulty: ${CURRENT_DIFFICULTY:-'Not set'}"

# Function to get next epoch/chapter/difficulty combination
get_next_combination() {
    # This will be called by Claude to determine what to work on next
    # Returns JSON with next epoch, chapter, difficulty
    jq -c '
        # Find first epoch that needs questions
        .epochs[] | 
        # Find first chapter that needs questions
        .chapters[] |
        # Return this combination
        {epoch: .parent.short_name, chapter: .short_name, difficulties: ["easy", "medium", "hard"]}
    ' "$MASTER_LIST" 2>/dev/null | head -1
}

log "${YELLOW}Ready for Claude Code to execute loop...${NC}"
log "Run: claude code /loop"

exit 0
```

Make it executable:
```bash
chmod +x /srv/testdziej-questions/scripts/loop-controller.sh
```

---

## Part 2: Claude Code Instructions

### Step 7: Create Main Loop Instructions

Create `/srv/testdziej-questions/.claude/instructions.md`:

```markdown
# Claude Code Loop Instructions for Testdziej Question Generation

## Overview

You are running in a loop to generate Polish history quiz questions for the Testdziej app. Each loop iteration generates ONE question file.

## Loop Workflow

### 1. Pick Epoch and Chapter

Read `/srv/testdziej-questions/.claude/state.json` to find:
- Current epoch
- Current chapter  
- Current difficulty

If any is null, query the database to find the next combination needing questions:

```bash
docker exec supabase_db_testdziej psql -U postgres -c "
  SELECT 
    e.short_name as epoch,
    c.short_name as chapter,
    q.difficulty,
    COUNT(*) as question_count
  FROM chapters c
  JOIN epochs e ON c.epoch_id = e.id
  LEFT JOIN quiz_questions q ON q.chapter_id = c.id
  GROUP BY e.short_name, c.short_name, q.difficulty
  HAVING COUNT(*) < 20 OR COUNT(*) IS NULL
  ORDER BY e.id, c.order_index, 
    CASE q.difficulty WHEN 'easy' THEN 1 WHEN 'medium' THEN 2 WHEN 'hard' THEN 3 ELSE 0 END
  LIMIT 1;
"
```

### 2. Determine Missing Questions

Query to check exact count for the selected combination:

```bash
docker exec supabase_db_testdziej psql -U postgres -c "
  SELECT COUNT(*) 
  FROM quiz_questions q
  JOIN chapters c ON q.chapter_id = c.id
  JOIN epochs e ON c.epoch_id = e.id
  WHERE e.short_name = '[EPOCH]'
    AND c.short_name = '[CHAPTER]'
    AND q.difficulty = '[DIFFICULTY]';
"
```

If count >= 20, skip to next combination.

### 3. Analyze Sources

Use web tool to search for reliable Polish historical sources:

**Priority sources:**
1. pl.wikipedia.org (Polish Wikipedia)
2. historiaposzkola.pl
3. dlaucznia.pl
4. bryk.pl
5. Polskie Radio - historiapolskich.pl

**Search query format:**
```
site:pl.wikipedia.org [epoka] [rozdział] historia Polski
site:historiaposzkola.pl [wydarzenie] lekcja
```

### 4. Create Summary File

Create file: `/srv/testdziej-questions/questions/pending/[epoch]-[chapter]-[difficulty]-[timestamp].md`

Follow the template in `/srv/testdziej-questions/templates/question-template.md`

The summary should:
- Be in Polish
- Cover the historical context of the chapter
- Be divided into 3-5 sections (potential question topics)
- Each section: 1-3 sentences max

### 5. Generate Question and Answer

Based on the summary, create a question:

**For EASY difficulty:**
- Simple factual questions (who, what, where, when)
- Well-known dates, names, events
- Primary school level

**For MEDIUM difficulty:**
- Causes and effects
- More detailed understanding
- Secondary school level

**For HARD difficulty:**
- Analytical questions
- Complex relationships
- Extended matura level

### 6. Create Incorrect Answers

**CRITICAL RULES for incorrect answers:**

1. **All answers must be similar length** - not always the correct one is shortest
2. **Incorrect answers must be:**
   - Historically TRUE facts
   - BUT not related to the question asked
   - OR from events 50-150 years different

3. **INCORRECT answers must NOT be:**
   - Total opposites (Poland gained vs Poland lost)
   - Obvious historical errors
   - Too short or too long compared to correct

4. **If question contains a date:**
   - Incorrect answers must NOT contain dates
   - All answers should reference events only

### 7. Verify Question

Use web tool to verify:

```bash
# Example verification
# Search for the historical fact
"site:pl.wikipedia.org [event name] [year]"

# Verify each incorrect answer is historically true
"site:pl.wikipedia.org [incorrect answer event]"
```

### 8. Validate No Correct Answers in Incorrect Options

Run validation script:

```bash
/srv/testdziej-questions/scripts/validate-question.sh [question-file.md]
```

Check that:
- Correct answer is actually correct
- Each incorrect answer is factually true (but wrong context)
- No answer contradicts another

### 9. Save Metadata

At the top of the file, save:

```markdown
---
created_at: [ISO 8601 timestamp]
session_start: [ISO 8601 timestamp when loop started]
session_end: [ISO 8601 timestamp]
tokens_input: [from API response]
tokens_output: [from API response]
tokens_total: [sum]
---
```

### 10. Update State File

Update `/srv/testdziej-questions/.claude/state.json`:

```json
{
  "current_epoch": "[CURRENT_EPOCH]",
  "current_chapter": "[CURRENT_CHAPTER]",
  "current_difficulty": "[CURRENT_DIFFICULTY]",
  "questions_generated_this_session": [N+1],
  "total_questions_generated": [TOTAL+1],
  "last_run": "[TIMESTAMP]",
  "status": "completed",
  "errors": []
}
```

### 11. Move to Validated

After successful validation:

```bash
mv /srv/testdziej-questions/questions/pending/[file].md \
   /srv/testdziej-questions/questions/validated/
```

## Loop Exit Conditions

Stop the loop if:
1. All epoch/chapter/difficulty combinations have 20 questions
2. 10 consecutive errors occur
3. Token budget exceeded
4. User interrupts

## Error Handling

If error occurs:
1. Log error to `/srv/testdziej-questions/logs/errors.log`
2. Update state file with error message
3. Skip to next combination
4. If 3 consecutive errors, pause and notify
```

### Step 8: Create Validation Rules

Create `/srv/testdziej-questions/.claude/validation-rules.md`:

```markdown
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
- Correct answer is historically accurate
- Incorrect answers reference real historical events

### 5. Time Period Check
For incorrect answers referencing different events:
- Verify 50-150 year distance OR
- Verify it's a different context entirely

## Manual Review Required

Questions flagged for manual review:
- Complex analytical questions (hard difficulty)
- Questions involving controversial historical interpretations
- Questions about recent history (III RP)
- Questions involving sensitive topics (WWII, Holocaust)

## Validation Script

Run: `/srv/testdziej-questions/scripts/validate-question.sh [file]`

Output:
- ✅ PASS - Question validated
- ⚠️ WARNING - Minor issues, needs review
- ❌ FAIL - Critical issues, must fix
```

---

## Part 3: Docker Setup

### Step 9: Create Dockerfile for Claude Code

Create `/srv/testdziej-questions/Dockerfile`:

```dockerfile
FROM ubuntu:24.04

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    jq \
    git \
    postgresql-client \
    python3 \
    python3-pip \
    nodejs \
    npm \
    && rm -rf /var/lib/apt/lists/*

# Install Claude CLI
RUN curl -fsSL https://claude.ai/install.sh | sh

# Set working directory
WORKDIR /workspace

# Copy project files
COPY . /workspace/

# Set environment
ENV CLAUDE_WORKSPACE=/workspace
ENV CLAUDE_STATE_FILE=/workspace/.claude/state.json

# Entry point
ENTRYPOINT ["/workspace/scripts/loop-controller.sh"]
```

### Step 10: Create Docker Compose

Create `/srv/testdziej-questions/docker-compose.yml`:

```yaml
version: '3.8'

services:
  claude-code:
    build: .
    container_name: testdziej-claude-loop
    volumes:
      - ./:/workspace
      - ~/.claude:/root/.claude  # Claude CLI config
    environment:
      - CLAUDE_API_KEY=${CLAUDE_API_KEY}
      - DATABASE_URL=${DATABASE_URL}
    networks:
      - testdziej-network
    restart: unless-stopped
    command: tail -f /dev/null  # Keep container running

networks:
  testdziej-network:
    external: true  # Connect to existing Supabase network
```

### Step 11: Build and Run Docker Container

```bash
cd /srv/testdziej-questions

# Create environment file
cat > .env << 'EOF'
CLAUDE_API_KEY=your_claude_api_key_here
DATABASE_URL=postgresql://postgres:password@supabase_db_testdziej:5432/postgres
EOF

# Build container
docker-compose build

# Start container
docker-compose up -d

# Verify container is running
docker ps | grep testdziej-claude-loop
```

---

## Part 4: Running the Loop

### Step 12: Execute First Loop Test

```bash
# Enter the container
docker exec -it testdziej-claude-loop bash

# Run Claude Code with loop
claude code /loop --instructions /workspace/.claude/instructions.md
```

### Step 13: Monitor Progress

```bash
# Watch logs
tail -f /srv/testdziej-questions/logs/loop-$(date +%Y%m%d).log

# Check state
cat /srv/testdziej-questions/.claude/state.json | jq

# Count generated questions
ls -la /srv/testdziej-questions/questions/validated/ | wc -l
```

---

## Part 5: Database Integration

### Step 14: Create Sync Script

Create `/srv/testdziej-questions/scripts/sync-to-db.sh`:

```bash
#!/bin/bash

# Sync validated questions to database

set -e

VALIDATED_DIR="/srv/testdziej-questions/questions/validated"

for file in "$VALIDATED_DIR"/*.md; do
    if [ -f "$file" ]; then
        echo "Processing $file..."
        
        # Extract metadata from markdown
        EPOCH=$(grep '^epoch:' "$file" | cut -d'"' -f2)
        CHAPTER=$(grep '^chapter:' "$file" | cut -d'"' -f2)
        DIFFICULTY=$(grep '^difficulty:' "$file" | cut -d'"' -f2)
        QUESTION_TEXT=$(sed -n '/^## Question Text$/,/^## /p' "$file" | sed '1d;$d' | tr -d '\n')
        CORRECT_ANSWER=$(grep '^\*\*Answer:\*\*' "$file" | cut -d'[' -f2 | cut -d']' -f1)
        
        # Extract options (A, B, C, D)
        OPTION_A=$(grep '^A)' "$file" | sed 's/^A) //')
        OPTION_B=$(grep '^B)' "$file" | sed 's/^B) //')
        OPTION_C=$(grep '^C)' "$file" | sed 's/^C) //')
        OPTION_D=$(grep '^D)' "$file" | sed 's/^D) //')
        
        # Get IDs from database
        docker exec supabase_db_testdziej psql -U postgres -c "
          INSERT INTO quiz_questions (
            question_text, 
            question_type, 
            epoch_id, 
            chapter_id, 
            difficulty, 
            options, 
            correct_answer, 
            is_free, 
            order_index
          )
          SELECT 
            '$QUESTION_TEXT',
            'multiple_choice',
            e.id,
            c.id,
            '$DIFFICULTY',
            '[$OPTION_A,$OPTION_B,$OPTION_C,$OPTION_D]'::jsonb,
            '$CORRECT_ANSWER',
            false,
            (SELECT COALESCE(MAX(order_index), 0) + 1 FROM quiz_questions)
          FROM epochs e
          LEFT JOIN chapters c ON c.epoch_id = e.id AND c.short_name = '$CHAPTER'
          WHERE e.short_name = '$EPOCH';
        "
        
        # Move to archived
        mv "$file" "/srv/testdziej-questions/questions/archived/"
        
        echo "✓ Synced: $file"
    fi
done

echo "Sync complete!"
```

Make executable:
```bash
chmod +x /srv/testdziej-questions/scripts/sync-to-db.sh
```

---

## Summary

### Final Directory Structure

```
/srv/testdziej-questions/
├── .claude/
│   ├── instructions.md          ✅ Loop instructions
│   ├── validation-rules.md      ✅ Validation rules
│   └── state.json               ✅ State tracking
├── epochs/
│   └── master-list.json         ✅ Master list
├── chapters/
│   └── (source materials)
├── questions/
│   ├── pending/                 (generated questions)
│   ├── validated/               (validated questions)
│   └── archived/                (synced to DB)
├── scripts/
│   ├── loop-controller.sh       ✅ Main controller
│   ├── validate-question.sh     (validator)
│   └── sync-to-db.sh           ✅ DB sync
├── templates/
│   └── question-template.md     ✅ Template
├── logs/
│   └── (log files)
├── .env                         (API keys)
├── Dockerfile                   ✅ Container definition
├── docker-compose.yml           ✅ Container orchestration
└── README.md                    (documentation)
```

### Quick Start Commands

```bash
# 1. Initialize everything
cd /srv/testdziej-questions
./scripts/loop-controller.sh

# 2. Start Docker container
docker-compose up -d

# 3. Run Claude Code loop
docker exec -it testdziej-claude-loop claude code /loop

# 4. Monitor progress
tail -f logs/loop-$(date +%Y%m%d).log

# 5. Sync to database
./scripts/sync-to-db.sh
```

### Current Gap Analysis

Based on your `summary.md`, here are the priorities:

| Epoch | Current Active | Target (per difficulty) | Gap |
|-------|---------------|------------------------|-----|
| Starożytność | 0 | 20 × 3 = 60 | **60 needed** |
| Piastowie | 3 | 60 | **57 needed** |
| Jagiellonowie | 32 | 60 | **28 needed** |
| Rzeczpospolita | 57 | 60 | **3 needed** |
| Rozbiory | 3 | 60 | **57 needed** |
| Międzywojnie | 4 | 60 | **56 needed** |
| II WŚ | 6 | 60 | **54 needed** |
| PRL | 6 | 60 | **54 needed** |
| III RP | 3 | 60 | **57 needed** |

**Total questions needed: ~426 questions** (assuming 20 per epoch/difficulty without chapter breakdown)

With chapters (assuming ~6 chapters per epoch on average):
**Estimated total needed: ~3,240 questions** (9 epochs × 6 chapters × 3 difficulties × 20 questions)

---

This setup provides a complete automation framework for generating Polish history quiz questions. Each loop iteration will:
1. Identify the next gap
2. Research the topic
3. Generate a validated question
4. Track progress
5. Sync to database

Let me know if you need any clarification or modifications!