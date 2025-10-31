#!/usr/bin/env python3
"""
Validate documentation signature files against actual get_it package source.

This script compares method signatures in documentation examples with the actual
get_it package implementation to detect API drift and outdated documentation.

Usage:
    python3 validate_signatures.py [--json] [--verbose]

Options:
    --json      Output results in JSON format
    --verbose   Show detailed comparison information
"""

import re
import json
from pathlib import Path
from typing import Dict, List, Optional, Tuple
from dataclasses import dataclass, asdict
import sys

# Paths
GET_IT_SOURCE = Path("../get_it/lib/get_it.dart")
SIGNATURE_DIR = Path("code_samples/lib/get_it")


@dataclass
class Parameter:
    """Represents a function parameter."""
    name: str
    type: str
    is_optional: bool = False
    is_named: bool = False
    default_value: Optional[str] = None


@dataclass
class MethodSignature:
    """Represents a method signature."""
    name: str
    return_type: str
    generic_params: str = ""
    parameters: List[Parameter] = None

    def __post_init__(self):
        if self.parameters is None:
            self.parameters = []

    def signature_str(self) -> str:
        """Generate a comparable signature string."""
        params_str = ", ".join([
            f"{p.type} {p.name}" + (f" = {p.default_value}" if p.default_value else "")
            for p in self.parameters
        ])
        return f"{self.return_type} {self.name}{self.generic_params}({params_str})"


@dataclass
class ValidationResult:
    """Result of signature validation."""
    signature_file: str
    source_method: Optional[str]
    status: str  # 'valid', 'minor_diff', 'broken', 'orphaned', 'missing_source'
    issues: List[str]
    signature_found: Optional[MethodSignature] = None
    signature_expected: Optional[MethodSignature] = None


def extract_source_signatures(source_file: Path) -> Dict[str, MethodSignature]:
    """Extract method signatures from get_it source code."""
    if not source_file.exists():
        print(f"Warning: Source file not found: {source_file}")
        return {}

    with open(source_file, 'r', encoding='utf-8') as f:
        content = f.read()

    signatures = {}

    # Pattern to match method signatures
    # Matches: ReturnType methodName<T>(...) { or ReturnType methodName<T>(...);
    method_pattern = r'^\s*(\w+(?:<[^>]+>)?)\s+(\w+)(<[^>]*>)?\s*\('

    lines = content.split('\n')
    i = 0

    while i < len(lines):
        line = lines[i]

        # Try to match method start
        match = re.match(method_pattern, line)
        if match:
            return_type = match.group(1)
            method_name = match.group(2)
            generic_params = match.group(3) or ""

            # Skip private methods
            if method_name.startswith('_'):
                i += 1
                continue

            # Collect full method signature across multiple lines until we hit ); or ) {
            full_signature = line
            j = i
            while j < len(lines) and not re.search(r'\)\s*[;{]', full_signature):
                j += 1
                if j < len(lines):
                    full_signature += ' ' + lines[j].strip()

            # Extract parameters from full signature
            # Find content between first ( and matching ) before ; or {
            # Need to handle nested parentheses like DisposingFunc<T>
            paren_start = full_signature.find('(')
            if paren_start == -1:
                params_text = ""
            else:
                paren_count = 1
                i = paren_start + 1
                while i < len(full_signature) and paren_count > 0:
                    if full_signature[i] == '(':
                        paren_count += 1
                    elif full_signature[i] == ')':
                        paren_count -= 1
                    i += 1
                params_text = full_signature[paren_start + 1:i - 1]

            # Parse parameters
            parameters = parse_parameters(params_text)

            signature = MethodSignature(
                name=method_name,
                return_type=return_type,
                generic_params=generic_params,
                parameters=parameters
            )

            signatures[method_name] = signature
            i = j  # Skip to end of this method signature

        i += 1

    return signatures


def parse_parameters(params_text: str) -> List[Parameter]:
    """Parse parameter list from Dart method signature."""
    parameters = []

    if not params_text.strip():
        return parameters

    # Split by comma, but not within <> brackets
    parts = []
    current = ""
    bracket_depth = 0
    paren_depth = 0

    for char in params_text:
        if char == '<':
            bracket_depth += 1
        elif char == '>':
            bracket_depth -= 1
        elif char == '(':
            paren_depth += 1
        elif char == ')':
            paren_depth -= 1
        elif char == ',' and bracket_depth == 0 and paren_depth == 0:
            parts.append(current.strip())
            current = ""
            continue
        current += char

    if current.strip():
        parts.append(current.strip())

    # Parse each parameter
    is_named = False
    for part in parts:
        part = part.strip()

        if not part:
            continue

        # Check for named parameters start
        if part.startswith('{'):
            is_named = True
            part = part[1:].strip()

        # Remove trailing }
        part = part.rstrip('}').strip()

        # Check for optional positional
        is_optional = part.startswith('[')
        if is_optional:
            part = part[1:].rstrip(']').strip()

        # Parse: Type name [= default]
        default_value = None
        if '=' in part:
            part, default_value = part.split('=', 1)
            part = part.strip()
            default_value = default_value.strip()

        # Check for 'required' keyword
        required = part.startswith('required ')
        if required:
            part = part[9:].strip()

        # Split type and name
        parts_split = part.split()
        if len(parts_split) >= 2:
            # Type might be complex like "Map<String, int>"
            # Name is always the last token
            param_name = parts_split[-1].rstrip(',').rstrip('?')
            param_type = ' '.join(parts_split[:-1])
        elif len(parts_split) == 1:
            # Only type, no name (shouldn't happen in real signatures)
            param_type = parts_split[0]
            param_name = ""
        else:
            continue

        parameters.append(Parameter(
            name=param_name,
            type=param_type,
            is_optional=is_optional or is_named or default_value is not None,
            is_named=is_named,
            default_value=default_value
        ))

    return parameters


def extract_signature_from_file(signature_file: Path) -> Optional[MethodSignature]:
    """Extract method signature from documentation signature file."""
    with open(signature_file, 'r', encoding='utf-8') as f:
        content = f.read()

    # Extract content within #region example if it exists
    region_match = re.search(r'// #region example(.*?)// #endregion', content, re.DOTALL)
    if region_match:
        content = region_match.group(1)

    # Look for method definitions (function signatures)
    # Pattern: ReturnType methodName<T>(...) followed by =>, {, or just end
    pattern = r'(\w+(?:<[^>]+>)?)\s+(\w+)(<[^>]*>)?\s*\('

    # Handle multi-line signatures - normalize whitespace
    content_single_line = re.sub(r'\s+', ' ', content)

    match = re.search(pattern, content_single_line)

    if not match:
        return None

    return_type = match.group(1)
    method_name = match.group(2)
    generic_params = match.group(3) or ""

    # Extract parameters - find content between ( and )
    # Need to handle nested parentheses in types like Function(String)
    paren_start = match.end() - 1  # Position of opening (
    paren_count = 1
    i = paren_start + 1

    while i < len(content_single_line) and paren_count > 0:
        if content_single_line[i] == '(':
            paren_count += 1
        elif content_single_line[i] == ')':
            paren_count -= 1
        i += 1

    params_text = content_single_line[paren_start + 1:i - 1]

    parameters = parse_parameters(params_text)

    return MethodSignature(
        name=method_name,
        return_type=return_type,
        generic_params=generic_params,
        parameters=parameters
    )


def compare_signatures(doc_sig: MethodSignature, source_sig: MethodSignature) -> Tuple[str, List[str]]:
    """
    Compare two signatures and return status and list of issues.

    Returns:
        (status, issues) where status is 'valid', 'minor_diff', or 'broken'
    """
    issues = []

    # Compare return types
    if doc_sig.return_type != source_sig.return_type:
        issues.append(f"Return type mismatch: doc='{doc_sig.return_type}' vs source='{source_sig.return_type}'")

    # Compare generic parameters - allow simplified versions without 'extends Object'
    doc_generics_simplified = re.sub(r'\s*extends\s+Object', '', doc_sig.generic_params)
    source_generics_simplified = re.sub(r'\s*extends\s+Object', '', source_sig.generic_params)

    if doc_generics_simplified != source_generics_simplified:
        issues.append(f"Generic params mismatch: doc='{doc_sig.generic_params}' vs source='{source_sig.generic_params}'")

    # Compare parameter count
    if len(doc_sig.parameters) != len(source_sig.parameters):
        issues.append(f"Parameter count mismatch: doc={len(doc_sig.parameters)} vs source={len(source_sig.parameters)}")
        return ('broken', issues)

    # Compare each parameter
    minor_issues = []
    for i, (doc_param, source_param) in enumerate(zip(doc_sig.parameters, source_sig.parameters)):
        # Type mismatch is critical
        if doc_param.type != source_param.type:
            issues.append(f"Param {i} type mismatch: doc='{doc_param.type}' vs source='{source_param.type}'")

        # Name mismatch is minor (docs might use different names for clarity)
        if doc_param.name != source_param.name:
            minor_issues.append(f"Param {i} name differs: doc='{doc_param.name}' vs source='{source_param.name}'")

        # Optionality mismatch is critical
        if doc_param.is_optional != source_param.is_optional:
            issues.append(f"Param {i} optionality mismatch: {doc_param.name}")

        # Named vs positional mismatch is critical
        if doc_param.is_named != source_param.is_named:
            issues.append(f"Param {i} named/positional mismatch: {doc_param.name}")

    # Determine status
    if issues:
        return ('broken', issues)
    elif minor_issues:
        return ('minor_diff', minor_issues)
    else:
        return ('valid', [])


def validate_signatures(verbose: bool = False) -> List[ValidationResult]:
    """Validate all signature files against source."""
    results = []

    # Extract source signatures
    print(f"Extracting signatures from {GET_IT_SOURCE}...")
    source_signatures = extract_source_signatures(GET_IT_SOURCE)
    print(f"Found {len(source_signatures)} methods in source\n")

    # Find all signature files
    signature_files = sorted(SIGNATURE_DIR.glob("*_signature.dart"))
    print(f"Found {len(signature_files)} signature files\n")

    # Validate each signature file
    for sig_file in signature_files:
        if verbose:
            print(f"Checking {sig_file.name}...")

        # Extract signature from documentation file
        doc_sig = extract_signature_from_file(sig_file)

        if doc_sig is None:
            results.append(ValidationResult(
                signature_file=sig_file.name,
                source_method=None,
                status='broken',
                issues=["Could not parse signature from file"]
            ))
            continue

        # Find matching source method
        source_sig = source_signatures.get(doc_sig.name)

        if source_sig is None:
            results.append(ValidationResult(
                signature_file=sig_file.name,
                source_method=doc_sig.name,
                status='missing_source',
                issues=[f"No method '{doc_sig.name}' found in source"],
                signature_found=doc_sig
            ))
            continue

        # Compare signatures
        status, issues = compare_signatures(doc_sig, source_sig)

        results.append(ValidationResult(
            signature_file=sig_file.name,
            source_method=doc_sig.name,
            status=status,
            issues=issues,
            signature_found=doc_sig,
            signature_expected=source_sig
        ))

        if verbose and issues:
            for issue in issues:
                print(f"  - {issue}")

    return results


def print_report(results: List[ValidationResult]):
    """Print human-readable validation report."""
    print("\n" + "="*80)
    print("SIGNATURE VALIDATION REPORT")
    print("="*80 + "\n")

    # Count by status
    status_counts = {
        'valid': 0,
        'minor_diff': 0,
        'broken': 0,
        'missing_source': 0,
        'orphaned': 0
    }

    for result in results:
        status_counts[result.status] = status_counts.get(result.status, 0) + 1

    # Summary
    print("SUMMARY:")
    print(f"  ✅ {status_counts['valid']} signatures valid")
    print(f"  ⚠️  {status_counts['minor_diff']} minor differences (parameter names)")
    print(f"  ❌ {status_counts['broken']} broken signatures")
    print(f"  📝 {status_counts['missing_source']} signature files without matching source method")
    print(f"  Total: {len(results)} signature files checked\n")

    # Details for problematic signatures
    if status_counts['broken'] > 0:
        print("\n" + "="*80)
        print("❌ BROKEN SIGNATURES:")
        print("="*80)
        for result in results:
            if result.status == 'broken':
                print(f"\n{result.signature_file} (method: {result.source_method})")
                for issue in result.issues:
                    print(f"  - {issue}")

    if status_counts['minor_diff'] > 0:
        print("\n" + "="*80)
        print("⚠️  MINOR DIFFERENCES:")
        print("="*80)
        for result in results:
            if result.status == 'minor_diff':
                print(f"\n{result.signature_file} (method: {result.source_method})")
                for issue in result.issues:
                    print(f"  - {issue}")

    if status_counts['missing_source'] > 0:
        print("\n" + "="*80)
        print("📝 SIGNATURE FILES WITHOUT SOURCE METHOD:")
        print("="*80)
        for result in results:
            if result.status == 'missing_source':
                print(f"\n{result.signature_file}")
                print(f"  Method '{result.source_method}' not found in get_it source")
                print(f"  (This might be a helper function or typedef, not an actual method)")


def main():
    """Main entry point."""
    import argparse

    parser = argparse.ArgumentParser(description="Validate get_it documentation signatures")
    parser.add_argument('--json', action='store_true', help='Output JSON format')
    parser.add_argument('--verbose', action='store_true', help='Verbose output')
    args = parser.parse_args()

    # Validate signatures
    results = validate_signatures(verbose=args.verbose)

    # Output results
    if args.json:
        # JSON output
        output = {
            'total': len(results),
            'valid': sum(1 for r in results if r.status == 'valid'),
            'minor_diff': sum(1 for r in results if r.status == 'minor_diff'),
            'broken': sum(1 for r in results if r.status == 'broken'),
            'missing_source': sum(1 for r in results if r.status == 'missing_source'),
            'results': [asdict(r) for r in results]
        }
        print(json.dumps(output, indent=2))
    else:
        # Human-readable report
        print_report(results)

    # Exit code: 0 if all valid or minor_diff, 1 if any broken
    broken_count = sum(1 for r in results if r.status == 'broken')
    sys.exit(1 if broken_count > 0 else 0)


if __name__ == '__main__':
    main()
