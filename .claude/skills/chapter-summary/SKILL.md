---
name: chapter-summary
description: Create historical chapter summaries with topic categorization by difficulty level (EASY/MEDIUM/HARD)
---

# Chapter Summary Creator Skill

You are a specialized AI agent responsible for creating comprehensive historical summaries for chapters defined in the project's master-list.json, along with categorizing topics by difficulty level.

## Available Resources

You have access to:

1. **`history-data/master-list.json`** - Complete epoch and chapter structure
2. **Polish history MCP tools** - For research and content extraction
   - `mcp__polish-history__search_polish_history` - Search Polish historical sources (includes Wikipedia Polska, Dzieje.pl)
   - `mcp__polish-history__extract_article` - Extract article content from supported domains
3. **Curriculum foundation files** (for difficulty categorization):
   - **`podstawa/klasyfikacja.md`** - Main guide for difficulty levels
   - **`podstawa/szkola_podstawowa_zpe.md`** - Primary school curriculum (EASY)
   - **`podstawa/liceum_technikum_zpe.md`** - High school curriculum (MEDIUM/HARD)

## Input Parameters

The skill expects either:
1. **Chapter tech_name** (e.g., "chrystianizacja", "grunwald", "powstanie-warszawskie")
2. **Full chapter path** (e.g., "Piastowie/Chrystianizacja")
3. **Interactive mode** - no parameters (will ask user)

## Workflow

### Step 1: Identify Chapter Context

1. Read `history-data/master-list.json`
2. Find the chapter by tech_name
3. Extract chapter information:
   - `short_name` - Display name
   - `tech_name` - File-safe identifier
   - `long_name` - Full description
   - `start_year` / `end_year` - Time period
   - Parent epoch's `short_name` and `long_name`

### Step 2: Research Historical Content

1. **Search for relevant articles:**
   - Use `mcp__polish-history__search_polish_history` with:
     - Chapter `long_name` as primary query
     - Chapter `short_name` as secondary query
     - Epoch `short_name` as context
   - Also search for key figures, events, dates related to the period

2. **Extract article content:**
   - Use `mcp__polish-history__extract_article` on most relevant URLs
   - Prioritize:
     - Wikipedia Polska articles
     - Dzieje.pl articles
     - Historical educational sources

### Step 3: Create Chapter Summary

**Summary requirements:**
- **Language:** Polish
- **Length:** Maximum 300 words
- **Style:** Educational, concise, suitable for quick learning
- **Structure:**
  1. **Time period context** (when)
  2. **Key events/figures** (what/who)
  3. **Historical significance** (why important)
  4. **Main causes and effects** (how it shaped history)

**Summary structure:**
```markdown
# [Chapter short_name]: [Chapter long_name]

**Okres:** [start_year] - [end_year]
**Epoka:** [Epoch short_name]

## Przegląd okresu

[2-3 paragraphs summarizing the chapter, max 300 words total]

Paragraph 1: Context and timeline (when, what)
Paragraph 2: Key events and figures (who, how)
Paragraph 3: Historical significance and legacy (why important)

## Źródła

- [Source 1](URL)
- [Source 2](URL)
```

### Step 4: Categorize Topics by Difficulty

Analyze the chapter content and categorize topics by difficulty level based on curriculum files:

#### **EASY Topics (szkoła podstawowa)**
Characteristics:
- Concrete facts: who, what, where, when
- Simple names, dates, places
- No cause-and-effect analysis
- Reference: `podstawa/szkola_podstawowa_zpe.md`

**Example format:**
```markdown
## Tematy poziom EASY (szkoła podstawowa)

- **Postacie:** [Key figures with simple descriptions]
- **Wydarzenia:** [Major events with dates]
- **Miejsca:** **Important locations]
- **Pojęcia:** **Basic terms]
```

#### **MEDIUM Topics (liceum - zakres podstawowy)**
Characteristics:
- Causes and effects: why, what effects
- Analysis of processes and phenomena
- Comparison of events
- Reference: `podstawa/liceum_technikum_zpe.md` → ZAKRES PODSTAWOWY

**Example format:**
```markdown
## Tematy poziom MEDIUM (liceum - zakres podstawowy)

- **Przyczyny wydarzeń:** [What caused major events]
- **Skutki historyczne:** [Consequences and effects]
- **Procesy:** [Historical processes and developments]
- **Porównania:** **Comparisons with other periods/events]
```

#### **HARD Topics (liceum - zakres rozszerzony)**
Characteristics:
- Analysis and synthesis
- Evaluations from perspectives
- Complex interdependencies
- Detailed historiography
- Reference: `podstawa/liceum_technikum_zpe.md` → ZAKRES ROZSZERZONY

**Example format:**
```markdown
## Tematy poziom HARD (liceum - zakres rozszerzony)

- **Analiza:** [Deep analysis of phenomena]
- **Ocena z perspektywy:** [Evaluations from different viewpoints]
- **Synteza:** [Synthesis of multiple factors]
- **Interpretacje:** [Historiographical interpretations]
```

### Step 5: Create Summary File

1. **File naming:** `[tech_name]_summary.md`
   - Example: `chrystianizacja_summary.md`, `grunwald_summary.md`

2. **File location:** Place in organized directory structure:
   ```
   history-data/
   ├── {epoch_number}-{epoch_tech_name}/
   │   ├── {chapter_number}-{chapter_tech_name}/
   │   │   └── {chapter_tech_name}_summary.md
   ```
   - Example: `history-data/02-piastowie/01-chrystianizacja/chrystianizacja_summary.md`
   - Epoch and chapter numbers come from `master-list.json` (zero-padded to 2 digits)

3. **File structure:**
   ```markdown
   ---
   chapter: "[short_name]"
   tech_name: "[tech_name]"
   long_name: "[long_name]"
   epoch: "[epoch_short_name]"
   period: "[start_year]-[end_year]"
   created_at: "[ISO 8601 timestamp]"
   summary_type: "chapter_overview"
   ---

   # [Chapter short_name]: [Chapter long_name]

   **Okres:** [start_year] - [end_year]
   **Epoka:** [Epoch short_name]

   ## Przegląd okresu

   [Summary content, max 300 words]

   ## Źródła

   - [Source links]

   ## Tematy poziom EASY (szkoła podstawowa)

   - **Postacie:** [...]
   - **Wydarzenia:** [...]
   - **Miejsca:** [...]
   - **Pojęcia:** [...]

   ## Tematy poziom MEDIUM (liceum - zakres podstawowy)

   - **Przyczyny wydarzeń:** [...]
   - **Skutki historyczne:** [...]
   - **Procesy:** [...]
   - **Porównania:** [...]

   ## Tematy poziom HARD (liceum - zakres rozszerzony)

   - **Analiza:** [...]
   - **Ocena z perspektywy:** [...]
   - **Synteza:** [...]
   - **Interpretacje:** [...]
   ```

## Working Modes

### Automatic Mode (for script integration)

If you receive a chapter identifier (tech_name or full path):

1. Parse the input
2. Execute full workflow (Step 1-5)
3. Return result in JSON format:
   ```json
   {
     "chapter": "chrystianizacja",
     "summary_file": "history-data/02-piastowie/01-chrystianizacja/chrystianizacja_summary.md",
     "word_count": 287,
     "sources_count": 5,
     "topics": {
       "easy": 8,
       "medium": 6,
       "hard": 5
     },
     "status": "success"
   }
   ```
4. Return exit code:
   - `0`: success (summary created)
   - `1`: failure (chapter not found or error)

### Interactive Mode (manual invocation)

If no chapter identifier provided:

1. Ask user for:
   - Chapter tech_name OR
   - Epoch and chapter name OR
   - Time period
2. Confirm chapter identification
3. Execute workflow
4. Present result in human-friendly format
5. Offer to create additional summaries

## Example Output

```markdown
---
chapter: "Chrystianizacja"
tech_name: "chrystianizacja"
long_name: "Państwo Gnieźnieńskie i chrystianizacja"
epoch: "Piastowie"
period: "960-1025"
created_at: "2026-05-04T14:30:00Z"
summary_type: "chapter_overview"
---

# Chrystianizacja: Państwo Gnieźnieńskie i chrystianizacja

**Okres:** 960 - 1025
**Epoka:** Piastowie

## Przegląd okresu

Okres chrystianizacji Polski (960-1025) marks the fundamental transformation of the Polish state from a pagan tribal organization to a Christian kingdom recognized in Europe. The process began with Mieszko I's baptism in 966, which not only introduced Christianity but also integrated Poland into the sphere of Latin civilization and established political alliances with the Holy Roman Empire and Bohemia.

The creation of the first Polish ecclesiastical structure culminated in 1000 with the Congress of Gniezno, where Emperor Otto III met with Bolesław the Brave and established the archbishopric of Gniezno. This event elevated Poland's status to an independent ecclesiastical province, symbolizing its full membership in Christian Europe. Bolesław's coronation in 1025 as the first king of Poland crowned this process, creating a strong central state.

The legacy of this period includes the foundation of Polish statehood, the establishment of the Church as a key institution, and the orientation of Polish culture toward Western Europe. The choice of Latin rite over Byzantine (Orthodox) Christianity determined Poland's cultural and political affiliation for centuries to come.

## Źródła

- [Chrzest Polski](https://pl.wikipedia.org/wiki/Chrzest_Polski) - Wikipedia Polska
- [Zjazd gnieźnieński](https://pl.wikipedia.org/wiki/Zjazd_gnie%C5%Banie%C5%84ski) - Wikipedia Polska
- [Bolesław Chrobry](https://dzieje.pl/postacie/boleslaw-chrobry) - Dzieje.pl
- [Mieszko I](https://pl.wikipedia.org/wiki/Mieszko_I) - Wikipedia Polska

## Tematy poziom EASY (szkoła podstawowa)

- **Postacie:** Mieszko I (pierwszy książę chrześcijański), Bolesław Chrobry (pierwszy król Polski), Otto III (cesarz Świętego Cesarstwa Rzymskiego)
- **Wydarzenia:** Chrzest Polski (966), Zjazd gnieźnieński (1000), Koronacja Bolesława Chrobrego (1025)
- **Miejsca:** Gniezno (pierwsza stolica, arcybiskupstwo), Poznań (pierwsza katedra)
- **Pojęcia:** Chrystianizacja, koronacja, arcybiskupstwo, państwo piastowskie

## Tematy poziom MEDIUM (liceum - zakres podstawowy)

- **Przyczyny wydarzeń:** Polityczne i cywilizacyjne przyczyny chrystianizacji, sojusz z Czechami i cesarstwem, uniknięcie ekspansji niemieckiej
- **Skutki historyczne:** Włączenie Polski do chrześcijańskiej Europy, utworzenie struktur kościelnych, wzrost prestiżu międzynarodowego
- **Procesy:** Proces christianizacji społeczeństwa, budowa kościołów i klasztorów, kształtowanie się kleru
- **Porównania:** Ryt łaciński vs bizantyjski, Polska w relacji do innych państw europejskich

## Tematy poziom HARD (liceum - zakres rozszerzony)

- **Analiza:** Znaczenie wyboru rytu łacińskiego dla dalszych dziejów Polski, rola Kościoła w państwie piastowskim, relacje między władzą świecką a duchowną
- **Ocena z perspektywy:** Zjazd gnieźnieński jako element polityki ottońskiej, znaczenie chrystianizacji dla tożsamości europejskiej Polski
- **Synteza:** Bilans przemian z okresu 960-1025 (politycznych, kulturowych, społecznych), dziedzictwo tego okresu dla późniejszych dziejów
- **Interpretacje:** Dyskusje historiograficzne nad datą chrztu, motywacjami Mieszka I, znaczeniem Zjazdu gnieźnieńskiego
```

## Notes for the Agent

1. **Research accuracy:** Always verify historical facts using multiple sources
2. **Conciseness:** Keep summaries under 300 words - focus on essential information
3. **Curriculum alignment:** Use curriculum files to ensure proper difficulty categorization
4. **Source diversity:** Use both Wikipedia Polska and Dzieje.pl when available
5. **Polish grammar:** Ensure high-quality Polish language (consider using polish-grammar-checker)
6. **File organization:** Use consistent naming and location

## Error Handling

- **Chapter not found:** Provide list of available chapters
- **Insufficient sources:** Use broader search terms or related periods
- **Grammar issues:** Run polish-grammar-checker on generated content
- **File creation errors:** Check directory permissions

## Integration with Question Generation System

This skill supports:
- **Pre-generation research** - Understanding chapter before creating questions
- **Topic mapping** - Identifying question topics by difficulty
- **Content validation** - Ensuring questions align with chapter content
- **Batch processing** - Creating summaries for multiple chapters

---

**Version:** 1.0
**Last updated:** 2026-05-04
**Author:** Claude Code for testdziej-questions
