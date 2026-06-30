#!/usr/bin/env python3
"""
Frame + caption iOS raw captures for the App Store (generalized).

Reads raw PNGs named <locale>_<NN>_<screen>.png and writes captioned, store-sized
images to framed/ios_phone/<locale>/<NN>_<screen>.png and framed/ios_tablet/...
(1290x2796 / 2048x2732).

captions.json may be either:
  { "<locale>": { "01_today": "…" } }            # dict keyed by screen
  { "<locale>": ["…", "…", "…"] }                # list ordered by screen number
Locale keys may be "en" or "en-US"/"pt-BR" (region codes ok).

Usage:
  python frame_ios.py --device phone  --raw raw_phone
  python frame_ios.py --device tablet --raw raw_tablet
"""
import argparse, json, re
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont, ImageFilter

HERE = Path(__file__).resolve().parent
NAME_RE = re.compile(r"^(?P<locale>.+?)_(?P<screen>\d{2}_[a-z_]+)$")
SIZES = {"phone": (1290, 2796), "tablet": (2048, 2732)}
FONT_DEFAULT = "/System/Library/Fonts/SFNS.ttf"
FONT_BY_LANG = {
    "zh": "/System/Library/Fonts/Hiragino Sans GB.ttc",
    "ja": "/System/Library/Fonts/Hiragino Sans GB.ttc",
    "ko": "/System/Library/Fonts/AppleSDGothicNeo.ttc",
    "ar": "/System/Library/Fonts/SFArabic.ttf",
    "hi": "/System/Library/Fonts/Kohinoor.ttc",
    "bn": "/System/Library/Fonts/KohinoorBangla.ttc",
}


def lang_of(locale):
    return re.split(r"[-_]", locale)[0]


def load_captions():
    p = HERE / "captions.json"
    return json.loads(p.read_text()) if p.exists() else {}


def _shape(text, lang):
    if lang == "ar":
        try:
            import arabic_reshaper
            from bidi.algorithm import get_display
            return get_display(arabic_reshaper.reshape(text))
        except Exception:
            return text
    return text


def caption_for(caps, locale, screen):
    lang = lang_of(locale)
    idx = int(screen[:2]) - 1
    for key in (locale, lang, "default", "en-US", "en"):
        if key in caps:
            val = caps[key]
            if isinstance(val, dict) and screen in val:
                return _shape(val[screen], lang)
            if isinstance(val, list) and 0 <= idx < len(val):
                return _shape(val[idx], lang)
    return screen.split("_", 1)[1].replace("_", " ").title()


def font(size, locale="en"):
    for path in (FONT_BY_LANG.get(lang_of(locale)), FONT_DEFAULT):
        if not path:
            continue
        try:
            return ImageFont.truetype(path, size)
        except Exception:
            continue
    return ImageFont.load_default()


def sample_bg(img):
    px = list(img.resize((24, 24)).convert("RGB").getdata())
    r = sum(p[0] for p in px) // len(px); g = sum(p[1] for p in px) // len(px); b = sum(p[2] for p in px) // len(px)
    return (int(r * 0.55), int(g * 0.55), int(b * 0.55))


def rounded(img, radius):
    mask = Image.new("L", img.size, 0)
    ImageDraw.Draw(mask).rounded_rectangle([0, 0, img.size[0], img.size[1]], radius, fill=255)
    out = img.convert("RGBA"); out.putalpha(mask); return out


def wrap(draw, text, fnt, max_w):
    words, lines, cur = text.split(), [], ""
    for w in words:
        t = (cur + " " + w).strip()
        if draw.textlength(t, font=fnt) <= max_w:
            cur = t
        else:
            if cur: lines.append(cur)
            cur = w
    if cur: lines.append(cur)
    return lines


def frame_one(raw_path, device, caps):
    W, H = SIZES[device]
    m = NAME_RE.match(raw_path.stem)
    if not m: return None
    locale, screen = m.group("locale"), m.group("screen")
    shot = Image.open(raw_path).convert("RGB")
    bg = Image.new("RGB", (W, H), sample_bg(shot))
    draw = ImageDraw.Draw(bg)

    margin = int(W * 0.07); avail_w = W - 2 * margin
    bottom_margin = int(H * 0.035); max_shot_h = int(H * 0.83)
    scale = min(avail_w / shot.width, max_shot_h / shot.height)
    sw, sh = int(shot.width * scale), int(shot.height * scale)
    x = (W - sw) // 2; sy = H - sh - bottom_margin

    cap = caption_for(caps, locale, screen)
    fsize = int(W * 0.084); fnt = font(fsize, locale)
    lines = wrap(draw, cap, fnt, W - 2 * margin)
    line_h = int(fsize * 1.14); block_h = line_h * len(lines)
    band_top = int(H * 0.025)
    y = band_top + ((sy - band_top) - block_h) // 2
    for ln in lines:
        w = draw.textlength(ln, font=fnt)
        draw.text(((W - w) / 2, y), ln, font=fnt, fill=(255, 255, 255)); y += line_h

    shot_r = rounded(shot.resize((sw, sh)), int(min(sw, sh) * 0.06))
    shadow = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    shadow.paste(Image.new("RGBA", (sw, sh), (0, 0, 0, 110)), (x, sy + 14),
                 rounded(Image.new("L", (sw, sh), 255).convert("RGBA"), int(min(sw, sh) * 0.06)))
    shadow = shadow.filter(ImageFilter.GaussianBlur(22))
    bg = Image.alpha_composite(bg.convert("RGBA"), shadow)
    bg.alpha_composite(shot_r, (x, sy))

    outdir = HERE / "framed" / f"ios_{device}" / locale
    outdir.mkdir(parents=True, exist_ok=True)
    bg.convert("RGB").save(outdir / f"{screen}.png")
    return True


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--device", choices=SIZES, required=True)
    ap.add_argument("--raw", default=str(HERE / "raw"))
    args = ap.parse_args()
    caps = load_captions()
    n = sum(1 for r in sorted(Path(args.raw).glob("*.png")) if frame_one(r, args.device, caps))
    print(f"framed {n} -> framed/ios_{args.device}/")


if __name__ == "__main__":
    main()
