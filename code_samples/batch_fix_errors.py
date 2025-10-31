#!/usr/bin/env python3
"""
Batch fix common compilation errors in extracted code samples
"""

import re
import subprocess
from pathlib import Path
from typing import List, Tuple

def get_files_with_errors() -> List[Path]:
    """Get list of files with compilation errors"""
    result = subprocess.run(
        ['flutter', 'analyze'],
        capture_output=True,
        text=True,
        cwd='/home/escamoteur/dev/flutter_it/docs/code_samples'
    )

    files = set()
    for line in result.stdout.split('\n'):
        if 'error •' in line and 'lib/get_it/' in line:
            match = re.search(r'lib/get_it/([^:]+)', line)
            if match:
                files.add(Path('lib/get_it') / match.group(1))

    return sorted(files)

def fix_placeholder_variables(filepath: Path) -> bool:
    """Fix undefined placeholder variables by adding them"""
    with open(filepath, 'r') as f:
        content = f.read()

    original = content
    placeholders_needed = set()

    # Find undefined identifiers
    if 'username' in content and 'Undefined name' not in content:
        placeholders_needed.add('username')
    if 'password' in content and 'Undefined name' not in content:
        placeholders_needed.add('password')
    if 'userId' in content and 'userId' not in content.split('final')[0]:
        placeholders_needed.add('userId')

    if placeholders_needed:
        # Add placeholders at start of main function
        lines = content.split('\n')
        main_idx = None
        for i, line in enumerate(lines):
            if 'void main()' in line or 'Future<void> main()' in line:
                main_idx = i + 1
                break

        if main_idx:
            indent = '  '
            placeholder_lines = []
            if 'username' in placeholders_needed:
                placeholder_lines.append(f'{indent}const username = "user@example.com";')
            if 'password' in placeholders_needed:
                placeholder_lines.append(f'{indent}const password = "password123";')
            if 'userId' in placeholders_needed:
                placeholder_lines.append(f'{indent}const userId = "user123";')

            lines = lines[:main_idx] + placeholder_lines + lines[main_idx:]
            content = '\n'.join(lines)

    if content != original:
        with open(filepath, 'w') as f:
            f.write(content)
        return True
    return False

def fix_widget_placeholders(filepath: Path) -> bool:
    """Fix widget files with placeholder parameters"""
    with open(filepath, 'r') as f:
        content = f.read()

    original = content

    # If it's a widget class with undefined username/password in onPressed
    if 'class ' in content and 'Widget build' in content:
        # Check if has undefined identifiers in method calls
        if re.search(r'\.login\(username,\s*password\)', content):
            # Replace with string literals
            content = re.sub(
                r'\.login\(username,\s*password\)',
                ".login('user@example.com', 'password')",
                content
            )

    if content != original:
        with open(filepath, 'w') as f:
            f.write(content)
        return True
    return False

def fix_class_extensions(filepath: Path) -> bool:
    """Fix class extension issues"""
    with open(filepath, 'r') as f:
        content = f.read()

    original = content

    # Fix "class X extends Mock" patterns - Mock isn't a class in our stubs
    if 'extends Mock' in content:
        # Remove extends Mock, make it a standalone class
        content = re.sub(r'class (\w+) extends Mock implements (\w+)', r'class \1 /* mock of \2 */', content)

    if content != original:
        with open(filepath, 'w') as f:
            f.write(content)
        return True
    return False

def add_missing_methods_to_stubs():
    """Add commonly needed methods to stubs"""
    stubs_path = Path('lib/get_it/_shared/stubs.dart')

    with open(stubs_path, 'r') as f:
        content = f.read()

    additions = []

    # Check what's missing and add
    if 'callOnce' not in content:
        additions.append('''
/// watch_it integration stubs (for examples showing integration)
void callOnce(Function() callback) {
  callback();
}

dynamic watchIt<T>() => null;
''')

    if additions:
        # Add before the last closing brace
        content = content.rstrip() + '\n\n' + '\n'.join(additions) + '\n'
        with open(stubs_path, 'w') as f:
            f.write(content)
        return True
    return False

def main():
    print("Starting batch error fixes...")

    # Add missing methods to stubs first
    if add_missing_methods_to_stubs():
        print("Added missing methods to stubs")

    files = get_files_with_errors()
    print(f"Found {len(files)} files with errors")

    fixed_count = 0

    for filepath in files:
        if not filepath.exists():
            continue

        fixed = False

        # Try various fixes
        if fix_placeholder_variables(filepath):
            print(f"  Fixed placeholders: {filepath.name}")
            fixed = True

        if fix_widget_placeholders(filepath):
            print(f"  Fixed widget placeholders: {filepath.name}")
            fixed = True

        if fix_class_extensions(filepath):
            print(f"  Fixed class extensions: {filepath.name}")
            fixed = True

        if fixed:
            fixed_count += 1

    print(f"\nFixed {fixed_count} files automatically")

if __name__ == '__main__':
    main()
