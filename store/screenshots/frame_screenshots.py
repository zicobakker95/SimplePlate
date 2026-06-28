#!/usr/bin/env python3
"""
Turn raw app captures (store/screenshots/raw/*.png) into store-ready,
per-locale, per-device-size marketing screenshots with localized caption
banners and a branded background.

Usage:
    python3 store/screenshots/frame_screenshots.py
    python3 store/screenshots/frame_screenshots.py --locales en-US,nl-NL --devices ios_6_7

Output:
    store/screenshots/framed/<device>/<locale>/<NN>_<name>.png

Requires Pillow (already used elsewhere in this repo's tooling). For Japanese
captions you also need a CJK-capable font (Noto Sans CJK / Hiragino); the script
auto-detects common paths and warns if none is found.
"""
import argparse
import json
import os
import sys
from pathlib import Path

try:
    from PIL import Image, ImageDraw, ImageFont
except ImportError:
    sys.exit("Pillow is required:  pip install Pillow")

ROOT = Path(__file__).resolve().parent
RAW_DIR = ROOT / "raw"
OUT_DIR = ROOT / "framed"
CAPTIONS = json.loads((ROOT / "captions.json").read_text(encoding="utf-8"))

BRAND_DARK = (10, 35, 24)      # #0A2318
BRAND_GREEN = (29, 185, 84)    # #1DB954
WHITE = (255, 255, 255)

# Exact store-required pixel sizes (portrait W x H).
DEVICES = {
    "ios_6_7":     (1290, 2796),   # iPhone 15/16 Pro Max — REQUIRED on App Store
    "ios_6_5":     (1242, 2688),   # iPhone 11 Pro Max / XS Max
    "ios_5_5":     (1242, 2208),   # iPhone 8 Plus
    "ipad_12_9":   (2048, 2732),   # iPad Pro 12.9" — only if app supports iPad
    "android_phone": (1080, 2340), # Google Play phone
}
# Which device each store cares about (for your own reference / filtering).
DEFAULT_DEVICES = ["ios_6_7", "ios_6_5", "ios_5_5", "android_phone"]

# Raw screenshot order -> caption index.
RAW_ORDER = ["01_today", "02_history", "03_goals", "04_add_food"]

# Font search paths (first hit wins). Latin + CJK.
LATIN_FONTS = [
    "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf",
    "/root/.pub-cache/hosted/pub.dev/provider-6.1.5+1/extension/devtools/build/assets/packages/devtools_app_shared/fonts/Roboto/Roboto-Black.ttf",
    "/root/.pub-cache/hosted/pub.dev/provider-6.1.4/extension/devtools/build/assets/packages/devtools_app_shared/fonts/Roboto/Roboto-Black.ttf",
    "/System/Library/Fonts/Helvetica.ttc",
    "C:/Windows/Fonts/arialbd.ttf",
]
CJK_FONTS = [
    "/usr/share/fonts/opentype/noto/NotoSansCJK-Bold.ttc",
    "/usr/share/fonts/truetype/noto/NotoSansCJKjp-Bold.otf",
    "/System/Library/Fonts/ヒラギノ角ゴシック W6.ttc",
    "/System/Library/Fonts/Hiragino Sans GB.ttc",
    "C:/Windows/Fonts/YuGothB.ttc",
    "C:/Windows/Fonts/msgothic.ttc",
]


def find_font(paths):
    for p in paths:
        if os.path.exists(p):
            return p
    return None


def load_font(locale, size):
    cjk = locale.startswith("ja") or locale.startswith("zh") or locale.startswith("ko")
    path = find_font(CJK_FONTS if cjk else LATIN_FONTS)
    if path is None and cjk:
        path = find_font(LATIN_FONTS)
        print(f"  ! No CJK font found for {locale}; captions may not render. "
              f"Install Noto Sans CJK.")
    if path is None:
        return ImageFont.load_default()
    return ImageFont.truetype(path, size)


def wrap(draw, text, font, max_w):
    words, lines, cur = text.split(" "), [], ""
    # For CJK (no spaces) fall back to char wrapping.
    if len(words) == 1 and draw.textlength(text, font=font) > max_w:
        for ch in text:
            t = cur + ch
            if draw.textlength(t, font=font) <= max_w:
                cur = t
            else:
                lines.append(cur); cur = ch
        if cur:
            lines.append(cur)
        return lines
    for w in words:
        t = (cur + " " + w).strip()
        if draw.textlength(t, font=font) <= max_w:
            cur = t
        else:
            lines.append(cur); cur = w
    if cur:
        lines.append(cur)
    return lines


def rounded(img, radius):
    mask = Image.new("L", img.size, 0)
    d = ImageDraw.Draw(mask)
    d.rounded_rectangle([0, 0, img.size[0], img.size[1]], radius=radius, fill=255)
    out = img.convert("RGBA")
    out.putalpha(mask)
    return out


def frame_one(raw_img, size, caption, locale):
    W, H = size
    canvas = Image.new("RGB", (W, H), BRAND_DARK)
    d = ImageDraw.Draw(canvas)
    for y in range(H):  # subtle vertical gradient
        t = y / H
        d.line([(0, y), (W, y)],
               fill=(int(10 + t * 8), int(35 + t * 30), int(24 + t * 16)))

    # Caption
    title_font = load_font(locale, int(W * 0.062))
    margin = int(W * 0.08)
    lines = wrap(d, caption, title_font, W - 2 * margin)
    y = int(H * 0.045)
    for ln in lines:
        tw = d.textlength(ln, font=title_font)
        d.text(((W - tw) / 2, y), ln, font=title_font, fill=WHITE)
        y += int(title_font.size * 1.25)

    # Device screenshot
    top = y + int(H * 0.02)
    avail_h = int(H * 0.93) - top
    avail_w = W - 2 * margin
    sw, sh = raw_img.size
    scale = min(avail_w / sw, avail_h / sh)
    nw, nh = int(sw * scale), int(sh * scale)
    shot = raw_img.resize((nw, nh), Image.LANCZOS)
    shot = rounded(shot, int(nw * 0.06))
    # soft shadow
    shadow = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
    sx, sy = (W - nw) // 2, top
    shadow.paste((0, 0, 0, 90), (sx + 8, sy + 14, sx + nw + 8, sy + nh + 14))
    canvas = Image.alpha_composite(canvas.convert("RGBA"), shadow).convert("RGB")
    canvas.paste(shot, (sx, sy), shot)
    return canvas


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--locales", default=",".join(CAPTIONS.keys()))
    ap.add_argument("--devices", default=",".join(DEFAULT_DEVICES))
    args = ap.parse_args()

    locales = [l for l in args.locales.split(",") if l in CAPTIONS]
    devices = [d for d in args.devices.split(",") if d in DEVICES]

    raws = sorted(RAW_DIR.glob("*.png")) if RAW_DIR.exists() else []
    if not raws:
        sys.exit(f"No raw screenshots in {RAW_DIR}. Capture them first with:\n"
                 f"  flutter drive --driver=test_driver/screenshot_driver.dart "
                 f"--target=integration_test/screenshot_test.dart -d <device>")

    print(f"Raw screenshots: {[r.name for r in raws]}")
    print(f"Locales: {locales}\nDevices: {devices}\n")

    for device in devices:
        size = DEVICES[device]
        for locale in locales:
            caps = CAPTIONS[locale]
            outdir = OUT_DIR / device / locale
            outdir.mkdir(parents=True, exist_ok=True)
            for raw in raws:
                stem = raw.stem  # e.g. 01_today
                idx = RAW_ORDER.index(stem) if stem in RAW_ORDER else 0
                caption = caps[idx] if idx < len(caps) else caps[-1]
                img = Image.open(raw).convert("RGB")
                framed = frame_one(img, size, caption, locale)
                framed.save(outdir / f"{stem}.png")
            print(f"  {device}/{locale}: {len(raws)} screenshots")
    print(f"\nDone → {OUT_DIR}")


if __name__ == "__main__":
    main()
