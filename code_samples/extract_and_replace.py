#!/usr/bin/env python3
"""
Script to extract code blocks from async_objects.md and replace them with import statements.
This automates the tedious manual extraction process.
"""

import re
from pathlib import Path

# Read the markdown file
md_file = Path('/home/escamoteur/dev/flutter_it/docs/docs/documentation/get_it/async_objects.md')
content = md_file.read_text()

# Find all dart code blocks that haven't been replaced yet
pattern = r'```dart\n(.*?)\n```'
matches = list(re.finditer(pattern, content, re.DOTALL))

print(f"Found {len(matches)} remaining inline code blocks")
print("\nShowing first 5:")
for i, match in enumerate(matches[:5], 1):
    code = match.group(1)
    print(f"\n--- Block {i} ---")
    print(f"Start position: {match.start()}")
    print(f"Length: {len(code)} chars")
    print(f"Preview: {code[:100]}...")

# Show what we've already extracted
extracted_files = list(Path('/home/escamoteur/dev/flutter_it/docs/code_samples/lib/get_it').glob('*.dart'))
print(f"\n\nAlready extracted {len(extracted_files)} files:")
for f in sorted(extracted_files):
    print(f"  - {f.name}")
