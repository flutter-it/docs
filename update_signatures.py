#!/usr/bin/env python3
"""
Update signature files from get_it source.

This script extracts method signatures from get_it.dart and updates the
corresponding signature files in the documentation code samples.

Usage:
    python3 update_signatures.py [--dry-run] [--verbose]

Options:
    --dry-run   Show what would be updated without making changes
    --verbose   Show detailed information about each signature
"""

import re
import sys
from pathlib import Path
from typing import Dict, List, Optional
from dataclasses import dataclass


@dataclass
class MethodSignature:
    """Represents a method signature."""
    name: str
    return_type: str
    generic_params: str
    parameters: str
    full_signature: str
    comment: Optional[str] = None


def extract_source_signatures(source_file: Path) -> Dict[str, MethodSignature]:
    """Extract method signatures from get_it source code."""
    if not source_file.exists():
        print(f"Error: Source file not found: {source_file}")
        return {}

    with open(source_file, 'r', encoding='utf-8') as f:
        content = f.read()

    signatures = {}
    lines = content.split('\n')
    i = 0

    while i < len(lines):
        line = lines[i]

        # Look for doc comments
        doc_comment = None
        if line.strip().startswith('///'):
            doc_lines = []
            j = i
            while j < len(lines) and lines[j].strip().startswith('///'):
                doc_lines.append(lines[j])
                j += 1
            doc_comment = '\n'.join(doc_lines)
            i = j
            if i >= len(lines):
                break
            line = lines[i]

        # Try to match method start
        # Pattern: ReturnType methodName<T>(...) {
        # Return type can include ? for nullable, and generic parameters
        match = re.match(r'^\s*(\w+(?:<[^>]+>)?\??)\s+(\w+)(<[^>]*>)?\s*\(', line)
        if match:
            return_type = match.group(1)
            method_name = match.group(2)
            generic_params = match.group(3) or ""

            # Skip private methods, constructors, and certain methods
            if method_name.startswith('_') or method_name == 'GetIt':
                i += 1
                continue

            # Collect full method signature across multiple lines until we hit ); or ) {
            full_signature = line
            j = i
            while j < len(lines) and not re.search(r'\)\s*[;{]', full_signature):
                j += 1
                if j < len(lines):
                    full_signature += '\n' + lines[j]

            # Extract parameters from full signature
            paren_start = full_signature.find('(')
            if paren_start == -1:
                params_text = ""
            else:
                paren_count = 1
                k = paren_start + 1
                while k < len(full_signature) and paren_count > 0:
                    if full_signature[k] == '(':
                        paren_count += 1
                    elif full_signature[k] == ')':
                        paren_count -= 1
                    k += 1
                params_text = full_signature[paren_start + 1:k - 1]

            # Clean up the signature - remove implementation and keep only declaration
            # First handle => expression; pattern
            clean_sig = re.sub(r'\)\s*=>.*?;', ');', full_signature, flags=re.DOTALL)
            # Then handle { ... } blocks
            clean_sig = re.sub(r'\)\s*\{.*', ');', clean_sig, flags=re.DOTALL)
            # Finally handle remaining ; patterns
            clean_sig = re.sub(r'\)\s*;.*', ');', clean_sig, flags=re.DOTALL)

            signature = MethodSignature(
                name=method_name,
                return_type=return_type,
                generic_params=generic_params,
                parameters=params_text,
                full_signature=clean_sig.rstrip(),  # Only strip trailing whitespace
                comment=doc_comment
            )

            signatures[method_name] = signature
            i = j

        i += 1

    return signatures


def find_signature_files_for_method(method_name: str, sig_dir: Path) -> List[Path]:
    """Find all signature files that might correspond to a method."""
    candidates = []

    # Look for files that might contain this method
    for sig_file in sig_dir.glob("*_signature.dart"):
        with open(sig_file, 'r', encoding='utf-8') as f:
            content = f.read()
            # Check if method name appears in the file
            if re.search(rf'\b{method_name}\b', content):
                candidates.append(sig_file)

    return candidates


def update_signature_file(sig_file: Path, signature: MethodSignature, dry_run: bool = False) -> bool:
    """Update a signature file with the new signature."""

    # Generate the new content
    lines = []
    lines.append("// ignore_for_file: missing_function_body, unused_element")

    # Check if we need import
    if 'GetIt' in signature.full_signature or 'ObjectRegistration' in signature.full_signature:
        lines.append("import 'package:get_it/get_it.dart';")
        lines.append("")

    lines.append("// #region example")

    # Collect all content (signature only, skip verbose doc comments for signature files)
    all_content = []
    # Only include first line of doc comment if it's short and descriptive
    if signature.comment:
        comment_lines = signature.comment.split('\n')
        # Only include if it's a single-line comment
        if len(comment_lines) == 1:
            all_content.extend(comment_lines)
    all_content.extend(signature.full_signature.split('\n'))

    # Remove common leading whitespace from all lines
    min_indent = float('inf')
    for line in all_content:
        if line.strip():  # Skip empty lines
            indent = len(line) - len(line.lstrip())
            min_indent = min(min_indent, indent)

    if min_indent < float('inf'):
        all_content = [line[min_indent:] if len(line) > min_indent else line for line in all_content]

    lines.extend(all_content)

    lines.append("// #endregion example")

    new_content = '\n'.join(lines) + '\n'

    if dry_run:
        print(f"Would update {sig_file.name}:")
        print(new_content)
        return False
    else:
        with open(sig_file, 'w', encoding='utf-8') as f:
            f.write(new_content)
        return True


def main():
    """Main entry point."""
    import argparse

    parser = argparse.ArgumentParser(description="Update signature files from get_it source")
    parser.add_argument('--dry-run', action='store_true', help='Show changes without applying them')
    parser.add_argument('--verbose', action='store_true', help='Show detailed information')
    args = parser.parse_args()

    # Paths
    base_dir = Path(__file__).parent
    source_file = base_dir.parent / "get_it" / "lib" / "get_it.dart"
    sig_dir = base_dir / "code_samples" / "lib" / "get_it"

    if not source_file.exists():
        print(f"Error: Source file not found: {source_file}")
        sys.exit(1)

    if not sig_dir.exists():
        print(f"Error: Signature directory not found: {sig_dir}")
        sys.exit(1)

    # Extract signatures from source
    print(f"Extracting signatures from {source_file}...")
    signatures = extract_source_signatures(source_file)
    print(f"Found {len(signatures)} methods in source\n")

    if args.verbose:
        print("Methods found:")
        for name in sorted(signatures.keys()):
            print(f"  - {name}")
        print()

    # Find and update signature files
    updated_count = 0
    not_found_count = 0

    # Common signature file mappings (based on existing files)
    known_mappings = {
        'get': ['code_sample_908a2d50.dart'],
        'maybeGet': ['code_sample_fdab4a35_signature.dart'],
        'isRegistered': ['code_sample_3ddc0f1f_signature.dart'],
        'unregister': ['function_example_1_signature.dart'],
        'resetLazySingleton': ['function_example_2_signature.dart'],
        'findFirstObjectRegistration': ['code_sample_f4194899_signature.dart'],
        'registerSingleton': ['t_example_signature.dart'],
        'registerSingletonAsync': ['register_singleton_async_signature.dart'],
        'registerFactoryAsync': ['register_factory_async_signature.dart'],
        'registerCachedFactoryAsync': ['register_cached_factory_async_signature.dart'],
        'registerLazySingletonAsync': ['register_lazy_singleton_async_signature.dart'],
        # Add more mappings as needed
    }

    for method_name, sig_files in known_mappings.items():
        if method_name not in signatures:
            print(f"⚠️  Method '{method_name}' not found in source")
            not_found_count += 1
            continue

        signature = signatures[method_name]

        for sig_file_name in sig_files:
            sig_file = sig_dir / sig_file_name

            if not sig_file.exists():
                print(f"⚠️  Signature file not found: {sig_file_name}")
                continue

            if update_signature_file(sig_file, signature, dry_run=args.dry_run):
                print(f"✅ Updated: {sig_file_name} ({method_name})")
                updated_count += 1
            elif args.dry_run:
                print(f"📝 Would update: {sig_file_name} ({method_name})")

    print(f"\n{'DRY RUN - ' if args.dry_run else ''}Summary:")
    print(f"  Updated: {updated_count} files")
    if not_found_count > 0:
        print(f"  Not found in source: {not_found_count} methods")

    if args.dry_run:
        print("\nRun without --dry-run to apply changes")


if __name__ == '__main__':
    main()
