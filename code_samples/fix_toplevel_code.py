#!/usr/bin/env python3
"""
Fix top-level executable code by wrapping it in async functions
"""

import re
import sys
from pathlib import Path

def needs_wrapping(code: str) -> bool:
    """Check if code has top-level executable statements"""
    lines = code.split('\n')

    for line in lines:
        stripped = line.strip()
        if not stripped or stripped.startswith('//'):
            continue

        # Check for executable statements (not declarations)
        if any(stripped.startswith(kw) for kw in ['await ', 'if ', 'for ', 'while ', 'print(', 'return ']):
            return True

        # Check for function calls at top level
        if re.match(r'^[a-z]\w*\.', stripped) and not stripped.startswith('final ') and not stripped.startswith('const '):
            return True

    return False

def fix_file(filepath: Path):
    """Fix a single file by wrapping top-level code"""
    with open(filepath, 'r') as f:
        content = f.read()

    # Find the region
    region_match = re.search(r'// #region example\n(.*?)\n// #endregion example', content, re.DOTALL)

    if not region_match:
        return False

    example_code = region_match.group(1)

    # Check if it needs wrapping
    if not needs_wrapping(example_code):
        return False

    # Wrap in async function
    wrapped_code = f"void main() async {{\n{example_code}\n}}"

    # Replace in content
    new_content = content.replace(
        f"// #region example\n{example_code}\n// #endregion example",
        f"// #region example\n{wrapped_code}\n// #endregion example"
    )

    # Write back
    with open(filepath, 'w') as f:
        f.write(new_content)

    return True

def main():
    """Process all example files"""
    lib_dir = Path('lib/get_it')

    fixed_count = 0

    for dart_file in lib_dir.glob('*_example*.dart'):
        if fix_file(dart_file):
            print(f"✓ Fixed {dart_file.name}")
            fixed_count += 1

    print(f"\nFixed {fixed_count} files")

if __name__ == '__main__':
    main()
