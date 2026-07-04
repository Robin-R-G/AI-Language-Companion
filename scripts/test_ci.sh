#!/bin/bash
# CI Test Script for AI Language Coach
# This script runs all tests and generates coverage reports

set -e

FRONTEND_DIR="frontend"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
COVERAGE_THRESHOLD=80

echo "========================================"
echo "  AI Language Coach - QA Test Suite"
echo "========================================"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

PASSED=0
FAILED=0
TOTAL=0

run_step() {
    local step_name="$1"
    local command="$2"
    
    echo -e "\n${YELLOW}--- $step_name ---${NC}"
    TOTAL=$((TOTAL + 1))
    
    if eval "$command"; then
        echo -e "${GREEN}  [PASSED] $step_name${NC}"
        PASSED=$((PASSED + 1))
    else
        echo -e "${RED}  [FAILED] $step_name${NC}"
        FAILED=$((FAILED + 1))
    fi
}

# 1. Setup
run_step "Setup dependencies" "cd $FRONTEND_DIR && flutter pub get && cd .."

# 2. Code Analysis
run_step "Code analysis" "cd $FRONTEND_DIR && flutter analyze --no-fatal-infos && cd .."

# 3. Format Check
run_step "Format check" "cd $FRONTEND_DIR && dart format --set-exit-if-changed . && cd .."

# 4. Unit Tests
run_step "Unit tests" "cd $FRONTEND_DIR && flutter test --coverage --reporter expanded && cd .."

# 5. Widget Tests
run_step "Widget tests" "cd $FRONTEND_DIR && flutter test test/widgets/ --reporter expanded && cd .."

# 6. Core Tests
run_step "Core tests" "cd $FRONTEND_DIR && flutter test test/core/ --reporter expanded && cd .."

# 7. Feature Tests
run_step "Feature tests" "cd $FRONTEND_DIR && flutter test test/features/ --reporter expanded && cd .."

# 8. Golden Tests
if [[ "${1:-}" != "--skip-golden" ]]; then
    run_step "Golden tests" "cd $FRONTEND_DIR && flutter test test/features/golden/ --update-goldens && cd .."
fi

# 9. Integration Tests
if [[ "${1:-}" != "--skip-integration" ]]; then
    run_step "Integration tests" "cd $FRONTEND_DIR && flutter test integration_test/ --reporter expanded && cd .."
fi

# 10. Edge Function Tests
run_step "Edge Function tests" "cd supabase/functions/shared/__tests__ && deno test --allow-all && cd ../../.."

# 11. Coverage Report
run_step "Coverage report" "cd $FRONTEND_DIR && if [ -f coverage/lcov.info ]; then echo 'Coverage report at coverage/lcov.info'; fi && cd .."

# Summary
echo ""
echo "========================================"
echo "  Test Summary"
echo "========================================"
echo ""
echo -e "Total: $TOTAL | ${GREEN}Passed: $PASSED${NC} | ${RED}Failed: $FAILED${NC}"
echo ""

if [ $FAILED -gt 0 ]; then
    echo -e "${RED}Some tests failed!${NC}"
    exit 1
else
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
fi
