# Polish Grammar Check Instructions

## When to Use Grammar Checking

Use the Polish grammar checking tool (`mcp__polish-history__check_grammar`) when:

**Polish Text Quality:**
- User asks to check, proofread, or improve Polish text
- User mentions "grammar", "spelling", "język polski", "polszczyzna", "check grammar"
- User wants to validate Polish documents, quiz questions, or messages
- Writing Polish content that needs verification
- Checking Polish educational materials or historical content

**Multi-language Text:**
- User asks to check grammar in any supported language (pl-PL, en-US, en-GB, de-DE, fr-FR, etc.)
- Text contains language-specific errors or style issues
- User wants suggestions for better wording

**Content Creation:**
- Writing quiz questions in Polish (common use case)
- Creating documentation, emails, articles in Polish/English
- Creating formal or professional text
- Proofreading before publishing or sending

## Tool Usage

### Basic Syntax

```
mcp__polish-history__check_grammar(text="text to check", language="pl-PL")
```

### Parameters

- `text` (required): The text to check for grammar errors
- `language` (optional): Language code, default is "pl-PL"
  - Polish: "pl-PL" (most common)
  - English US: "en-US"
  - English GB: "en-GB"
  - German: "de-DE"
  - French: "fr-FR"
  - Spanish: "es-ES"
  - And many more supported by LanguageTool

### Return Format

The tool returns a JSON string with:

```json
{
  "result": "{'matches': [...], 'language': {...}, 'summary': {...}}"
}
```

Actual parsed result contains:

```json
{
  "matches": [
    {
      "message": "Spacje wokół dywizu (w przeciwieństwie do myślnika) są zbędne: \"później-w\"; jeśli to miał być myślnik, to należy napisać \"później — w\".",
      "shortMessage": "Błąd typograficzny",
      "replacements": ["później-w", "później — w"],
      "context": {
        "text": "...się z czeską księżniczką Dobrawą, a rok później - w 966 - przyjął chrzest. Chrzest odbył si...",
        "offset": 43,
        "length": 11
      },
      "offset": 441,
      "length": 11,
      "rule": {
        "id": "DYWIZ",
        "description": "Spacja wokół dywizu",
        "issueType": "typographical",
        "category": {
          "id": "TYPOGRAPHY",
          "name": "Błędy typograficzne"
        }
      },
      "sentence": "W 965 roku ożenił się z czeską księżniczką Dobrawą, a rok później - w 966 - przyjął chrzest."
    }
  ],
  "language": {
    "name": "Polish",
    "code": "pl-PL",
    "detectedLanguage": {
      "name": "Polish",
      "code": "pl-PL",
      "confidence": 0.99999696
    }
  },
  "summary": {
    "total_errors": 1,
    "by_type": {
      "typographical": 1
    }
  }
}
```

## Common Examples

### Polish Grammar Check

```python
# Check Polish text with grammar error
result = await mcp__polish-history__check_grammar(
    text="On poszedł do sklep.",
    language="pl-PL"
)
# Returns: Error "do sklep" should be "do sklepu" (dopełniacz)

# Check correct Polish text
result = await mcp__polish-history__check_grammar(
    text="Ala ma kota.",
    language="pl-PL"
)
# Returns: No errors found (total_errors: 0)
```

### Historical Content Check (Real Example)

```python
# Check Polish historical text for quiz questions
result = await mcp__polish-history__check_grammar(
    text="Chrystianizacja Polski to proces przyjęcia chrześcijaństwa przez księcia Mieszka I, który miał miejsce w 966 roku. To wydarzenie uznaje się za jeden z najważniejszych momentów w historii Polski, ponieważ włączyło nasz kraj do kręgu kultury zachodniej i rozpoczęło oficjalnie państwowość polską.",
    language="pl-PL"
)
# Returns: Typography error - hyphen should be em dash
```

### English Grammar Check

```python
# Check English text
result = await mcp__polish-history__check_grammar(
    text="This are a test.",
    language="en-US"
)
# Returns: 2 errors - "This" should be "These", "are" should be "is"

# Check correct English
result = await mcp__polish-history__check_grammar(
    text="These are tests.",
    language="en-US"
)
# Returns: No errors found
```

### File-Based Grammar Check

```python
# Check quiz question file
result = await mcp__polish-history__check_grammar(
    text="W którym roku Mieszko I przyjął chrzest, co oznaczało chrystianizację Polski? Mieszko I przyjął chrzest w 966 roku. Ta data jest uważana za początek chrystianizacji Polski i jest jednym z najważniejszych wydarzeń w naszej historii.",
    language="pl-PL"
)
# Returns: Typography errors (hyphens instead of em dashes)
```

## Best Practices

**When calling the tool:**
1. Always provide the full text, not just snippets
2. Use the appropriate language code for non-Polish text
3. Don't break text into artificial sentences - provide natural paragraphs
4. Include punctuation marks for better context
5. For long texts, break into logical sections (questions, explanations, etc.)
6. Check multiple sections separately for better error localization

**When interpreting results:**
1. `total_errors: 0` means the text is grammatically correct
2. Check `issueType` to understand error category:
   - `grammar` - Grammar mistakes (most important)
   - `spelling` - Spelling errors (important)
   - `typographical` - Typography issues (important in Polish)
   - `style` - Style suggestions (optional)
3. Use `replacements` array for suggested corrections
4. Consider `shortMessage` for quick error overview
5. Use `message` for detailed explanations in Polish
6. Check `rule.id` to understand the specific grammar rule violated

**When fixing errors:**
1. Present errors to user with context and suggestions
2. Don't auto-fix without user confirmation
3. Consider the context - some suggestions may not fit the intended meaning
4. Prioritize grammar and spelling errors over style suggestions
5. Typography errors (hyphens vs em dashes) are important in Polish
6. Explain the error in the target language when possible

## Error Types Explained

### Grammar Errors (Most Important)
- Incorrect verb forms, conjugations
- Wrong case usage (Polish: mianownik, dopełniacz, etc.)
- Subject-verb agreement issues
- Incorrect preposition usage

### Spelling Errors (Important)
- Typos and misspellings
- Capitalization errors
- Punctuation mistakes

### Typography Errors (Important in Polish)
- Hyphens (`-`) vs em dashes (`—`) - very common issue
- Spacing around punctuation marks
- Quote marks and apostrophes

### Style Suggestions (Optional)
- Better word choices
- More formal/informal alternatives
- Clarity improvements

## Workflow Patterns

**Standard grammar check workflow:**
1. Receive text from user or file
2. Call `mcp__polish-history__check_grammar()` with appropriate language
3. Parse JSON result
4. Present errors clearly with context
5. Show replacement suggestions
6. Ask user if they want help implementing corrections

**File-based workflow (for quiz questions, documents):**
1. Read the file to be checked
2. Extract key sections (questions, explanations, summaries)
3. Check each section separately
4. Aggregate all errors found
5. Present summary with line numbers and error types
6. Offer to fix all errors or review individually

**Example interaction:**
```
User: "Check this Polish text: On poszedł do sklep."
Agent: [Calls mcp__polish-history__check_grammar()]
Agent: "Found 1 grammar error:
       Error: 'do sklep' → should be 'do sklepu'
       Rule: Przyimek wymaga dopełniacza (preposition requires genitive case)
       Suggestion: Use 'do sklepu' instead of 'do sklep'"
```

**Real example from quiz file:**
```
User: "Check the grammar of piastowie-chrystianizacja-easy.md"
Agent: [Reads file, checks sections with grammar tool]
Agent: "Grammar check complete. Found 12 typography issues:
       Main Issue: Hyphens used instead of em dashes
       Examples:
       - 'później - w 966' should be 'później — w 966'
       - 'Polski - w tym czasie' should be 'Polski — w tym czasie'

       All errors are typographical, not grammatical.
       Text quality: GOOD for educational content."
```

## Limitations

**What the tool CAN do:**
- Detect grammar and spelling errors accurately
- Provide replacement suggestions
- Support multiple languages (50+ languages)
- Give detailed error explanations in the target language
- Work with various text types (formal, informal, technical)
- Identify typography issues important in Polish publishing
- Handle educational content well

**What the tool CANNOT do:**
- Understand deep context or user intent
- Detect semantic errors (wrong meaning but correct grammar)
- Verify factual accuracy of historical content
- Handle code syntax or technical programming languages
- Process very long texts efficiently (break into chunks < 2000 words)
- Detect style inconsistencies across documents
- Verify if quiz questions are pedagogically sound

## Integration Notes

**Tool availability:**
- MCP tool name: `mcp__polish-history__check_grammar`
- Part of the polish-history MCP server
- Requires: MCP server running and configured in Claude Code
- Parameters: `text` (required), `language` (optional, default "pl-PL")

**Service architecture:**
- Uses LanguageTool API (languagetool.org)
- No local service management required
- MCP server handles the connection automatically
- Works offline with cached grammar rules

**Performance considerations:**
- Response time: ~1-3 seconds for typical text segments
- Optimal text length: 100-500 characters per call
- For long documents, check section by section
- Rate limiting: No significant limits observed

## Polish-Specific Issues

### Common Typography Errors in Polish

**Hyphens vs Em Dashes:**
- ❌ Wrong: `później - w 966 roku` (hyphen without spaces)
- ✅ Correct: `później — w 966 roku` (em dash with spaces)
- Rule ID: `DYWIZ`
- Very common in educational content and quiz questions

**Spacing Around Punctuation:**
- ❌ Wrong: `słowo ,inne słowo` (space before comma)
- ✅ Correct: `słowo, inne słowo` (no space before comma)

**Quote Marks:**
- Polish uses specific quote marks: „...” or «...»
- Not English-style "..." or German-style ,,..."

### Grammar Categories in Polish

**Cases (Przypadki):**
- Mianownik (nominative): Ala ma kota.
- Dopełniacz (genitive): Nie mam kota.
- Celownik (dative): Dam kotu mleko.
- Biernik (accusative): Widzę kota.
- Narzędnik (instrumental): Interesuję się kotem.
- Miejscownik (locative): Mówię o kocie.
- Wołacz (vocative): O kocie!

**Common Issues:**
- Preposition-case mismatch (e.g., "do sklep" → "do sklepu")
- Wrong verb conjugations
- Gender agreement errors
- Number agreement errors

## Testing

**Quick verification:**
```python
# Test Polish grammar
result = await mcp__polish-history__check_grammar(
    text="To jest test.",
    language="pl-PL"
)
# Should return: total_errors: 0

# Test error detection
result = await mcp__polish-history__check_grammar(
    text="On idzie do sklep.",
    language="pl-PL"
)
# Should return: 1 error (sklep → sklepu)
```

**Expected behavior:**
- Correct text: Returns `total_errors: 0`
- Incorrect text: Returns matches with suggestions
- Network issues: May timeout or return connection errors
