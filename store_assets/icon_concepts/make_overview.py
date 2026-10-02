"""Builds overview.png and one Play feature graphic per PlateSimple icon
concept (adapted from the Word Waves icon pipeline).

Run after rendering the concepts and the store shots (repo root):
    flutter test --dart-define=ICON_CONCEPTS=true test/icon_concepts_test.dart
    flutter test test/store_shots_test.dart --dart-define=STORE_SHOTS=true --dart-define=DEVICES=phone --dart-define=LOCALES=en
    python store_assets/icon_concepts/make_overview.py

Per concept, on a light and a dark home-screen background: the 1024 master
(at 300 px) and real-size renders at 180/96/48/29 px with the iOS mask, plus
the platform masks at 180 px (iOS rounded rect from the master, Android
circle from the adaptive layers: centre 72/108 viewport). Then
feature_<concept>.png (1024x500) for each concept.
"""

from __future__ import annotations

import sys
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent / 'v2'))
import make_store_shots as ms  # noqa: E402

# (id, label, pitch, file stem)
CONCEPTS = [
    ('A', 'A - Sprout on the plate', "Today's icon (linen, plate, macro ring) with Sprout sitting on the plate",
     'A_sprout_on_plate'),
    ('B', 'B - Sprout close-up', 'A big star-eyed Sprout on a white plate, herb-green ground',
     'B_sprout_closeup'),
    ('C', 'C - Today ring', "The app's hero: green progress ring on linen, Sprout perched on it",
     'C_today_ring'),
]
SIZES = [180, 96, 48, 29]
LIGHT_BG = (236, 239, 244)
DARK_BG = (22, 24, 30)
FONT = 'C:/Windows/Fonts/segoeuib.ttf'
FONT_REG = 'C:/Windows/Fonts/segoeui.ttf'


def font(path: str, size: int):
    try:
        return ImageFont.truetype(path, size)
    except OSError:
        return ImageFont.load_default()


def ios_mask(img: Image.Image, size: int) -> Image.Image:
    big = img.convert('RGBA').resize((size * 4, size * 4), Image.LANCZOS)
    mask = Image.new('L', big.size, 0)
    ImageDraw.Draw(mask).rounded_rectangle(
        (0, 0, big.size[0] - 1, big.size[1] - 1), radius=int(big.size[0] * 0.2237), fill=255)
    big.putalpha(mask)
    return big.resize((size, size), Image.LANCZOS)


def android_circle(bg: Image.Image, fg: Image.Image, size: int) -> Image.Image:
    layered = bg.convert('RGBA').copy()
    layered.alpha_composite(fg.convert('RGBA'))
    w = layered.size[0]
    inset = w * (108 - 72) / 2 / 108
    view = layered.crop((round(inset), round(inset), round(w - inset), round(w - inset)))
    big = view.resize((size * 4, size * 4), Image.LANCZOS)
    mask = Image.new('L', big.size, 0)
    ImageDraw.Draw(mask).ellipse((0, 0, big.size[0] - 1, big.size[1] - 1), fill=255)
    big.putalpha(mask)
    return big.resize((size, size), Image.LANCZOS)


def panel(master, bg, fg, color, dark):
    width, height = 1010, 470
    p = Image.new('RGBA', (width, height), color + (255,))
    d = ImageDraw.Draw(p)
    ink = (235, 238, 245) if dark else (40, 46, 56)
    small = font(FONT_REG, 18)
    p.alpha_composite(ios_mask(master, 300), (30, 40))
    d.text((30, 350), '1024 master (shown at 300)', font=small, fill=ink)
    x = 360
    for s in SIZES:
        p.alpha_composite(ios_mask(master, s), (x, 40 + (180 - s) // 2))
        d.text((x, 235), f'{s} px', font=small, fill=ink)
        x += s + 40
    p.alpha_composite(ios_mask(master, 180), (360, 270))
    d.text((360, 444), 'iOS', font=small, fill=ink)
    p.alpha_composite(android_circle(bg, fg, 180), (580, 270))
    d.text((580, 444), 'Android adaptive (circle)', font=small, fill=ink)
    p.alpha_composite(android_circle(bg, fg, 48), (830, 336))
    d.text((830, 392), '48 px', font=small, fill=ink)
    return p


def build_overview():
    title = font(FONT, 34)
    sub = font(FONT_REG, 22)
    row_h = 560
    cur = Image.open(HERE.parents[1] / 'assets' / 'icon' / 'icon.png')
    rows = [('Current', 'Current icon, for comparison', cur, cur, Image.new('RGBA', cur.size, (0, 0, 0, 0)))]
    for _, label, pitch, stem in CONCEPTS:
        master = Image.open(HERE / f'{stem}.png')
        assert master.size == (1024, 1024), master.size
        assert master.convert('RGBA').getextrema()[3][0] == 255, f'{stem} must be opaque'
        rows.append((label, pitch, master, Image.open(HERE / f'{stem}_adaptive_bg.png'),
                     Image.open(HERE / f'{stem}_adaptive_fg.png')))
    sheet = Image.new('RGBA', (2080, 90 + row_h * len(rows)), (255, 255, 255, 255))
    d = ImageDraw.Draw(sheet)
    d.text((30, 24), 'PlateSimple - app icon concepts (Sprout, Kitchen table)', font=font(FONT, 40),
           fill=(43, 38, 32))
    y = 90
    for label, pitch, master, bg, fg in rows:
        d.text((30, y + 6), label, font=title, fill=(43, 38, 32))
        d.text((30, y + 50), pitch, font=sub, fill=(110, 100, 90))
        sheet.alpha_composite(panel(master, bg, fg, LIGHT_BG, False), (20, y + 86))
        sheet.alpha_composite(panel(master, bg, fg, DARK_BG, True), (1050, y + 86))
        y += row_h
    sheet.convert('RGB').save(HERE / 'overview.png', optimize=True)
    print('wrote overview.png')


def feature(stem, theme):
    """Feature graphic A's layout with the concept icon in place of today's."""
    W, H = 1024, 500
    fl, INK, HERB = ms.fl, ms.INK, ms.HERB
    dark_ground = theme == 'herb'
    c = ms.ground((W, H), theme, stem)
    c = ms.plate(c, 800, 250, 250)
    c = ms.confetti(c, 11, n=14, keep_out=(40, 60, 540, 420), scale=0.9)
    ph, pad = ms.phone_tilt('en_01_today.png', 600, -7)
    c.alpha_composite(ph, (800 - ph.width // 2, 64 - pad))
    icon = Image.open(HERE / f'{stem}.png').convert('RGBA').resize((132, 132), Image.LANCZOS)
    m = Image.new('L', icon.size, 0)
    ImageDraw.Draw(m).rounded_rectangle((0, 0, 131, 131), radius=30, fill=255)
    icon.putalpha(m)
    icon, ip = ms.with_shadow(icon, 8, opacity=70, offset=(0, 5))
    c.alpha_composite(icon, (62 - ip, 80 - ip))
    ink = ms.WHITE if dark_ground else INK
    wm = ms.wordmark(70, ink)
    if dark_ground:
        wm, wp = ms.with_shadow(wm, 5, opacity=60, offset=(0, 3))
    else:
        wp = 0
    c.alpha_composite(wm, (58 - wp, 236 - wp))
    tag = fl.render_line('Calories & macros, simply.', *ms.F_LATIN_MED, 32,
                         (225, 245, 232) if dark_ground else HERB)
    c.alpha_composite(tag, (62, 326))
    return c.convert('RGB')


def build_features():
    for cid, _, _, stem in CONCEPTS:
        img = feature(stem, 'herb' if cid == 'B' else 'linen')
        assert img.size == (1024, 500)
        img.save(HERE / f'feature_{cid}_{stem[2:]}.png', optimize=True)
    print('wrote 3 feature graphics')


if __name__ == '__main__':
    build_overview()
    build_features()
