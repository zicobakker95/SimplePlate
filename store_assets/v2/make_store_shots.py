"""PlateSimple store art: framed screenshots, feature graphics, overview.

    flutter test test/store_shots_test.dart --dart-define=STORE_SHOTS=true
    flutter test test/store_shots_test.dart --dart-define=STORE_SHOTS=true --dart-define=LOCALES=ja
    python store_assets/v2/make_store_shots.py              # everything
    python store_assets/v2/make_store_shots.py frames       # or: feature, overview

Reads build/store_shots/<device>/<loc>_<screen>.png, build/store_art/sprout_*.png
and captions.json; writes, next to this script:

  play_phone/<loc>/NN_name.png    1080x1920  (raw: phone)
  play_tablet/<loc>/NN_name.png   1600x2560  (raw: tablet; the app is portrait-only)
  ios_phone/<loc>/NN_name.png     1290x2796  (raw: phone, App Store 6.9")
  ios_ipad/<loc>/NN_name.png      2048x2732  (raw: ipad, App Store 13")
  feature_graphic/feature_[ABC].png  1024x500 (Play)
  overview.png                    contact sheet

The "Kitchen table" frame: linen / herb green / espresso grounds, a white
plate ringed in the macro colours behind the phone (the app icon), food
confetti, Sprout on a couple of shots. Captions in Rubik Bold (the app's
font), Yu Gothic Bold for Japanese, shaped with HarfBuzz
(Z:/Github/night/frame_localized.py). Fails loudly if a caption shrinks
below 70% of its design size or a raw shot is missing.

The barcode screen is captured over a black camera feed (no camera in a
widget test); scan_scene() paints a granola pack under it.
"""
import json
import math
import random
import sys
from pathlib import Path

import numpy as np
from PIL import Image, ImageChops, ImageDraw, ImageFilter

sys.path.insert(0, r'Z:\Github\night')
import frame_localized as fl  # noqa: E402

HERE = Path(__file__).resolve().parent
REPO = HERE.parent.parent
RAW = REPO / 'build' / 'store_shots'
ART = REPO / 'build' / 'store_art'
CAPS = json.loads((HERE / 'captions.json').read_text(encoding='utf-8'))

F_LATIN = (str(REPO / 'assets' / 'fonts' / 'Rubik-Bold.ttf'), 0)
F_LATIN_MED = (str(REPO / 'assets' / 'fonts' / 'Rubik-Medium.ttf'), 0)
F_JA = ('C:/Windows/Fonts/YuGothB.ttc', 0)

# Palette (lib/ui/theme/plate_theme.dart).
LINEN = (246, 241, 231)
LINEN_D = (236, 226, 208)
SUNKEN = (239, 232, 219)
HERB = (36, 137, 79)
FRESH = (61, 184, 115)
PROTEIN = (63, 143, 214)
CARBS = (232, 150, 42)
FAT = (226, 96, 78)
HONEY = (242, 169, 59)
INK = (43, 38, 32)        # warm charcoal
ESPRESSO = (33, 30, 25)
NIGHT = (21, 19, 15)
WHITE = (255, 255, 255)
BEZEL = (40, 36, 31)

# name -> (top, bottom, ink, texture)
THEMES = {
    'linen': (LINEN, LINEN_D, INK, True),
    'herb': ((52, 163, 98), (30, 116, 66), WHITE, False),
    'night': ((44, 39, 33), NIGHT, LINEN, False),
}

# screen -> (theme, optional Sprout (pose, side))
SCREENS = {
    '01_today': ('linen', ('happy', 'left')),
    '02_log': ('herb', None),
    '03_scan': ('linen', None),
    '04_detail': ('herb', None),
    '05_recipes': ('linen', None),
    '06_celebrate': ('herb', ('celebrate', 'right')),
    '07_history': ('linen', None),
    '08_dark': ('night', None),
}

# slot -> (raw device, canvas size, device corner radius, bezel), as
# fractions of the device width.
SLOTS = {
    'play_phone': ('phone', (1080, 1920), 0.085, 0.024),
    'play_tablet': ('tablet', (1600, 2560), 0.05, 0.018),
    'ios_phone': ('phone', (1290, 2796), 0.085, 0.024),
    'ios_ipad': ('ipad', (2048, 2732), 0.045, 0.016),
}
# Logical width of each raw capture (test/store_shots_test.dart).
LOGICAL_W = {'phone': 390, 'tablet': 600, 'ipad': 512}
LOCALES = ['en', 'nl', 'de', 'fr', 'es', 'it', 'pt', 'ja']

shrunk = []


def font_for(loc):
    return F_JA if loc == 'ja' else F_LATIN


def gradient(size, top, bottom):
    W, H = size
    g = Image.new('RGB', (1, 256))
    for y in range(256):
        t = y / 255
        g.putpixel((0, y), tuple(int(top[i] + (bottom[i] - top[i]) * t) for i in range(3)))
    g = g.resize((W, H), Image.BICUBIC)
    spot = Image.new('L', size, 0)  # a soft light from the top left
    ImageDraw.Draw(spot).ellipse((-W * 0.4, -H * 0.25, W * 0.7, H * 0.35), fill=60)
    spot = spot.filter(ImageFilter.GaussianBlur(W * 0.12))
    return Image.composite(Image.new('RGB', size, WHITE), g, spot)


def linen_texture(img, strength=10):
    """A faint woven weave: thin warm threads both ways."""
    W, H = img.size
    rnd = random.Random(3)
    layer = Image.new('RGBA', img.size, (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)
    step = max(3, W // 360)
    for y in range(0, H, step):
        a = rnd.randint(0, strength)
        d.line((0, y, W, y), fill=(120, 95, 60, a))
    for x in range(0, W, step):
        a = rnd.randint(0, strength)
        d.line((x, 0, x, H), fill=(120, 95, 60, a))
    return Image.alpha_composite(img.convert('RGBA'), layer)


def plate(canvas, cx, cy, r, dark=False):
    """The app icon's plate: a white dish ringed by green, orange, blue."""
    layer = Image.new('RGBA', canvas.size, (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)
    ring = r * 0.17
    box = (cx - r, cy - r, cx + r, cy + r)
    alpha = 150 if dark else 235
    # start at 12 o'clock, clockwise: green 150deg, orange 95, blue 80, track 35
    segs = [(FRESH, 0, 150), (CARBS, 150, 245), (PROTEIN, 245, 325),
            ((70, 62, 52) if dark else (226, 218, 203), 325, 360)]
    for col, a0, a1 in segs:
        d.pieslice(box, a0 - 90, a1 - 90, fill=col + (alpha,))
    inner = r - ring
    bg = (44, 39, 33, 255) if dark else LINEN + (255,)
    d.ellipse((cx - inner, cy - inner, cx + inner, cy + inner), fill=bg)
    dish = inner * 0.86
    d.ellipse((cx - dish, cy - dish, cx + dish, cy + dish),
              fill=((52, 47, 40, 255) if dark else WHITE + (255,)))
    shadow = layer.split()[3].filter(ImageFilter.GaussianBlur(r * 0.04))
    sh = Image.new('RGBA', canvas.size, (60, 40, 20, 0))
    sh.putalpha(shadow.point(lambda v: v * 50 // 255))
    canvas = Image.alpha_composite(canvas, sh)
    return Image.alpha_composite(canvas, layer)


def confetti(canvas, seed, n=22, keep_out=None, scale=1.0):
    """Food confetti like the app's: peas, leaves, macro-coloured crumbs.
    [keep_out] is a box the pieces avoid (the caption)."""
    W, H = canvas.size
    rnd = random.Random(seed)
    layer = Image.new('RGBA', (W, H), (0, 0, 0, 0))
    placed = 0
    tries = 0
    while placed < n and tries < 2000:
        tries += 1
        x, y = rnd.uniform(0, W), rnd.uniform(0, H)
        # Edges only: a band around the outside of the canvas.
        if W * 0.1 < x < W * 0.9 and y > H * 0.16:
            continue
        if keep_out and keep_out[0] - W * 0.04 < x < keep_out[2] + W * 0.04 \
                and keep_out[1] - W * 0.03 < y < keep_out[3] + W * 0.03:
            continue
        kind = rnd.choice(['pea', 'pea', 'leaf', 'crumb', 'crumb'])
        s = W * rnd.uniform(0.012, 0.022) * scale
        piece = Image.new('RGBA', (int(s * 4), int(s * 4)), (0, 0, 0, 0))
        d = ImageDraw.Draw(piece)
        c = s * 2
        if kind == 'pea':
            d.ellipse((c - s, c - s, c + s, c + s), fill=FRESH + (255,))
            d.ellipse((c - s * 0.5, c - s * 0.6, c - s * 0.05, c - s * 0.15), fill=(160, 230, 185, 255))
        elif kind == 'leaf':
            d.ellipse((c - s * 1.5, c - s * 0.6, c + s * 1.5, c + s * 0.6), fill=HERB + (255,))
            d.line((c - s * 1.2, c, c + s * 1.2, c), fill=(120, 200, 150, 255), width=max(1, int(s * 0.15)))
        else:
            col = rnd.choice([PROTEIN, CARBS, FAT, HONEY])
            d.rounded_rectangle((c - s * 0.8, c - s * 0.5, c + s * 0.8, c + s * 0.5),
                                radius=s * 0.3, fill=col + (255,))
        piece = piece.rotate(rnd.uniform(0, 360), resample=Image.BICUBIC)
        layer.alpha_composite(piece, (int(x - c), int(y - c)))
        placed += 1
    return Image.alpha_composite(canvas, layer)


def text_block(text, loc, max_w, base_px, color, max_lines=2):
    """Caption lines: explicit \\n breaks, else the most balanced split into
    at most [max_lines] lines; shrinks to fit [max_w]. Returns (img, scale)."""
    fp, idx = font_for(loc)
    adv = lambda s: fl._adv(s, fp, idx)  # noqa: E731
    upem = adv('x')[1]
    if '\n' in text:
        lines = text.split('\n')
    else:
        words = text.split(' ')
        lines = [text]
        if adv(text)[0] * base_px / upem > max_w and len(words) > 1:
            best = None
            for i in range(1, len(words)):
                a, b = ' '.join(words[:i]), ' '.join(words[i:])
                w = max(adv(a)[0], adv(b)[0])
                if best is None or w < best[0]:
                    best = (w, [a, b])
            lines = best[1]
        assert len(lines) <= max_lines
    widest = max(adv(line)[0] for line in lines)
    px = min(base_px, int(max_w * upem / widest))
    imgs = [fl.render_line(line, fp, idx, px, color) for line in lines]
    w = max(i.width for i in imgs)
    gap = int(px * (0.1 if loc == 'ja' else -0.04))
    h = sum(i.height for i in imgs) + gap * (len(imgs) - 1)
    block = Image.new('RGBA', (w, h), (0, 0, 0, 0))
    y = 0
    for im in imgs:
        block.alpha_composite(im, ((w - im.width) // 2, y))
        y += im.height + gap
    return block, px / base_px


def with_shadow(img, radius, opacity=90, offset=(0, 0), tint=(40, 28, 15)):
    a = img.split()[3].point(lambda v: v * opacity // 255)
    sh = Image.new('RGBA', (img.width + radius * 4, img.height + radius * 4), (0, 0, 0, 0))
    black = Image.new('RGBA', img.size, tint + (255,))
    black.putalpha(a)
    sh.alpha_composite(black, (radius * 2 + offset[0], radius * 2 + offset[1]))
    sh = sh.filter(ImageFilter.GaussianBlur(radius))
    sh.alpha_composite(img, (radius * 2, radius * 2))
    return sh, radius * 2


def device(shot, width, corner, bezel):
    """The raw shot inside a rounded warm-charcoal bezel (a generic phone)."""
    b = int(width * bezel)
    sw = width - 2 * b
    s = shot.resize((sw, int(shot.height * sw / shot.width)), Image.LANCZOS)
    W, H = width, s.height + 2 * b
    r = int(width * corner)
    out = Image.new('RGBA', (W, H), (0, 0, 0, 0))
    ImageDraw.Draw(out).rounded_rectangle((0, 0, W - 1, H - 1), radius=r, fill=BEZEL + (255,))
    mask = Image.new('L', s.size, 0)
    ImageDraw.Draw(mask).rounded_rectangle((0, 0, s.width - 1, s.height - 1), radius=max(4, r - b), fill=255)
    out.paste(s, (b, b), mask)
    ImageDraw.Draw(out).rounded_rectangle((1, 1, W - 2, H - 2), radius=r, outline=(90, 82, 72, 255),
                                          width=max(1, b // 6))
    return out


def sprout(pose, height):
    im = Image.open(ART / f'sprout_{pose}.png').convert('RGBA')
    im = im.crop(im.getbbox())
    return im.resize((int(im.width * height / im.height), height), Image.LANCZOS)


# ── The barcode shot ────────────────────────────────────────────────────────

def _barcode(w, h):
    """EAN-13-looking bars and digits on white."""
    img = Image.new('RGB', (w, h), WHITE)
    d = ImageDraw.Draw(img)
    rnd = random.Random(8712345)
    x = w * 0.08
    bar_h = h * 0.72
    unit = w * 0.84 / 95
    pattern = '101' + ''.join(rnd.choice(['0001101', '0011001', '0010011', '0111101', '0100011'])
                              for _ in range(6)) + '01010' + ''.join(
        rnd.choice(['1110010', '1100110', '1101100', '1000010', '1011100']) for _ in range(6)) + '101'
    for i, bit in enumerate(pattern):
        if bit == '1':
            guard = i < 3 or 45 <= i < 50 or i >= 92
            d.rectangle((x + i * unit, h * 0.08, x + (i + 1) * unit - 0.5,
                         h * 0.08 + bar_h + (h * 0.06 if guard else 0)), fill=(20, 20, 20))
    digits = fl.render_line('8 712345 678906', *F_LATIN_MED, int(h * 0.13), (20, 20, 20))
    img.paste(digits, (int((w - digits.width) / 2), int(h * 0.82)), digits)
    return img


def scan_scene(raw, device_name):
    """Puts a granola pack under the scanner UI: the scene, dimmed outside
    the frame like the app does, then the UI (drawn over black) screened on."""
    W, H = raw.size
    k = W / LOGICAL_W[device_name]
    # Kitchen counter: warm wood, softly out of focus.
    scene = gradient((W, H), (150, 112, 76), (98, 70, 46)).convert('RGBA')
    d = ImageDraw.Draw(scene)
    rnd = random.Random(5)
    for _ in range(60):
        y = rnd.uniform(0, H)
        d.line((0, y, W, y + rnd.uniform(-20, 20)), fill=(70, 48, 30, rnd.randint(8, 22)),
               width=int(k * rnd.uniform(1, 4)))
    scene = scene.filter(ImageFilter.GaussianBlur(k * 2.5))  # out of focus
    # The pack, slightly rotated.
    pw, ph = int(min(W * 0.84, 310 * k)), int(min(H * 0.72, 500 * k))
    pack = Image.new('RGBA', (pw, ph), (0, 0, 0, 0))
    pd = ImageDraw.Draw(pack)
    pd.rounded_rectangle((0, 0, pw - 1, ph - 1), radius=int(k * 14), fill=(250, 244, 230, 255))
    pd.rectangle((0, int(ph * 0.04), pw, int(ph * 0.2)), fill=CARBS + (255,))
    pd.rectangle((0, int(ph * 0.86), pw, ph - int(k * 14)), fill=HERB + (255,))
    title = fl.render_line('GRANOLA', *F_LATIN, int(k * 44), WHITE)
    pack.alpha_composite(title, ((pw - title.width) // 2, int(ph * 0.12 - title.height / 2)))
    sub = fl.render_line('oats · honey · almonds', *F_LATIN_MED, int(k * 15), (110, 90, 70))
    pack.alpha_composite(sub, ((pw - sub.width) // 2, int(ph * 0.24)))
    # A bowl of oats illustration: dots in a half circle.
    bx, by, br = pw / 2, ph * 0.71, pw * 0.22
    for _ in range(140):
        a = rnd.uniform(math.pi, 2 * math.pi)
        rr = br * math.sqrt(rnd.random())
        x, y = bx + rr * math.cos(a), by + rr * math.sin(a) * 0.5
        s = k * rnd.uniform(2.5, 4.5)
        pd.ellipse((x - s, y - s * 0.7, x + s, y + s * 0.7), fill=rnd.choice([(214, 170, 110), (196, 146, 86), (232, 196, 140)]) + (255,))
    pd.chord((bx - br * 1.05, by - br * 0.55, bx + br * 1.05, by + br * 0.9), 0, 180, fill=PROTEIN + (255,))
    # Barcode label centred where the scanner frame sits.
    bw, bh = int(220 * k), int(118 * k)
    bc = _barcode(bw, bh)
    pack.paste(bc, ((pw - bw) // 2, (ph - bh) // 2 - int(ph * 0.04)))
    pack = pack.rotate(-4, resample=Image.BICUBIC, expand=True)
    pack, pad = with_shadow(pack, int(k * 10), opacity=110, offset=(0, int(k * 8)))
    scene.alpha_composite(pack, ((W - pack.width) // 2, (H - pack.height) // 2 + int(H * 0.04 * 0)
                                 + int(ph * 0.04)))
    # Dim outside the frame (270 x 170 logical, centred), as the app does.
    fw, fh = 270 * k, 170 * k
    hole = Image.new('L', (W, H), 255)
    ImageDraw.Draw(hole).rounded_rectangle(((W - fw) / 2, (H - fh) / 2, (W + fw) / 2, (H + fh) / 2),
                                           radius=12 * k, fill=0)
    dim = Image.new('RGBA', (W, H), (0, 0, 0, 0))
    dim.putalpha(hole.point(lambda v: v * 140 // 255))
    scene = Image.alpha_composite(scene, dim)
    # The UI was drawn over black: recover an alpha from its brightness
    # and lay it over the scene.
    ui_rgb = raw.convert('RGB')
    a = ImageChops.lighter(ImageChops.lighter(*ui_rgb.split()[:2]), ui_rgb.split()[2])
    a = a.point(lambda v: min(255, int(v * 1.6)))
    over = Image.new('RGBA', (W, H))
    over.paste(_unpremultiply(ui_rgb, a), (0, 0))
    over.putalpha(a)
    return Image.alpha_composite(scene, over).convert('RGB')


def _unpremultiply(rgb, alpha):
    c = np.asarray(rgb).astype(np.float32)
    al = np.asarray(alpha).astype(np.float32)[..., None] / 255
    out = np.clip(c / np.maximum(al, 1 / 255), 0, 255).astype(np.uint8)
    return Image.fromarray(out, 'RGB')


# ── Frames ───────────────────────────────────────────────────────────────────

def ground(size, theme, seed, caption_box=None):
    top, bottom, _, texture = THEMES[theme]
    canvas = gradient(size, top, bottom).convert('RGBA')
    if texture:
        canvas = linen_texture(canvas)
    else:
        canvas = linen_texture(canvas, strength=6)
    return canvas


def frame(raw, caption, loc, slot, screen):
    _, size, corner, bezel = SLOTS[slot]
    W, H = size
    theme, buddy = SCREENS[screen]
    _, _, ink, _ = THEMES[theme]
    canvas = ground(size, theme, screen)

    margin = int(W * 0.07)
    base_px = int(W * (0.082 if W / H < 0.6 else 0.068))
    block, scale = text_block(caption, loc, W - 2 * margin, base_px, ink)
    if scale < 0.7:
        shrunk.append((slot, loc, screen, round(scale, 2)))
    cy = int(H * 0.045)
    cap_bottom = cy + block.height

    dev_top = cap_bottom + int(H * 0.03)
    avail_h = H - dev_top - int(H * 0.035)
    aspect = raw.height / raw.width
    dw = int(min(W * 0.84, avail_h / (aspect + 2 * bezel)))
    dev = device(raw, dw, corner, bezel)
    dx = (W - dw) // 2

    # The plate behind the phone, peeking out on both sides.
    canvas = plate(canvas, W / 2, dev_top + dev.height * 0.5, W * 0.56, dark=theme == 'night')
    canvas = confetti(canvas, sum(map(ord, screen)),
                      keep_out=((W - block.width) / 2, cy, (W + block.width) / 2, cap_bottom),
                      scale=1.0 if W / H < 0.6 else 0.8)
    if ink == WHITE or theme == 'night':
        sblock, pad = with_shadow(block, max(4, base_px // 12), opacity=60, offset=(0, base_px // 24))
    else:
        sblock, pad = block, 0
    canvas.alpha_composite(sblock, ((W - block.width) // 2 - pad, cy - pad))

    dev, dpad = with_shadow(dev, int(W * 0.025), opacity=120, offset=(0, int(W * 0.014)))
    canvas.alpha_composite(dev, (dx - dpad, dev_top - dpad))

    if buddy:
        pose, side = buddy
        bh = int(H * 0.13)
        b = sprout(pose, bh)
        b, bp = with_shadow(b, max(6, bh // 30), opacity=70, offset=(0, bh // 30))
        bx = W - b.width + bp - int(W * 0.01) if side == 'right' else int(W * 0.01) - bp
        by = H - bh - int(H * 0.025) - bp
        canvas.alpha_composite(b, (bx, by))
    return canvas.convert('RGB')


def load_raw(dev, loc, screen):
    path = RAW / dev / f'{loc}_{screen}.png'
    if not path.exists():
        return None
    raw = Image.open(path).convert('RGB')
    if screen == '03_scan':
        raw = scan_scene(raw, dev)
    return raw


def make_frames(locales=LOCALES):
    made, missing = 0, []
    for slot, (dev, *_rest) in SLOTS.items():
        for loc in locales:
            out = HERE / slot / loc
            out.mkdir(parents=True, exist_ok=True)
            for screen in SCREENS:
                raw = load_raw(dev, loc, screen)
                if raw is None:
                    missing.append(f'{dev}/{loc}_{screen}')
                    continue
                img = frame(raw, CAPS[loc][screen], loc, slot, screen)
                assert img.size == SLOTS[slot][1]
                img.save(out / f'{screen}.png', optimize=True)
                made += 1
        print(slot, 'done', flush=True)
    print(f'framed {made}')
    if missing:
        raise SystemExit('missing raw shots:\n  ' + '\n  '.join(missing))
    if shrunk:
        raise SystemExit(f'captions shrunk below 70%: {shrunk}')


# ── Feature graphics (Play, 1024x500) ───────────────────────────────────────

def wordmark(px, ink):
    return fl.render_line('PlateSimple', *F_LATIN, px, ink)


def phone_tilt(raw_name, height, angle):
    raw = Image.open(RAW / 'phone' / raw_name).convert('RGB')
    w = int(height / (raw.height / raw.width + 2 * 0.024))
    dev = device(raw, w, 0.085, 0.024)
    dev = dev.rotate(angle, resample=Image.BICUBIC, expand=True)
    return with_shadow(dev, 14, opacity=110, offset=(0, 10))


def feature_A():
    """Linen table: icon + wordmark + tagline left, the Today screen on a
    tilted phone over the plate, Sprout cheering. Works with today's icon."""
    W, H = 1024, 500
    c = ground((W, H), 'linen', 'fa')
    c = plate(c, 800, 250, 250)
    c = confetti(c, 11, n=14, keep_out=(40, 60, 540, 420), scale=0.9)
    ph, pad = phone_tilt('en_01_today.png', 600, -7)
    c.alpha_composite(ph, (800 - ph.width // 2, 64 - pad))
    icon = Image.open(REPO / 'assets' / 'icon' / 'icon.png').convert('RGBA').resize((112, 112), Image.LANCZOS)
    m = Image.new('L', icon.size, 0)
    ImageDraw.Draw(m).rounded_rectangle((0, 0, 111, 111), radius=26, fill=255)
    icon.putalpha(m)
    icon, ip = with_shadow(icon, 8, opacity=60, offset=(0, 5))
    c.alpha_composite(icon, (64 - ip, 96 - ip))
    wm = wordmark(70, INK)
    c.alpha_composite(wm, (58, 228))
    tag = fl.render_line('Calories & macros, simply.', *F_LATIN_MED, 32, HERB)
    c.alpha_composite(tag, (62, 318))
    sp = sprout('celebrate', 136)
    sp, sp_pad = with_shadow(sp, 6, opacity=60, offset=(0, 5))
    c.alpha_composite(sp, (590 - sp_pad, 346 - sp_pad))
    return c.convert('RGB')


def feature_B():
    """Herb green: big Sprout on the plate, wordmark left."""
    W, H = 1024, 500
    c = ground((W, H), 'herb', 'fb')
    c = confetti(c, 21, n=16, keep_out=(40, 150, 560, 360), scale=0.9)
    c = plate(c, 800, 250, 190)
    sp = sprout('happy', 220)
    sp, p = with_shadow(sp, 8, opacity=60, offset=(0, 6))
    c.alpha_composite(sp, (800 - sp.width // 2, 250 - sp.height // 2 - 6))
    wm = wordmark(76, WHITE)
    wm, wp = with_shadow(wm, 5, opacity=60, offset=(0, 3))
    c.alpha_composite(wm, (60 - wp, 172 - wp))
    tag = fl.render_line('Track calories & macros', *F_LATIN_MED, 36, (225, 245, 232))
    c.alpha_composite(tag, (66, 280))
    return c.convert('RGB')


def feature_C():
    """Three phones fanned on linen: history, Today, dark; wordmark on top."""
    W, H = 1024, 500
    c = ground((W, H), 'linen', 'fc')
    c = plate(c, 512, 560, 380)
    c = confetti(c, 31, n=14, keep_out=(200, 20, 824, 130), scale=0.9)
    wm = wordmark(64, INK)
    c.alpha_composite(wm, ((W - wm.width) // 2, 28))
    for name, x, ang, h in [('en_07_history.png', 300, 7, 420), ('en_08_dark.png', 724, -7, 420),
                            ('en_01_today.png', 512, 0, 460)]:
        ph, pad = phone_tilt(name, h, ang)
        c.alpha_composite(ph, (x - ph.width // 2, 128 - pad))
    sp = sprout('celebrate', 120)
    c.alpha_composite(sp, (850, 360))
    return c.convert('RGB')


def make_features():
    out = HERE / 'feature_graphic'
    out.mkdir(exist_ok=True)
    for name, fn in [('A', feature_A), ('B', feature_B), ('C', feature_C)]:
        img = fn()
        assert img.size == (1024, 500) and img.mode == 'RGB'
        img.save(out / f'feature_{name}.png', optimize=True)
    print('feature graphics 3')


# ── Overview ─────────────────────────────────────────────────────────────────

def label(img, text, px=28, color=(70, 60, 50)):
    line = fl.render_line(text, *F_LATIN, px, color)
    img.alpha_composite(line, (8, 4))


def make_overview():
    """Every English slot in full, then the Play phone set in every language,
    then the feature graphics."""
    th = 520
    rows = []
    for slot in SLOTS:
        rows.append((f'{slot}  en', [HERE / slot / 'en' / f'{s}.png' for s in SCREENS]))
    for loc in LOCALES[1:]:
        rows.append((f'play_phone  {loc}', [HERE / 'play_phone' / loc / f'{s}.png' for s in SCREENS]))
    gap, head = 14, 44
    thumbs = []
    for title, files in rows:
        ims = [Image.open(f).convert('RGB') for f in files]
        ims = [i.resize((int(i.width * th / i.height), th), Image.LANCZOS) for i in ims]
        thumbs.append((title, ims))
    feats = sorted((HERE / 'feature_graphic').glob('feature_*.png'))
    fw = 600
    fh = int(fw * 500 / 1024)
    W = max(sum(i.width + gap for i in ims) for _, ims in thumbs) + gap
    W = max(W, 3 * (fw + gap) + gap)
    H = len(thumbs) * (th + head + gap) + (fh + head + gap) + gap
    sheet = Image.new('RGBA', (W, H), (228, 220, 205, 255))
    y = gap
    for title, ims in thumbs:
        label_img = Image.new('RGBA', (W, head), (0, 0, 0, 0))
        label(label_img, title)
        sheet.alpha_composite(label_img, (gap, y))
        x = gap
        for im in ims:
            sheet.paste(im, (x, y + head))
            x += im.width + gap
        y += th + head + gap
    label_img = Image.new('RGBA', (W, head), (0, 0, 0, 0))
    label(label_img, 'feature graphic  A / B / C')
    sheet.alpha_composite(label_img, (gap, y))
    for i, f in enumerate(feats[:3]):
        sheet.paste(Image.open(f).convert('RGB').resize((fw, fh), Image.LANCZOS),
                    (gap + i * (fw + gap), y + head))
    sheet.convert('RGB').save(HERE / 'overview.png', optimize=True)
    print('overview', sheet.size)


if __name__ == '__main__':
    args = sys.argv[1:]
    locs = [a[4:] for a in args if a.startswith('loc=')]
    what = {a for a in args if not a.startswith('loc=')} or {'frames', 'feature', 'overview'}
    if 'frames' in what:
        make_frames(locs[0].split(',') if locs else LOCALES)
    if 'feature' in what:
        make_features()
    if 'overview' in what:
        make_overview()
