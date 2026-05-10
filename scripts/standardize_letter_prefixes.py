#!/usr/bin/env python3
"""
Standardize all letter prefixes in incorrect answer sections to "A: " format.

Handles multiple formats:
  - **A.** Answer text (bold format)
  - A. Answer text (plain format with period)
  - Odpowiedź A (text) - Polish "Answer" keyword
  - Odp A: explanation - Abbreviated Polish format
  - A (text) - Letter directly followed by parentheses
  - **A. Answer** – explanation (bold with dash)

Transforms all to: "A: explanation"
"""

import re
import os
import sys
from pathlib import Path

def fix_letter_prefixes(content):
    """Fix all letter prefix formats to standard 'A: ' format."""

    lines = content.split('\n')
    fixed_lines = []
    in_incorrect_section = False

    for line in lines:
        # Check if we're in an incorrect answer section
        if '**Analiza odpowiedzi błędnych:**' in line or 'Analiza odpowiedzi błędnych:' in line:
            in_incorrect_section = True
            fixed_lines.append(line)
            continue

        # Check if we've left the section (next heading or separator)
        if line.strip().startswith('---') or line.strip().startswith('##'):
            in_incorrect_section = False
            fixed_lines.append(line)
            continue

        # Only process lines in incorrect answer sections that start with dash
        if in_incorrect_section and line.strip().startswith('-'):
            # Pattern 1: Odpowiedź A (text) – explanation
            match1 = re.match(r'^\-\s*Odpowiedź\s+([A-D])\s+\((.+?)\)\s+–\s+(.+)$', line)
            if match1:
                letter = match1.group(1)
                explanation = match1.group(3)
                fixed_lines.append(f'- {letter}: {explanation}')
                continue

            # Pattern 2: Odpowiedź A (text) - explanation (with regular dash)
            match2 = re.match(r'^\-\s*Odpowiedź\s+([A-D])\s+\((.+?)\)\s+-\s+(.+)$', line)
            if match2:
                letter = match2.group(1)
                explanation = match2.group(3)
                fixed_lines.append(f'- {letter}: {explanation}')
                continue

            # Pattern 3: **A. Answer text** – explanation (bold with dash)
            match3 = re.match(r'^\-\s+\*\*([A-D])\.\s+(.+?)\*\*\s+–\s+(.+)$', line)
            if match3:
                letter = match3.group(1)
                explanation = match3.group(3)
                fixed_lines.append(f'- {letter}: {explanation}')
                continue

            # Pattern 4: **A. Answer text** - explanation (bold with regular dash)
            match4 = re.match(r'^\-\s+\*\*([A-D])\.\s+(.+?)\*\*\s+-\s+(.+)$', line)
            if match4:
                letter = match4.group(1)
                explanation = match4.group(3)
                fixed_lines.append(f'- {letter}: {explanation}')
                continue

            # Pattern 5: A. Answer text – explanation (plain with period and dash)
            match5 = re.match(r'^\-\s*([A-D])\.\s+(.+?)\s+–\s+(.+)$', line)
            if match5:
                letter = match5.group(1)
                explanation = match5.group(3)
                fixed_lines.append(f'- {letter}: {explanation}')
                continue

            # Pattern 6: A. Answer text - explanation (plain with period and regular dash)
            match6 = re.match(r'^\-\s*([A-D])\.\s+(.+?)\s+-\s+(.+)$', line)
            if match6:
                letter = match6.group(1)
                explanation = match6.group(3)
                fixed_lines.append(f'- {letter}: {explanation}')
                continue

            # Pattern 7: A (text) – explanation (parentheses with dash)
            match7 = re.match(r'^\-\s*([A-D])\s+\((.+?)\)\s+–\s+(.+)$', line)
            if match7:
                letter = match7.group(1)
                explanation = match7.group(3)
                fixed_lines.append(f'- {letter}: {explanation}')
                continue

            # Pattern 8: A (text) - explanation (parentheses with regular dash)
            match8 = re.match(r'^\-\s*([A-D])\s+\((.+?)\)\s+-\s+(.+)$', line)
            if match8:
                letter = match8.group(1)
                explanation = match8.group(3)
                fixed_lines.append(f'- {letter}: {explanation}')
                continue

            # Pattern 9: Odp A: explanation (abbreviated Polish - already has colon)
            match9 = re.match(r'^\-\s*Odp\s+([A-D]):\s+(.+)$', line)
            if match9:
                letter = match9.group(1)
                explanation = match9.group(2)
                fixed_lines.append(f'- {letter}: {explanation}')
                continue

            # Pattern 10: Odpowiedź A: explanation (full Polish with colon)
            match10 = re.match(r'^\-\s*Odpowiedź\s+([A-D]):\s+(.+)$', line)
            if match10:
                letter = match10.group(1)
                explanation = match10.group(2)
                fixed_lines.append(f'- {letter}: {explanation}')
                continue

        # Keep line as is if no pattern matched
        fixed_lines.append(line)

    return '\n'.join(fixed_lines)

def find_all_question_files():
    """Find all question files in the project."""
    base_path = Path('history-data')
    question_files = []

    for epoch_dir in base_path.iterdir():
        if epoch_dir.is_dir() and not epoch_dir.name.startswith('.'):
            for chapter_dir in epoch_dir.iterdir():
                if chapter_dir.is_dir():
                    # Look for questions files
                    for file in chapter_dir.glob('*_questions_*.md'):
                        question_files.append(file)

    return question_files

def main():
    print("🔍 Finding all question files...")
    question_files = find_all_question_files()
    print(f"📁 Found {len(question_files)} question files")

    fixed_count = 0
    for file_path in question_files:
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                original_content = f.read()

            fixed_content = fix_letter_prefixes(original_content)

            # Only write if content changed
            if fixed_content != original_content:
                with open(file_path, 'w', encoding='utf-8') as f:
                    f.write(fixed_content)
                print(f"✅ Fixed: {file_path}")
                fixed_count += 1

        except Exception as e:
            print(f"❌ Error processing {file_path}: {e}")

    print(f"\n📊 Summary: Fixed {fixed_count} out of {len(question_files)} files")

if __name__ == '__main__':
    main()
