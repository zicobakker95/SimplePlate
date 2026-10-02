"""Apply the chosen app icon (A, Sprout on the plate) everywhere.

    flutter test --dart-define=ICON_CONCEPTS=true test/icon_concepts_test.dart
    python store_assets/v2/icon/make_app_icon.py

Sources (store_assets/icon_concepts/, 1024 px):
  A_sprout_on_plate.png             opaque master (iOS, stores)
  A_sprout_on_plate_adaptive_fg.png Android adaptive foreground (full 108dp
                                    layer; ring + plate + Sprout stay inside
                                    the 66dp safe zone)
  A_sprout_on_plate_adaptive_bg.png Android adaptive background (linen)

Writes:
  android/app/src/main/res/drawable-*dpi/ic_launcher_{foreground,background,monochrome}.png
  android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml, ic_launcher_round.xml
  android/app/src/main/res/mipmap-*dpi/ic_launcher.png, ic_launcher_round.png  (legacy)
  ios/Runner/Assets.xcassets/AppIcon.appiconset/*  (every size, opaque RGB)
  assets/icon/icon*.png         (flutter_launcher_icons sources)
  assets/promo/platesimple.png  (cross-promo tile)
  store_assets/v2/icon/play_icon_512.png, appstore_icon_1024.png
  build/icon_check.png          (preview sheet; pass --no-preview to skip)
"""
import json
import math
import sys
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw, ImageFilter, ImageFont

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]
SRC = REPO / 'store_assets' / 'icon_concepts'
RES = REPO / 'android' / 'app' / 'src' / 'main' / 'res'
IOS = REPO / 'ios' / 'Runner' / 'Assets.xcassets' / 'AppIcon.appiconset'

MASTER = Image.open(SRC / 'A_sprout_on_plate.png').convert('RGB')
FG = Image.open(SRC / 'A_sprout_on_plate_adaptive_fg.png').convert('RGBA')
BG = Image.open(SRC / 'A_sprout_on_plate_adaptive_bg.png').convert('RGB')
assert MASTER.size == FG.size == BG.size == (1024, 1024)

# Adaptive layers are 108dp; legacy icons 48dp.
ADAPTIVE = {'mdpi': 108, 'hdpi': 162, 'xhdpi': 216, 'xxhdpi': 324, 'xxxhdpi': 432}
LEGACY = {'mdpi': 48, 'hdpi': 72, 'xhdpi': 96, 'xxhdpi': 144, 'xxxhdpi': 192}

# Geometry of the foreground layer (px on the 1024 canvas): the macro ring's
# outer edge and the white plate's edge, both centred.
C = 511.5
R_OUT = 297.0
R_PLATE = 202.0


def fit(img, px):
    return img.resize((px, px), Image.LANCZOS)


def _mask(a):
    return Image.fromarray(np.clip(a * 255, 0, 255).astype(np.uint8), 'L')


def monochrome():
    """Android 13 themed icon: one-colour silhouette of the macro ring (with
    thin cuts between the segments) around Sprout, who sits on the now-empty
    plate. Sprout's eyes, smile and glint are cut out so the face reads."""
    a = np.asarray(FG).astype(np.float32)
    rgb, alpha = a[..., :3], a[..., 3]
    mx, mn = rgb.max(-1), rgb.min(-1)
    sat = mx - mn
    yy, xx = np.mgrid[0:1024, 0:1024].astype(np.float32)
    dx, dy = xx - C, yy - C
    r = np.hypot(dx, dy)
    ang = (np.degrees(np.arctan2(dx, -dy)) + 360) % 360  # 0 = 12 o'clock, cw

    # Flat ring colour for every angle, sampled mid-ring (no leaf reaches it).
    def ring_colour(deg):
        t = np.radians(deg)
        x, y = C + 270 * np.sin(t), C - 270 * np.cos(t)
        return a[int(round(y)), int(round(x)), :3]

    lut = np.stack([ring_colour(d) for d in range(360)])
    ring_rgb = lut[ang.astype(int) % 360]

    # Sprout: saturated pixels on the plate (body, cheeks, stem, leaf bases)
    # plus the leaf tips that overlap the ring (pixels that are not the flat
    # ring colour at that angle), above the plate centre only.
    # Soft masks (anti-aliased edges stay proportional), cleaned up below by
    # a small blur + threshold so the silhouette has smooth outlines.
    # On the plate: anything clearly darker than the white plate. The pale
    # plate-shadow ellipse and Sprout's glint fall below the cut-off.
    away_from_white = 255 - mn
    on_plate = (r < R_PLATE - 1) * np.clip((away_from_white - 45) / 50, 0, 1) * (alpha / 255)
    diff = np.abs(rgb - ring_rgb).max(-1)
    tips = ((r >= R_PLATE + 3) & (r < 245) & (yy < 420)) * np.clip((diff - 15) / 40, 0, 1)
    # Drop thin slivers (anti-aliased seams between ring segments).
    body = _mask((tips > 0.5).astype(np.float32)).filter(ImageFilter.MinFilter(5))         .filter(ImageFilter.MaxFilter(7))
    tips = tips * (np.asarray(body, np.float32) / 255)
    sprout = np.maximum(on_plate, tips)
    # Leaf tips cross the plate edge: bridge the thin band where neither
    # test applies, next to existing leaf pixels only.
    near = np.asarray(_mask(sprout).filter(ImageFilter.GaussianBlur(3)), np.float32) / 255 > 0.25
    seam = near & (r >= R_PLATE - 2) & (r < R_PLATE + 4) & (yy < 420)
    sprout = np.maximum(sprout, seam.astype(np.float32))
    # Cut the face out: dark eyes and smile.
    lum = rgb @ np.array([0.299, 0.587, 0.114], np.float32)
    feats = (r < R_PLATE - 1) * np.clip((120 - lum) / 40, 0, 1) * (alpha / 255)
    sprout = np.clip(sprout - feats, 0, 1)
    sprout = (np.asarray(_mask(sprout).filter(ImageFilter.GaussianBlur(1.5)), np.float32) / 255
              > 0.5).astype(np.float32)

    # Ring: analytic anti-aliased annulus, minus a rounded gap around
    # Sprout's leaves, minus thin radial cuts where the macro segments meet.
    ring = np.clip(R_OUT - r + 0.5, 0, 1) * np.clip(r - R_PLATE + 0.5, 0, 1)
    halo = np.asarray(_mask(sprout).filter(ImageFilter.GaussianBlur(9)), np.float32) / 255
    gap = (halo > 0.1).astype(np.float32)
    ring = np.clip(ring - gap, 0, 1)
    seg = np.array([tuple(int(v) // 8 for v in lut[d]) for d in range(360)])
    raw = [d - 0.5 for d in range(360) if tuple(seg[d]) != tuple(seg[d - 1])]
    # Anti-aliased edges give a 1-degree sliver of blended colour: merge
    # transitions closer than 3 degrees into one boundary.
    bounds = []
    for b in raw:
        if bounds and b - bounds[-1][-1] < 3:
            bounds[-1].append(b)
        else:
            bounds.append([b])
    bounds = [sum(g) / len(g) for g in bounds]
    for b in bounds:
        t = math.radians(b)
        ux, uy = math.sin(t), -math.cos(t)
        # distance of each pixel from the boundary ray
        dist = np.abs(dx * uy - dy * ux)
        along = dx * ux + dy * uy
        cut = np.clip(7 - dist + 0.5, 0, 1) * (along > 0)
        ring = np.clip(ring - cut, 0, 1)

    shape = np.maximum(ring, sprout)
    shape_img = _mask(shape).filter(ImageFilter.GaussianBlur(0.8))
    out = Image.new('RGBA', FG.size, (255, 255, 255, 0))
    out.putalpha(shape_img)
    return out, len(bounds)


def adaptive_composite():
    comp = BG.convert('RGBA')
    comp.alpha_composite(FG)
    return comp


def _viewport():
    """The 72dp adaptive viewport (centre 72/108 of the layers)."""
    return adaptive_composite().crop((171, 171, 853, 853))


def _masked(px, shape):
    """Pre-Oreo launcher icon on the 48dp grid (2dp margin)."""
    m = round(px * 2 / 48)
    inner = px - 2 * m
    c = fit(_viewport(), inner)
    big = inner * 4
    mask = Image.new('L', (big, big), 0)
    d = ImageDraw.Draw(mask)
    if shape == 'round':
        d.ellipse((0, 0, big - 1, big - 1), fill=255)
    else:
        d.rounded_rectangle((0, 0, big - 1, big - 1), radius=int(big * 0.2), fill=255)
    mask = mask.resize((inner, inner), Image.LANCZOS)
    out = Image.new('RGBA', (px, px), (0, 0, 0, 0))
    out.paste(c, (m, m), mask)
    return out


def android():
    mono, nbounds = monochrome()
    for d, px in ADAPTIVE.items():
        folder = RES / f'drawable-{d}'
        folder.mkdir(exist_ok=True)
        fit(FG, px).save(folder / 'ic_launcher_foreground.png', optimize=True)
        fit(BG, px).save(folder / 'ic_launcher_background.png', optimize=True)
        fit(mono, px).save(folder / 'ic_launcher_monochrome.png', optimize=True)
    for d, px in LEGACY.items():
        folder = RES / f'mipmap-{d}'
        _masked(px, 'square').save(folder / 'ic_launcher.png', optimize=True)
        _masked(px, 'round').save(folder / 'ic_launcher_round.png', optimize=True)
    xml = ('<?xml version="1.0" encoding="utf-8"?>\n'
           '<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">\n'
           '    <background android:drawable="@drawable/ic_launcher_background"/>\n'
           '    <foreground android:drawable="@drawable/ic_launcher_foreground"/>\n'
           '    <monochrome android:drawable="@drawable/ic_launcher_monochrome"/>\n'
           '</adaptive-icon>\n')
    for name in ['ic_launcher.xml', 'ic_launcher_round.xml']:
        (RES / 'mipmap-anydpi-v26' / name).write_text(xml, encoding='utf-8', newline='\n')
    # The old flutter_launcher_icons background colour is now a drawable layer.
    old = RES / 'values' / 'colors.xml'
    if old.exists() and 'ic_launcher_background' in old.read_text(encoding='utf-8'):
        old.unlink()
    return mono, nbounds


def ios():
    contents = json.loads((IOS / 'Contents.json').read_text(encoding='utf-8'))
    made = 0
    for img in contents['images']:
        name = img.get('filename')
        if not name:
            continue
        pts = float(img['size'].split('x')[0])
        px = round(pts * int(img['scale'].rstrip('x')))
        fit(MASTER, px).convert('RGB').save(IOS / name, optimize=True)
        made += 1
    for f in IOS.glob('*.png'):
        im = Image.open(f)
        assert im.mode == 'RGB', f
    return made


def extras(mono):
    icons = REPO / 'assets' / 'icon'
    MASTER.save(icons / 'icon.png', optimize=True)
    FG.save(icons / 'icon_foreground.png', optimize=True)
    BG.save(icons / 'icon_background.png', optimize=True)
    mono.save(icons / 'icon_monochrome.png', optimize=True)
    # Cross-promo tile (ClipRRect rounds it in the list).
    fit(MASTER, 126).convert('RGBA').save(REPO / 'assets' / 'promo' / 'platesimple.png', optimize=True)
    fit(MASTER, 512).convert('RGBA').save(HERE / 'play_icon_512.png', optimize=True)
    MASTER.save(HERE / 'appstore_icon_1024.png', optimize=True)
    assert (HERE / 'play_icon_512.png').stat().st_size < 1_000_000


# ---------------------------------------------------------------- preview

def _font(px, bold=False):
    for name in (['arialbd.ttf'] if bold else []) + ['arial.ttf', 'DejaVuSans.ttf']:
        try:
            return ImageFont.truetype(name, px)
        except OSError:
            pass
    return ImageFont.load_default()


def _squircle_mask(px):
    big = px * 4
    m = Image.new('L', (big, big), 0)
    ImageDraw.Draw(m).rounded_rectangle((0, 0, big - 1, big - 1), radius=int(big * 0.3), fill=255)
    return m.resize((px, px), Image.LANCZOS)


def _circle_mask(px):
    big = px * 4
    m = Image.new('L', (big, big), 0)
    ImageDraw.Draw(m).ellipse((0, 0, big - 1, big - 1), fill=255)
    return m.resize((px, px), Image.LANCZOS)


def _ios_mask(px):
    big = px * 4
    m = Image.new('L', (big, big), 0)
    ImageDraw.Draw(m).rounded_rectangle((0, 0, big - 1, big - 1), radius=int(big * 0.2237), fill=255)
    return m.resize((px, px), Image.LANCZOS)


def _adaptive(px, mask_fn, fg=None, bg=None):
    """Launcher render from the actual drawable files: crop the 72dp
    viewport and apply the launcher's mask."""
    fg = fg or Image.open(RES / 'drawable-xxxhdpi' / 'ic_launcher_foreground.png').convert('RGBA')
    bg = bg or Image.open(RES / 'drawable-xxxhdpi' / 'ic_launcher_background.png').convert('RGBA')
    comp = bg.copy()
    comp.alpha_composite(fg)
    s = comp.size[0]
    k = round(s * 18 / 108)
    view = comp.crop((k, k, s - k, s - k)).resize((px, px), Image.LANCZOS)
    out = Image.new('RGBA', (px, px), (0, 0, 0, 0))
    out.paste(view, (0, 0), mask_fn(px))
    return out


def _themed(px, tint_bg, tint_fg):
    mono = Image.open(RES / 'drawable-xxxhdpi' / 'ic_launcher_monochrome.png').convert('RGBA')
    s = mono.size[0]
    bg = Image.new('RGBA', (s, s), tint_bg)
    fg = Image.new('RGBA', (s, s), tint_fg)
    fg.putalpha(mono.split()[3])
    return _adaptive(px, _circle_mask, fg=fg, bg=bg)


def preview():
    """Contact sheet of every launcher shape at real sizes, on a light and a
    dark home screen: legacy PNGs, adaptive round + squircle masks, the
    Android 13 themed icon (two tints) and the iOS 60/180 icons."""
    light_tint = ((215, 230, 205, 255), (35, 75, 40, 255))
    dark_tint = ((40, 55, 42, 255), (190, 225, 185, 255))
    lines = [
        [(Image.open(RES / f'mipmap-{dpi}' / 'ic_launcher.png').convert('RGBA'), f'legacy {px}')
         for dpi, px in [('mdpi', 48), ('xhdpi', 96), ('xxxhdpi', 192)]] +
        [(_adaptive(px, _circle_mask), f'round {px}') for px in (48, 96, 192)],
        [(_adaptive(px, _squircle_mask), f'squircle {px}') for px in (48, 96, 192)] +
        [(_themed(px, *light_tint), f'themed light {px}') for px in (48, 96)] +
        [(_themed(px, *dark_tint), f'themed dark {px}') for px in (48, 96)] +
        [(_themed(192, *light_tint), 'themed 192')],
    ]
    ios_items = []
    for fname, px in [('Icon-App-20x20@3x.png', 60), ('Icon-App-60x60@3x.png', 180)]:
        im = Image.open(IOS / fname).convert('RGBA')
        assert im.size == (px, px) and Image.open(IOS / fname).mode == 'RGB'
        masked = Image.new('RGBA', (px, px), (0, 0, 0, 0))
        masked.paste(im, (0, 0), _ios_mask(px))
        ios_items.append((masked, f'iOS {px}'))
    lines.append(ios_items)

    W, LINE = 1640, 250
    block = 60 + LINE * len(lines)
    H = 90 + 2 * (block + 20)
    sheet = Image.new('RGB', (W, H), (250, 248, 243))
    d = ImageDraw.Draw(sheet)
    d.text((40, 24), 'PlateSimple app icon A - Sprout on the plate', fill=(40, 40, 40), font=_font(34, True))
    for i, (colour, name) in enumerate([((250, 248, 243), 'light home screen'),
                                        ((32, 33, 38), 'dark home screen')]):
        y0 = 90 + i * (block + 20)
        d.rectangle((20, y0, W - 20, y0 + block), fill=colour)
        tc = (30, 30, 30) if colour[0] > 128 else (230, 230, 230)
        d.text((40, y0 + 12), name, fill=tc, font=_font(22, True))
        for li, items in enumerate(lines):
            x, base = 40, y0 + 60 + li * LINE + 192
            for im, lab in items:
                px = im.size[0]
                sheet.paste(im, (x, base - px), im)
                d.text((x, base + 8), lab, fill=tc, font=_font(16))
                x += max(px, 130) + 30
    out = REPO / 'build' / 'icon_check.png'
    out.parent.mkdir(exist_ok=True)
    sheet.save(out)
    return out


if __name__ == '__main__':
    mono, nb = android()
    n = ios()
    extras(mono)
    print(f'android layers + legacy ({nb} ring cuts), ios {n} sizes, store exports done')
    if '--no-preview' not in sys.argv:
        print('preview:', preview())
