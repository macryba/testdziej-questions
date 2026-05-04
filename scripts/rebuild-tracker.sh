#!/bin/bash

# Rebuild questions-tracker.json from generated question files
# Scans all question files in history-data/ and updates the tracker

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
HISTORY_DIR="$PROJECT_DIR/history-data"
TRACKER_FILE="$PROJECT_DIR/history-data/questions-tracker.json"
MASTER_LIST="$PROJECT_DIR/history-data/master-list.json"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Rebuilding Questions Tracker${NC}"
echo -e "${BLUE}========================================${NC}"

# Check if master list exists
if [ ! -f "$MASTER_LIST" ]; then
    echo -e "${YELLOW}Warning: master-list.json not found, using default structure${NC}"
fi

# Initialize tracker from master-list.json if it exists
if [ -f "$MASTER_LIST" ]; then
    echo -e "${GREEN}Initializing tracker from master-list.json...${NC}"

    # Build tracker structure from master-list.json
    jq '
      {
        tracking: {
          .epochs | reduce .[] as $epoch (
            {};
            . + {
              ($epoch.short_name): (
                $epoch.chapters | reduce .[] as $chapter (
                  {};
                  . + {
                    ($chapter.short_name): {
                      easy: 0,
                      medium: 0,
                      hard: 0
                    }
                  }
                )
              )
            }
          )
        },
        last_updated: null
      }
    ' "$MASTER_LIST" > "$TRACKER_FILE.tmp"
else
    # Fallback: use hardcoded structure
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
fi

# Counter for total questions
total_questions=0

echo -e "${GREEN}Scanning question files in history-data/...${NC}"

# Find all question files (new structure)
for file in $(find "$HISTORY_DIR" -name "*_questions_*.md" -type f); do
    # Extract metadata from the file
    epoch=$(grep '^epoch:' "$file" 2>/dev/null | cut -d':' -f2- | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' || echo "")
    chapter=$(grep '^chapter:' "$file" 2>/dev/null | cut -d':' -f2- | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' || echo "")
    difficulty=$(grep '^difficulty:' "$file" 2>/dev/null | cut -d':' -f2- | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | tr '[:upper:]' '[:lower:]' || echo "")
    question_count=$(grep '^question_count:' "$file" 2>/dev/null | cut -d':' -f2- | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' || echo "0")

    if [ -n "$epoch" ] && [ -n "$chapter" ] && [ -n "$difficulty" ]; then
        echo "  Found: $epoch/$chapter/$difficulty ($question_count questions)"

        # Add the question count to the tracker
        jq --arg epoch "$epoch" \
           --arg chapter "$chapter" \
           --arg difficulty "$difficulty" \
           --argjson count "$question_count" \
           '.tracking[$epoch][$chapter][$difficulty] += $count' \
           "$TRACKER_FILE.tmp" > "$TRACKER_FILE.tmp2" && \
        mv "$TRACKER_FILE.tmp2" "$TRACKER_FILE.tmp"

        total_questions=$((total_questions + question_count))
    fi
done

# Also check old structure for backward compatibility
if [ -d "$PROJECT_DIR/questions/validated" ]; then
    echo -e "${YELLOW}Also checking old questions/validated/ directory...${NC}"

    for file in "$PROJECT_DIR/questions/validated"/*.md; do
        if [ -f "$file" ]; then
            epoch=$(grep '^epoch:' "$file" 2>/dev/null | cut -d':' -f2- | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' || echo "")
            chapter=$(grep '^chapter:' "$file" 2>/dev/null | cut -d':' -f2- | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' || echo "")
            difficulty=$(grep '^difficulty:' "$file" 2>/dev/null | cut -d':' -f2- | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | tr '[:upper:]' '[:lower:]' || echo "")
            question_count=$(grep '^question_count:' "$file" 2>/dev/null | cut -d':' -f2- | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' || echo "1")

            if [ -n "$epoch" ] && [ -n "$chapter" ] && [ -n "$difficulty" ]; then
                echo "  Found (old): $epoch/$chapter/$difficulty ($question_count questions)"

                jq --arg epoch "$epoch" \
                   --arg chapter "$chapter" \
                   --arg difficulty "$difficulty" \
                   --argjson count "$question_count" \
                   '.tracking[$epoch][$chapter][$difficulty] += $count' \
                   "$TRACKER_FILE.tmp" > "$TRACKER_FILE.tmp2" && \
                mv "$TRACKER_FILE.tmp2" "$TRACKER_FILE.tmp"

                total_questions=$((total_questions + question_count))
            fi
        fi
    done
fi

# Update the last_updated timestamp
jq --arg timestamp "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" \
   '.last_updated = $timestamp' \
   "$TRACKER_FILE.tmp" > "$TRACKER_FILE" && \
rm "$TRACKER_FILE.tmp"

echo -e "${GREEN}✓ Tracker rebuilt successfully!${NC}"
echo "Total questions found: $total_questions"
echo "Updated: $TRACKER_FILE"
echo ""

# Show summary
echo -e "${BLUE}Summary by epoch:${NC}"
jq -r '
  .tracking |
  to_entries[] |
  select(.key != "last_updated") |
  .key as $epoch |
  .value |
  to_entries[] |
  reduce (.value | to_entries[]) as $item (
    {total: 0};
    .total += $item.value |
    .chapters += [$item.key + ": " + ($item.value | tostring)]
  ) |
  select(.total > 0) |
  "\n\($epoch):\n  " + (.chapters | join("\n  ")) |
  gsub(": 0"; "")
' "$TRACKER_FILE"

echo ""
echo -e "${BLUE}Next chapters needing questions:${NC}"
jq -r '
  .tracking |
  to_entries[] |
  select(.key != "last_updated") |
  .key as $epoch |
  .value |
  to_entries[] |
  .key as $chapter |
  select(.value.easy < 10 or .value.medium < 10 or .value.hard < 10) |
  "  \($epoch)/\($chapter): easy=\(.value.easy) medium=\(.value.medium) hard=\(.value.hard)"
' "$TRACKER_FILE" | head -10

exit 0
