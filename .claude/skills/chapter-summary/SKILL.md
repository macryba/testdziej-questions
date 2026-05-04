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

#### **EASY Topics (szkoła podstawowa) - WITH CURRICULUM VERIFICATION**

**CRITICAL:** Before categorizing EASY topics, verify against primary school curriculum:
1. Read `/home/macryba/testdziej-questions/history-data/podstawa/szkola_podstawowa_zpe.md`
2. Check if the chapter topic appears in:
   - **Dział IV:** 17 key figures (Mieszko, Bolesław Chrobry, Kazimierz Wielki, etc.)
   - **Dział VI:** Rozbicie dzielnicowe and zjednoczenie (general coverage only)
   - **Treści dodatkowe:** 9 optional topics
3. Make a determination:

**Case 1: Topic NOT in primary school curriculum**
- Summary states: `**Temat nie ujęty w poziomie szkoły podstawowej.**`
- No EASY topics listed
- Recommendation: EASY questions file should contain only the statement

**Case 2: Topic HAS limited curriculum coverage**
- List available topics but note: `**Temat ograniczony w podstawie programowej.**`
- Recommend specific question count: `**Zalecana liczba pytań EASY: X**` (where X = 3-5)
- Only list topics that are actually in the curriculum

**Case 3: Topic HAS full curriculum coverage**
- List all relevant topics normally
- Default recommendation: 10 questions

Characteristics of EASY topics:
- Concrete facts: who, what, where, when
- Simple names, dates, places
- No cause-and-effect analysis
- Reference: `/home/macryba/testdziej-questions/history-data/podstawa/szkola_podstawowa_zpe.md`

**Example format (Case 1 - Not in curriculum):**
```markdown
## Tematy poziom EASY (szkoła podstawowa)

**Temat nie ujęty w poziomie szkoły podstawowej.**

Ten rozdział wykracza poza zakres podstawy programowej szkoły podstawowej (klasy IV-VIII). Zgodnie z podstawą programową, ten temat nie jest objęty wymaganiami dla szkoły podstawowej.

**Uwaga:** Proste pytania faktyczne (Kto? Co? Gdzie? Kiedy?) związane z tym tematem powinny być zawarte w pytaniach poziomu średniego (MEDIUM).

**Zalecana liczba pytań EASY:** 0 (plik z informacją o braku pytań)
**Zalecana liczba pytań MEDIUM:** 10-15 (w tym pytania faktograficzne z podstawy programowej)
```

**Example format (Case 2 - Limited coverage):**
```markdown
## Tematy poziom EASY (szkoła podstawowa)

**Temat ograniczony w podstawie programowej.**

- **Postacie:** [Only figures listed in Dział IV]
- **Wydarzenia:** [Only events from curriculum]
- **Miejsca:** [Key locations from curriculum]
- **Pojęcia:** [Basic terms from curriculum]

**Zalecana liczba pytań EASY:** 3-5 (zgodnie z zakresem w podstawie programowej)
```

**Example format (Case 3 - Full coverage):**
```markdown
## Tematy poziom EASY (szkoła podstawowa)

- **Postacie:** [Key figures with simple descriptions]
- **Wydarzenia:** [Major events with dates]
- **Miejsca:** [Important locations]
- **Pojęcia:** [Basic terms]

**Zalecana liczba pytań EASY:** 10
```

#### **MEDIUM Topics (liceum - zakres podstawowy)**
Characteristics:
- **Simple factual questions (Kto? Co? Gdzie? Kiedy?)** - IMPORTANT: These are NOT exclusive to EASY level
  - When EASY is not in curriculum, these questions belong in MEDIUM
  - All simple factual questions from curriculum should be at MEDIUM level
  - Examples: names, dates, places, events
- **Analytical questions (Dlaczego? Jakie skutki?)**
  - Causes and effects: why, what effects
  - Analysis of processes and phenomena
  - Comparison of events
- Reference: `/home/macryba/testdziej-questions/history-data/podstawa/liceum_technikum_zpe.md` → ZAKRES PODSTAWOWY

**Example format (when EASY IS in curriculum):**
```markdown
## Tematy poziom MEDIUM (liceum - zakres podstawowy)

- **Przyczyny wydarzeń:** [What caused major events]
- **Skutki historyczne:** [Consequences and effects]
- **Procesy:** [Historical processes and developments]
- **Porównania:** [Comparisons with other periods/events]

**Zalecana liczba pytań MEDIUM:** 10
```

**Example format (when EASY is NOT in curriculum):**
```markdown
## Tematy poziom MEDIUM (liceum - zakres podstawowy)

**Uwaga:** Poziom łatwy (EASY) nie jest objęty podstawą programową dla tego tematu. Proste pytania faktograficzne (Kto? Co? Gdzie? Kiedy?) znajdują się na poziomie średnim.

- **Pytania faktograficzne (Kto? Co? Gdzie? Kiedy?):**
  - [Key figures from the period]
  - [Major events with dates]
  - [Important locations]
  - [Basic terms and concepts]
- **Przyczyny wydarzeń:** [What caused major events]
- **Skutki historyczne:** [Consequences and effects]
- **Procesy:** [Historical processes and developments]
- **Porównania:** [Comparisons with other periods/events]

**Zalecana liczba pytań MEDIUM:** 12-15 (z uwzględnieniem pytań faktograficznych)
```

#### **HARD Topics (liceum - zakres rozszerzony)**
Characteristics:
- **Analytical questions** (primary focus):
  - Analysis and synthesis
  - Evaluations from perspectives
  - Complex interdependencies
  - Detailed historiography
  - Reference: `/home/macryba/testdziej-questions/history-data/podstawa/liceum_technikum_zpe.md` → ZAKRES ROZSZERZONY
- **Specialized factual questions** (secondary):
  - Simple question types (Kto? Co? Gdzie? Kiedy?) for topics NOT in curriculum
  - Events, places, figures outside standard curriculum coverage
  - More obscure but historically significant details
  - Content not covered in liceum_technikum_zpe.md

**Question count:** 0-5 maximum
- Only generate if summary has clear HARD topics OR specialized factual content
- If neither exists: HARD section should state "Brak pytań na poziomie rozszerzonym"

**Example format (with HARD topics):**
```markdown
## Tematy poziom HARD (liceum - zakres rozszerzony)

- **Analiza:** [Deep analysis of phenomena]
- **Ocena z perspektywy:** [Evaluations from different viewpoints]
- **Synteza:** [Synthesis of multiple factors]
- **Treści specjalistyczne (poza programem):** [Specialized factual content outside curriculum]

**Zalecana liczba pytań HARD:** 3-5
```

**Example format (without HARD topics):**
```markdown
## Tematy poziom HARD (liceum - zakres rozszerzony)

**Brak tematów na poziomie rozszerzonym.**

Ten rozdział nie zawiera tematów wymagających analizy na poziomie rozszerzonym (zakres rozszerzony podstawy programowej). Wszystkie istotne zagadnienia zostały objęte poziomem podstawowym (MEDIUM).

**Zalecana liczba pytań HARD:** 0
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
   easy_question_count: [0 or 3-5 or up to 10]
   medium_question_count: [10-15]
   hard_question_count: [0-5]
   curriculum_coverage: ["none" or "limited" or "full"]
   ---

   # [Chapter short_name]: [Chapter long_name]

   **Okres:** [start_year] - [end_year]
   **Epoka:** [Epoch short_name]

   ## Przegląd okresu

   [Summary content, max 300 words]

   ## Źródła

   - [Source links]

   ## Tematy poziom EASY (szkoła podstawowa)

   [One of three formats based on curriculum verification:
   1. "Temat nie ujęty w podstawie programowej" + easy_question_count: 0
   2. "Temat ograniczony" + topics list + easy_question_count: 3-5
   3. Full topics list + easy_question_count: up to 10]

   ## Tematy poziom MEDIUM (liceum - zakres podstawowy)

   [If EASY in curriculum: Focus on analytical topics]
   [If EASY NOT in curriculum: Include simple factual + analytical topics]
   [Recommended count varies: 10-15]

   ## Tematy poziom HARD (liceum - zakres rozszerzony)

   [One of two formats:
   1. With HARD topics: lista tematów analitycznych + treści specjalistyczne (0-5 pytań)
   2. Without HARD topics: "Brak tematów na poziomie rozszerzonym" (0 pytań)]
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
     "curriculum": {
       "easy_coverage": "full",
       "easy_question_count": 10,
       "medium_question_count": 10,
       "hard_question_count": 3
     },
     "status": "success"
   }
   ```

**Curriculum field values:**
- `easy_coverage`: "none" | "limited" | "full"
- `easy_question_count`: 0 | 3-5 | up to 10
- `medium_question_count`: 10-15 (higher if EASY not in curriculum)
- `hard_question_count`: 0-5 (only if HARD topics exist)
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
3. **Curriculum verification:**
   - **CRITICAL for EASY level:** Always verify against `/home/macryba/testdziej-questions/history-data/podstawa/szkola_podstawowa_zpe.md`
   - Check Dział IV (17 figures) and Dział VI (rozbicie dzielnicowe)
   - Be honest about curriculum coverage - don't force topics into EASY if they're not there
   - Mark topics as "none", "limited", or "full" coverage
   - Recommend appropriate question counts (0, 3-5, or 10)
4. **HARD topic identification:**
   - Look for analytical, evaluative, or synthetic topics in the research
   - Check against `/home/macryba/testdziej-questions/history-data/podstawa/liceum_technikum_zpe.md` → ZAKRES ROZSZERZONY
   - Identify specialized factual content outside curriculum (obscure figures, detailed dates, specific locations)
   - Be conservative - if no clear HARD topics exist, set count to 0
   - HARD should be the exception, not the rule
5. **Source diversity:** Use both Wikipedia Polska and Dzieje.pl when available
6. **Polish grammar:** Ensure high-quality Polish language (consider using polish-grammar-checker)
7. **File organization:** Use consistent naming and location

## Error Handling

- **Chapter not found:** Provide list of available chapters
- **Insufficient sources:** Use broader search terms or related periods
- **Grammar issues:** Run polish-grammar-checker on generated content
- **File creation errors:** Check directory permissions

## Integration with Question Generation System

This skill supports:
- **Pre-generation research** - Understanding chapter before creating questions
- **Topic mapping** - Identifying question topics by difficulty
- **Curriculum verification** - Checking EASY topics against primary school curriculum
- **Question count recommendation** - Suggesting appropriate question counts for all levels
- **Content validation** - Ensuring questions align with chapter content
- **Batch processing** - Creating summaries for multiple chapters

**Workflow integration:**
1. Chapter summary is created first (with curriculum verification)
2. Question generation uses the summary's assessment:
   - **EASY level:**
     - If "none": Create EASY file with statement only (0 questions)
     - If "limited": Generate recommended count (3-5 questions)
     - If "full": Generate up to 10 questions
   - **MEDIUM level:**
     - If EASY "none" or "limited": Include simple factual questions + analytical (12-15 questions)
     - If EASY "full": Focus on analytical questions (10 questions)
   - **HARD level:**
     - If summary has HARD topics OR specialized factual content: Generate 3-5 questions
     - If summary has neither: Create HARD file with statement only (0 questions)
3. Total questions per chapter: 10-30 (variable based on curriculum coverage and content depth)

---

**Version:** 1.0
**Last updated:** 2026-05-04
**Author:** Claude Code for testdziej-questions
