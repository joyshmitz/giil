# RESEARCH FINDINGS: giil (Get Image from Internet Link) - TOON Integration Analysis

**Date**: 2026-01-25
**Bead**: bd-2uo
**Researcher**: Claude Code Agent (cc)

## 1. Project Overview

| Attribute | Value |
|-----------|-------|
| **Language** | Bash + Node.js (Hybrid) |
| **CLI Framework** | Pure Bash with embedded Node.js |
| **Browser Automation** | Playwright |
| **Tier** | 4 (Additional Tool) |
| **Directory** | `/dp/giil` |

### Purpose
giil (Get Image from Internet Link) downloads full-resolution images from cloud photo sharing services:
- iCloud Photos
- Dropbox
- Google Photos
- Google Drive

## 2. TOON Integration Status: COMPLETE

**TOON support is fully implemented in giil.**

### CLI Flags
```
--format FMT     Output format: json|toon
--json           Alias for --format json
```

### Implementation Details

| Location | Implementation |
|----------|----------------|
| Line 23 | Option documented in header |
| Line 415 | `TOON_BIN="${TOON_TRU_BIN:-${TOON_BIN:-tru}}"` |
| Lines 491-498 | `encode_json_to_toon()` function |
| Lines 500-514 | `encode_json_lines_to_toon()` for streaming |
| Line 2964 | TOON encoding pipeline |

### TOON Encoding Flow
```bash
# File: /dp/giil/giil
encode_json_to_toon() {
    local json_payload="$1"
    local -a toon_cmd=("$TOON_BIN" "--encode")
    if [[ "${TOON_STATS:-}" == "1" ]]; then
        toon_cmd+=("--stats")
    fi
    printf '%s' "$json_payload" | "${toon_cmd[@]}"
}
```

### Binary Discovery
The `tru` binary (toon_rust CLI) is discovered via:
1. `TOON_TRU_BIN` environment variable
2. `TOON_BIN` environment variable
3. Default: `tru` in PATH

### Environment Variables
| Variable | Purpose |
|----------|---------|
| `TOON_TRU_BIN` | Primary override for tru binary path |
| `TOON_BIN` | Secondary override for tru binary path |
| `TOON_STATS` | Set to `1` to enable TOON stats output |

## 3. Output Analysis

### JSON Output Structure
```json
{
  "ok": true,
  "path": "/path/to/image_YYYYMMDD_HHMMSS.jpg",
  "method": "download_button|network_cdn|element_shot|viewport_shot",
  "size": 1234567
}
```

### TOON Output (example)
```
ok: true
path: /path/to/image_YYYYMMDD_HHMMSS.jpg
method: download_button
size: 1234567
```

### Output Modes
| Mode | stdout | Description |
|------|--------|-------------|
| Default | `/path/to/file.jpg` | Just the saved file path |
| `--format json` | `{"ok":true,...}` | Full JSON metadata |
| `--format toon` | TOON-encoded metadata | Token-optimized |
| `--base64` | Raw base64 data | Image as base64 |

## 4. Token Savings Estimate

| Output | JSON Tokens (est.) | TOON Tokens (est.) | Savings |
|--------|-------------------|-------------------|---------|
| Single image | ~60 | ~35 | 42% |
| Album (10 images) | ~600 | ~350 | 42% |

**Note**: giil outputs are typically small (single-image metadata), so absolute savings are modest but percentage savings align with TOON goals.

## 5. Implementation Quality

### Strengths
- Full TOON support with `--format toon` flag
- Environment variable overrides for binary path
- `TOON_STATS` support for debugging
- Clean pipeline: JSON generation -> TOON encoding
- Streaming support via `encode_json_lines_to_toon()`
- Already documented in AGENTS.md (line 98)

### Architecture
```
giil (bash)
  └── Node.js extractor generates JSON
      └── encode_json_to_toon() pipes to `tru --encode`
          └── TOON output to stdout
```

## 6. Exit Code Scheme

| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | All capture strategies failed |
| 2 | Bad CLI options/arguments |
| 3 | Missing dependencies (Node.js/Playwright) |
| 10 | Network error (timeout, DNS) |
| 11 | Authentication required |
| 12 | Link expired/deleted (404) |
| 13 | Unsupported content type |
| 20 | Internal error (bug) |

## 7. Acceptance Criteria Status

- [x] `--format toon` flag implemented
- [x] TOON encoding via `tru` CLI
- [x] Environment variable support (TOON_BIN, TOON_TRU_BIN)
- [x] Documented in --help
- [x] Documented in AGENTS.md
- [x] Streaming support for album mode

## 8. Conclusion

**TOON integration for giil is COMPLETE.**

The implementation is well-designed:
- Uses the `tru` binary for encoding
- Supports environment variable overrides
- Has streaming support for multi-image albums
- Is already documented

**bd-3nf (Integrate TOON into giil) should be marked COMPLETE** - no additional implementation work is required.

## 9. Related Beads

- **bd-2uo**: This research bead - Complete
- **bd-3nf**: Integrate TOON into giil - Should be verified/closed
- **bd-1y9**: Research orchestration parent bead
