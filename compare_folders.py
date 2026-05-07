#!/usr/bin/env python3
import re
from pathlib import Path
from collections import defaultdict

# Define epoch mappings
OLD_TO_NEW_EPOCHS = {
    'starozytnosc': '01-starozytnosc',
    'piastowie': '02-piastowie',
    'jagiellonowie': '03-jagiellonowie',
    'rzeczpospolita': '04-rzeczpospolita',
    'rozbiory': '05-rozbiory',
    'miedzywojnie': '06-miedzywojnie',
    'ii-wojna': '07-ii-wojna-swiatowa',
    'prl': '08-prl',
    'iii-rp': '09-iii-rp',
}

# Define chapter mappings
OLD_TO_NEW_CHAPTERS = {
    'pradzieje': '01-pradzieje',
    'slowianie': '02-slowianie',
    'chrystianizacja': '01-chrystianizacja',
    'ekspansja': '02-ekspansja',
    'rozbicie-dzielnicowe-i': '03-rozbicie-dzielnicowe-i',
    'najazd-mongolski': '04-najazd-mongolski',
}

def parse_old_filename(filename):
    """Parse old filename and extract epoch, chapter, difficulty"""
    # Remove .md extension
    name = filename.replace('.md', '')

    # Handle various patterns
    # Pattern: epoch-chapter-difficulty (chapter can contain hyphens)
    # Examples: piastowie-najazd-mongolski-easy, starozytnosc-pradzieje-medium

    # Remove suffixes like -part2, -questions21-30, -001
    name = re.sub(r'-part\d+$', '', name)
    name = re.sub(r'-questions\d+-\d+$', '', name)
    name = re.sub(r'-\d+$', '', name)
    name = re.sub(r'-consolidated$', '', name)

    # Now extract epoch, chapter, difficulty
    # The pattern is: epoch-(...chapter parts...)-difficulty
    # We need to match the epoch specifically from known epochs
    known_epochs = '|'.join(OLD_TO_NEW_EPOCHS.keys())

    # Try to match the pattern with known epochs
    match = re.match(r'^(' + known_epochs + r')-(.+)-(easy|medium|hard)$', name)
    if match:
        epoch, chapter, difficulty = match.groups()
        return normalize_epoch_chapter(epoch, chapter)

    return None

def normalize_epoch_chapter(old_epoch, old_chapter):
    """Normalize old naming to new naming"""
    new_epoch = OLD_TO_NEW_EPOCHS.get(old_epoch, old_epoch)
    new_chapter = OLD_TO_NEW_CHAPTERS.get(old_chapter, old_chapter)
    return f"{new_epoch}/{new_chapter}"

def get_old_chapters():
    """Get all epoch/chapter combinations from old folder"""
    old_folder = Path('/home/macryba/testdziej-questions/questions/validated')
    old_chapters = set()

    for file in old_folder.glob('*.md'):
        result = parse_old_filename(file.name)
        if result:
            old_chapters.add(result)

    return sorted(old_chapters)

def get_new_chapters():
    """Get all epoch/chapter combinations from new folder"""
    new_folder = Path('/home/macryba/testdziej-questions/history-data')
    new_chapters = set()

    for epoch_dir in new_folder.iterdir():
        if epoch_dir.is_dir() and '-' in epoch_dir.name:
            for chapter_dir in epoch_dir.iterdir():
                if chapter_dir.is_dir() and '-' in chapter_dir.name:
                    new_chapters.add(f"{epoch_dir.name}/{chapter_dir.name}")

    return sorted(new_chapters)

def main():
    old_chapters = get_old_chapters()
    new_chapters = get_new_chapters()

    print("=== CHAPTERS IN OLD FOLDER ===")
    for chapter in sorted(old_chapters):
        print(f"  {chapter}")
    print(f"\nTotal: {len(old_chapters)} chapters\n")

    print("=== CHAPTERS IN NEW FOLDER ===")
    for chapter in sorted(new_chapters):
        print(f"  {chapter}")
    print(f"\nTotal: {len(new_chapters)} chapters\n")

    missing = set(old_chapters) - set(new_chapters)
    print("=== CHAPTERS IN OLD BUT MISSING IN NEW ===")
    if missing:
        for chapter in sorted(missing):
            print(f"  {chapter}")
        print(f"\nTotal missing: {len(missing)} chapters")
    else:
        print("  None - all old chapters are in new format")

    print("\n=== CHAPTERS IN NEW BUT NOT IN OLD ===")
    extra = set(new_chapters) - set(old_chapters)
    if extra:
        for chapter in sorted(extra):
            print(f"  {chapter}")
        print(f"\nTotal new: {len(extra)} chapters")
    else:
        print("  None")

if __name__ == '__main__':
    main()
