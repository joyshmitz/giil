# giil — Get iCloud Image Link

![Platform](https://img.shields.io/badge/platform-macOS%20%7C%20Linux-blue)
![Runtime](https://img.shields.io/badge/runtime-Node.js%2018+-purple)
![Status](https://img.shields.io/badge/status-stable-green)
![License](https://img.shields.io/badge/license-MIT-green)

Single-file bash CLI that downloads images from iCloud photo share links, compressing them to optimized JPEGs with datetime-stamped filenames. Auto-installs all dependencies on first run.

<div align="center">

```bash
curl -fsSL https://raw.githubusercontent.com/Dicklesworthstone/get_icloud_image_link/main/install.sh | bash
```

</div>

---

## ✨ Highlights

- **Zero-setup installation**: One-liner installer handles everything—Node.js, Playwright, Chromium, Sharp.
- **Works with iCloud share URLs**: Handles both `share.icloud.com` and `www.icloud.com/photos/#` formats.
- **Smart image capture**: Intercepts actual CDN image requests for full-resolution photos, falls back to element screenshots.
- **Optimized output**: Compresses to MozJPEG with configurable quality (default 85%), typically 40-50% smaller.
- **Datetime filenames**: Auto-generates collision-free filenames like `icloud_photo_2024-01-15_14-32-45-123.jpg`.
- **Base64 mode**: Output image as base64 for piping to other tools or embedding.

## 💡 Why giil exists

- **iCloud photo shares are JavaScript-heavy**: Standard `curl`/`wget` can't extract images from iCloud's single-page app architecture.
- **Copy/paste loses quality**: Screenshots and manual downloads often result in compressed or cropped images.
- **Automation-friendly**: Perfect for scripts, bots, or workflows that need to process shared iCloud images.
- **Privacy-respecting**: Runs locally, no external services, images never leave your machine.

## 🧭 Design principles

- **Self-contained**: Single bash script with embedded Node.js extractor; no global npm packages required.
- **Auto-healing dependencies**: Detects and installs missing components (Node.js, Playwright, Chromium).
- **Graceful degradation**: Multiple fallback strategies for image capture (CDN intercept → element screenshot → viewport screenshot).
- **Minimal footprint**: Runtime cached in `~/.giil`, Chromium shared with other Playwright tools.

## 🧠 How it works (technical details)

1. **URL normalization**: Converts `share.icloud.com/photos/XXX` to `www.icloud.com/photos/#XXX` format.
2. **Headless browser launch**: Spawns Chromium via Playwright with stealth user-agent and realistic viewport.
3. **Network interception**: Monitors all responses for images from `cvws.icloud-content.com` (iCloud's CDN).
4. **Size-based selection**: Keeps the largest image buffer (actual photo vs thumbnails).
5. **Fallback capture**: If CDN interception fails, screenshots the image element or viewport.
6. **Sharp processing**: Converts to optimized JPEG using MozJPEG encoder with configurable quality.
7. **Atomic output**: Writes to destination with datetime-stamped filename.

## 🔍 Supported URL formats

```
https://share.icloud.com/photos/02cD9okNHvVd-uuDnPCH3ZEEA
https://www.icloud.com/photos/#02cD9okNHvVd-uuDnPCH3ZEEA
```

Both formats are automatically normalized and handled identically.

## ⚡ Quickstart

### Installation

**macOS / Linux (recommended):**
```bash
curl -fsSL https://raw.githubusercontent.com/Dicklesworthstone/get_icloud_image_link/main/install.sh | bash
```

**Manual installation:**
```bash
# Download script
curl -fsSL https://raw.githubusercontent.com/Dicklesworthstone/get_icloud_image_link/main/giil -o ~/.local/bin/giil
chmod +x ~/.local/bin/giil

# Ensure ~/.local/bin is in PATH
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

### First run

```bash
giil "https://share.icloud.com/photos/02cD9okNHvVd-uuDnPCH3ZEEA"
```

First run downloads Playwright Chromium (~200MB, cached for future runs).

## 🚀 Usage

```bash
giil <icloud-photo-url> [options]
```

### Options

| Flag | Default | Description |
|------|---------|-------------|
| `--output DIR` | `.` (current dir) | Output directory for saved image |
| `--quality N` | `85` | JPEG quality (1-100) |
| `--base64` | off | Output base64 to stdout instead of saving file |
| `--version` | — | Print version and exit |
| `--help` | — | Show help message |

### Examples

**Basic usage** — save to current directory:
```bash
giil "https://share.icloud.com/photos/02cD9okNHvVd-uuDnPCH3ZEEA"
# Output: ./icloud_photo_2024-01-15_14-32-45-123.jpg
```

**Custom output directory:**
```bash
giil "https://share.icloud.com/photos/XXX" --output ~/Downloads
```

**Lower quality for smaller files:**
```bash
giil "https://share.icloud.com/photos/XXX" --quality 60
```

**Base64 output** (for piping/embedding):
```bash
giil "https://share.icloud.com/photos/XXX" --base64 > image.b64

# Or pipe directly
giil "https://share.icloud.com/photos/XXX" --base64 | base64 -d > image.jpg
```

**In a script:**
```bash
#!/bin/bash
IMAGE_PATH=$(giil "https://share.icloud.com/photos/XXX" --output /tmp 2>/dev/null)
echo "Downloaded: $IMAGE_PATH"
```

## 📋 Output

- **Filename format**: `icloud_photo_YYYY-MM-DD_HH-MM-SS-mmm.jpg`
- **Image format**: JPEG (MozJPEG optimized)
- **Typical compression**: 40-50% smaller than original
- **stdout**: File path (or base64 with `--base64`)
- **stderr**: Progress/status messages

## 🗂️ File locations

| Path | Purpose |
|------|---------|
| `~/.local/bin/giil` | Main script (default install location) |
| `~/.giil/` | Runtime directory |
| `~/.giil/node_modules/` | Playwright + Sharp packages |
| `~/.giil/extractor.mjs` | Generated Node.js extraction script |
| `~/.giil/.installed` | Installation marker file |
| `~/.cache/ms-playwright/` | Chromium browser cache (Linux) |
| `~/Library/Caches/ms-playwright/` | Chromium browser cache (macOS) |

## 🛡️ Security & privacy

- **Local execution**: All processing happens on your machine.
- **No telemetry**: No data sent anywhere except to iCloud to fetch the image.
- **No authentication stored**: Uses iCloud's public share mechanism (no login required).
- **Sandboxed browser**: Chromium runs with `--no-sandbox` for compatibility but in headless mode.

## 🏎️ Performance

- **First run**: ~30-60 seconds (downloads Chromium ~200MB).
- **Subsequent runs**: ~5-15 seconds depending on image size and network.
- **Memory usage**: ~200-400MB during extraction (Chromium overhead).
- **Disk usage**: ~500MB for Chromium cache, ~50MB for node_modules.

## 🧭 Troubleshooting

| Symptom | Cause | Fix |
|---------|-------|-----|
| "Node.js not found" | Node.js not installed | Script auto-installs, or manually: `brew install node` (macOS) / `apt install nodejs` (Ubuntu) |
| Timeout errors | Slow network or iCloud issues | Retry; check if URL works in browser |
| "Failed to capture image" | Page structure changed | Check for updates; open GitHub issue |
| Small/wrong image | Captured thumbnail instead | Should auto-select largest; report if persistent |
| "Debug screenshot saved" | Extraction failed | Check debug image to see page state |

## 🌐 Environment variables

| Variable | Description |
|----------|-------------|
| `PLAYWRIGHT_BROWSERS_PATH` | Custom Chromium cache location |
| `NODE_OPTIONS` | Pass options to Node.js (e.g., `--max-old-space-size=4096`) |

## 📦 Dependencies

**Automatically installed on first run:**

- **Node.js** (v18+) — JavaScript runtime
- **Playwright** — Browser automation
- **Chromium** — Headless browser (via Playwright)
- **Sharp** — High-performance image processing

## 🔧 Uninstallation

```bash
# Remove script
rm ~/.local/bin/giil

# Remove runtime and cache
rm -rf ~/.giil
rm -rf ~/.cache/ms-playwright  # Linux
rm -rf ~/Library/Caches/ms-playwright  # macOS
```

## 📄 License

MIT License — see [LICENSE](LICENSE) for details.

## 🤝 Contributing

Issues and PRs welcome! Please include:
- Your OS and Node.js version
- The iCloud URL (if shareable)
- Full error output
- Contents of any debug screenshot

---

<div align="center">

**[Report Bug](https://github.com/Dicklesworthstone/get_icloud_image_link/issues) · [Request Feature](https://github.com/Dicklesworthstone/get_icloud_image_link/issues)**

</div>
