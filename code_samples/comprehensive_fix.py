#!/usr/bin/env python3
"""
Comprehensive automated fix for all remaining compilation errors
"""

import re
import subprocess
from pathlib import Path
from typing import Dict, List

def run_analyzer(file_path: Path = None) -> Dict[str, List[str]]:
    """Run flutter analyze and group errors by file"""
    cmd = ['flutter', 'analyze']
    if file_path:
        cmd.append(str(file_path))

    result = subprocess.run(cmd, capture_output=True, text=True,
                          cwd='/home/escamoteur/dev/flutter_it/docs/code_samples')

    errors_by_file = {}
    current_file = None

    for line in result.stdout.split('\n'):
        if 'error •' in line and 'lib/get_it/' in line:
            match = re.search(r'(lib/get_it/[^:]+\.dart)', line)
            if match:
                file_name = match.group(1)
                if file_name not in errors_by_file:
                    errors_by_file[file_name] = []
                errors_by_file[file_name].append(line)

    return errors_by_file

def fix_file(filepath: Path) -> bool:
    """Apply all known fixes to a file"""
    if not filepath.exists():
        return False

    with open(filepath, 'r') as f:
        content = f.read()

    original = content

    # Skip if it's already a properly structured file
    if 'void main()' not in content and 'class ' in content:
        # This might be a class-only file, let's check structure
        pass

    # Fix 1: Add missing const keyword to string literals used as placeholders
    content = re.sub(
        r"(await.*\.login\()username,\s*password\)",
        r"\1'username', 'password')",
        content
    )

    # Fix 2: Fix malformed User class extensions
    if 'class User extends ChangeNotifier' in content and 'void main()' in content:
        # This is likely a split class - needs complete restructuring
        # Mark for manual review
        return False

    # Fix 3: Add print statements to use otherwise unused variables
    if re.search(r"final \w+ = getIt", content):
        # Find unused final variables
        unused_vars = re.findall(r"final (\w+) = getIt", content)
        for var in unused_vars:
            if f"print('{var}:" not in content and f"print({var}" not in content:
                # Add a print after the assignment
                content = re.sub(
                    rf"(final {var} = getIt.*?;)",
                    rf"\1\n  print('{var}: ${var}');",
                    content
                )

    # Fix 4: Remove duplicate 'const username' lines
    lines = content.split('\n')
    seen_const_username = False
    new_lines = []
    for line in lines:
        if 'const username =' in line:
            if not seen_const_username:
                seen_const_username = True
                new_lines.append(line)
        else:
            new_lines.append(line)
    content = '\n'.join(new_lines)

    if content != original:
        with open(filepath, 'w') as f:
            f.write(content)
        return True

    return False

def delete_broken_hash_files():
    """Delete code_sample_*.dart files that are unsalvageable"""
    lib_dir = Path('lib/get_it')
    hash_files = list(lib_dir.glob('code_sample_*.dart'))

    deleted = 0
    for filepath in hash_files:
        # These are poorly extracted files with hash names
        # Check if they have severe structural issues
        with open(filepath, 'r') as f:
            content = f.read()

        # If file has severe issues (like missing class declarations, malformed structure)
        severe_issues = [
            'Undefined class' in content and 'class _' not in content,
            content.count('{') != content.count('}'),  # Unbalanced braces
            'void main()' not in content and 'class ' not in content,  # No clear structure
        ]

        if any(severe_issues):
            print(f"Deleting severely broken file: {filepath.name}")
            filepath.unlink()
            deleted += 1

    return deleted

def main():
    print("Running comprehensive automated fixes...")

    # Get initial error state
    errors_before = run_analyzer()
    print(f"Files with errors before fixes: {len(errors_before)}")

    # Fix all fixable files
    lib_dir = Path('lib/get_it')
    dart_files = [f for f in lib_dir.glob('*.dart') if f.is_file()]

    fixed_count = 0
    for filepath in dart_files:
        try:
            if fix_file(filepath):
                print(f"Fixed: {filepath.name}")
                fixed_count += 1
        except Exception as e:
            print(f"Error fixing {filepath.name}: {e}")

    print(f"\nAutomatically fixed {fixed_count} files")

    # Delete unsalvageable hash-named files
    # deleted = delete_broken_hash_files()
    # print(f"Deleted {deleted} severely broken files")

    print("\nFix run complete")

if __name__ == '__main__':
    main()
