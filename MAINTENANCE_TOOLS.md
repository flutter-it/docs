# Documentation Maintenance Tools

This directory contains tools for maintaining the get_it documentation and code examples.

## Tools

### validate_signatures.py

Validates that documentation signature files match the actual get_it package API.

**Purpose:** Detects when signature files become outdated due to API changes in the get_it package.

**Usage:**
```bash
python3 validate_signatures.py              # Human-readable report
python3 validate_signatures.py --json       # JSON output for CI
python3 validate_signatures.py --verbose    # Detailed comparison
```

**What it checks:**
- Return types match between docs and source
- Generic parameters match (allows simplified `<T>` vs `<T extends Object>`)
- Parameter counts and types match
- Parameter optionality (required vs optional)
- Named vs positional parameters

**Exit codes:**
- `0` - All signatures valid or only minor differences (parameter names)
- `1` - Broken signatures found (critical issues)

**When to run:**
- After updating the get_it package
- Before releasing new documentation
- Periodically to catch drift
- Can be added to CI pipeline

---

### update_baseline.py

Updates the baseline snapshot of all code examples.

**Purpose:** Creates a JSON snapshot of the current state of all code samples for future comparison and verification work.

**Usage:**
```bash
python3 update_baseline.py                           # Updates phase1_original_code.json
python3 update_baseline.py --output baseline.json    # Custom output file
```

**What it captures:**
- All `.dart` files in `code_samples/lib/get_it/`
- All `#region` blocks within each file

**When to run:**
- After making significant changes to code examples
- Before starting major refactoring work (to have a baseline)
- After verifying all code compiles and examples are correct

**Output format:**
```json
{
  "filename.dart": {
    "example": "// code from #region example",
    "another-region": "// code from #region another-region"
  }
}
```

---

## Files

- **validate_signatures.py** (16K) - Signature validation tool
- **update_baseline.py** (3.2K) - Baseline snapshot tool
- **phase1_original_code.json** (~88K) - Current baseline snapshot
- **package.json**, **package-lock.json** - VitePress build dependencies

---

## Workflow Examples

### After API Changes

```bash
# 1. Update get_it package
cd ../get_it
git pull

# 2. Check for outdated signatures
cd ../docs
python3 validate_signatures.py

# 3. Fix any broken signatures reported
# (edit signature files as needed)

# 4. Verify docs build
npm run docs:build

# 5. Update baseline
python3 update_baseline.py
```

### Before Major Refactoring

```bash
# 1. Create snapshot of current state
python3 update_baseline.py --output before_refactor.json

# 2. Do refactoring work
# (edit code examples, markdown, etc.)

# 3. Verify everything compiles
cd code_samples
flutter analyze

# 4. Compare changes (optional - use diff tool)
python3 update_baseline.py --output after_refactor.json
# Then manually compare before_refactor.json vs after_refactor.json

# 5. Update official baseline
python3 update_baseline.py
```

### Routine Maintenance

```bash
# Weekly/monthly checks
python3 validate_signatures.py
npm run docs:build

# If all good, update baseline
python3 update_baseline.py
```

---

## Integration with CI

### GitHub Actions Example

```yaml
- name: Validate signature files
  run: |
    cd docs
    python3 validate_signatures.py --json > signature_results.json

- name: Upload results
  uses: actions/upload-artifact@v3
  with:
    name: signature-validation
    path: docs/signature_results.json
```

---

## Notes

- **signature files** (ending in `_signature.dart`) show API surface without implementation
- **region markers** use format `// #region name` and `// #endregion`
- **stubs** are in `code_samples/lib/get_it/_shared/stubs.dart`
- All code examples must compile (verify with `flutter analyze`)
