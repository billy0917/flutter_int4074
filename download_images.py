import os
from io import BytesIO
from urllib import request

from PIL import Image, ImageDraw, ImageFont

OUT_DIR = "assets/images/vocab"
CARD_SIZE = 300
ICON_BASE_URL = "https://cdnjs.cloudflare.com/ajax/libs/twemoji/14.0.2/72x72"

CATEGORY_STYLES = {
    "greetings": {"start": "#FFE0B5", "end": "#FFB874", "accent": "#FFF4E2"},
    "restaurant": {"start": "#FFD8C2", "end": "#FF9B73", "accent": "#FFF1E8"},
    "school": {"start": "#D5ECFF", "end": "#7CB8FF", "accent": "#EEF7FF"},
    "shopping": {"start": "#FFE0EA", "end": "#FF98B8", "accent": "#FFF0F5"},
    "transport": {"start": "#D8F4F4", "end": "#6CC5C8", "accent": "#EEFDFC"},
    "hospital": {"start": "#DDF7E4", "end": "#7BC99A", "accent": "#F1FFF5"},
    "home_life": {"start": "#FFE8CF", "end": "#D9A66E", "accent": "#FFF5EA"},
    "weather": {"start": "#D9F4FF", "end": "#7CC9FF", "accent": "#F0FBFF"},
}

VOCAB = [
    ("hello", "你好", "Hello", "greetings", ["1f44b"]),
    ("good_morning", "早上好", "Good morning", "greetings", ["1f305"]),
    ("good_evening", "晚上好", "Good evening", "greetings", ["1f306"]),
    ("goodbye", "再見", "Goodbye", "greetings", ["1f44b", "1f6aa"]),
    ("thank_you", "謝謝", "Thank you", "greetings", ["1f64f"]),
    ("welcome", "不客氣", "You're welcome", "greetings", ["1f91d"]),
    ("sorry", "對不起", "Sorry", "greetings", ["1f647"]),
    ("its_okay", "沒關係", "It's okay", "greetings", ["1f44d"]),
    ("chopsticks", "筷子", "Chopsticks", "restaurant", ["1f962"]),
    ("order_food", "點菜", "Order food", "restaurant", ["1f37d"]),
    ("pay_bill", "買單", "Pay the bill", "restaurant", ["1f9fe", "1f4b3"]),
    ("waiter", "服務員", "Waiter", "restaurant", ["1f6ce"]),
    ("menu", "菜單", "Menu", "restaurant", ["1f4d6"]),
    ("delicious", "好吃", "Delicious", "restaurant", ["1f60b"]),
    ("rice", "米飯", "Rice", "restaurant", ["1f35a"]),
    ("drink", "飲料", "Drink", "restaurant", ["1f964"]),
    ("textbook", "課本", "Textbook", "school", ["1f4d8"]),
    ("playground", "操場", "Playground", "school", ["26bd"]),
    ("exam", "考試", "Exam", "school", ["1f4dd"]),
    ("classmate", "同學", "Classmate", "school", ["1f465"]),
    ("teacher", "老師", "Teacher", "school", ["1f469-200d-1f3eb"]),
    ("homework", "作業", "Homework", "school", ["270d-fe0f"]),
    ("classroom", "教室", "Classroom", "school", ["1f3eb"]),
    ("library", "圖書館", "Library", "school", ["1f4da"]),
    ("cashier", "收銀台", "Cashier", "shopping", ["1f4b3"]),
    ("discount", "打折", "Discount", "shopping", ["1f3f7-fe0f"]),
    ("shopping_cart", "購物車", "Shopping cart", "shopping", ["1f6d2"]),
    ("snacks", "零食", "Snacks", "shopping", ["1f37f"]),
    ("how_much", "多少錢", "How much?", "shopping", ["2753", "1f4b0"]),
    ("expensive", "太貴了", "Too expensive", "shopping", ["1f4b8"]),
    ("cheap", "便宜", "Cheap", "shopping", ["1f4b5"]),
    ("change_money", "找錢", "Change (money)", "shopping", ["1f4b1"]),
    ("subway", "地鐵", "Subway", "transport", ["1f687"]),
    ("bus_transport", "公交車", "Bus", "transport", ["1f68c"]),
    ("traffic_light", "紅綠燈", "Traffic light", "transport", ["1f6a6"]),
    ("crosswalk", "斑馬線", "Crosswalk", "transport", ["1f6b6"]),
    ("taxi", "出租車", "Taxi", "transport", ["1f695"]),
    ("train_station", "火車站", "Train station", "transport", ["1f689"]),
    ("airport", "飛機場", "Airport", "transport", ["1f6eb"]),
    ("parking", "停車場", "Parking lot", "transport", ["1f17f-fe0f"]),
    ("register_hospital", "掛號", "Register", "hospital", ["1f3e5", "1f4dd"]),
    ("body_temp", "體溫", "Temperature", "hospital", ["1f321-fe0f"]),
    ("pharmacy", "藥房", "Pharmacy", "hospital", ["1f48a"]),
    ("doctor", "醫生", "Doctor", "hospital", ["1fa7a"]),
    ("cold_illness", "感冒", "Cold (illness)", "hospital", ["1f927"]),
    ("headache", "頭疼", "Headache", "hospital", ["1f635"]),
    ("take_medicine", "吃藥", "Take medicine", "hospital", ["1f48a", "1f964"]),
    ("nurse", "護士", "Nurse", "hospital", ["1f489"]),
    ("wash_dishes", "洗碗", "Wash dishes", "home_life", ["1f9fd", "1f37d"]),
    ("vacuum", "吸塵器", "Vacuum cleaner", "home_life", ["1f9f9"]),
    ("remote", "遙控器", "Remote control", "home_life", ["1f4fa"]),
    ("wardrobe", "衣櫃", "Wardrobe", "home_life", ["1f455"]),
    ("washing_machine", "洗衣機", "Washing machine", "home_life", ["1f455", "1f4a7"]),
    ("fridge", "冰箱", "Fridge", "home_life", ["1f9ca"]),
    ("sofa", "沙發", "Sofa", "home_life", ["1f6cb-fe0f"]),
    ("window", "窗戶", "Window", "home_life", ["1fa9f"]),
    ("storm", "暴風雨", "Storm", "weather", ["26c8-fe0f"]),
    ("rainbow", "彩虹", "Rainbow", "weather", ["1f308"]),
    ("thermometer", "溫度", "Temperature", "weather", ["1f321-fe0f"]),
    ("smog", "霧霾", "Smog", "weather", ["1f32b-fe0f"]),
    ("raining", "下雨", "Raining", "weather", ["1f327-fe0f"]),
    ("windy", "颳風", "Windy", "weather", ["1f32c-fe0f"]),
    ("sunny", "晴天", "Sunny day", "weather", ["2600-fe0f"]),
    ("snowing", "下雪", "Snowing", "weather", ["1f328-fe0f"]),
]

ICON_CACHE = {}


def hex_to_rgb(value):
    value = value.lstrip("#")
    return tuple(int(value[index:index + 2], 16) for index in (0, 2, 4))


def find_font_path(names):
    windir = os.environ.get("WINDIR", r"C:\Windows")
    for name in names:
        candidate = os.path.join(windir, "Fonts", name)
        if os.path.exists(candidate):
            return candidate
        if os.path.exists(name):
            return name
    return None


def load_font(size, bold=False):
    candidates = ["msyhbd.ttc", "msyh.ttc", "seguiemj.ttf", "arialbd.ttf", "arial.ttf"]
    if not bold:
        candidates = ["msyh.ttc", "msyhbd.ttc", "segoeui.ttf", "arial.ttf"]
    font_path = find_font_path(candidates)
    if font_path:
        return ImageFont.truetype(font_path, size=size)
    return ImageFont.load_default()


def text_width(draw, text, font):
    left, _, right, _ = draw.textbbox((0, 0), text, font=font)
    return right - left


def wrap_english_text(draw, text, max_width):
    size = 20
    while size >= 15:
        font = load_font(size)
        words = text.split()
        lines = []
        current = ""
        for word in words:
            trial = word if not current else f"{current} {word}"
            if text_width(draw, trial, font) <= max_width:
                current = trial
            else:
                if current:
                    lines.append(current)
                current = word
        if current:
            lines.append(current)
        if len(lines) <= 2 and all(text_width(draw, line, font) <= max_width for line in lines):
            return lines, font
        size -= 1
    return [text], load_font(15)


def build_background(style):
    start = hex_to_rgb(style["start"])
    end = hex_to_rgb(style["end"])
    image = Image.new("RGBA", (CARD_SIZE, CARD_SIZE))
    draw = ImageDraw.Draw(image)
    for y in range(CARD_SIZE):
        ratio = y / (CARD_SIZE - 1)
        color = tuple(int(start[i] * (1 - ratio) + end[i] * ratio) for i in range(3))
        draw.line((0, y, CARD_SIZE, y), fill=color + (255,))

    accent = hex_to_rgb(style["accent"])
    draw.ellipse((168, -16, 332, 148), fill=accent + (74,))
    draw.ellipse((-48, 112, 108, 268), fill=(255, 255, 255, 52))
    draw.rounded_rectangle((18, 210, 282, 284), radius=28, fill=(255, 255, 255, 214))
    return image


def download_icon(code):
    key = code.lower()
    cached = ICON_CACHE.get(key)
    if cached is not None:
        return cached.copy()

    candidates = [key]
    if "-fe0f" in key:
        candidates.append(key.replace("-fe0f", ""))

    last_error = None
    for candidate in candidates:
        url = f"{ICON_BASE_URL}/{candidate}.png"
        req = request.Request(url, headers={"User-Agent": "PinPinGoAssetBuilder/1.0"})
        try:
            with request.urlopen(req, timeout=20) as response:
                data = response.read()
            icon = Image.open(BytesIO(data)).convert("RGBA")
            ICON_CACHE[key] = icon
            return icon.copy()
        except Exception as exc:
            last_error = exc

    raise RuntimeError(f"Unable to download icon '{code}': {last_error}")


def placeholder_icon(label):
    tile = Image.new("RGBA", (120, 120), (255, 255, 255, 0))
    draw = ImageDraw.Draw(tile)
    draw.ellipse((6, 6, 114, 114), fill=(255, 255, 255, 235))
    font = load_font(58, bold=True)
    letter = label[:1].upper()
    bbox = draw.textbbox((0, 0), letter, font=font)
    width = bbox[2] - bbox[0]
    height = bbox[3] - bbox[1]
    draw.text(((120 - width) / 2, (120 - height) / 2 - 4), letter, fill=(56, 72, 96), font=font)
    return tile


def paste_icons(card, english, icon_codes):
    icons = []
    for code in icon_codes:
        try:
            icons.append(download_icon(code))
        except Exception:
            continue

    if not icons:
        icons = [placeholder_icon(english)]

    if len(icons) == 1:
        size = 144
        positions = [(CARD_SIZE // 2 - size // 2, 48)]
    elif len(icons) == 2:
        size = 108
        positions = [(42, 66), (CARD_SIZE - 42 - size, 66)]
    else:
        size = 90
        positions = [(28, 78), (CARD_SIZE // 2 - size // 2, 48), (CARD_SIZE - 28 - size, 78)]
        icons = icons[:3]

    for icon, (x, y) in zip(icons, positions):
        scaled = icon.resize((size, size), Image.LANCZOS)
        card.alpha_composite(scaled, (x, y))


def draw_labels(card, chinese, english):
    draw = ImageDraw.Draw(card)
    chinese_font = load_font(36, bold=True)
    chinese_bbox = draw.textbbox((0, 0), chinese, font=chinese_font)
    chinese_width = chinese_bbox[2] - chinese_bbox[0]
    draw.text(((CARD_SIZE - chinese_width) / 2, 218), chinese, fill=(39, 56, 74), font=chinese_font)

    lines, english_font = wrap_english_text(draw, english, 228)
    y = 255 if len(lines) == 1 else 247
    for line in lines:
        bbox = draw.textbbox((0, 0), line, font=english_font)
        width = bbox[2] - bbox[0]
        draw.text(((CARD_SIZE - width) / 2, y), line, fill=(86, 102, 120), font=english_font)
        y += 19


def build_card(chinese, english, category, icon_codes):
    style = CATEGORY_STYLES[category]
    card = build_background(style)
    paste_icons(card, english, icon_codes)
    draw_labels(card, chinese, english)
    return card.convert("RGB")


def main():
    os.makedirs(OUT_DIR, exist_ok=True)
    success = 0
    fail = 0
    total = len(VOCAB)

    for index, (name, chinese, english, category, icon_codes) in enumerate(VOCAB, start=1):
        out_path = os.path.join(OUT_DIR, f"{name}.jpg")
        try:
            card = build_card(chinese, english, category, icon_codes)
            card.save(out_path, format="JPEG", quality=94)
            size = os.path.getsize(out_path)
            print(f"[{index}/{total}] OK: {name}.jpg ({size} bytes) <- {english}")
            success += 1
        except Exception as exc:
            print(f"[{index}/{total}] FAIL: {name} - {exc}")
            fail += 1

    print(f"\nDone: {success} success, {fail} failed out of {total} total")


if __name__ == "__main__":
    main()
