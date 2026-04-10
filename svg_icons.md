# SVG 圖示說明文件

本專案使用 `flutter_svg ^2.0.10+1` 套件渲染所有 SVG 圖示，取代原先以 Unicode Emoji 字元顯示的圖示。

- **圖示來源**：[Lucide Icons](https://lucide.dev/)（ISC 開源授權，v1.7.0）
- **底部導覽列拍照圖示**：保留自訂 SVG（點擊後變白色）
- 所有圖示檔案存放於 `assets/icons/`，透過 `lib/utils/app_icons.dart` 中的 `AppIcons` 類別統一管理。

---

## 目錄結構

```
assets/
└── icons/
    ├── fire.svg
    ├── star.svg
    ├── star_outline.svg
    ├── book.svg
    ├── camera.svg
    ├── chat.svg
    ├── scroll.svg
    ├── rocket.svg
    ├── chick_hatching.svg
    ├── chick.svg
    ├── fox.svg
    ├── lion.svg
    ├── dragon.svg
    ├── sparkle.svg
    ├── crown.svg
    ├── wave.svg
    ├── burger.svg
    ├── school.svg
    ├── cart.svg
    ├── bus.svg
    ├── hospital.svg
    ├── house.svg
    ├── weather.svg
    ├── party.svg
    ├── thumbsup.svg
    ├── flex.svg
    ├── refresh.svg
    ├── pencil.svg
    ├── globe.svg
    ├── speaker.svg
    ├── music.svg
    ├── home.svg
    ├── history.svg
    ├── trash.svg
    ├── info.svg
    └── check.svg
```

---

## 圖示分類總覽

### 1. 統計數據（Stats）

| 常數名稱 | 檔案路徑 | Lucide 圖示名 | 取代的 Emoji | 用途說明 |
|---|---|---|---|---|
| `AppIcons.fire` | `assets/icons/fire.svg` | `flame` | 🔥 | 連續學習天數（streak）|
| `AppIcons.star` | `assets/icons/star.svg` | `star` | ⭐ | 已獲得的星星數（實心）|
| `AppIcons.starOutline` | `assets/icons/star_outline.svg` | `star-off` | ☆ | 未獲得的星星（空心）|
| `AppIcons.book` | `assets/icons/book.svg` | `book-open` | 📚 | 已學詞語數量 |

---

### 2. 功能入口（Features）

| 常數名稱 | 檔案路徑 | Lucide 圖示名 | 取代的 Emoji | 用途說明 |
|---|---|---|---|---|
| `AppIcons.camera` | `assets/icons/camera.svg` | **自訂（保留原版）** | 📷 / 📸 | 拍照辨識功能、空白頁提示 |
| `AppIcons.chat` | `assets/icons/chat.svg` | `message-circle` | 🗣️ | 日常短語學習入口 |
| `AppIcons.scroll` | `assets/icons/scroll.svg` | `scroll` | 📜 | 備用/卷軸效果 |
| `AppIcons.rocket` | `assets/icons/rocket.svg` | `rocket` | 🚀 | 辨識按鈕（開始辨識）|

---

### 3. 等級圖示（Levels）

等級圖示透過 `AppIcons.levelIcon(int level)` 方法取得對應路徑，再以 `AppIcons.svg()` 渲染。

| 常數名稱 | 檔案路徑 | Lucide 圖示名 | 取代的 Emoji | 對應等級 | 等級稱號 |
|---|---|---|---|---|---|
| `AppIcons.chickHatching` | `assets/icons/chick_hatching.svg` | `egg` | 🐣 | Lv. 1 | 小新手 |
| `AppIcons.chick` | `assets/icons/chick.svg` | `baby` | 🐥 | Lv. 2 | 小學生 |
| `AppIcons.fox` | `assets/icons/fox.svg` | `cat` | 🦊 | Lv. 3 | 小達人 |
| `AppIcons.lion` | `assets/icons/lion.svg` | `shield` | 🦁 | Lv. 4 | 詞語高手 |
| `AppIcons.dragon` | `assets/icons/dragon.svg` | `swords` | 🐉 | Lv. 5 | 語言大師 |
| `AppIcons.sparkle` | `assets/icons/sparkle.svg` | `sparkles` | 🌟 | Lv. 6 | 中文天才 |
| `AppIcons.crown` | `assets/icons/crown.svg` | `crown` | 👑 | Lv. 7 | 超級學霸 |

---

### 4. 短語分類（Phrase Categories）

分類圖示透過 `AppIcons.categoryIcon(String categoryId)` 方法取得，以 `category.iconPath` 欄位儲存於 `PhraseCategory` 模型中。

| 常數名稱 | 檔案路徑 | Lucide 圖示名 | 取代的 Emoji | 分類 ID | 分類名稱 |
|---|---|---|---|---|---|
| `AppIcons.wave` | `assets/icons/wave.svg` | `hand` | 👋 | `greetings` | 打招呼 |
| `AppIcons.burger` | `assets/icons/burger.svg` | `utensils` | 🍔 | `restaurant` | 餐廳與美食 |
| `AppIcons.school` | `assets/icons/school.svg` | `graduation-cap` | 🏫 | `school` | 校園生活 |
| `AppIcons.cart` | `assets/icons/cart.svg` | `shopping-cart` | 🛒 | `shopping` | 超市購物 |
| `AppIcons.bus` | `assets/icons/bus.svg` | `bus` | 🚌 | `transport` | 交通出行 |
| `AppIcons.hospital` | `assets/icons/hospital.svg` | `hospital` | 🏥 | `hospital` | 看病就醫 |
| `AppIcons.house` | `assets/icons/house.svg` | `house` | 🏠 | `home_life` | 家庭日常 |
| `AppIcons.weather` | `assets/icons/weather.svg` | `cloud-sun` | 🌦️ | `weather` | 天氣與自然 |

---

### 5. 練習回饋（Feedback）

回饋圖示透過 `AppIcons.feedbackIcon(double score)` 方法依分數取得對應路徑。

| 常數名稱 | 檔案路徑 | Lucide 圖示名 | 取代的 Emoji | 觸發條件 | 回饋含義 |
|---|---|---|---|---|---|
| `AppIcons.party` | `assets/icons/party.svg` | `party-popper` | 🎉 | 分數 ≥ 80 | 優秀！達到最高評級 |
| `AppIcons.thumbsup` | `assets/icons/thumbsup.svg` | `thumbs-up` | 👍 | 分數 60–79 | 良好，繼續加油 |
| `AppIcons.flex` | `assets/icons/flex.svg` | `biceps-flexed` | 💪 | 分數 30–59 | 再試一次，可以更好 |
| `AppIcons.refresh` | `assets/icons/refresh.svg` | `refresh-cw` | 🔄 | 分數 < 30 | 需要重新練習 |

---

### 6. 其他介面圖示（UI / Navigation）

| 常數名稱 | 檔案路徑 | Lucide 圖示名 | 取代的 Emoji | 使用位置 |
|---|---|---|---|---|
| `AppIcons.pencil` | `assets/icons/pencil.svg` | `pencil` | 📝 | 開始測驗按鈕、空白提示（短語歷史）|
| `AppIcons.globe` | `assets/icons/globe.svg` | `globe` | 🌐 | 設定頁：語言切換 |
| `AppIcons.speaker` | `assets/icons/speaker.svg` | `volume-2` | 🔊 | 設定頁：語速調整、試聽按鈕；測驗頁：播放發音 |
| `AppIcons.music` | `assets/icons/music.svg` | `music` | 🎵 | 啟動頁（Splash Screen）App Logo |
| `AppIcons.home` | `assets/icons/home.svg` | `home` | — | 底部導覽列：首頁分頁 |
| `AppIcons.history` | `assets/icons/history.svg` | `history` | — | 底部導覽列：記錄分頁 |
| `AppIcons.trash` | `assets/icons/trash.svg` | `trash-2` | 🗑️ | 設定頁：清除學習記錄 |
| `AppIcons.info` | `assets/icons/info.svg` | `info` | ℹ️ | 設定頁：關於 App |
| `AppIcons.check` | `assets/icons/check.svg` | `check` | — | 備用：確認/完成動作 |

---

## AppIcons 工具方法

定義於 `lib/utils/app_icons.dart`。

| 方法 | 簽名 | 說明 |
|---|---|---|
| `svg()` | `Widget svg(String assetPath, {double size, Color? color, BoxFit fit})` | 渲染單一 SVG 圖示為 Widget |
| `levelIcon()` | `String levelIcon(int level)` | 根據等級（1–7）回傳對應圖示的資產路徑 |
| `categoryIcon()` | `String categoryIcon(String categoryId)` | 根據短語分類 ID 回傳對應圖示路徑 |
| `feedbackIcon()` | `String feedbackIcon(double score)` | 根據練習分數（0–100）回傳回饋圖示路徑 |
| `starRow()` | `Widget starRow(int filledCount, {int maxStars, double size})` | 渲染一排星星（實心＋空心），取代 `GameConfig.starDisplay()` |

### 使用範例

```dart
// 渲染單一圖示
AppIcons.svg(AppIcons.fire, size: 24)

// 渲染有顏色的圖示
AppIcons.svg(AppIcons.star, size: 20, color: Color(0xFFFFD93D))

// 根據等級渲染對應圖示
AppIcons.svg(AppIcons.levelIcon(level.level), size: 28)

// 根據分類渲染對應圖示
AppIcons.svg(category.iconPath, size: 28)

// 渲染三顆星（2/3 實心）
AppIcons.starRow(2, maxStars: 3, size: 20)
```

---

## 模型欄位變更對照

| 類別 | 舊欄位名 | 新欄位名 | 類型 | 說明 |
|---|---|---|---|---|
| `GameLevel` | `emoji` | `iconPath` | `String` | 儲存 SVG 資產路徑 |
| `PhraseCategory` | `emoji` | `iconPath` | `String` | 儲存 SVG 資產路徑 |
| `FeatureCard` (Widget) | `emoji` | `icon` | `Widget` | 直接傳入渲染好的 Widget |

---

## 底部導覽列架構

原本的首頁（Camera Hero 卡片 + History 磚塊）已拆分為三個獨立分頁，透過 `MainShell` 管理。

| 分頁 | 圖示常數 | 來源 | 畫面 |
|---|---|---|---|
| 首頁 | `AppIcons.home` | Lucide `home` | `HomeScreen` |
| 拍照 | `AppIcons.camera`（特殊漸層圓形）| **自訂 SVG（點擊變白色）** | `CameraScreen` |
| 記錄 | `AppIcons.history` | Lucide `history` | `HistoryScreen` |
