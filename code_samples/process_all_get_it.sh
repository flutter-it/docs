#!/bin/bash

# Process all remaining get_it documentation files
# Usage: bash process_all_get_it.sh

set -e  # Exit on error

echo "============================================================"
echo "Processing all get_it documentation files"
echo "============================================================"
echo

files=(
    "../docs/documentation/get_it/getting_started.md"
    "../docs/documentation/get_it/object_registration.md"
    "../docs/documentation/get_it/scopes.md"
    "../docs/documentation/get_it/multiple_registrations.md"
    "../docs/documentation/get_it/advanced.md"
    "../docs/documentation/get_it/testing.md"
    "../docs/documentation/get_it/faq.md"
)

total=${#files[@]}
current=0

for file in "${files[@]}"; do
    current=$((current + 1))
    echo "[$current/$total] Processing: $file"
    python3 extract_samples_v2.py "$file" get_it
    echo
done

echo "============================================================"
echo "All get_it files processed!"
echo "Running flutter analyze to check for errors..."
echo "============================================================"
echo

flutter analyze 2>&1 | grep -E '(error|warning|info|issues found)'

echo
echo "Done! Check the output above for any compilation errors."
