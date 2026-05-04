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
                      easy_completed: false,
                      medium: 0,
                      medium_completed: false,
                      hard: 0,
                      hard_completed: false
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
          "Pradzieje": {"easy": 0, "easy_completed": false, "medium": 0, "medium_completed": false, "hard": 0, "hard_completed": false},
          "Słowianie": {"easy": 0, "easy_completed": false, "medium": 0, "medium_completed": false, "hard": 0, "hard_completed": false}
        },
        "Piastowie": {
          "Chrystianizacja": {"easy": 0, "easy_completed": false, "medium": 0, "medium_completed": false, "hard": 0, "hard_completed": false},
          "Ekspansja": {"easy": 0, "easy_completed": false, "medium": 0, "medium_completed": false, "hard": 0, "hard_completed": false},
          "Rozbicie dzielnicowe I": {"easy": 0, "easy_completed": false, "medium": 0, "medium_completed": false, "hard": 0, "hard_completed": false},
          "Najazd mongolski": {"easy": 0, "easy_completed": false, "medium": 0, "medium_completed": false, "hard": 0, "hard_completed": false},
          "Zjednoczenie": {"easy": 0, "easy_completed": false, "medium": 0, "medium_completed": false, "hard": 0, "hard_completed": false},
          "Łokietek": {"easy": 0, "easy_completed": false, "medium": 0, "medium_completed": false, "hard": 0, "hard_completed": false},
          "Kazimierz Wielki": {"easy": 0, "easy_completed": false, "medium": 0, "medium_completed": false, "hard": 0, "hard_completed": false}
        },
        "Jagiellonowie": {
          "Unia Krewska": {"easy": 0, "easy_completed": false, "medium": 0, "medium_completed": false, "hard": 0, "hard_completed": false},
          "Grunwald": {"easy": 0, "easy_completed": false, "medium": 0, "medium_completed": false, "hard": 0, "hard_completed": false},
          "Warneńczyk": {"easy": 0, "easy_completed": false, "medium": 0, "medium_completed": false, "hard": 0, "hard_completed": false},
          "Kazimierz Jagiellończyk": {"easy": 0, "easy_completed": false, "medium": 0, "medium_completed": false, "hard": 0, "hard_completed": false},
          "Wojna trzynastoletnia": {"easy": 0, "easy_completed": false, "medium": 0, "medium_completed": false, "hard": 0, "hard_completed": false},
          "Zygmunt Stary": {"easy": 0, "easy_completed": false, "medium": 0, "medium_completed": false, "hard": 0, "hard_completed": false},
          "Zygmunt August": {"easy": 0, "easy_completed": false, "medium": 0, "medium_completed": false, "hard": 0, "hard_completed": false}
        },
        "Rzeczpospolita": {
          "Unia Lubelska": {"easy": 0, "easy_completed": false, "medium": 0, "medium_completed": false, "hard": 0, "hard_completed": false},
          "Wazowie": {"easy": 0, "easy_completed": false, "medium": 0, "medium_completed": false, "hard": 0, "hard_completed": false},
          "Wojny polsko-tureckie": {"easy": 0, "easy_completed": false, "medium": 0, "medium_completed": false, "hard": 0, "hard_completed": false},
          "Potop": {"easy": 0, "easy_completed": false, "medium": 0, "medium_completed": false, "hard": 0, "hard_completed": false},
          "Sobieski": {"easy": 0, "easy_completed": false, "medium": 0, "medium_completed": false, "hard": 0, "hard_completed": false},
          "Czasy saskie": {"easy": 0, "easy_completed": false, "medium": 0, "medium_completed": false, "hard": 0, "hard_completed": false},
          "Oświecenie": {"easy": 0, "easy_completed": false, "medium": 0, "medium_completed": false, "hard": 0, "hard_completed": false},
          "Upadek": {"easy": 0, "easy_completed": false, "medium": 0, "medium_completed": false, "hard": 0, "hard_completed": false}
        },
        "Rozbiory": {
          "Rozbiory": {"easy": 0, "easy_completed": false, "medium": 0, "medium_completed": false, "hard": 0, "hard_completed": false},
          "Insurekcja": {"easy": 0, "easy_completed": false, "medium": 0, "medium_completed": false, "hard": 0, "hard_completed": false},
          "Księstwo Warszawskie": {"easy": 0, "easy_completed": false, "medium": 0, "medium_completed": false, "hard": 0, "hard_completed": false},
          "Kongresówka": {"easy": 0, "easy_completed": false, "medium": 0, "medium_completed": false, "hard": 0, "hard_completed": false},
          "Powstanie listopadowe": {"easy": 0, "easy_completed": false, "medium": 0, "medium_completed": false, "hard": 0, "hard_completed": false},
          "Wiosna Ludów": {"easy": 0, "easy_completed": false, "medium": 0, "medium_completed": false, "hard": 0, "hard_completed": false},
          "Powstanie styczniowe": {"easy": 0, "easy_completed": false, "medium": 0, "medium_completed": false, "hard": 0, "hard_completed": false},
          "Praca organiczna": {"easy": 0, "easy_completed": false, "medium": 0, "medium_completed": false, "hard": 0, "hard_completed": false}
        },
        "Międzywojnie": {
          "Odrodzenie": {"easy": 0, "easy_completed": false, "medium": 0, "medium_completed": false, "hard": 0, "hard_completed": false},
          "Wojna bolszewicka": {"easy": 0, "easy_completed": false, "medium": 0, "medium_completed": false, "hard": 0, "hard_completed": false},
          "Budowa państwa": {"easy": 0, "easy_completed": false, "medium": 0, "medium_completed": false, "hard": 0, "hard_completed": false},
          "Przewrót majowy": {"easy": 0, "easy_completed": false, "medium": 0, "medium_completed": false, "hard": 0, "hard_completed": false},
          "Sanacja": {"easy": 0, "easy_completed": false, "medium": 0, "medium_completed": false, "hard": 0, "hard_completed": false},
          "Zagrożenie": {"easy": 0, "easy_completed": false, "medium": 0, "medium_completed": false, "hard": 0, "hard_completed": false}
        },
        "II WŚ": {
          "Kampania wrześniowa": {"easy": 0, "easy_completed": false, "medium": 0, "medium_completed": false, "hard": 0, "hard_completed": false},
          "Okupacja": {"easy": 0, "easy_completed": false, "medium": 0, "medium_completed": false, "hard": 0, "hard_completed": false},
          "Ruch oporu": {"easy": 0, "easy_completed": false, "medium": 0, "medium_completed": false, "hard": 0, "hard_completed": false},
          "Powstanie warszawskie": {"easy": 0, "easy_completed": false, "medium": 0, "medium_completed": false, "hard": 0, "hard_completed": false},
          "Holocaust": {"easy": 0, "easy_completed": false, "medium": 0, "medium_completed": false, "hard": 0, "hard_completed": false},
          "Wyzwolenie": {"easy": 0, "easy_completed": false, "medium": 0, "medium_completed": false, "hard": 0, "hard_completed": false}
        },
        "PRL": {
          "Początki PRL": {"easy": 0, "easy_completed": false, "medium": 0, "medium_completed": false, "hard": 0, "hard_completed": false},
          "Stalinizm": {"easy": 0, "easy_completed": false, "medium": 0, "medium_completed": false, "hard": 0, "hard_completed": false},
          "Październik 56": {"easy": 0, "easy_completed": false, "medium": 0, "medium_completed": false, "hard": 0, "hard_completed": false},
          "Gomułka": {"easy": 0, "easy_completed": false, "medium": 0, "medium_completed": false, "hard": 0, "hard_completed": false},
          "Grudzień 70": {"easy": 0, "easy_completed": false, "medium": 0, "medium_completed": false, "hard": 0, "hard_completed": false},
          "Gierek": {"easy": 0, "easy_completed": false, "medium": 0, "medium_completed": false, "hard": 0, "hard_completed": false},
          "Solidarność": {"easy": 0, "easy_completed": false, "medium": 0, "medium_completed": false, "hard": 0, "hard_completed": false},
          "Stan wojenny": {"easy": 0, "easy_completed": false, "medium": 0, "medium_completed": false, "hard": 0, "hard_completed": false},
          "Okrągły Stół": {"easy": 0, "easy_completed": false, "medium": 0, "medium_completed": false, "hard": 0, "hard_completed": false}
        },
        "III RP": {
          "Transformacja": {"easy": 0, "easy_completed": false, "medium": 0, "medium_completed": false, "hard": 0, "hard_completed": false},
          "Balcerowicz": {"easy": 0, "easy_completed": false, "medium": 0, "medium_completed": false, "hard": 0, "hard_completed": false},
          "Rządy III RP": {"easy": 0, "easy_completed": false, "medium": 0, "medium_completed": false, "hard": 0, "hard_completed": false},
          "Integracja": {"easy": 0, "easy_completed": false, "medium": 0, "medium_completed": false, "hard": 0, "hard_completed": false}
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

        # Check if this is an intentional "0 questions" file (topic not in curriculum)
        # by looking for the "Brak pytań" or "not in curriculum" marker
        is_intentional_zero=0
        if [ "$question_count" -eq 0 ]; then
            if grep -q "Brak pytań\|nie ujęty w podstawie programowej\|not in curriculum" "$file" 2>/dev/null; then
                is_intentional_zero=1
            fi
        fi

        # Add the question count to the tracker
        # If question_count > 0 OR is_intentional_zero, mark as completed
        jq --arg epoch "$epoch" \
           --arg chapter "$chapter" \
           --arg difficulty "$difficulty" \
           --argjson count "$question_count" \
           --argjson intentional "$is_intentional_zero" \
           '.tracking[$epoch][$chapter][$difficulty] += $count |
            .tracking[$epoch][$chapter][($difficulty + "_completed")] |= (. or ($count > 0) or $intentional)' \
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
  select(
    (.value.easy < 10 and (.value.easy_completed | not)) or
    (.value.medium < 10 and (.value.medium_completed | not)) or
    (.value.hard < 10 and (.value.hard_completed | not))
  ) |
  "  \($epoch)/\($chapter): easy=\(.value.easy) medium=\(.value.medium) hard=\(.value.hard)"
' "$TRACKER_FILE" | head -10

exit 0
