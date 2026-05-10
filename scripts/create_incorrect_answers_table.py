#!/usr/bin/env python3
"""
Create incorrect answers table from question files.

Extracts incorrect answer explanations from question files and creates a unified
markdown table showing File name, metadata, Question ID, text, answer options, category, and comments.

Format: Each file gets a single header row with metadata, followed by question rows.
"""

import json
import re
import os
from pathlib import Path
from typing import Optional, Tuple, List, Dict


def load_master_list(path: str) -> Dict:
    """Load master-list.json to get epoch and chapter metadata."""
    with open(path, 'r', encoding='utf-8') as f:
        return json.load(f)


def get_metadata_from_master_list(master_list: Dict, epoch_name: str, chapter_name: str) -> Tuple[str, str]:
    """
    Get tech_name for epoch and chapter from master-list.json.

    Returns:
        Tuple of (epoch_tech_name, chapter_tech_name)
    """
    for epoch in master_list.get('epochs', []):
        if epoch.get('short_name') == epoch_name:
            epoch_tech_name = epoch.get('tech_name', '')
            for chapter in epoch.get('chapters', []):
                if chapter.get('short_name') == chapter_name:
                    chapter_tech_name = chapter.get('tech_name', '')
                    return epoch_tech_name, chapter_tech_name
    return '', ''


def extract_answer_text(block: str, letter: str) -> Optional[str]:
    """
    Extract answer text from question block.

    Handles only standard format: A. Answer text
    """
    # Standard format: A. Answer text (on its own line)
    pattern = rf'^{letter}\.\s+(.+)$'
    for line in block.split('\n'):
        line = line.strip()
        match = re.match(pattern, line)
        if match:
            return match.group(1).strip()

    return None


def parse_question_file(file_path: str, master_list: Dict) -> Optional[Dict]:
    """
    Parse a question file and extract questions with incorrect answer analysis.

    Returns:
        Dict with metadata (epoch, chapter, difficulty) and questions list
        None if file has no questions or parsing fails
    """
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # Extract metadata from YAML frontmatter
    metadata_match = re.search(r'^---\n(.*?)\n---', content, re.DOTALL)
    if not metadata_match:
        return None

    metadata_text = metadata_match.group(1)

    # Parse YAML metadata manually
    metadata = {}
    for line in metadata_text.split('\n'):
        if ':' in line:
            key, value = line.split(':', 1)
            key = key.strip()
            value = value.strip().strip('"')
            metadata[key] = value

    question_count = int(metadata.get('question_count', 0))
    if question_count == 0:
        return {
            'file': os.path.basename(file_path),
            'epoch': metadata.get('epoch', ''),
            'chapter': metadata.get('chapter', ''),
            'difficulty': metadata.get('difficulty', ''),
            'question_count': 0,
            'questions': []
        }

    # Get tech names from master-list.json
    epoch_name = metadata.get('epoch', '')
    chapter_name = metadata.get('chapter', '')
    epoch_tech_name, chapter_tech_name = get_metadata_from_master_list(master_list, epoch_name, chapter_name)

    # Split content into question blocks
    question_blocks = re.split(r'\n---\n', content)

    questions = []

    for block in question_blocks:
        if '**Question ID:**' not in block and '**Question ID:' not in block:
            continue

        # Extract Question ID (multiple formats):
        # - **Question ID: Q-PRA-H-001** (one colon, ** at end)
        # - **Question ID:** Q-III-RP-BALC-001 (two colons, no ** at end)
        # - **Question ID:** Q-ST-SLOW-H-001 (two colons, ** later)
        q_id_match = re.search(r'\*\*Question ID:\*?\*?\s*([A-Z0-9\-]+)', block)
        if not q_id_match:
            continue
        question_id = q_id_match.group(1).strip()

        # Extract Question text (try two formats)
        # Format 1: **Pytanie:** Question text
        # Format 2: Question text (first line after Question ID that's not blank and not an answer)
        q_text_match = re.search(r'\*\*Pytanie:\*\*\s*([^\n]+)', block)
        if not q_text_match:
            # Try format 2: find first line after Question ID that's not blank and not an answer
            lines = block.split('\n')
            found_q_id = False
            question_text = None
            for line in lines:
                line_stripped = line.strip()
                if not found_q_id:
                    if '**Question ID:' in line:
                        found_q_id = True
                else:
                    # Skip blank lines
                    if not line_stripped:
                        continue
                    # Skip answer lines (A., B., C., D., **Prawidłowa odpowiedź:**)
                    if re.match(r'^[A-D]\.\s+', line_stripped) or line_stripped.startswith('**'):
                        continue
                    # This should be the question text
                    question_text = line_stripped
                    break
            if not question_text:
                continue
        else:
            question_text = q_text_match.group(1).strip()

        # Extract correct answer (try both patterns)
        correct_match = re.search(r'\*\*(?:Poprawna|Prawidłowa) odpowiedź:\*\*\s*([A-D])', block)
        if not correct_match:
            continue
        correct_answer = correct_match.group(1).strip()

        # Extract answer options
        answers = {}
        for letter in ['A', 'B', 'C', 'D']:
            answer_text = extract_answer_text(block, letter)
            if answer_text:
                answers[letter] = answer_text

        # Check if we found all answers
        if len(answers) < 2:
            continue

        # Extract incorrect answer analysis
        incorrect_analysis = []

        # Extract incorrect answer analysis section (standard heading only)
        analysis_section_match = re.search(
            r'\*\*Analiza odpowiedzi błędnych:\*\*\s*\n(.*?)(?=\n---|\n\*\*Źródła|\**\Z)',
            block,
            re.DOTALL
        )

        if analysis_section_match:
            analysis_text = analysis_section_match.group(1)


            # Parse each incorrect answer line
            for line in analysis_text.split('\n'):
                line = line.strip()
                if not line or line.startswith('#') or not line.startswith('-'):
                    continue

                # Remove leading "- " and "– "
                clean_line = line[1:].strip().lstrip('–').strip()

                # Parse standard format: A. Answer text – explanation

                category = ''
                comment = ''
                answer_letter = None

                # Extract answer letter (only standard format: A. text)
                pattern = r'^([A-D])\.'
                match = re.search(pattern, clean_line)
                if match:
                    answer_letter = match.group(1)
                else:
                    # No letter found - skip this line (will be visible in table as missing)
                    continue

                # Now extract category and comment
                # Check if there's a colon with category before it
                # Need to find the LAST " – " before ":" because answer text may contain dashes
                if ':' in clean_line:
                    # Split by ':' to separate category/comment from the rest
                    parts = clean_line.split(':', 1)
                    before_colon = parts[0]
                    after_colon = parts[1] if len(parts) > 1 else ''

                    # Find the LAST ' – ' in before_colon
                    last_dash_pos = before_colon.rfind(' – ')
                    if last_dash_pos >= 0:
                        # Format with category
                        category = before_colon[last_dash_pos + 3:].strip()  # +3 to skip ' – '
                        comment = after_colon.strip()
                    else:
                        # No dash before colon - might be a different format
                        # Try to find ANY ' – ' and treat it as separator
                        if ' – ' in before_colon:
                            category = ''
                            comment = after_colon.strip()
                        else:
                            # No dash at all
                            comment = after_colon.strip()
                else:
                    # Format without colon - check if category is in parentheses at the end
                    # Format: "A. text (category)" or "A (text) (category)"
                    paren_match = re.search(r'\(([^)]+)\)$', clean_line)
                    if paren_match:
                        # Category is in parentheses at the end
                        category = paren_match.group(1).strip()
                        # Comment is everything before the parentheses
                        comment = clean_line[:paren_match.start()].strip()
                        # Remove answer letter pattern from comment (standard format only)
                        comment = re.sub(rf'^{answer_letter}\.\s+', '', comment, count=1)
                        comment = comment.strip()
                        # If there's a dash at the end, remove it
                        comment = re.sub(r'–\s*$', '', comment).strip()
                    elif ' – ' in clean_line:
                        # Format with dash but no colon
                        last_dash_pos = clean_line.rfind(' – ')
                        if last_dash_pos >= 0:
                            comment = clean_line[last_dash_pos + 3:].strip()
                        else:
                            # No dash - take everything after answer letter
                            remaining = clean_line
                            # Remove answer letter pattern (standard format only)
                            remaining = re.sub(rf'^{answer_letter}\.\s+', '', remaining, count=1)
                            comment = remaining.strip()
                    else:
                        # No dash - take everything after answer letter
                        remaining = clean_line
                        # Remove answer letter pattern (standard format only)
                        remaining = re.sub(rf'^{answer_letter}\.\s+', '', remaining, count=1)
                        comment = remaining.strip()

                # Get full answer text
                if answer_letter in answers:
                    full_answer = f"{answer_letter}. {answers[answer_letter]}"
                else:
                    full_answer = f"{answer_letter}. "

                incorrect_analysis.append({
                    'letter': answer_letter,
                    'answer': full_answer,
                    'category': category,
                    'comment': comment
                })

        questions.append({
            'id': question_id,
            'text': question_text,
            'correct_answer': correct_answer,
            'answers': answers,
            'incorrect_analysis': incorrect_analysis
        })

    return {
        'file': os.path.basename(file_path),
        'epoch': metadata.get('epoch', ''),
        'chapter': metadata.get('chapter', ''),
        'epoch_tech_name': epoch_tech_name,
        'chapter_tech_name': chapter_tech_name,
        'difficulty': metadata.get('difficulty', ''),
        'question_count': len(questions),
        'questions': questions
    }


def create_table_rows(parsed_data: Dict) -> List[str]:
    """
    Create markdown table rows from parsed question data.

    Returns:
        List of markdown table row strings
    """
    if parsed_data['question_count'] == 0:
        return []

    rows = []

    # First row: metadata header
    filename = parsed_data['file']
    epoch_name = parsed_data['epoch_tech_name']
    chapter_name = parsed_data['chapter_tech_name']
    difficulty = parsed_data['difficulty']
    rows.append(f"| **File: {filename}** | **Epoch:** {epoch_name} | **Chapter:** {chapter_name} | **Difficulty:** {difficulty} | | |")

    for q in parsed_data['questions']:
        question_id = q['id']
        question_text = q['text']
        correct_answer = q['correct_answer']

        # First, add the correct answer row
        if correct_answer in q['answers']:
            correct_answer_text = f"{correct_answer}. {q['answers'][correct_answer]}"
        else:
            correct_answer_text = f"{correct_answer}. "

        rows.append(f"| {question_id} | {question_text} | {correct_answer_text} | CORRECT | |")

        # Then add incorrect answer rows
        for analysis in q['incorrect_analysis']:
            letter = analysis['letter']
            answer = analysis['answer']
            category = analysis['category'] if analysis['category'] else ''
            comment = analysis['comment']

            rows.append(f"| | | {answer} | {category} | {comment} |")

    return rows


def main():
    """Main function to create the incorrect answers table."""
    # Load master-list.json
    master_list_path = 'history-data/master-list.json'
    master_list = load_master_list(master_list_path)

    # Find all question files
    question_files = []
    for root, dirs, files in os.walk('history-data'):
        for file in files:
            if re.match(r'.*_questions_(easy|medium|hard)\.md', file):
                question_files.append(os.path.join(root, file))

    question_files.sort()

    # Create output file
    output_path = 'history-data/questions-table.md'

    with open(output_path, 'w', encoding='utf-8') as out:
        # Write main header
        out.write("# Incorrect Answers Analysis Table\n\n")
        out.write("| File | Metadata | Question text | Answer | Category | Comment |\n")
        out.write("|------|----------|---------------|--------|----------|---------|\n")

        # Process each file
        for file_path in question_files:
            print(f"Processing: {file_path}")

            # Parse the file
            parsed = parse_question_file(file_path, master_list)

            if not parsed:
                print(f"  Skipped (no metadata)")
                continue

            # Write table rows
            rows = create_table_rows(parsed)
            for row in rows:
                out.write(row + "\n")

            if parsed['question_count'] > 0:
                print(f"  Processed {len(parsed['questions'])} questions")
            else:
                print(f"  No questions")

    print(f"\nTable created: {output_path}")


if __name__ == '__main__':
    main()
