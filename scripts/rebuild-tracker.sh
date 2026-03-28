#!/bin/bash

# Rebuild questions-tracker.json from validated questions
# Scans all validated question files and updates the tracker

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
VALIDATED_DIR="$PROJECT_DIR/questions/validated"
TRACKER_FILE="$PROJECT_DIR/.claude/questions-tracker.json"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Rebuilding Questions Tracker${NC}"
echo -e "${BLUE}========================================${NC}"

# Check if validated directory exists
if [ ! -d "$VALIDATED_DIR" ]; then
    echo -e "${YELLOW}No validated questions directory found${NC}"
    exit 0
fi

# Count questions by epoch, chapter, and difficulty
echo -e "${GREEN}Scanning validated questions...${NC}"

# Use jq to initialize a new tracker structure
jq '{
  tracking: {
    "Starożytność": {
      "Pradzieje": {"easy": 0, "medium": 0, "hard": 0},
      "Słowianie": {"easy": 0, "medium": 0, "hard": 0}
    },
    "Piastowie": {
      "Chrystianizacja": {"easy": 0, "medium": 0, "hard": 0},
      "Ekspansja": {"easy": 0, "medium": 0, "hard": 0},
      "Rozbicie dzielnicowe I": {"easy": 0, "medium": 0, "hard": 0},
      "Najazd mongolski": {"easy": 0, "medium": 0, "hard": 0},
      "Zjednoczenie": {"easy": 0, "medium": 0, "hard": 0},
      "Łokietek": {"easy": 0, "medium": 0, "hard": 0},
      "Kazimierz Wielki": {"easy": 0, "medium": 0, "hard": 0}
    },
    "Jagiellonowie": {
      "Unia Krewska": {"easy": 0, "medium": 0, "hard": 0},
      "Grunwald": {"easy": 0, "medium": 0, "hard": 0},
      "Warneńczyk": {"easy": 0, "medium": 0, "hard": 0},
      "Kazimierz Jagiellończyk": {"easy": 0, "medium": 0, "hard": 0},
      "Wojna trzynastoletnia": {"easy": 0, "medium": 0, "hard": 0},
      "Zygmunt Stary": {"easy": 0, "medium": 0, "hard": 0},
      "Zygmunt August": {"easy": 0, "medium": 0, "hard": 0}
    },
    "Rzeczpospolita": {
      "Unia Lubelska": {"easy": 0, "medium": 0, "hard": 0},
      "Wazowie": {"easy": 0, "medium": 0, "hard": 0},
      "Wojny polsko-tureckie": {"easy": 0, "medium": 0, "hard": 0},
      "Potop": {"easy": 0, "medium": 0, "hard": 0},
      "Sobieski": {"easy": 0, "medium": 0, "hard": 0},
      "Czasy saskie": {"easy": 0, "medium": 0, "hard": 0},
      "Oświecenie": {"easy": 0, "medium": 0, "hard": 0},
      "Upadek": {"easy": 0, "medium": 0, "hard": 0}
    },
    "Rozbiory": {
      "Rozbiory": {"easy": 0, "medium": 0, "hard": 0},
      "Insurekcja": {"easy": 0, "medium": 0, "hard": 0},
      "Księstwo Warszawskie": {"easy": 0, "medium": 0, "hard": 0},
      "Kongresówka": {"easy": 0, "medium": 0, "hard": 0},
      "Powstanie listopadowe": {"easy": 0, "medium": 0, "hard": 0},
      "Wiosna Ludów": {"easy": 0, "medium": 0, "hard": 0},
      "Powstanie styczniowe": {"easy": 0, "medium": 0, "hard": 0},
      "Praca organiczna": {"easy": 0, "medium": 0, "hard": 0}
    },
    "Międzywojnie": {
      "Odrodzenie": {"easy": 0, "medium": 0, "hard": 0},
      "Wojna bolszewicka": {"easy": 0, "medium": 0, "hard": 0},
      "Budowa państwa": {"easy": 0, "medium": 0, "hard": 0},
      "Przewrót majowy": {"easy": 0, "medium": 0, "hard": 0},
      "Sanacja": {"easy": 0, "medium": 0, "hard": 0},
      "Zagrożenie": {"easy": 0, "medium": 0, "hard": 0}
    },
    "II WŚ": {
      "Kampania wrześniowa": {"easy": 0, "medium": 0, "hard": 0},
      "Okupacja": {"easy": 0, "medium": 0, "hard": 0},
      "Ruch oporu": {"easy": 0, "medium": 0, "hard": 0},
      "Powstanie warszawskie": {"easy": 0, "medium": 0, "hard": 0},
      "Holocaust": {"easy": 0, "medium": 0, "hard": 0},
      "Wyzwolenie": {"easy": 0, "medium": 0, "hard": 0}
    },
    "PRL": {
      "Początki PRL": {"easy": 0, "medium": 0, "hard": 0},
      "Stalinizm": {"easy": 0, "medium": 0, "hard": 0},
      "Październik 56": {"easy": 0, "medium": 0, "hard": 0},
      "Gomułka": {"easy": 0, "medium": 0, "hard": 0},
      "Grudzień 70": {"easy": 0, "medium": 0, "hard": 0},
      "Gierek": {"easy": 0, "medium": 0, "hard": 0},
      "Solidarność": {"easy": 0, "medium": 0, "hard": 0},
      "Stan wojenny": {"easy": 0, "medium": 0, "hard": 0},
      "Okrągły Stół": {"easy": 0, "medium": 0, "hard": 0}
    },
    "III RP": {
      "Transformacja": {"easy": 0, "medium": 0, "hard": 0},
      "Balcerowicz": {"easy": 0, "medium": 0, "hard": 0},
      "Rządy III RP": {"easy": 0, "medium": 0, "hard": 0},
      "Integracja": {"easy": 0, "medium": 0, "hard": 0}
    }
  },
  last_updated: null
}' > "$TRACKER_FILE.tmp"

# Counter for total questions
total_count=0

# Process each validated question file
for file in "$VALIDATED_DIR"/*.md; do
  if [ -f "$file" ]; then
    # Extract metadata from the file
    epoch=$(grep '^epoch:' "$file" | cut -d':' -f2- | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' || echo "")
    chapter=$(grep '^chapter:' "$file" | cut -d':' -f2- | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' || echo "")
    difficulty=$(grep '^difficulty:' "$file" | cut -d':' -f2- | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' || echo "")

    if [ -n "$epoch" ] && [ -n "$chapter" ] && [ -n "$difficulty" ]; then
      # Increment the counter in the tracker
      jq --arg epoch "$epoch" \
         --arg chapter "$chapter" \
         --arg difficulty "$difficulty" \
         '.tracking[$epoch][$chapter][$difficulty] += 1' \
         "$TRACKER_FILE.tmp" > "$TRACKER_FILE.tmp2" && \
      mv "$TRACKER_FILE.tmp2" "$TRACKER_FILE.tmp"

      total_count=$((total_count + 1))
    fi
  fi
done

# Update the last_updated timestamp
jq --arg timestamp "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" \
   '.last_updated = $timestamp' \
   "$TRACKER_FILE.tmp" > "$TRACKER_FILE" && \
rm "$TRACKER_FILE.tmp"

echo -e "${GREEN}Tracker rebuilt successfully!${NC}"
echo "Total questions found: $total_count"
echo "Updated: $TRACKER_FILE"

# Show summary
echo -e "\n${BLUE}Questions per epoch:${NC}"
jq -r '
  to_entries[] |
  select(.key != "last_updated") |
  .key as $epoch |
  .value |
  to_entries[] |
  .key as $chapter |
  .value |
  to_entries[] |
  select(.value > 0) |
  "\($epoch) - \($chapter) - \(.key): \(.value)"
' "$TRACKER_FILE"

exit 0
