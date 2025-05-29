#!/bin/bash
# Save as: test-coverage.sh

set -e

echo "Running tests with code coverage..."
swift test --enable-code-coverage

echo "Generating coverage report..."

# Find the profdata file and build directory
PROFDATA=$(find .build -name "default.profdata" | head -1)
BUILD_DIR=$(dirname "$(dirname "$PROFDATA")")

# Find the test executable
TEST_BINARY=$(find "$BUILD_DIR" -name "*PackageTests.xctest" -o -name "*PackageTests" | head -1)

if [[ "$TEST_BINARY" == *.xctest ]]; then
    EXECUTABLE="$TEST_BINARY/Contents/MacOS/$(basename "$TEST_BINARY" .xctest)"
else
    EXECUTABLE="$TEST_BINARY"
fi

echo ""
echo "=== PACKAGE COVERAGE ==="
echo ""

# Parse and format the coverage data nicely
xcrun llvm-cov report "$EXECUTABLE" --instr-profile="$PROFDATA" | grep "^Sources/" | grep -v ".build/checkouts" | awk '
{
    # Extract filename (remove Sources/ModuleName/ prefix)
    filename = $1
    gsub(/^Sources\/[^\/]+\//, "", filename)
    
    # Calculate line coverage percentage
    total_lines = $8
    missed_lines = $9
    if (total_lines > 0) {
        covered_lines = total_lines - missed_lines
        percentage = (covered_lines / total_lines) * 100
        printf "  %-25s %6.1f%% (%d/%d lines)\n", filename, percentage, covered_lines, total_lines
    }
    
    # Track totals
    total_all_lines += total_lines
    total_missed_lines += missed_lines
}
END {
    if (total_all_lines > 0) {
        total_covered = total_all_lines - total_missed_lines
        total_percentage = (total_covered / total_all_lines) * 100
        print ""
        printf "  %-25s %6.1f%% (%d/%d lines)\n", "TOTAL", total_percentage, total_covered, total_all_lines
    }
}'