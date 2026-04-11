"""
Generate phrase audio files using edge-tts (Microsoft Edge TTS).

Usage:
    pip install edge-tts
    python generate_phrase_audio.py

Outputs MP3 files to assets/audio/phrases/<category_id>_<index>.mp3
"""

import asyncio
import os
import edge_tts

# zh-CN-XiaoxiaoNeural: female, natural
# zh-CN-YunxiNeural: male, natural
VOICE = "zh-CN-XiaoxiaoNeural"
RATE = "-10%"  # slightly slower for learners
OUTPUT_DIR = os.path.join(os.path.dirname(__file__), "assets", "audio", "phrases")

# All phrase categories and their Chinese text (matching phrase_data.dart)
PHRASES = {
    "greetings": [
        "你好", "早上好", "晚上好", "再見", "謝謝", "不客氣", "對不起", "沒關係",
    ],
    "restaurant": [
        "筷子", "點菜", "買單", "服務員", "菜單", "好吃", "米飯", "飲料",
    ],
    "school": [
        "課本", "操場", "考試", "同學", "老師", "作業", "教室", "圖書館",
    ],
    "shopping": [
        "收銀台", "打折", "購物車", "零食", "多少錢", "太貴了", "便宜", "找錢",
    ],
    "transport": [
        "地鐵", "公交車", "紅綠燈", "斑馬線", "出租車", "火車站", "飛機場", "停車場",
    ],
    "hospital": [
        "掛號", "體溫", "藥房", "醫生", "感冒", "頭疼", "吃藥", "護士",
    ],
    "home_life": [
        "洗碗", "吸塵器", "遙控器", "衣櫃", "洗衣機", "冰箱", "沙發", "窗戶",
    ],
    "weather": [
        "暴風雨", "彩虹", "溫度", "霧霾", "下雨", "颳風", "晴天", "下雪",
    ],
}


async def generate_all():
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    tasks = []
    for category, phrases in PHRASES.items():
        for i, text in enumerate(phrases):
            filename = f"{category}_{i}.mp3"
            filepath = os.path.join(OUTPUT_DIR, filename)
            tasks.append((text, filepath, filename))

    total = len(tasks)
    for idx, (text, filepath, filename) in enumerate(tasks, 1):
        print(f"[{idx}/{total}] Generating {filename} — \"{text}\"")
        communicate = edge_tts.Communicate(text, VOICE, rate=RATE)
        await communicate.save(filepath)

    print(f"\nDone! Generated {total} audio files in {OUTPUT_DIR}")


if __name__ == "__main__":
    asyncio.run(generate_all())
