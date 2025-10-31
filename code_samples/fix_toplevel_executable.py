#!/usr/bin/env python3
"""
Wrap top-level executable code in main() function
"""

import re
from pathlib import Path

def needs_wrapping(content: str) -> bool:
    """Check if file has unwrapped executable code"""
    # Skip if already has void main()
    if re.search(r'void\s+main\s*\(', content):
        return False

    # Check for top-level executable statements after #region example
    region_match = re.search(r'// #region example\n(.*?)// #endregion example', content, re.DOTALL)
    if not region_match:
        return False

    region_content = region_match.group(1)

    # Look for executable patterns
    executable_patterns = [
        r'^\s*getIt\.',
        r'^\s*final\s+\w+\s*=\s*getIt',
        r'^\s*var\s+\w+\s*=',
        r'^\s*await\s+',
    ]

    for line in region_content.split('\n'):
        stripped = line.strip()
        if stripped and not stripped.startswith('//'):
            for pattern in executable_patterns:
                if re.match(pattern, line):
                    return True

    return False

def wrap_executable_code(filepath: Path):
    """Wrap executable code in void main()"""
    with open(filepath, 'r') as f:
        content = f.read()

    if not needs_wrapping(content):
        return False

    # Find the region
    region_match = re.search(r'(// #region example\n)(.*?)(// #endregion example)', content, re.DOTALL)
    if not region_match:
        return False

    region_start = region_match.group(1)
    region_content = region_match.group(2)
    region_end = region_match.group(3)

    # Split into class definitions and executable code
    lines = region_content.split('\n')
    class_lines = []
    exec_lines = []
    in_exec = False

    for line in lines:
        stripped = line.strip()

        # Check if this is the start of executable code
        if not in_exec and (
            re.match(r'getIt\.', stripped) or
            re.match(r'final\s+\w+\s*=\s*getIt', stripped) or
            (stripped.startswith('//') and 'Find' in stripped) or
            (stripped.startswith('//') and 'Returns' in stripped)
        ):
            in_exec = True

        if in_exec:
            if stripped:
                exec_lines.append('  ' + line if line.strip() else '')
            else:
                exec_lines.append('')
        else:
            class_lines.append(line)

    # Rebuild content
    new_region = region_start
    new_region += '\n'.join(class_lines).rstrip() + '\n\n'
    new_region += 'void main() {\n'
    new_region += '\n'.join(exec_lines).rstrip() + '\n'
    new_region += '}\n'
    new_region += region_end

    new_content = content[:region_match.start()] + new_region + content[region_match.end():]

    with open(filepath, 'w') as f:
        f.write(new_content)

    return True

def main():
    lib_dir = Path("lib/get_it")
    dart_files = [f for f in lib_dir.glob("*.dart") if not f.name.endswith('_signature.dart')]

    fixed_count = 0
    for filepath in dart_files:
        try:
            if wrap_executable_code(filepath):
                print(f"Fixed {filepath.name}")
                fixed_count += 1
        except Exception as e:
            print(f"Error processing {filepath.name}: {e}")

    print(f"\nFixed {fixed_count} files with unwrapped executable code")

if __name__ == '__main__':
    main()
