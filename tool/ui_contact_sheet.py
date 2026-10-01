"""Contact sheet of the UI screenshot harness.

    flutter test --dart-define=UI_SHOTS=true test/ui_shots_test.dart
    PYTHONIOENCODING=utf-8 python tool/ui_contact_sheet.py [pattern] [out.png]

Reads build/ui_shots/*.png and tiles them (light and dark side by side when
both exist) into docs/ui_revamp/overview.png, captioned with the shot name.
"""
import glob
import os
import sys

from PIL import Image, ImageDraw, ImageFont

SRC = "build/ui_shots"
pattern = sys.argv[1] if len(sys.argv) > 1 else "*"
OUT = sys.argv[2] if len(sys.argv) > 2 else "docs/ui_revamp/overview.png"
THUMB_W = 300
COLS = 6
PAD = 18
CAPTION = 30
BG = (246, 241, 231)
INK = (43, 38, 32)


def font(size):
    for name in ("C:/Windows/Fonts/seguisb.ttf", "C:/Windows/Fonts/arial.ttf"):
        if os.path.exists(name):
            return ImageFont.truetype(name, size)
    return ImageFont.load_default()


paths = sorted(glob.glob(os.path.join(SRC, pattern + ".png")))
if not paths:
    sys.exit(f"no shots matching {pattern!r} in {SRC}")

thumbs = []
for p in paths:
    im = Image.open(p).convert("RGB")
    h = round(im.height * THUMB_W / im.width)
    thumbs.append((os.path.basename(p)[:-4], im.resize((THUMB_W, h), Image.LANCZOS)))

cell_h = max(t.height for _, t in thumbs) + CAPTION
rows = (len(thumbs) + COLS - 1) // COLS
title_h = 70
sheet = Image.new(
    "RGB",
    (COLS * (THUMB_W + PAD) + PAD, title_h + rows * (cell_h + PAD) + PAD),
    BG,
)
draw = ImageDraw.Draw(sheet)
draw.text((PAD, 18), "PlateSimple UI revamp - Kitchen table", fill=INK, font=font(30))
small = font(17)
for i, (name, im) in enumerate(thumbs):
    r, c = divmod(i, COLS)
    x = PAD + c * (THUMB_W + PAD)
    y = title_h + r * (cell_h + PAD)
    sheet.paste(im, (x, y))
    draw.text((x + 2, y + im.height + 5), name, fill=INK, font=small)

os.makedirs(os.path.dirname(OUT), exist_ok=True)
sheet.save(OUT, optimize=True)
print(f"wrote {OUT} ({len(thumbs)} shots, {sheet.width}x{sheet.height})")
