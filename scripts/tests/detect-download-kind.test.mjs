/**
 * Unit tests for detectDownloadKind()
 *
 * detectDownloadKind classifies a Google Photos native-download buffer (from the
 * Shift+D shortcut) as an image, video, or zip archive so that videos/zips are
 * saved as originals instead of being forced through the image pipeline. This is
 * the core of the fix for issue #2 (videos saved as poster-frame screenshots,
 * albums saved as individual previews instead of a .zip).
 */

import { describe, it, before, after } from 'node:test';
import assert from 'node:assert';
import { writeFileSync, unlinkSync, existsSync } from 'fs';
import { dirname, join } from 'path';
import { fileURLToPath } from 'url';
import { execSync } from 'child_process';

const __dirname = dirname(fileURLToPath(import.meta.url));

describe('detectDownloadKind Tests', () => {
    let detectDownloadKind;
    let tempModule;

    before(async () => {
        const extractorPath = join(__dirname, 'extract-functions.mjs');
        const projectRoot = join(__dirname, '../..');
        tempModule = join(projectRoot, `giil-test-detect-download-kind-${process.pid}.mjs`);

        const extracted = execSync(`node "${extractorPath}"`, { encoding: 'utf8' });
        writeFileSync(tempModule, extracted);

        const mod = await import(tempModule);
        detectDownloadKind = mod.detectDownloadKind;
    });

    after(() => {
        if (tempModule && existsSync(tempModule)) {
            try { unlinkSync(tempModule); } catch {}
        }
    });

    // Helper: build a 12-byte buffer from a leading byte sequence (zero-padded).
    const buf = (bytes) => {
        const b = Buffer.alloc(Math.max(12, bytes.length));
        for (let i = 0; i < bytes.length; i++) b[i] = bytes[i];
        return b;
    };

    describe('magic-byte classification', () => {
        it('detects ZIP archives (PK\\x03\\x04) as zip', () => {
            const r = detectDownloadKind(buf([0x50, 0x4b, 0x03, 0x04]), 'album.zip');
            assert.strictEqual(r.kind, 'zip');
            assert.strictEqual(r.ext, 'zip');
        });

        it('detects empty-archive ZIP marker (PK\\x05\\x06) as zip', () => {
            const r = detectDownloadKind(buf([0x50, 0x4b, 0x05, 0x06]), 'album.zip');
            assert.strictEqual(r.kind, 'zip');
        });

        it('detects JPEG as image/jpg', () => {
            const r = detectDownloadKind(buf([0xff, 0xd8, 0xff, 0xe0]), 'photo.jpg');
            assert.strictEqual(r.kind, 'image');
            assert.strictEqual(r.ext, 'jpg');
        });

        it('detects PNG as image/png', () => {
            const r = detectDownloadKind(buf([0x89, 0x50, 0x4e, 0x47]), 'x.png');
            assert.strictEqual(r.kind, 'image');
            assert.strictEqual(r.ext, 'png');
        });

        it('detects GIF as image/gif', () => {
            const r = detectDownloadKind(buf([0x47, 0x49, 0x46, 0x38]), 'x.gif');
            assert.strictEqual(r.kind, 'image');
            assert.strictEqual(r.ext, 'gif');
        });

        it('detects WebP (RIFF....WEBP) as image/webp', () => {
            const r = detectDownloadKind(
                buf([0x52, 0x49, 0x46, 0x46, 0, 0, 0, 0, 0x57, 0x45, 0x42, 0x50]),
                'x.webp'
            );
            assert.strictEqual(r.kind, 'image');
            assert.strictEqual(r.ext, 'webp');
        });

        it('detects MP4 (ftyp isom) as video/mp4', () => {
            const r = detectDownloadKind(
                buf([0, 0, 0, 0x18, 0x66, 0x74, 0x79, 0x70, 0x69, 0x73, 0x6f, 0x6d]),
                'clip.mp4'
            );
            assert.strictEqual(r.kind, 'video');
            assert.strictEqual(r.ext, 'mp4');
        });

        it('detects QuickTime (ftyp qt) as video/mov', () => {
            const r = detectDownloadKind(
                buf([0, 0, 0, 0x18, 0x66, 0x74, 0x79, 0x70, 0x71, 0x74, 0x20, 0x20]),
                'm.mov'
            );
            assert.strictEqual(r.kind, 'video');
            assert.strictEqual(r.ext, 'mov');
        });

        it('detects HEIC (ftyp heic) as image/heic, not video', () => {
            const r = detectDownloadKind(
                buf([0, 0, 0, 0x18, 0x66, 0x74, 0x79, 0x70, 0x68, 0x65, 0x69, 0x63]),
                'x.heic'
            );
            assert.strictEqual(r.kind, 'image');
            assert.strictEqual(r.ext, 'heic');
        });

        it('detects 10-bit HEIC (ftyp heix) as image, not video/mp4', () => {
            // heix is the standard brand for 10-bit HEIC; must NOT fall through to mp4.
            const r = detectDownloadKind(
                buf([0, 0, 0, 0x18, 0x66, 0x74, 0x79, 0x70, 0x68, 0x65, 0x69, 0x78]),
                'x.heic'
            );
            assert.strictEqual(r.kind, 'image');
            assert.strictEqual(r.ext, 'heic');
        });

        it('detects HEIC image sequence (ftyp msf1) as image, not video', () => {
            // msf1 is HEIF image sequence container (e.g. Apple Live Photos still).
            const r = detectDownloadKind(
                buf([0, 0, 0, 0x18, 0x66, 0x74, 0x79, 0x70, 0x6d, 0x73, 0x66, 0x31]),
                'live.heic'
            );
            assert.strictEqual(r.kind, 'image');
            assert.strictEqual(r.ext, 'heic');
        });

        it('detects HEIC image sequence (ftyp hevc) as image, not video', () => {
            const r = detectDownloadKind(
                buf([0, 0, 0, 0x18, 0x66, 0x74, 0x79, 0x70, 0x68, 0x65, 0x76, 0x63]),
                'seq.heic'
            );
            assert.strictEqual(r.kind, 'image');
            assert.strictEqual(r.ext, 'heic');
        });

        it('detects AVIF (ftyp avif) as image/avif', () => {
            const r = detectDownloadKind(
                buf([0, 0, 0, 0x18, 0x66, 0x74, 0x79, 0x70, 0x61, 0x76, 0x69, 0x66]),
                'x.avif'
            );
            assert.strictEqual(r.kind, 'image');
            assert.strictEqual(r.ext, 'avif');
        });

        it('detects WebM / Matroska as video', () => {
            const r = detectDownloadKind(buf([0x1a, 0x45, 0xdf, 0xa3]), 'v.webm');
            assert.strictEqual(r.kind, 'video');
            assert.strictEqual(r.ext, 'webm');
        });
    });

    describe('extension fallback for inconclusive bytes', () => {
        it('falls back to video extension when bytes are unknown', () => {
            const r = detectDownloadKind(buf([1, 2, 3, 4, 5, 6, 7, 8]), 'movie.mp4');
            assert.strictEqual(r.kind, 'video');
            assert.strictEqual(r.ext, 'mp4');
        });

        it('falls back to image extension and normalizes jpeg -> jpg', () => {
            const r = detectDownloadKind(buf([1, 2, 3, 4, 5, 6, 7, 8]), 'pic.jpeg');
            assert.strictEqual(r.kind, 'image');
            assert.strictEqual(r.ext, 'jpg');
        });

        it('returns unknown for tiny / empty buffers', () => {
            const r = detectDownloadKind(Buffer.alloc(4), '');
            assert.strictEqual(r.kind, 'unknown');
        });

        it('returns unknown/bin for unrecognized bytes and no useful extension', () => {
            const r = detectDownloadKind(buf([1, 2, 3, 4, 5, 6, 7, 8]), 'mystery.dat');
            assert.strictEqual(r.kind, 'unknown');
            assert.strictEqual(r.ext, 'dat');
        });
    });
});
