#!/usr/bin/env python3
"""
Count existing questions in history-data directory structure.
Generates counts for each chapter by difficulty level.
"""

import os
import json
import re
from pathlib import Path

def count_questions_in_file(file_path):
    """Count questions in a single question file."""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()

        # Look for question_count in metadata
        question_count_match = re.search(r"question_count:\s*(\d+)", content)
        if question_count_match:
            count = int(question_count_match.group(1))
                        return count

        # Fallback: count question patterns (try multiple patterns)
        patterns = [
            r'^\s*\d+\.\s+',  # 1. format
            r'^## Pytanie \d+',  ## Pytanie X format
            r'^\*\*Pytanie \d+\*\*'  # **Pytanie X** format
        ]
        for i, pattern in enumerate(patterns):
            questions = re.findall(pattern, content, re.MULTILINE)
            if questions:
                print(f"Found {len(questions)} questions with pattern {i+1} in {file_path}")
                return len(questions)

        print(f"No questions found in {file_path}")
        return 0

    except Exception as e:
        print(f"Error reading {file_path}: {e}")
        return 0

def count_questions_in_directory(epoch_dir, chapter_dir):
    """Count questions in a chapter directory."""
    chapter_path = os.path.join(epoch_dir, chapter_dir)
    if not os.path.exists(chapter_path):
        return {"easy": 0, "medium": 0, "hard": 0}

    counts = {"easy": 0, "medium": 0, "hard": 0}

    # Count question files
    for difficulty in ["easy", "medium", "hard"]:
        # Extract just the tech_name part (remove ID prefix)
        chapter_tech = chapter_dir.split('-', 1)[1]  # Remove "01-" prefix
        question_file = os.path.join(chapter_path, f"{chapter_tech}_questions_{difficulty}.md")
        print(f"Checking file: {question_file}")
        if os.path.exists(question_file):
            # print(f"Processing: {question_file}")
            count = count_questions_in_file(question_file)
            print(f"Got count: {count}")
            counts[difficulty] = count
        else:
            print(f"File not found: {question_file}")

    return counts

def main():
    """Main function to count all questions and update master-list."""
    print("Starting question counting...")
    base_dir = os.path.join(os.path.dirname(__file__), "history-data")
    master_list_path = os.path.join(base_dir, "master-list.json")
    print(f"Base dir: {base_dir}")
    print(f"Master list: {master_list_path}")

    # Load master-list
    with open(master_list_path, 'r', encoding='utf-8') as f:
        master_list = json.load(f)

    # Count questions for each epoch and chapter
    for epoch in master_list["epochs"]:
        epoch_dir = os.path.join(base_dir, f"{epoch['id']:02d}-{epoch['tech_name']}")

        if not os.path.exists(epoch_dir):
            print(f"Epoch directory not found: {epoch_dir}")
            print(f"Epoch id: {epoch['id']}, tech_name: {epoch['tech_name']}")
            print(f"Looking for: {os.path.join(base_dir, f'{epoch["id"]}-{epoch["tech_name"]}')}")
            print(f"Available directories: {os.listdir(base_dir)}")
            continue

        for chapter in epoch["chapters"]:
            chapter_dir = f"{chapter['id']}-{chapter['tech_name']}"
            print(f"Looking for chapter: {chapter_dir}")
            chapter_path = os.path.join(epoch_dir, chapter_dir)
            print(f"Full chapter path: {chapter_path}")
            print(f"Chapter exists: {os.path.exists(chapter_path)}")
            chapter_counts = count_questions_in_directory(epoch_dir, chapter_dir)

            # Add counts to chapter (insert after end_year to maintain structure)
            chapter_data = {
                "id": chapter["id"],
                "short_name": chapter["short_name"],
                "tech_name": chapter["tech_name"],
                "long_name": chapter["long_name"],
                "start_year": chapter["start_year"],
                "end_year": chapter["end_year"],
                "questions": chapter_counts
            }

            # Replace the chapter data
            for i, ch in enumerate(epoch["chapters"]):
                if ch["id"] == chapter["id"]:
                    epoch["chapters"][i] = chapter_data
                    break

            print(f"{epoch['tech_name']} | {chapter['tech_name']}: {chapter_counts}")

    # Save updated master-list
    with open(master_list_path, 'w', encoding='utf-8') as f:
        json.dump(master_list, f, indent=2, ensure_ascii=False)

    print(f"\nUpdated master-list.json with question counts")

if __name__ == "__main__":
    main()