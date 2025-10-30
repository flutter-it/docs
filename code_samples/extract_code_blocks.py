#!/usr/bin/env python3
"""
Script to extract all Dart code blocks from markdown files.
This helps identify which code samples need to be extracted into separate files.
"""

import re
import os
from pathlib import Path

def extract_code_blocks(markdown_file):
    """Extract all dart code blocks from a markdown file."""
    with open(markdown_file, 'r', encoding='utf-8') as f:
        content = f.read()

    # Pattern to match ```dart ... ``` code blocks
    pattern = r'```dart\n(.*?)\n```'
    matches = re.findall(pattern, content, re.DOTALL)

    return matches

def analyze_docs_directory(docs_root):
    """Analyze all markdown files in the docs directory."""
    docs_path = Path(docs_root)
    results = {}

    for md_file in docs_path.rglob('*.md'):
        code_blocks = extract_code_blocks(md_file)
        if code_blocks:
            rel_path = md_file.relative_to(docs_path)
            results[str(rel_path)] = {
                'path': str(md_file),
                'count': len(code_blocks),
                'blocks': code_blocks
            }

    return results

if __name__ == '__main__':
    docs_root = '/home/escamoteur/dev/flutter_it/docs/docs'
    results = analyze_docs_directory(docs_root)

    print(f"Found {len(results)} markdown files with Dart code blocks:\n")

    total_blocks = 0
    for file_path, data in sorted(results.items()):
        print(f"{file_path}: {data['count']} code blocks")
        total_blocks += data['count']

    print(f"\nTotal: {total_blocks} code blocks to extract")

    # Focus on async_objects.md for now
    async_objects = 'documentation/get_it/async_objects.md'
    if async_objects in results:
        print(f"\n\n=== Analyzing {async_objects} ===")
        print(f"Found {results[async_objects]['count']} code blocks")
        print("\nFirst 3 blocks preview:")
        for i, block in enumerate(results[async_objects]['blocks'][:3], 1):
            print(f"\n--- Block {i} ({len(block)} chars) ---")
            print(block[:200] + ('...' if len(block) > 200 else ''))
