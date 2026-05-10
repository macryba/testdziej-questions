#!/usr/bin/env python3
"""
Fix incorrect answer format in question files.

Transforms:
  - **B. Full option text** – explanation

To:
  - B: explanation
"""

import re
import sys

def fix_incorrect_answers_section(content):
    """Fix the format of incorrect answer sections."""

    # Pattern to match lines like: - **B. Full text** – explanation
    # Capture groups: letter, full text, dash, explanation
    pattern = r'^\-\s+\*\*([A-D])\.\s+(.+?)\*\*\s+–\s+(.+)$'

    def replacement(match):
        letter = match.group(1)
        explanation = match.group(3)
        return f'- {letter}: {explanation}'

    # Apply the transformation line by line
    lines = content.split('\n')
    fixed_lines = []

    for line in lines:
        # Check if this is an incorrect answer line
        match = re.match(pattern, line)
        if match:
            # Transform to new format
            fixed_line = replacement(match)
            fixed_lines.append(fixed_line)
        else:
            # Keep line as is
            fixed_lines.append(line)

    return '\n'.join(fixed_lines)

def main():
    if len(sys.argv) != 2:
        print("Usage: python3 fix_incorrect_answers_format.py <file_path>")
        sys.exit(1)

    file_path = sys.argv[1]

    # Read the file
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # Fix the content
    fixed_content = fix_incorrect_answers_section(content)

    # Write back
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(fixed_content)

    print(f"Fixed incorrect answer format in: {file_path}")

if __name__ == '__main__':
    main()
