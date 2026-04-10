import math
from PIL import Image, ImageDraw, ImageFont

SIZE = 1024
img = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))

# --- Rounded rectangle mask ---
mask = Image.new("L", (SIZE, SIZE), 0)
md = ImageDraw.Draw(mask)
r = 220
md.rounded_rectangle([0, 0, SIZE - 1, SIZE - 1], radius=r, fill=255)

# --- Gradient background (pink) ---
bg = Image.new("RGBA", (SIZE, SIZE))
for y in range(SIZE):
    t = y / SIZE
    red   = int(255 * (1 - t) + 255 * t)
    green = int(100 * (1 - t) + 160 * t)
    blue  = int(120 * (1 - t) + 210 * t)
    for x in range(SIZE):
        bg.putpixel((x, y), (red, green, blue, 255))

img.paste(bg, mask=mask)

d = ImageDraw.Draw(img)

# --- White book rectangle ---
d.rectangle([170, 270, 854, 770], fill=(255, 255, 255, 235))
# Book spine
d.line([(512, 270), (512, 770)], fill=(255, 100, 135, 160), width=18)

# --- Gold 5-point star ---
cx, cy, outer_r, inner_r = 512, 550, 155, 65
star_pts = []
for i in range(10):
    angle = i * math.pi / 5 - math.pi / 2
    r = outer_r if i % 2 == 0 else inner_r
    star_pts.append((cx + r * math.cos(angle), cy + r * math.sin(angle)))
d.polygon(star_pts, fill=(255, 210, 0, 255))

# --- Text ---
try:
    font_big  = ImageFont.truetype("arialbd.ttf", 155)
    font_num  = ImageFont.truetype("arialbd.ttf", 145)
except OSError:
    font_big  = ImageFont.load_default()
    font_num  = font_big

# "INT" at top
d.text((SIZE // 2, 130), "INT",  font=font_big, fill=(255, 255, 255, 255), anchor="mm")
# "4074" at bottom
d.text((SIZE // 2, 890), "4074", font=font_num, fill=(255, 255, 255, 255), anchor="mm")

img.save("assets/app_icon.png")
print("Icon saved to assets/app_icon.png")
