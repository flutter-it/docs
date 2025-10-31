#!/bin/bash
# Final cleanup of all remaining error files

echo "Running final cleanup..."

# Fix files with duplicate definitions
for file in lib/get_it/*.dart; do
  # Remove duplicate const username lines
  if grep -q "const username =" "$file"; then
    # Keep only the first occurrence
    awk '!seen[$0]++ || !/const username =/' "$file" > "$file.tmp" && mv "$file.tmp" "$file"
  fi

  # Remove duplicate const password lines
  if grep -q "const password =" "$file"; then
    awk '!seen[$0]++ || !/const password =/' "$file" > "$file.tmp" && mv "$file.tmp" "$file"
  fi
done

# Format all files that can be formatted
dart format lib/get_it/*.dart 2>/dev/null

# Run analyzer to get final count
echo ""
echo "Final analysis:"
flutter analyze 2>&1 | grep -E "^(  error|issues found)"

echo "Cleanup complete"
