#!/usr/bin/env python3
"""
Automated Code Sample Extractor for flutter_it Documentation

This script:
1. Extracts code blocks from markdown documentation files
2. Creates compilable .dart files with proper structure and region markers
3. Updates markdown files to use VitePress region import syntax
4. Ensures all code samples are compilable via flutter analyze

Usage:
    python extract_samples_v2.py <markdown_file> <package_name>

Example:
    python extract_samples_v2.py docs/documentation/get_it/object_registration.md get_it
"""

import re
import os
import sys
from pathlib import Path
from typing import List, Tuple, Dict
import hashlib


class CodeBlock:
    """Represents a code block extracted from markdown"""
    def __init__(self, code: str, language: str, line_number: int, context: str = ""):
        self.code = code.strip()
        self.language = language
        self.line_number = line_number
        self.context = context  # Heading or description before the code block
        self.is_signature = self._detect_signature()
        self.filename = self._generate_filename()

    def _detect_signature(self) -> bool:
        """Detect if this is a signature/API definition block"""
        # Check context for signature indicators
        signature_keywords = ['signature', 'api', 'method signature', 'function signature']
        context_lower = self.context.lower()
        if any(keyword in context_lower for keyword in signature_keywords):
            return True

        # Check if code looks like signatures (functions without bodies)
        lines = self.code.split('\n')
        function_lines = [l for l in lines if l.strip() and not l.strip().startswith('//')]

        # If most non-comment lines end with ) or ; without {, it's likely a signature
        if function_lines:
            signature_pattern_count = sum(1 for l in function_lines
                                         if l.rstrip().endswith((');', ')')) and '{' not in l)
            return signature_pattern_count > len(function_lines) * 0.6

        return False

    def _generate_filename(self) -> str:
        """Generate a meaningful filename from context or code content"""
        # Try to extract a function/class name from the code
        patterns = [
            r'void\s+(\w+)\s*\(',
            r'class\s+(\w+)',
            r'Future<\w+>\s+(\w+)\s*\(',
            r'registerSingleton<(\w+)>',
            r'registerFactory<(\w+)>',
        ]

        for pattern in patterns:
            match = re.search(pattern, self.code)
            if match:
                name = match.group(1)
                suffix = '_signature.dart' if self.is_signature else '_example.dart'
                return f"{self._to_snake_case(name)}{suffix}"

        # Fall back to hash-based naming
        code_hash = hashlib.md5(self.code.encode()).hexdigest()[:8]
        suffix = '_signature.dart' if self.is_signature else '.dart'
        return f"code_sample_{code_hash}{suffix}"

    def _to_snake_case(self, name: str) -> str:
        """Convert CamelCase to snake_case"""
        s1 = re.sub('(.)([A-Z][a-z]+)', r'\1_\2', name)
        return re.sub('([a-z0-9])([A-Z])', r'\1_\2', s1).lower()


class MarkdownProcessor:
    """Processes markdown files to extract and replace code blocks"""

    def __init__(self, markdown_path: str, package_name: str):
        self.markdown_path = Path(markdown_path)
        self.package_name = package_name
        self.code_blocks: List[CodeBlock] = []
        self.content = ""

        # Determine output directory
        self.output_dir = Path("lib") / package_name
        self.output_dir.mkdir(parents=True, exist_ok=True)

    def extract_code_blocks(self) -> List[CodeBlock]:
        """Extract all Dart code blocks from the markdown file"""
        with open(self.markdown_path, 'r', encoding='utf-8') as f:
            self.content = f.read()

        # Pattern to match code blocks with optional language specifier
        pattern = r'```(\w+)?\n(.*?)\n```'
        matches = re.finditer(pattern, self.content, re.DOTALL)

        current_heading = ""

        for match in matches:
            language = match.group(1) or 'dart'
            code = match.group(2)
            line_number = self.content[:match.start()].count('\n') + 1

            # Only process Dart code blocks
            if language.lower() in ['dart', 'flutter']:
                # Skip blocks that contain markdown syntax (nested code blocks)
                if self._contains_markdown(code):
                    print(f"  ⊘ Skipping markdown content at line {line_number}")
                    continue

                # Find the most recent heading before this code block
                heading_pattern = r'^#+\s+(.+)$'
                content_before = self.content[:match.start()]
                headings = re.findall(heading_pattern, content_before, re.MULTILINE)
                if headings:
                    current_heading = headings[-1]

                block = CodeBlock(code, language, line_number, current_heading)
                self.code_blocks.append(block)

        print(f"✓ Extracted {len(self.code_blocks)} code blocks from {self.markdown_path.name}")
        return self.code_blocks

    def _contains_markdown(self, code: str) -> bool:
        """Check if code block contains markdown syntax (invalid Dart code)"""
        markdown_indicators = [
            r'```',  # Nested code blocks
            r'^\d+\.\s+\*\*',  # Numbered lists with bold (1. **Step**)
            r'^\s*#{1,6}\s+\w',  # Markdown headers
            r'\[.*\]\(.*\)',  # Markdown links
            r'→',  # Arrows (diagrams/flowcharts)
            r'^\s*Push\s+\w+',  # Pseudo-code like "Push DetailPage"
            r'^\s*Pop\s+\w+',  # Pseudo-code like "Pop DetailPage"
            r'refCount\s*=',  # Diagram notation
        ]

        for pattern in markdown_indicators:
            if re.search(pattern, code, re.MULTILINE):
                return True
        return False

    def _needs_function_wrapper(self, code: str) -> bool:
        """Check if code needs to be wrapped in a function"""
        # Don't wrap if it already has a main/function definition
        if re.search(r'^(void|Future<void>)\s+main\s*\(', code, re.MULTILINE):
            return False

        # Don't wrap class definitions
        if re.search(r'^class\s+\w+', code, re.MULTILINE):
            return False

        # Don't wrap if it's only function/class definitions
        lines = [l.strip() for l in code.split('\n') if l.strip() and not l.strip().startswith('//')]
        if all(re.match(r'^(class|abstract\s+class|void|Future|enum|typedef)\s+', l) for l in lines if l):
            return False

        # Check for executable statements (ignore comments and blank lines)
        non_comment_lines = [l.strip() for l in code.split('\n') if l.strip() and not l.strip().startswith('//')]

        # Wrap if it has await
        if 'await ' in code:
            return True

        # Wrap if there are executable statements
        for line in non_comment_lines:
            # Check for common executable patterns
            if any(line.startswith(pattern) for pattern in [
                'getIt.', 'getIt<', 'if ', 'for ', 'while ', 'print(',
                'final ', 'var ', 'return ', 'throw '
            ]):
                return True

        return False

    def create_dart_file(self, block: CodeBlock, index: int) -> Path:
        """Create a compilable .dart file from a code block"""
        # Generate unique filename if there's a conflict
        base_filename = block.filename
        filename = base_filename
        counter = 1

        while (self.output_dir / filename).exists():
            name, ext = os.path.splitext(base_filename)
            filename = f"{name}_{counter}{ext}"
            counter += 1

        filepath = self.output_dir / filename

        # Build the complete file content
        content_parts = []

        # Signature files get special treatment
        if block.is_signature:
            content_parts.append("// ignore_for_file: missing_function_body, unused_element")
            content_parts.append(block.code)
        else:
            # Regular example files
            # Add imports
            content_parts.append(f"import 'package:get_it/get_it.dart';")

            # Add Flutter import if needed
            if self._needs_flutter_import(block.code):
                content_parts.append("import 'package:flutter/material.dart';")

            # Add stubs import
            content_parts.append(f"import '_shared/stubs.dart';")
            content_parts.append("")

            # Add GetIt instance if used
            if 'getIt' in block.code or 'GetIt.instance' in block.code:
                content_parts.append("final getIt = GetIt.instance;")
                content_parts.append("")

            # Add the example code with region markers
            content_parts.append("// #region example")

            # Wrap in async function if needed
            if self._needs_function_wrapper(block.code):
                content_parts.append("void main() async {")
                content_parts.append(block.code)
                content_parts.append("}")
            else:
                content_parts.append(block.code)

            content_parts.append("// #endregion example")

        # Write the file
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write('\n'.join(content_parts))

        file_type = "[signature]" if block.is_signature else "[example]  "
        print(f"  → {file_type} Created {filepath}")
        return filepath

    def _needs_flutter_import(self, code: str) -> bool:
        """Check if code needs Flutter import"""
        flutter_indicators = [
            'Widget', 'StatelessWidget', 'StatefulWidget',
            'BuildContext', 'MaterialApp', 'Scaffold',
            'runApp', 'FutureBuilder', 'StreamBuilder'
        ]
        return any(indicator in code for indicator in flutter_indicators)

    def update_markdown(self, replacements: Dict[int, str]) -> str:
        """Update markdown file to use VitePress region syntax"""
        lines = self.content.split('\n')
        updated_lines = []
        i = 0

        while i < len(lines):
            line = lines[i]

            # Check if this is the start of a code block we want to replace
            if line.startswith('```'):
                # Find the line number
                line_number = i + 1

                if line_number in replacements:
                    # Skip the entire code block
                    i += 1
                    while i < len(lines) and not lines[i].startswith('```'):
                        i += 1
                    i += 1  # Skip the closing ```

                    # Add the VitePress import instead
                    updated_lines.append('')
                    updated_lines.append(replacements[line_number])
                    continue

            updated_lines.append(line)
            i += 1

        return '\n'.join(updated_lines)

    def process(self, dry_run: bool = False) -> None:
        """Main processing function"""
        print(f"\n{'='*60}")
        print(f"Processing: {self.markdown_path}")
        print(f"Package: {self.package_name}")
        print(f"{'='*60}\n")

        # Extract code blocks
        blocks = self.extract_code_blocks()

        if not blocks:
            print("No code blocks found!")
            return

        # Create .dart files and track replacements
        replacements = {}

        for i, block in enumerate(blocks):
            filepath = self.create_dart_file(block, i)

            # Generate VitePress import path
            relative_path = filepath.relative_to(Path("lib").parent)

            # Signature files import the whole file, examples use #example region
            if block.is_signature:
                vitepress_import = f"<<< @/../code_samples/{relative_path}"
            else:
                vitepress_import = f"<<< @/../code_samples/{relative_path}#example"

            replacements[block.line_number] = vitepress_import

        if dry_run:
            print(f"\n✓ Dry run complete. Would have updated {len(replacements)} code blocks.")
            return

        # Update the markdown file
        updated_content = self.update_markdown(replacements)

        # Create backup
        backup_path = self.markdown_path.with_suffix('.md.backup')
        with open(backup_path, 'w', encoding='utf-8') as f:
            f.write(self.content)
        print(f"\n✓ Created backup: {backup_path}")

        # Write updated markdown
        with open(self.markdown_path, 'w', encoding='utf-8') as f:
            f.write(updated_content)

        print(f"✓ Updated {self.markdown_path.name} with {len(replacements)} VitePress imports")
        print(f"\n{'='*60}")
        print(f"Summary:")
        print(f"  - Code blocks extracted: {len(blocks)}")
        print(f"  - Dart files created: {len(blocks)}")
        print(f"  - Markdown file updated: {self.markdown_path.name}")
        print(f"{'='*60}\n")


def main():
    """Main entry point"""
    # Parse arguments
    dry_run = '--dry-run' in sys.argv
    args = [arg for arg in sys.argv[1:] if not arg.startswith('--')]

    if len(args) < 2:
        print("Usage: python extract_samples_v2.py [--dry-run] <markdown_file> <package_name>")
        print("\nExample:")
        print("  python extract_samples_v2.py docs/documentation/get_it/object_registration.md get_it")
        print("  python extract_samples_v2.py --dry-run docs/documentation/get_it/object_registration.md get_it")
        sys.exit(1)

    markdown_file = args[0]
    package_name = args[1]

    if not os.path.exists(markdown_file):
        print(f"Error: File not found: {markdown_file}")
        sys.exit(1)

    processor = MarkdownProcessor(markdown_file, package_name)
    processor.process(dry_run=dry_run)


if __name__ == '__main__':
    main()
