#!/usr/bin/env bash
# E2E Integration Test: iCloud Photo Download
#
# Tests giil's ability to download from real iCloud photo share links.
# Verifies file integrity via SHA256 checksum.
#
# Environment:
#   GIIL_REAL_TEST_URL  - Override default test URL (optional)
#   GIIL_HOME           - Override cache directory (optional)
#   GIIL_LOG_FORMAT     - json|text (auto-detects CI)
#
# Usage:
#   ./scripts/tests/e2e/icloud.test.sh
#
# Exit codes:
#   0 - All tests passed
#   1 - Test failure

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

# Source logging library
# shellcheck source=../lib/log.sh
source "$SCRIPT_DIR/../lib/log.sh"

# Test configuration
readonly DEFAULT_TEST_URL="https://share.icloud.com/photos/02cD9okNHvVd-uuDnPCH3ZEEA"
readonly EXPECTED_SHA_FILE="$PROJECT_ROOT/scripts/real_icloud_expected.sha256"
readonly PLATFORM="icloud"

# Allow URL override for testing different links
TEST_URL="${GIIL_REAL_TEST_URL:-$DEFAULT_TEST_URL}"

# Setup cache and output directories
CACHE_ROOT="${GIIL_HOME:-$PROJECT_ROOT/.ci-cache/giil}"
OUTPUT_DIR="$PROJECT_ROOT/.ci-output/e2e-$PLATFORM"
OUTPUT_JSON="$OUTPUT_DIR/output.json"

# Track test state
TESTS_PASSED=0
TESTS_FAILED=0
SUITE_START_MS=0

# Get current time in milliseconds
get_ms() {
    if command -v python3 &>/dev/null; then
        python3 -c 'import time; print(int(time.time() * 1000))'
    else
        echo $(($(date +%s) * 1000))
    fi
}

# Initialize test environment
setup() {
    SUITE_START_MS=$(get_ms)

    log_section "E2E Test: iCloud Platform"
    log_info "Platform: $PLATFORM"
    log_info "URL: $TEST_URL"
    log_info "Cache: $CACHE_ROOT"
    log_info "Output: $OUTPUT_DIR"

    # Create directories
    mkdir -p "$OUTPUT_DIR"
    mkdir -p "$CACHE_ROOT"

    # Set environment for giil
    export GIIL_HOME="$CACHE_ROOT"
    export PLAYWRIGHT_BROWSERS_PATH="$GIIL_HOME/ms-playwright"
    export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$PROJECT_ROOT/.ci-cache}"

    # Verify expected SHA file exists
    if [[ ! -f "$EXPECTED_SHA_FILE" ]]; then
        log_fail "Missing expected SHA file: $EXPECTED_SHA_FILE"
        exit 1
    fi
}

# Run giil and capture output
test_download() {
    local test_name="download_photo"
    local start_ms
    start_ms=$(get_ms)

    log_info "Running giil download..."

    if ! "$PROJECT_ROOT/giil" "$TEST_URL" --json --output "$OUTPUT_DIR" --timeout 120 > "$OUTPUT_JSON" 2>&1; then
        local duration_ms=$(($(get_ms) - start_ms))
        log_test_result "$test_name" "fail" "$duration_ms" "giil command failed"
        ((TESTS_FAILED++))
        return 1
    fi

    local duration_ms=$(($(get_ms) - start_ms))
    log_test_result "$test_name" "pass" "$duration_ms"
    ((TESTS_PASSED++))

    log_timing "$duration_ms" "Download completed"
}

# Parse JSON output and verify fields
test_json_output() {
    local test_name="json_schema"
    local start_ms
    start_ms=$(get_ms)

    # Parse JSON output
    if ! command -v python3 &>/dev/null; then
        log_warn "python3 not available, skipping JSON validation"
        return 0
    fi

    local parse_result
    if ! parse_result=$(python3 - << 'PY' "$OUTPUT_JSON"
import json, sys, os
try:
    with open(sys.argv[1], 'r', encoding='utf-8') as f:
        data = json.load(f)

    # Required fields
    required = ['path', 'method', 'datetime']
    missing = [f for f in required if f not in data]
    if missing:
        print(f"FAIL:missing_fields:{','.join(missing)}")
        sys.exit(1)

    # Verify file exists
    if not os.path.isfile(data.get('path', '')):
        print(f"FAIL:file_not_found:{data.get('path', 'none')}")
        sys.exit(1)

    # Output parsed values
    print(f"OK:{data['path']}:{data['method']}")
except json.JSONDecodeError as e:
    print(f"FAIL:json_parse:{e}")
    sys.exit(1)
PY
    ); then
        local duration_ms=$(($(get_ms) - start_ms))
        log_test_result "$test_name" "fail" "$duration_ms" "JSON parse failed: $parse_result"
        ((TESTS_FAILED++))
        return 1
    fi

    # Parse result
    local status result_path method
    IFS=':' read -r status result_path method <<< "$parse_result"

    if [[ "$status" != "OK" ]]; then
        local duration_ms=$(($(get_ms) - start_ms))
        log_test_result "$test_name" "fail" "$duration_ms" "$parse_result"
        ((TESTS_FAILED++))
        return 1
    fi

    local duration_ms=$(($(get_ms) - start_ms))
    log_test_result "$test_name" "pass" "$duration_ms"
    log_info "Method: $method"
    log_info "Path: $result_path"
    ((TESTS_PASSED++))

    # Export for later tests
    export E2E_OUTPUT_PATH="$result_path"
    export E2E_CAPTURE_METHOD="$method"
}

# Verify SHA256 checksum matches expected
test_checksum() {
    local test_name="sha256_checksum"
    local start_ms
    start_ms=$(get_ms)

    if [[ -z "${E2E_OUTPUT_PATH:-}" ]]; then
        log_test_result "$test_name" "skip" 0 "No output path from previous test"
        return 0
    fi

    # Read expected SHA
    local expected_sha
    expected_sha=$(tr -d '[:space:]' < "$EXPECTED_SHA_FILE")

    if [[ -z "$expected_sha" ]]; then
        local duration_ms=$(($(get_ms) - start_ms))
        log_test_result "$test_name" "fail" "$duration_ms" "Expected SHA file is empty"
        ((TESTS_FAILED++))
        return 1
    fi

    # Compute actual SHA
    local actual_sha
    actual_sha=$(sha256sum "$E2E_OUTPUT_PATH" | awk '{print $1}')

    if [[ "$actual_sha" != "$expected_sha" ]]; then
        local duration_ms=$(($(get_ms) - start_ms))
        log_test_result "$test_name" "fail" "$duration_ms" "SHA mismatch: expected=$expected_sha actual=$actual_sha"
        ((TESTS_FAILED++))
        return 1
    fi

    local duration_ms=$(($(get_ms) - start_ms))
    log_test_result "$test_name" "pass" "$duration_ms"
    log_info "SHA256: ${actual_sha:0:16}..."
    ((TESTS_PASSED++))
}

# Verify image dimensions using identify (if available)
test_image_dimensions() {
    local test_name="image_dimensions"
    local start_ms
    start_ms=$(get_ms)

    if [[ -z "${E2E_OUTPUT_PATH:-}" ]]; then
        log_test_result "$test_name" "skip" 0 "No output path"
        return 0
    fi

    if ! command -v identify &>/dev/null; then
        log_test_result "$test_name" "skip" 0 "ImageMagick not available"
        return 0
    fi

    local dimensions
    if ! dimensions=$(identify -format "%wx%h" "$E2E_OUTPUT_PATH" 2>/dev/null); then
        local duration_ms=$(($(get_ms) - start_ms))
        log_test_result "$test_name" "fail" "$duration_ms" "identify command failed"
        ((TESTS_FAILED++))
        return 1
    fi

    # Extract width and height
    local width height
    IFS='x' read -r width height <<< "$dimensions"

    # Verify reasonable dimensions (at least 100x100)
    if [[ "$width" -lt 100 || "$height" -lt 100 ]]; then
        local duration_ms=$(($(get_ms) - start_ms))
        log_test_result "$test_name" "fail" "$duration_ms" "Image too small: ${width}x${height}"
        ((TESTS_FAILED++))
        return 1
    fi

    local duration_ms=$(($(get_ms) - start_ms))
    log_test_result "$test_name" "pass" "$duration_ms"
    log_info "Dimensions: ${width}x${height}"
    ((TESTS_PASSED++))
}

# Report file size
report_file_size() {
    if [[ -n "${E2E_OUTPUT_PATH:-}" && -f "$E2E_OUTPUT_PATH" ]]; then
        local size_bytes
        size_bytes=$(stat -c%s "$E2E_OUTPUT_PATH" 2>/dev/null || stat -f%z "$E2E_OUTPUT_PATH" 2>/dev/null || echo "0")
        local size_kb=$((size_bytes / 1024))
        log_info "Size: ${size_kb} KB"
    fi
}

# Main test runner
main() {
    setup

    log_separator

    # Run tests in sequence
    test_download
    test_json_output
    test_checksum
    test_image_dimensions

    report_file_size

    log_separator

    # Calculate suite duration
    local suite_end_ms
    suite_end_ms=$(get_ms)
    local suite_duration_ms=$((suite_end_ms - SUITE_START_MS))

    # Report summary
    log_suite_summary "$PLATFORM" "$TESTS_PASSED" "$TESTS_FAILED" 0 "$suite_duration_ms"

    # Exit with failure if any tests failed
    if [[ "$TESTS_FAILED" -gt 0 ]]; then
        exit 1
    fi
}

main "$@"
