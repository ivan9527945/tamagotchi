#!/usr/bin/env python3
"""
Trump Tamagotchi — Character Animated GIF Generator
去背 + 製作 idle 彈跳動圖（透明背景 APNG/GIF）
"""

import os
from pathlib import Path
from PIL import Image
import numpy as np

try:
    from rembg import remove
    HAS_REMBG = True
except ImportError:
    HAS_REMBG = False
    print("Warning: rembg not found, using fallback background removal")

# ── 路徑設定 ──────────────────────────────────────────────
DESIGN_DIR = Path(__file__).parent
IMAGES_DIR = DESIGN_DIR / "images"
OUTPUT_DIR = DESIGN_DIR / "characters"
OUTPUT_DIR.mkdir(exist_ok=True)

# ── 角色清單 ──────────────────────────────────────────────
CHARACTERS = [
    ("baby_donald",       "generated-1774266028083.png", "🍼 Baby Donald"),
    ("queens_kid",        "generated-1774266173772.png", "👦 Queens Kid"),
    ("military_cadet",    "generated-1774266195420.png", "🎖️ Military Cadet"),
    ("wharton_boy",       "generated-1774266224912.png", "🎓 Wharton Boy"),
    ("daddys_apprentice", "generated-1774266257522.png", "💼 Daddy's Apprentice"),
    ("manhattan_mogul",   "generated-1774266281565.png", "🏙️ Manhattan Mogul"),
    ("casino_king",       "generated-1774266302036.png", "🎰 Casino King"),
    ("tv_star",           "generated-1774266326015.png", "📺 TV Star"),
    ("candidate",         "generated-1774266361933.png", "🇺🇸 Candidate"),
    ("the_president",     "generated-1774266393510.png", "👑 THE PRESIDENT"),
]

# ── 動畫參數 ──────────────────────────────────────────────
TARGET_SIZE = (300, 300)   # 輸出尺寸
FPS = 12                   # 每秒幀數
BOUNCE_PX = 8              # 彈跳幅度（像素）
BOUNCE_FRAMES = 16         # 一個循環的幀數
FRAME_DURATION = int(1000 / FPS)  # ms per frame


def remove_background(img: Image.Image) -> Image.Image:
    """使用 rembg AI 去背"""
    if HAS_REMBG:
        return remove(img)
    # Fallback: 簡單角落取樣去背
    return remove_background_fallback(img)


def remove_background_fallback(img: Image.Image) -> Image.Image:
    """Fallback: 取四角平均色作為背景色，tolerance 去除"""
    img = img.convert("RGBA")
    arr = np.array(img)
    # 取四角 5x5 平均作為背景色
    corners = np.concatenate([
        arr[:5, :5].reshape(-1, 4),
        arr[:5, -5:].reshape(-1, 4),
        arr[-5:, :5].reshape(-1, 4),
        arr[-5:, -5:].reshape(-1, 4),
    ])
    bg_color = corners[:, :3].mean(axis=0)
    # 計算每像素與背景的 L2 距離
    diff = np.linalg.norm(arr[:, :, :3].astype(float) - bg_color, axis=2)
    # tolerance 越高 → 去除更多背景
    mask = diff < 60
    arr[mask, 3] = 0  # 透明化
    return Image.fromarray(arr)


def make_bounce_frames(img: Image.Image, n_frames: int, bounce_px: int) -> list[Image.Image]:
    """
    製作彈跳動畫幀：
    - 正弦曲線 Y 位移（上下浮動）
    - 輕微縮放（落地壓縮感）
    """
    frames = []
    w, h = img.size
    canvas_h = h + bounce_px * 2

    for i in range(n_frames):
        t = i / n_frames  # 0.0 → 1.0
        # 正弦彈跳 (0 = 最高點, 0.5 = 最低點)
        phase = np.sin(t * 2 * np.pi)  # -1 → +1
        offset_y = int(-phase * bounce_px)          # 向上為負
        scale_y  = 1.0 - abs(phase) * 0.03          # 落地微縮

        # 輕微縮放
        new_h = max(1, int(h * scale_y))
        scaled = img.resize((w, new_h), Image.LANCZOS)

        # 貼到透明畫布
        canvas = Image.new("RGBA", (w, canvas_h), (0, 0, 0, 0))
        paste_y = (canvas_h - new_h) + offset_y - bounce_px
        canvas.paste(scaled, (0, paste_y), scaled)
        frames.append(canvas)

    return frames


def process_character(key: str, filename: str, label: str):
    src = IMAGES_DIR / filename
    if not src.exists():
        print(f"  ✗ 找不到 {filename}")
        return

    print(f"  處理 {label}...", end=" ", flush=True)

    # 1. 載入 & 去背
    raw = Image.open(src).convert("RGBA")
    nobg = remove_background(raw)

    # 2. 裁切透明邊緣
    bbox = nobg.getbbox()
    if bbox:
        nobg = nobg.crop(bbox)

    # 3. 等比縮放至目標尺寸
    nobg.thumbnail(TARGET_SIZE, Image.LANCZOS)

    # 4. 置中到正方形畫布
    canvas = Image.new("RGBA", TARGET_SIZE, (0, 0, 0, 0))
    x = (TARGET_SIZE[0] - nobg.width) // 2
    y = (TARGET_SIZE[1] - nobg.height) // 2
    canvas.paste(nobg, (x, y), nobg)

    # 5. 儲存靜態去背 PNG（供 app 直接用）
    png_path = OUTPUT_DIR / f"{key}.png"
    canvas.save(png_path, "PNG")

    # 6. 製作彈跳動畫幀
    frames = make_bounce_frames(canvas, BOUNCE_FRAMES, BOUNCE_PX)

    # 7. 儲存 GIF（透明背景）
    gif_path = OUTPUT_DIR / f"{key}.gif"
    frames[0].save(
        gif_path,
        save_all=True,
        append_images=frames[1:],
        optimize=False,
        loop=0,
        duration=FRAME_DURATION,
        disposal=2,       # 每幀前清除 → 保持透明背景
    )

    size_kb = gif_path.stat().st_size // 1024
    print(f"✓  → {key}.gif ({size_kb}KB)")


def main():
    print(f"\n🎬 Trump Tamagotchi — 角色動圖生成器")
    print(f"   輸出目錄: {OUTPUT_DIR}\n")

    for key, filename, label in CHARACTERS:
        process_character(key, filename, label)

    print(f"\n✅ 完成！共 {len(CHARACTERS)} 個角色")
    print(f"   靜態 PNG：{key}.png  (去背，供 UI 直接使用)")
    print(f"   動態 GIF：{key}.gif  (透明背景 idle 彈跳動畫)")
    print(f"\n   對照 TRUMP_GAME_DESIGN.md 的 character_key 即可 import。")


if __name__ == "__main__":
    main()
