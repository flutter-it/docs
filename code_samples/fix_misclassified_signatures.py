#!/usr/bin/env python3
"""
Fix misclassified signature files that actually contain executable code
"""

import os
import re
from pathlib import Path

def has_executable_code(content: str) -> bool:
    """Check if content has executable code patterns"""
    # Remove comments
    lines = [l.strip() for l in content.split('\n')
             if l.strip() and not l.strip().startswith('//')]

    executable_patterns = [
        r'getIt\.',
        r'await\s+',
        r'final\s+\w+\s*=',
        r'var\s+\w+\s*=',
        r'print\(',
        r'if\s*\(',
        r'for\s*\(',
    ]

    for line in lines:
        for pattern in executable_patterns:
            if re.search(pattern, line):
                return True
    return False

def fix_signature_file(filepath: Path):
    """Convert misclassified signature file to proper example"""
    with open(filepath, 'r') as f:
        content = f.read()

    # Skip if already has proper structure
    if 'import ' in content and 'void main()' in content:
        return False

    # Remove ignore directive if present
    content = re.sub(r'// ignore_for_file:.*\n', '', content)

    # Build proper file structure
    new_content = [
        "import 'package:get_it/get_it.dart';",
        "import '_shared/stubs.dart';",
        "",
        "final getIt = GetIt.instance;",
        "",
        "// #region example",
        "void main() {",
    ]

    # Add indented content
    for line in content.split('\n'):
        if line.strip():
            new_content.append(f"  {line}")
        else:
            new_content.append("")

    new_content.extend([
        "}",
        "// #endregion example",
    ])

    # Write back
    with open(filepath, 'w') as f:
        f.write('\n'.join(new_content))

    return True

def main():
    lib_dir = Path("lib/get_it")
    signature_files = list(lib_dir.glob("*_signature*.dart"))

    fixed_count = 0
    for filepath in signature_files:
        with open(filepath, 'r') as f:
            content = f.read()

        if has_executable_code(content):
            print(f"Fixing {filepath.name}...")
            if fix_signature_file(filepath):
                fixed_count += 1

    print(f"\nFixed {fixed_count} misclassified signature files")

if __name__ == '__main__':
    main()
