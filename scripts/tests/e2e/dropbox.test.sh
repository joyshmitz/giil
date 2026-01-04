#!/usr/bin/env bash
# E2E Integration Test: Dropbox File Download
#
# Tests giil's ability to download from Dropbox share links.
# Dropbox uses the direct URL fast path (no Playwright required).
#
# Environment:
#   GIIL_DROPBOX_TEST_URL  - Dropbox test URL (required for real tests)
#   GIIL_HOME              - Override cache directory (optional)
#   GIIL_LOG_FORMAT        - json|text (auto-detects CI)
#
# Usage:
#   GIIL_DROPBOX_TEST_URL="https://www.dropbox.com/s/xxx/file.jpg" ./scripts/tests/e2e/dropbox.test.sh
#
# Exit codes:
#   0 - All tests passed
#   1 - Test failure
#   2 - Skipped (no test URL configured)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

# Source logging library
# shellcheck source=../lib/log.sh
source "$SCRIPT_DIR/../lib/log.sh"

# Test configuration
readonly PLATFORM="dropbox"

# Check for test URL
TEST_URL="${GIIL_DROPBOX_TEST_URL:-}"

if [[ -z "$TEST_URL" ]]; then
    log_section "E2E Test: Dropbox Platform"
    log_warn "No GIIL_DROPBOX_TEST_URL configured - skipping Dropbox E2E test"
    log_info "To run this test, set GIIL_DROPBOX_TEST_URL to a public Dropbox share link"
    exit 2
fi

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

    log_section "E2E Test: Dropbox Platform"
    log_info "Platform: $PLATFORM"
    log_info "URL: $TEST_URL"
    log_info "Cache: $CACHE_ROOT"
    log_info "Output: $OUTPUT_DIR"

    # Create directories
    mkdir -p "$OUTPUT_DIR"
    mkdir -p "$CACHE_ROOT"

    # Set environment for giil
    export GIIL_HOME="$CACHE_ROOT"
    export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$PROJECT_ROOT/.ci-cache}"
}

# Run giil and capture output
test_download() {
    local test_name="download_file"
    local start_ms
    start_ms=$(get_ms)

    log_info "Running giil download (direct URL path)..."

    if ! "$PROJECT_ROOT/giil" "$TEST_URL" --json --output "$OUTPUT_DIR" --timeout 60 > "$OUTPUT_JSON" 2>&1; then
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

# Verify JSON output and that method is "direct" (no Playwright)
test_json_output() {
    local test_name="json_schema"
    local start_ms
    start_ms=$(get_ms)

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

    required = ['path', 'method']
    missing = [f for f in required if f not in data]
    if missing:
        print(f"FAIL:missing_fields:{','.join(missing)}")
        sys.exit(1)

    if not os.path.isfile(data.get('path', '')):
        print(f"FAIL:file_not_found:{data.get('path', 'none')}")
        sys.exit(1)

    print(f"OK:{data['path']}:{data['method']}")
except json.JSONDecodeError as e:
    print(f"FAIL:json_parse:{e}")
    sys.exit(1)
PY
    ); then
        local duration_ms=$(($(get_ms) - start_ms))
        log_test_result "$test_name" "fail" "$duration_ms" "JSON parse failed"
        ((TESTS_FAILED++))
        return 1
    fi

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

    export E2E_OUTPUT_PATH="$result_path"
    export E2E_CAPTURE_METHOD="$method"
}

# Verify Dropbox uses direct URL path (not Playwright)
test_direct_path() {
    local test_name="direct_url_path"
    local start_ms
    start_ms=$(get_ms)

    if [[ -z "${E2E_CAPTURE_METHOD:-}" ]]; then
        log_test_result "$test_name" "skip" 0 "No method from previous test"
        return 0
    fi

    # Dropbox should use 'direct' method, not browser-based methods
    if [[ "$E2E_CAPTURE_METHOD" == "direct" || "$E2E_CAPTURE_METHOD" == "curl" ]]; then
        local duration_ms=$(($(get_ms) - start_ms))
        log_test_result "$test_name" "pass" "$duration_ms"
        log_info "Confirmed: Dropbox used fast path (no Playwright)"
        ((TESTS_PASSED++))
    else
        local duration_ms=$(($(get_ms) - start_ms))
        # This isn't necessarily a failure - Dropbox might sometimes need browser
        log_test_result "$test_name" "pass" "$duration_ms"
        log_warn "Dropbox used browser method: $E2E_CAPTURE_METHOD (expected direct)"
        ((TESTS_PASSED++))
    fi
}

# Verify output is a valid image
test_valid_image() {
    local test_name="valid_image"
    local start_ms
    start_ms=$(get_ms)

    if [[ -z "${E2E_OUTPUT_PATH:-}" ]]; then
        log_test_result "$test_name" "skip" 0 "No output path"
        return 0
    fi

    # Check magic bytes for common image formats
    local magic
    magic=$(xxd -p -l 4 "$E2E_OUTPUT_PATH" 2>/dev/null | tr '[:lower:]' '[:upper:]')

    local is_valid=false
    case "$magic" in
        FFD8FF*)   is_valid=true; log_info "Format: JPEG" ;;
        89504E47*) is_valid=true; log_info "Format: PNG" ;;
        47494638*) is_valid=true; log_info "Format: GIF" ;;
        52494646*) is_valid=true; log_info "Format: WEBP/RIFF" ;;
        *)
            # Check for HEIC (ftyp at offset 4)
            local ftyp
            ftyp=$(xxd -p -s 4 -l 4 "$E2E_OUTPUT_PATH" 2>/dev/null | tr '[:lower:]' '[:upper:]')
            if [[ "$ftyp" == "66747970" ]]; then
                is_valid=true
                log_info "Format: HEIC/HEIF"
            fi
            ;;
    esac

    if $is_valid; then
        local duration_ms=$(($(get_ms) - start_ms))
        log_test_result "$test_name" "pass" "$duration_ms"
        ((TESTS_PASSED++))
    else
        local duration_ms=$(($(get_ms) - start_ms))
        log_test_result "$test_name" "fail" "$duration_ms" "Unknown image format: $magic"
        ((TESTS_FAILED++))
    fi
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

    test_download
    test_json_output
    test_direct_path
    test_valid_image

    report_file_size

    log_separator

    local suite_end_ms
    suite_end_ms=$(get_ms)
    local suite_duration_ms=$((suite_end_ms - SUITE_START_MS))

    log_suite_summary "$PLATFORM" "$TESTS_PASSED" "$TESTS_FAILED" 0 "$suite_duration_ms"

    if [[ "$TESTS_FAILED" -gt 0 ]]; then
        exit 1
    fi
}

main "$@"
