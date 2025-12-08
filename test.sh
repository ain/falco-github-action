#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Docker image name
IMAGE_NAME="falco-github-action-test"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Build Docker image if it doesn't exist
if ! docker image inspect "$IMAGE_NAME" &>/dev/null; then
    echo -e "${YELLOW}Building Docker image...${NC}"
    docker build -t "$IMAGE_NAME" "$SCRIPT_DIR"
fi

# Test counter
PASSED=0
FAILED=0
TOTAL=0

# Create tmp directory if it doesn't exist
TMP_DIR="$SCRIPT_DIR/tmp"
mkdir -p "$TMP_DIR"

# Function to run a test
run_test() {
    local file=$1
    local options=$2
    local should_pass=$3
    local description=$4
    
    TOTAL=$((TOTAL + 1))
    
    echo -n "Testing $description... "
    
    # Run falco lint in Docker container
    # Arguments: $1=subcommand, $2=options, $3=target (as per entrypoint.sh and action.yml)
    if docker run --rm \
        -v "$SCRIPT_DIR:/workspace" \
        -w /workspace \
        "$IMAGE_NAME" \
        lint "$options" "$file" > "$TMP_DIR/falco_test_output.txt" 2>&1; then
        exit_code=0
    else
        exit_code=$?
    fi
    
    # Check if test result matches expectation
    if [ "$should_pass" = "true" ]; then
        if [ $exit_code -eq 0 ]; then
            echo -e "${GREEN}PASSED${NC}"
            PASSED=$((PASSED + 1))
            return 0
        else
            echo -e "${RED}FAILED${NC} (expected success, got exit code $exit_code)"
            echo "Output:"
            cat "$TMP_DIR/falco_test_output.txt" | sed 's/^/  /'
            FAILED=$((FAILED + 1))
            return 1
        fi
    else
        if [ $exit_code -ne 0 ]; then
            echo -e "${GREEN}PASSED${NC}"
            PASSED=$((PASSED + 1))
            return 0
        else
            echo -e "${RED}FAILED${NC} (expected failure, got exit code 0)"
            echo "Output:"
            cat "$TMP_DIR/falco_test_output.txt" | sed 's/^/  /'
            FAILED=$((FAILED + 1))
            return 1
        fi
    fi
}

echo "Running Falco VCL/ACL tests..."
echo ""

# Test valid VCL file
run_test "test/vcl/valid.vcl" "" "true" "valid.vcl"

# Test valid VCL file with include
run_test "test/vcl/valid_with_include.vcl" "-I test/vcl/includes" "true" "valid_with_include.vcl (with -I option)"

# Test invalid VCL file
run_test "test/vcl/invalid_syntax.vcl" "" "false" "invalid_syntax.vcl"

# Test valid ACL file
run_test "test/acl/valid.acl" "" "true" "valid.acl"

# Test invalid ACL files
run_test "test/acl/invalid_syntax.acl" "" "false" "invalid_syntax.acl"
run_test "test/acl/invalid_ip.acl" "" "false" "invalid_ip.acl"
run_test "test/acl/invalid_range.acl" "" "false" "invalid_range.acl"

echo ""
echo "=========================================="
echo "Test Results: $PASSED passed, $FAILED failed, $TOTAL total"

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}Some tests failed!${NC}"
    exit 1
fi

