#!/usr/bin/env python3
"""
Update baseline code snapshot from current state.

This script extracts code from all files in code_samples/lib/get_it/ and saves
a JSON snapshot for future comparison and verification work.

Usage:
    python3 update_baseline.py [--output FILE]

Options:
    --output FILE    Output JSON file (default: phase1_original_code.json)
"""

import json
import re
from pathlib import Path
from typing import Dict, List, Optional
import sys


def extract_regions_from_file(file_path: Path) -> Dict[str, str]:
    """Extract all #region blocks from a Dart file."""
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    regions = {}

    # Find all region blocks
    pattern = r'// #region\s+(\S+)(.*?)// #endregion'
    matches = re.finditer(pattern, content, re.DOTALL)

    for match in matches:
        region_name = match.group(1)
        region_content = match.group(2).strip()
        regions[region_name] = region_content

    return regions


def extract_all_code_samples(base_dir: Path) -> Dict[str, Dict[str, str]]:
    """Extract code from all files in get_it code samples directory."""
    code_samples = {}

    get_it_dir = base_dir / "code_samples" / "lib" / "get_it"

    if not get_it_dir.exists():
        print(f"Error: Directory not found: {get_it_dir}")
        return code_samples

    # Find all .dart files (excluding _shared directory)
    dart_files = [
        f for f in get_it_dir.rglob("*.dart")
        if "_shared" not in f.parts
    ]

    print(f"Found {len(dart_files)} Dart files")

    for dart_file in sorted(dart_files):
        # Use relative path from get_it directory as key
        rel_path = dart_file.relative_to(get_it_dir)
        file_key = str(rel_path)

        try:
            regions = extract_regions_from_file(dart_file)
            if regions:
                code_samples[file_key] = regions
                print(f"  ✓ {file_key}: {len(regions)} regions")
            else:
                print(f"  ⚠ {file_key}: no regions found")
        except Exception as e:
            print(f"  ✗ {file_key}: {e}")

    return code_samples


def main():
    """Main entry point."""
    import argparse

    parser = argparse.ArgumentParser(
        description="Update baseline code snapshot from current state"
    )
    parser.add_argument(
        '--output',
        default='phase1_original_code.json',
        help='Output JSON file (default: phase1_original_code.json)'
    )
    args = parser.parse_args()

    # Extract code samples
    base_dir = Path(__file__).parent
    print(f"Extracting code samples from {base_dir}/code_samples/lib/get_it/\n")

    code_samples = extract_all_code_samples(base_dir)

    if not code_samples:
        print("\nError: No code samples found")
        sys.exit(1)

    # Save to JSON
    output_path = base_dir / args.output
    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump(code_samples, f, indent=2, ensure_ascii=False)

    print(f"\n✓ Saved {len(code_samples)} files to {args.output}")
    print(f"  Total size: {output_path.stat().st_size / 1024:.1f} KB")


if __name__ == '__main__':
    main()
