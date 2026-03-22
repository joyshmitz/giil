# Changelog

All notable changes to **giil** (Get Image [from] Internet Link) are documented here.

Repository: <https://github.com/Dicklesworthstone/giil>

---

## [Unreleased] (after v3.1.0)

19 commits since v3.1.0. No new tag yet.

### Features

- Claude Code SKILL.md for automatic capability discovery ([c124309](https://github.com/Dicklesworthstone/giil/commit/c124309add5f1db1b2b6ce7731f82f10a902766b))
- Improved image extraction logic in giil script ([6aae707](https://github.com/Dicklesworthstone/giil/commit/6aae7076fc268f959bbde009a202b5172618fd2b))
- Enhanced script with improved functionality and documentation ([e9c247f](https://github.com/Dicklesworthstone/giil/commit/e9c247ff8f5521fb7803430eb1b59d036879d67e))
- E2E test script for TOON format support ([e7c03f0](https://github.com/Dicklesworthstone/giil/commit/e7c03f0f978587526e9a102b44496dbd83bbdd7f))

### CI / Infrastructure

- ACFS checksum update notification workflow ([e513d76](https://github.com/Dicklesworthstone/giil/commit/e513d76c36d8babac9530956f93e6d37073522ca))
- ACFS checksum dispatch ([ad51850](https://github.com/Dicklesworthstone/giil/commit/ad518507dd36853712b4620d9df1db313a92942c))
- Improve GitHub Actions workflows with best practices ([43def97](https://github.com/Dicklesworthstone/giil/commit/43def97aa2fe51e3cabfe9f736fd2b980f90675e))
- Handle exit code 77 (skip) in E2E tests ([0025925](https://github.com/Dicklesworthstone/giil/commit/00259251041086361b993022d3e75eae87845877))
- ACFS notification workflow for installer changes ([8d956b7](https://github.com/Dicklesworthstone/giil/commit/8d956b75edfbd56db3e352380bed8297fe8a0ff0))
- notify-acfs workflow for ACFS lesson registry sync ([e148569](https://github.com/Dicklesworthstone/giil/commit/e14856919f017401e8aa846a597fd7b7803fa389))

### Maintenance

- Update Node.js dependencies to latest stable versions ([404e63a](https://github.com/Dicklesworthstone/giil/commit/404e63a952eee11b79656114513a7a9cc29ab84e))
- Update license to MIT with OpenAI/Anthropic Rider ([4182374](https://github.com/Dicklesworthstone/giil/commit/41823743e7d4bee961cae458b698e1d152af3ec9), [830459c](https://github.com/Dicklesworthstone/giil/commit/830459cfff5d0fedae9aec2301b72961c3818f79))
- Add GitHub social preview image ([72b45be](https://github.com/Dicklesworthstone/giil/commit/72b45be6a966bc7191a9dc91ec266b285f0bbb44))
- Add .DS_Store to .gitignore ([21e17cc](https://github.com/Dicklesworthstone/giil/commit/21e17cc8b9d30511f16d0d97e3957098f9240b08))
- Add ephemeral beads file patterns to .gitignore ([7182811](https://github.com/Dicklesworthstone/giil/commit/7182811d0296f9a8a9cbb3e964a743612ec7e76e))

---

## [v3.1.0] -- 2026-01-04 (GitHub Release)

**UX Overhaul & Multi-Platform Branding** -- 7 commits over [v3.0.0](https://github.com/Dicklesworthstone/giil/releases/tag/v3.0.0).

Tag: [`v3.1.0`](https://github.com/Dicklesworthstone/giil/releases/tag/v3.1.0) points to commit [`32aad7d`](https://github.com/Dicklesworthstone/giil/commit/32aad7d8a7b63d57a0aee221978d2ec8bc51ce24).

### Branding

- Renamed from "Get iCloud Image Link" to **"Get Image [from] Internet Link"** to reflect multi-platform scope ([5562f5b](https://github.com/Dicklesworthstone/giil/commit/5562f5b461cb9b8cecaf851e1a9b42a03b957b22))
- Repository renamed: `get_icloud_image_link` -> `giil`
- Icon changed from platform-specific Apple emoji to platform-agnostic camera emoji
- Complete branding update across all documentation ([666f459](https://github.com/Dicklesworthstone/giil/commit/666f4595b3c5488a30f46c5d77b5587db4e7dac8), [140a363](https://github.com/Dicklesworthstone/giil/commit/140a363ce30c13a64513791aa46cfd369e55b5c8))

### UX Improvements

- Gum-styled help output with graceful ASCII fallback ([5562f5b](https://github.com/Dicklesworthstone/giil/commit/5562f5b461cb9b8cecaf851e1a9b42a03b957b22))
- New `--quiet` / `-q` flag for suppressing progress messages
- Gum spinners during npm and Chromium installation
- Consistent logging: `info`/`verbose` helpers respect quiet mode
- Platform-specific filename prefixes: `icloud_`, `dropbox_`, `gphotos_`, `gdrive_` ([d33908a](https://github.com/Dicklesworthstone/giil/commit/d33908a85b07b0c90838d118bbe9933e8a0e5d77))
- Datetime extraction added to Dropbox JSON output ([d33908a](https://github.com/Dicklesworthstone/giil/commit/d33908a85b07b0c90838d118bbe9933e8a0e5d77))

### Bug Fixes

- Install exifr dependency for unit tests ([a99ec13](https://github.com/Dicklesworthstone/giil/commit/a99ec137eacf97162d08515beaf088869f8d4932))
- Wrap test suites in parent `describe` for proper async `before()` handling ([11f1a6a](https://github.com/Dicklesworthstone/giil/commit/11f1a6a90f5dfdeefcf11afe98736f4bb71e0283))

### Supported Platforms (as of v3.1.0)

| Platform | URL Pattern | Capture Method |
|----------|-------------|----------------|
| iCloud Photos | `share.icloud.com/photos/...` | 4-tier capture (download button, CDN, element screenshot, viewport) |
| Dropbox | `dropbox.com/s/...` | Direct URL (no Playwright needed) |
| Google Photos | `photos.app.goo.gl/...` | CDN interception with `=s0` full-resolution modifier |
| Google Drive | `drive.google.com/file/d/...` | Multi-tier (download button, direct URL, thumbnail, screenshot) |

---

## [v3.0.0] -- 2026-01-04 (GitHub Release)

**Multi-Platform Image Downloader** -- 73 commits over the initial release + v2.1.0. Major release with breaking changes.

Tag: [`v3.0.0`](https://github.com/Dicklesworthstone/giil/releases/tag/v3.0.0) points to commit [`5487824`](https://github.com/Dicklesworthstone/giil/commit/54878248b7f0fb962183e045172f7f275653dd13).

### BREAKING CHANGES

- **Exit code reorganization**: `EXIT_NETWORK_ERROR` moved from 4 to 10; `EXIT_AUTH_REQUIRED` moved from 5 to 11. New codes: 12 (not found), 13 (unsupported type), 20 (internal error).
- **MozJPEG compression on by default**: downloaded images are now re-compressed through MozJPEG for optimal size/quality. Use `--preserve` to keep original bytes. ([7c4b7d2](https://github.com/Dicklesworthstone/giil/commit/7c4b7d2478e0b24c9e8cb47abb6ee7ef3a6f2b14))

### Multi-Platform Support (new)

- **Platform Adapter interface** for pluggable platform backends ([fc09061](https://github.com/Dicklesworthstone/giil/commit/fc0906175e86beae4d1e0d07c62d71db169370c6))
- **Dropbox** support: fast direct download, no Playwright needed ([b302b64](https://github.com/Dicklesworthstone/giil/commit/b302b64d88d0cfa5eb1a777faf02fe4207c77e6f))
- **Google Photos** support: CDN URL extraction, full-resolution download via `=s0` modifier, album mode with URL collection fallback ([6968673](https://github.com/Dicklesworthstone/giil/commit/6968673072a8ea52d995b21bae8eea608423cf07), [cec3823](https://github.com/Dicklesworthstone/giil/commit/cec3823913f89f594187f63a0e8ea5f75567cdfc))
- **Google Drive** support: file ID extraction, auth detection, response validation, multi-tier capture strategy ([13d2555](https://github.com/Dicklesworthstone/giil/commit/13d2555e50b41db5680a5be120821f84afcee568), [b15f373](https://github.com/Dicklesworthstone/giil/commit/b15f373568c484ecd3f56395611a9b1de59abd0e), [23a964a](https://github.com/Dicklesworthstone/giil/commit/23a964a57742ba0ceabb8c7b3b8bc5451c879d4b))

### New CLI Flags

- `--preserve` -- skip MozJPEG compression, keep original bytes ([bb21c8a](https://github.com/Dicklesworthstone/giil/commit/bb21c8a50bf2295a604548653e2e5ffe233bc7d8))
- `--optimize` / `--convert <format>` -- explicit compression and format conversion (jpeg, png, webp) ([c13b20d](https://github.com/Dicklesworthstone/giil/commit/c13b20dc10e80edf9c04616cf84149d614d88cec))
- `--quality <N>` -- set compression quality 1-100 (default 85)
- `--all` -- album mode: download entire shared albums with rate limiting ([1e25e15](https://github.com/Dicklesworthstone/giil/commit/1e25e157bc5455e83fb710df9350ce7da637dd1d))
- `--json` -- structured JSON output with `schema_version: "1"`
- `--base64` -- base64-encoded image output for piping/embedding

### Security

- Domain boundary enforcement in URL detection to prevent spoofing (e.g., `fakedropbox.com`) ([40a8569](https://github.com/Dicklesworthstone/giil/commit/40a8569fdb4e6af48b7ded6af868a06a9661d859), [d742476](https://github.com/Dicklesworthstone/giil/commit/d742476a2db807057deb49cc19702aec7da55d0a))
- Proper cleanup of temp files on all error paths ([a86ba86](https://github.com/Dicklesworthstone/giil/commit/a86ba86f2e1d226479988240d94b2501daa593b2))
- ShellCheck compliance and security hardening ([f2524eb](https://github.com/Dicklesworthstone/giil/commit/f2524ebae625fc9d44aa76e47b8c3efb08264312))

### Content Validation

- Magic byte verification to detect HTML error pages masquerading as images
- Content-Type header validation
- Automatic rejection of login redirects and error pages
- Google Drive response validation ([381c515](https://github.com/Dicklesworthstone/giil/commit/381c5150c45fdde9dc7e569110b8c0a5b99677cc))

### Bug Fixes

- Fix `OUTPUT_DIR` relative path handling (now converts to absolute) ([eeb443c](https://github.com/Dicklesworthstone/giil/commit/eeb443c9099d8a711dd8eb0c54c615ee6c5498bf))
- Fix HEIC conversion with system tools (sips on macOS, heif-convert on Linux) ([4fc8172](https://github.com/Dicklesworthstone/giil/commit/4fc817287306802ec20307dd78253b3a235f8096))
- Fix version comparison for semver ([4fc8172](https://github.com/Dicklesworthstone/giil/commit/4fc817287306802ec20307dd78253b3a235f8096))
- Fix temp file cleanup on error exits in installer ([a86ba86](https://github.com/Dicklesworthstone/giil/commit/a86ba86f2e1d226479988240d94b2501daa593b2))
- Fix stream separation: stdout for data, stderr for logs ([fb9be61](https://github.com/Dicklesworthstone/giil/commit/fb9be61ff22f83a3ab446d02eb5de0383c049d6d), [8ab4cf3](https://github.com/Dicklesworthstone/giil/commit/8ab4cf3536d049d36403d9c792493e724bdb4ff9))
- Fix `set -e` arithmetic bug (`((VAR++))` returns exit 1 when VAR is 0) ([528161c](https://github.com/Dicklesworthstone/giil/commit/528161c5ecb3ffd018141e3a70ca1e4499d83121))
- Normalize `jpeg` to `jpg` for consistent file extensions ([ed48ccf](https://github.com/Dicklesworthstone/giil/commit/ed48ccf7873dbb51bc9946f99d4de74f76f6eb09))
- Fix `path.join()` usage in traceMode (use imported `join()`) ([37a8934](https://github.com/Dicklesworthstone/giil/commit/37a8934e0f7861abf580043c2cc54efb32f4aff9))
- Fix `error.code` property in error handler ([d9407dc](https://github.com/Dicklesworthstone/giil/commit/d9407dc449e9f986472d6f4abc03814c1f8eb64f))
- Fix `real_link_test.sh` variable capture and sync VERSION ([1188f70](https://github.com/Dicklesworthstone/giil/commit/1188f70d0a406d3dd41262d75e3ebf6e8ae8366a))
- Prevent filename collisions in output-modes E2E tests ([e64bf8b](https://github.com/Dicklesworthstone/giil/commit/e64bf8b2ffd9cd117bff1422fa01e5a3ff61c5a2))
- Implement missing `--preserve` flag for skipping MozJPEG ([bb21c8a](https://github.com/Dicklesworthstone/giil/commit/bb21c8a50bf2295a604548653e2e5ffe233bc7d8))
- Add domain boundaries to platform detection regex ([40a8569](https://github.com/Dicklesworthstone/giil/commit/40a8569fdb4e6af48b7ded6af868a06a9661d859))

### Test Infrastructure (new)

- Unit test framework for pure functions ([5346459](https://github.com/Dicklesworthstone/giil/commit/5346459da4f9e7f9f3ab7cfc4e252f44e4e93ef6))
- Unit tests: JSON formatting, Google Photos URL extraction, Google Drive URLs, Google Drive response validation, date formatting, EXIF datetime, bash detect_platform/normalize_dropbox_url, version_gt/detect_os
- E2E tests: output modes (`--json`, `--base64`, `--convert`, `--quality`), album mode (`--all`), error scenarios (timeout, auth, not found)
- E2E test runner script and shared `common.sh` library ([c539dbd](https://github.com/Dicklesworthstone/giil/commit/c539dbd0a754ad16013ca9a6d8c8f5fe2b8a7438), [447ba7e](https://github.com/Dicklesworthstone/giil/commit/447ba7e8914e83314b2e13191ae5f0e540f08161))
- Test fixtures: sample images and magic bytes ([1bf95e0](https://github.com/Dicklesworthstone/giil/commit/1bf95e0ab51b637866271a2b9a36bbdd7a065869))
- Test infrastructure with logging and CI pipeline ([b52b82c](https://github.com/Dicklesworthstone/giil/commit/b52b82c86300055502eb56436bd92426a5067103))
- iCloud domain boundary enforcement tests ([5487824](https://github.com/Dicklesworthstone/giil/commit/54878248b7f0fb962183e045172f7f275653dd13))

### CI / Infrastructure

- GitHub Actions for testing and automated releases ([b0aeb4f](https://github.com/Dicklesworthstone/giil/commit/b0aeb4f3be47a40b304533f1aafef98d7cff0072))
- Real iCloud link integration test with daily schedule ([2543c22](https://github.com/Dicklesworthstone/giil/commit/2543c22f559ff1ac151b8b9fbb8c6e20c7c1abab))
- Opt-in update checking and checksum verification (`GIIL_CHECK_UPDATES=1`) ([8bbcc5d](https://github.com/Dicklesworthstone/giil/commit/8bbcc5d4bc63167dccc5cf0d85b63c66955d37a1))

---

## v2.1.0 -- 2026-01-02 (no GitHub release)

**Hybrid capture strategy with album mode** -- single commit from the initial release. No tag; identified by commit message.

Commit: [`ac97c96`](https://github.com/Dicklesworthstone/giil/commit/ac97c9688c0f4d3368b8542949bac90b221f21ad)

### Features

- Hybrid capture strategy: download button -> CDN interception -> element screenshot -> viewport screenshot
- Album mode for downloading entire shared iCloud albums
- Enhanced reliability with multi-tier fallback
- Complete README rewrite with primary use case (remote AI-assisted debugging) and technical deep-dive ([5145170](https://github.com/Dicklesworthstone/giil/commit/514517006bfdfe565083464d95d6710c7fd62a43))

### Installer

- Proper fish shell PATH support ([0bbb1ad](https://github.com/Dicklesworthstone/giil/commit/0bbb1adfb24e06c07cdefac8ec71a95df7bd6212))

---

## v1.0.0 -- 2026-01-02 (initial release, no tag)

**Get iCloud Image Link** -- the first commit.

Commit: [`559c8af`](https://github.com/Dicklesworthstone/giil/commit/559c8aff68c3eebb912c8803a574f6e68a16899a)

### Capabilities

- Single-file bash script with embedded Node.js extractor
- Download full-resolution images from iCloud share links
- Headless Chromium via Playwright for JavaScript-heavy SPA rendering
- EXIF-aware datetime stamping for output filenames
- Auto-installation of all dependencies (Node.js, Playwright, Chromium)
- macOS and Linux support
- curl-pipe-bash installer

---

<!-- Link references -->
[Unreleased]: https://github.com/Dicklesworthstone/giil/compare/v3.1.0...HEAD
[v3.1.0]: https://github.com/Dicklesworthstone/giil/compare/v3.0.0...v3.1.0
[v3.0.0]: https://github.com/Dicklesworthstone/giil/compare/559c8af...v3.0.0
