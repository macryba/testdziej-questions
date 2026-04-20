#!/bin/bash

# Difficulty Reviewer - Weryfikacja poziomów trudności pytań historycznych
# Użycie: ./scripts/difficulty-reviewer.sh [ścieżka-do-pliku-z-pytaniem]
# Lub użyj skill: difficulty-reviewer w Claude Code

PROJECT_ROOT="/home/macryba/testdziej-questions"
SKILL_FILE="$PROJECT_ROOT/.claude/skills/difficulty-reviewer/SKILL.md"

# Kolory do outputu
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Funkcja wyświetlająca użycie
usage() {
    echo "Użycie: $0 [opcje] [plik-z-pytaniem]"
    echo ""
    echo "Opcje:"
    echo "  -h, --help     Pokaż tę pomoc"
    echo "  -l, --level    Sugerowany poziom (EASY|MEDIUM|HARD)"
    echo "  -j, --json     Zwróć wynik w formacie JSON"
    echo "  -v, --verbose  Tryb gadatlny"
    echo ""
    echo "Przykłady:"
    echo "  $0 questions/validated/piastowie-chrystianizacja-easy.md"
    echo "  $0 -l EASY questions/validated/piastowie-chrystianizacja-easy.md"
    echo "  $0 -j -l MEDIUM questions/validated/piastowie-rozbicie-dzielnicowe-medium.md"
    exit 1
}

# Parsowanie argumentów
LEVEL=""
JSON_OUTPUT=false
VERBOSE=false
QUESTION_FILE=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            usage
            ;;
        -l|--level)
            LEVEL="$2"
            shift 2
            ;;
        -j|--json)
            JSON_OUTPUT=true
            shift
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -*)
            echo -e "${RED}Błąd:${NC} Nieznana opcja: $1"
            usage
            ;;
        *)
            QUESTION_FILE="$1"
            shift
            ;;
    esac
done

# Sprawdzenie czy plik z pytaniem został podany
if [[ -z "$QUESTION_FILE" ]]; then
    echo -e "${RED}Błąd:${NC} Nie podano pliku z pytaniem"
    usage
fi

# Sprawdzenie czy plik istnieje
if [[ ! -f "$QUESTION_FILE" ]]; then
    echo -e "${RED}Błąd:${NC} Plik nie istnieje: $QUESTION_FILE"
    exit 1
fi

# Przygotowanie promptu dla agenta
if [[ "$JSON_OUTPUT" == true ]]; then
    PROMPT="Weryfikuj pytanie w pliku: $QUESTION_FILE"
    if [[ -n "$LEVEL" ]]; then
        PROMPT="$PROMPT

Sugerowany poziom: $LEVEL"
    fi
    PROMPT="$PROMPT

Zwróć wynik TYLKO w formacie JSON (bez dodatkowego tekstu):
{
  \"question\": \"\",
  \"labeled_difficulty\": \"$LEVEL\",
  \"verified_difficulty\": \"\",
  \"is_correct\": false,
  \"reason\": \"\"
}"
else
    PROMPT="Jesteś Difficulty Reviewer. Weryfikuj pytanie w pliku: $QUESTION_FILE"
    if [[ -n "$LEVEL" ]]; then
        PROMPT="$PROMPT

Sugerowany poziom: $LEVEL"
    fi
    PROMPT="$PROMPT

Przedstaw wynik w formacie raportu markdown."
fi

# Wyświetlenie promptu (dla debugowania)
if [[ "$VERBOSE" == true ]]; then
    echo -e "${YELLOW}Prompt dla agenta:${NC}"
    echo "$PROMPT"
    echo "---"
fi

# Uruchomienie agenta (tu powinno być wywołanie Claude Code)
# Na razie tylko wyświetlamy instrukcję
echo -e "${GREEN}Difficulty Reviewer Agent${NC}"
echo ""
echo "Plik z pytaniem: $QUESTION_FILE"
if [[ -n "$LEVEL" ]]; then
    echo "Sugerowany poziom: $LEVEL"
fi
echo ""
echo -e "${YELLOW}Aby uruchomić agenta, użyj w Claude Code:${NC}"
echo ""
echo "Powiedz mi: 'Uruchom difficulty-reviewer dla pliku $QUESTION_FILE'"
if [[ -n "$LEVEL" ]]; then
    echo "z sugerowanym poziomem: $LEVEL"
fi
echo ""
echo "Lub użyj Skill tool:"
echo "  skill: difficulty-reviewer"
echo "  args: $QUESTION_FILE"
echo ""
exit 0
