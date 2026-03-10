# ✅ 需求確認完畢，以下是完整的開發 Prompt

---

## 📋 快速確認摘要

| 項目 | 決定 |
|------|------|
| 目標用戶 | 香港小朋友學普通話 |
| UI 風格 | 暖色系 Claymorphism |
| 語言 | 中英文切換 |
| 核心功能 | 拍照識物→學發音→測驗→歷史記錄 |
| AI API | apiplus.org 中轉站 (OpenAI格式) |
| TTS | 系統內建 flutter_tts |
| 畫聲調 | Canvas 手繪 + AI 判斷 |
| 儲存 | 本地 Hive |

---

## 🚀 以下是可直接使用的完整 Prompt

> 直接複製下方整段丟給 AI（Claude / GPT）即可開始開發 👇

---

```markdown
# Flutter 語言教育 APP 完整開發需求

## 一、項目概述

開發一款面向 **香港小朋友學習普通話（Mandarin）** 的 Flutter 教育 APP。
- 項目名稱：INT4074 Group Project
- APP 建議名稱：「拼拼樂 PinPin Go」（可在代碼中修改）
- 支持平台：iOS & Android
- 介面語言：繁體中文 / English 自由切換
- UI 風格：**暖色系 Claymorphism（粘土擬態）**
- 目標用戶：6-12 歲香港兒童

---

## 二、技術棧 & 依賴

```yaml
dependencies:
  flutter_localizations:
    sdk: flutter
  intl: ^0.19.0            # 國際化
  provider: ^6.1.0          # 狀態管理
  hive: ^2.2.3              # 本地數據庫
  hive_flutter: ^1.1.0
  image_picker: ^1.0.7      # 拍照/選圖
  http: ^1.2.0              # API 請求
  flutter_tts: ^3.8.5       # 文字轉語音
  path_provider: ^2.1.2
  uuid: ^4.3.3
  
dev_dependencies:
  hive_generator: ^2.0.1
  build_runner: ^2.4.8
```

---

## 三、設計系統 — Claymorphism（粘土擬態）

### 3.1 色彩系統（暖色調）

```dart
class AppColors {
  // 主色
  static const primary = Color(0xFFFF8C42);       // 暖橙色
  static const primaryLight = Color(0xFFFFAA6B);   // 淺橙
  static const secondary = Color(0xFFFF6B8A);      // 暖粉色
  
  // 背景
  static const background = Color(0xFFFFF5EB);     // 奶油色背景
  static const cardBg = Color(0xFFFFE8D6);          // 卡片底色（淡桃色）
  static const cardBgAlt = Color(0xFFFFF0E0);       // 備用卡片色
  
  // 功能色
  static const success = Color(0xFF7EC8A0);         // 柔綠（答對）
  static const error = Color(0xFFFF7979);           // 柔紅（答錯）
  static const star = Color(0xFFFFD93D);            // 星星金色
  
  // 文字
  static const textDark = Color(0xFF4A3728);        // 深棕（主文字）
  static const textMedium = Color(0xFF8B7355);      // 中棕（副文字）
  static const textLight = Color(0xFFBFA98E);       // 淺棕（提示文字）
  
  // 聲調專用色
  static const tone1 = Color(0xFFFF6B6B);  // 一聲 紅
  static const tone2 = Color(0xFF4ECDC4);  // 二聲 青
  static const tone3 = Color(0xFFFFBE0B);  // 三聲 金
  static const tone4 = Color(0xFF7B68EE);  // 四聲 紫
  static const toneLight = Color(0xFFCCCCCC); // 輕聲 灰
}
```

### 3.2 Claymorphism 核心組件

所有卡片、按鈕必須使用以下粘土風格 decoration：

```dart
/// 粘土風格容器 Decoration
BoxDecoration clayDecoration({
  Color color = AppColors.cardBg,
  double radius = 24,
  bool isPressed = false,
}) {
  return BoxDecoration(
    color: color,
    borderRadius: BorderRadius.circular(radius),
    boxShadow: isPressed
        ? [
            // 按下狀態：內凹效果
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              offset: const Offset(2, 2),
              blurRadius: 4,
              spreadRadius: -1,
            ),
          ]
        : [
            // 默認狀態：外凸效果（粘土凸起感）
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              offset: const Offset(4, 4),
              blurRadius: 8,
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.8),
              offset: const Offset(-3, -3),
              blurRadius: 6,
            ),
            // 底部加重陰影（粘土落在桌面的感覺）
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              offset: const Offset(0, 8),
              blurRadius: 16,
            ),
          ],
  );
}

/// 粘土風格按鈕（帶按壓動畫）
class ClayButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final Color color;
  final double width;
  final double height;
  // ... 實現按壓時縮小 + 陰影變化的動畫效果
}
```

### 3.3 字體 & 圓角

- **標題字體大小：** 28sp，加粗，圓潤字體
- **正文字體大小：** 16sp
- **拼音顯示：** 32sp，使用等寬或專用拼音字體
- **聲調數字：** 48sp 超大顯示
- **所有圓角：** 最小 16px，卡片建議 24px，按鈕 20px
- **所有圖標：** 使用圓潤風格，線條粗 2.5px

---

## 四、APP 頁面結構 & 導航

### 4.0 整體架構

```
App
├── SplashScreen（啟動頁，顯示 APP Logo 動畫 1.5s）
├── HomePage（主頁 ★ 核心頁面）
├── CameraScreen（拍照頁）
├── ResultScreen（辨識結果 & 學習頁）
├── QuizScreen（測驗頁）
│   ├── DrawToneQuiz（畫聲調測驗）
│   ├── MultipleChoiceQuiz（選擇題測驗）
│   └── QuizResultScreen（測驗結果頁）
├── HistoryScreen（歷史記錄頁）
├── HistoryDetailScreen（歷史詳情頁）
└── SettingsScreen（設定頁 — 語言切換等）
```

不使用底部導航欄（BottomNavigationBar），而是以主頁為中心的卡片式導航。

---

## 五、各頁面詳細設計

### 5.1 🏠 HomePage — 主頁

**佈局結構（由上到下）：**

```
┌─────────────────────────────────┐
│  頂部問候欄                       │
│  "Good Morning! ☀️"              │
│  "準備好學普通話了嗎？"             │
│  [⚙️ 設定按鈕 — 右上角]           │
├─────────────────────────────────┤
│                                  │
│  ┌─────────────────────────┐    │
│  │  🎯 今日學習統計卡片       │    │
│  │  已學 12 個詞  |  連續 3 天  │    │
│  └─────────────────────────┘    │
│                                  │
│  ── 主要功能 ──                   │
│                                  │
│  ┌────────┐  ┌────────┐         │
│  │ 📷     │  │ 📝     │         │
│  │ 拍一拍  │  │ 小測驗  │         │
│  │ Snap   │  │ Quiz   │         │
│  │ & Learn│  │ Time   │         │
│  └────────┘  └────────┘         │
│                                  │
│  ┌────────┐  ┌────────┐         │
│  │ 📜     │  │ ⭐     │         │
│  │ 歷史   │  │ 收藏夾  │         │
│  │ 記錄   │  │ (即將   │         │
│  │History │  │ 推出)  │         │
│  └────────┘  └────────┘         │
│                                  │
│  ── 最近學過 ──                   │
│                                  │
│  ┌──┐ ┌──┐ ┌──┐ ┌──┐ → 可滑動  │
│  │🍎│ │🐱│ │📖│ │✏️│           │
│  │蘋果│ │貓 │ │書 │ │筆 │          │
│  └──┘ └──┘ └──┘ └──┘            │
│                                  │
│  ── 更多功能（即將推出）──          │
│                                  │
│  ┌────────┐  ┌────────┐         │
│  │ 🎮     │  │ 🏆     │         │
│  │ 趣味   │  │ 成就   │         │
│  │ 遊戲   │  │ 系統   │         │
│  │ 開發中  │  │ 開發中  │         │
│  └────────┘  └────────┘         │
│                                  │
└─────────────────────────────────┘
```

**關鍵實現細節：**
- 4 個主要功能卡片使用 2x2 Grid，每個卡片都是 ClayButton
- 「即將推出」的卡片呈灰色半透明粘土效果，點擊彈出 Snackbar 提示 "Coming Soon!"
- 「最近學過」區域是水平滾動的列表（ListView.builder, horizontal），每個 item 顯示縮略圖 + 漢字，點擊可進入該詞的 ResultScreen
- 頂部問候語根據時間段自動變化（早上/下午/晚上）
- 頁面整體可垂直滾動（SingleChildScrollView）

---

### 5.2 📷 CameraScreen — 拍照頁

**功能：**
1. 打開相機或從相簿選擇圖片（使用 image_picker）
2. 拍照/選取後顯示預覽
3. 點擊「開始辨識」按鈕 → 調用 API → 加載動畫 → 跳轉 ResultScreen

**佈局：**
```
┌─────────────────────────────────┐
│  [← 返回]     拍一拍     [相簿📁]│
├─────────────────────────────────┤
│                                  │
│  ┌─────────────────────────┐    │
│  │                          │    │
│  │      相機預覽 / 圖片預覽   │    │
│  │      （圓角矩形框）        │    │
│  │                          │    │
│  └─────────────────────────┘    │
│                                  │
│  提示文字：「拍下你想學的東西吧！」  │
│                                  │
│      ┌──────────────┐           │
│      │  📷 拍照按鈕   │           │
│      │  （大圓形粘土按鈕）│          │
│      └──────────────┘           │
│                                  │
│  拍完後顯示：                     │
│      ┌──────────────┐           │
│      │ 🚀 開始辨識    │           │
│      └──────────────┘           │
│      ┌──────────────┐           │
│      │ 🔄 重新拍攝    │           │
│      └──────────────┘           │
└─────────────────────────────────┘
```

**加載狀態：** 辨識中顯示粘土風格的 Loading 動畫（跳動的圓球 or 旋轉的地球）+ 文字「AI 正在辨識中…」

---

### 5.3 📖 ResultScreen — 辨識結果 & 學習頁

**API 返回解析後顯示：**

```
┌─────────────────────────────────┐
│  [← 返回]     學習卡片            │
├─────────────────────────────────┤
│                                  │
│  ┌─────────────────────────┐    │
│  │    [拍攝的圖片 — 圓角]     │    │
│  └─────────────────────────┘    │
│                                  │
│  ┌─────────────────────────┐    │
│  │  漢字：   蘋 果              │    │
│  │          （大字顯示 48sp）    │    │
│  │                             │    │
│  │  拼音：   píng guǒ          │    │
│  │          （帶聲調符號 36sp）  │    │
│  │                             │    │
│  │  聲調：   二聲 + 三聲         │    │
│  │          [聲調走勢圖示]       │    │
│  │                             │    │
│  │  英文：   Apple              │    │
│  │                             │    │
│  │  粵語對照：蘋果 (ping4 gwo2) │    │
│  │  （幫助港童理解差異）          │    │
│  │                             │    │
│  │  ┌────────────────┐        │    │
│  │  │ 🔊 聽發音（TTS）  │        │    │
│  │  └────────────────┘        │    │
│  └─────────────────────────┘    │
│                                  │
│  ┌─────────────────────────┐    │
│  │ 📝 開始測驗                  │    │
│  └─────────────────────────┘    │
│                                  │
│  ┌─────────────────────────┐    │
│  │ 📷 再拍一張                  │    │
│  └─────────────────────────┘    │
│                                  │
└─────────────────────────────────┘
```

**聲調走勢圖示：** 使用 CustomPainter 繪製 4 種聲調的走勢線條：
- 一聲（陰平）：→ 水平高音線
- 二聲（陽平）：↗ 上升線
- 三聲（上聲）：↘↗ 先降後升
- 四聲（去聲）：↘ 下降線

每個聲調用對應的 tone color 繪製。

---

### 5.4 📝 QuizScreen — 測驗頁

點擊「開始測驗」後，基於當前識別的詞語，調用 API 生成一組測驗題（3-5 題）。

**測驗類型（每次隨機組合）：**

#### 題型 A：畫聲調（DrawToneQuiz）
```
┌─────────────────────────────────┐
│  第 1 題 / 共 5 題    [進度條]     │
├─────────────────────────────────┤
│                                  │
│  請畫出「蘋」(píng) 的聲調走勢     │
│  提示：這是第二聲                  │
│                                  │
│  ┌─────────────────────────┐    │
│  │                          │    │
│  │   [Canvas 畫布區域]       │    │
│  │   用戶手指在此畫出聲調      │    │
│  │   灰色輔助格線背景         │    │
│  │                          │    │
│  └─────────────────────────┘    │
│                                  │
│  [🗑️ 清除重畫]                    │
│                                  │
│  ┌─────────────────────────┐    │
│  │  ✅ 提交答案               │    │
│  └─────────────────────────┘    │
│                                  │
│  提交後顯示：                     │
│  ✅ 正確！很棒！/ ❌ 不對哦～      │
│  正確的聲調走勢：[動畫展示]         │
│                                  │
│  [下一題 →]                       │
└─────────────────────────────────┘
```

**畫聲調實現邏輯：**
1. 使用 `GestureDetector` + `CustomPainter` 記錄用戶的觸摸軌跡（List<Offset>）
2. 提交時，將軌跡點歸一化為方向描述（如 "起點在左中，終點在右上" → 上升趨勢）
3. 將描述發送給 AI API 判斷是否匹配目標聲調
4. API Prompt 模板見下方 §6.3

#### 題型 B：看圖選拼音
```
「這個東西的普通話拼音是什麼？」
[圖片]
(A) píng guǒ  (B) pín guǒ  (C) píng guó  (D) péng guǒ
```

#### 題型 C：聽音選字
```
🔊 [播放 TTS 發音]
「你聽到的是哪個詞？」
(A) 蘋果  (B) 平果  (C) 瓶蓋  (D) 拼搏
```

#### 題型 D：選擇正確聲調
```
「"píng" 是第幾聲？」
(A) 第一聲  (B) 第二聲 ✓  (C) 第三聲  (D) 第四聲
```

#### 題型 E：聲調配對
```
「以下哪個聲調走勢圖代表第三聲？」
(A) [→]  (B) [↗]  (C) [↘↗] ✓  (D) [↘]
```

**每道題的交互流程：**
1. 顯示題目
2. 用戶作答
3. 立即反饋正確/錯誤（帶動畫效果）
   - 正確：綠色閃爍 + 星星飛出動畫 + 音效（可選）
   - 錯誤：輕微抖動 + 顯示正確答案
4. 「下一題」按鈕
5. 最後一題後跳轉 QuizResultScreen

---

### 5.5 🏆 QuizResultScreen — 測驗結果頁

```
┌─────────────────────────────────┐
│           測驗完成！🎉            │
├─────────────────────────────────┤
│                                  │
│          ⭐ ⭐ ⭐                │
│        （0-60% = 1星,            │
│         60-80% = 2星,            │
│         80-100% = 3星）          │
│                                  │
│     你答對了 4 / 5 題！           │
│     正確率：80%                   │
│                                  │
│  ┌─────────────────────────┐    │
│  │  答題詳情：                   │    │
│  │  1. ✅ 畫聲調 — 正確          │    │
│  │  2. ✅ 選拼音 — 正確          │    │
│  │  3. ❌ 聽音選字 — 答錯        │    │
│  │     你選：瓶蓋  正確：蘋果     │    │
│  │  4. ✅ 選聲調 — 正確          │    │
│  │  5. ✅ 聲調配對 — 正確        │    │
│  └─────────────────────────┘    │
│                                  │
│  ┌──────────┐ ┌──────────┐      │
│  │ 🔄 再測一次│ │ 🏠 回主頁 │      │
│  └──────────┘ └──────────┘      │
│                                  │
└─────────────────────────────────┘
```

---

### 5.6 📜 HistoryScreen — 歷史記錄頁

```
┌─────────────────────────────────┐
│  [← 返回]     歷史記錄            │
├─────────────────────────────────┤
│  [🔍 搜索框]                      │
│                                  │
│  ── 2025年1月15日 ──              │
│  ┌─────────────────────────┐    │
│  │ [🍎縮略圖] 蘋果 píng guǒ      │    │
│  │ 測驗成績：⭐⭐⭐ 5/5          │    │
│  │ 下午 3:24                     │    │
│  └─────────────────────────┘    │
│  ┌─────────────────────────┐    │
│  │ [🐱縮略圖] 貓 māo             │    │
│  │ 測驗成績：⭐⭐ 3/5             │    │
│  │ 上午 10:15                    │    │
│  └─────────────────────────┘    │
│                                  │
│  ── 2025年1月14日 ──              │
│  ┌─────────────────────────┐    │
│  │ [📖縮略圖] 書 shū              │    │
│  │ 測驗成績：未測驗                │    │
│  │ 下午 5:30                     │    │
│  └─────────────────────────┘    │
│                                  │
│  ... 更多記錄（懶加載）            │
└─────────────────────────────────┘
```

**點擊任一記錄 → 進入 HistoryDetailScreen**，顯示：
- 原始拍攝圖片
- 漢字、拼音、聲調資訊（同 ResultScreen）
- 歷次測驗成績
- 可重新測驗
- 可刪除記錄（左滑刪除 or 長按刪除）

---

### 5.7 ⚙️ SettingsScreen — 設定頁

```
┌─────────────────────────────────┐
│  [← 返回]     設定               │
├─────────────────────────────────┤
│                                  │
│  🌐 語言 / Language               │
│  [繁體中文 ▼] ←→ [English ▼]     │
│                                  │
│  🔊 TTS 語速                      │
│  [========●==] 0.8x              │
│                                  │
│  🗑️ 清除所有歷史記錄              │
│  [確認清除]                       │
│                                  │
│  ℹ️ 關於                          │
│  INT4074 Group Project            │
│  Version 1.0.0                   │
│                                  │
└─────────────────────────────────┘
```

---

## 六、API 整合詳細規格

### 6.1 API 配置

```dart
class ApiConfig {
  static const String baseUrl = 'https://api.apiplus.org/v1/chat/completions';
  static const String apiKey = 'YOUR_API_KEY_HERE';  // ← 替換為真實 Key
  static const String model = 'gemini-3-flash-preview';
}
```

### 6.2 API 調用 — 拍照辨識物件

**Request 格式（OpenAI 兼容 multimodal）：**

```dart
Future<RecognitionResult> recognizeObject(File imageFile) async {
  final bytes = await imageFile.readAsBytes();
  final base64Image = base64Encode(bytes);

  final response = await http.post(
    Uri.parse(ApiConfig.baseUrl),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${ApiConfig.apiKey}',
    },
    body: jsonEncode({
      'model': ApiConfig.model,
      'messages': [
        {
          'role': 'system',
          'content': '''你是一個兒童普通話教學助手。用戶會發送一張圖片，請你：
1. 辨識圖片中最主要的物件
2. 返回以下 JSON 格式（不要返回其他任何文字，只返回純 JSON）：

{
  "object_name_zh": "蘋果",
  "object_name_en": "Apple",
  "pinyin": "píng guǒ",
  "pinyin_no_tone": "ping guo",
  "characters": [
    {
      "char": "蘋",
      "pinyin": "píng",
      "tone_number": 2,
      "tone_name_zh": "第二聲（陽平）",
      "tone_name_en": "2nd tone (rising)"
    },
    {
      "char": "果",
      "pinyin": "guǒ",
      "tone_number": 3,
      "tone_name_zh": "第三聲（上聲）",
      "tone_name_en": "3rd tone (dipping)"
    }
  ],
  "cantonese_reference": "蘋果 (ping4 gwo2)",
  "example_sentence_zh": "我喜歡吃蘋果。",
  "example_sentence_pinyin": "Wǒ xǐ huān chī píng guǒ.",
  "example_sentence_en": "I like to eat apples."
}'''
        },
        {
          'role': 'user',
          'content': [
            {
              'type': 'text',
              'text': '請辨識這張圖片中的物件，並按要求的 JSON 格式返回結果。'
            },
            {
              'type': 'image_url',
              'image_url': {
                'url': 'data:image/jpeg;base64,$base64Image'
              }
            }
          ]
        }
      ],
      'max_tokens': 1000,
      'temperature': 0.3,
    }),
  );

  // 解析 response.body → RecognitionResult
}
```

### 6.3 API 調用 — 生成測驗題

```dart
Future<List<QuizQuestion>> generateQuiz(RecognitionResult result) async {
  final response = await http.post(
    Uri.parse(ApiConfig.baseUrl),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${ApiConfig.apiKey}',
    },
    body: jsonEncode({
      'model': ApiConfig.model,
      'messages': [
        {
          'role': 'system',
          'content': '''你是一個兒童普通話測驗生成器。根據提供的詞語信息，生成 5 道測驗題。

題目類型必須包含以下混合組合：
- 1 題「畫聲調」題（draw_tone）：要求用戶畫出某個字的聲調走勢
- 1 題「看圖選拼音」（pick_pinyin）：給出 4 個拼音選項，其中 1 個正確
- 1 題「聽音選字」（listen_pick_char）：給出 4 個漢字選項
- 1 題「選擇聲調」（pick_tone）：問某個拼音是第幾聲
- 1 題「聲調走勢配對」（match_tone_shape）：看走勢圖選聲調

返回純 JSON 數組格式：
[
  {
    "type": "draw_tone",
    "question_zh": "請畫出「蘋」(píng) 的聲調走勢",
    "question_en": "Draw the tone contour for '蘋' (píng)",
    "target_char": "蘋",
    "target_pinyin": "píng",
    "correct_tone": 2,
    "correct_description": "從左下到右上的上升線"
  },
  {
    "type": "pick_pinyin",
    "question_zh": "「蘋果」的正確拼音是？",
    "question_en": "What is the correct pinyin for '蘋果'?",
    "options": ["píng guǒ", "pín guǒ", "píng guó", "péng guǒ"],
    "correct_index": 0
  },
  {
    "type": "listen_pick_char",
    "question_zh": "聽發音，選出正確的詞語",
    "question_en": "Listen and pick the correct word",
    "tts_text": "蘋果",
    "options": ["蘋果", "平果", "瓶蓋", "評估"],
    "correct_index": 0
  },
  {
    "type": "pick_tone",
    "question_zh": "「píng」是第幾聲？",
    "question_en": "What tone is 'píng'?",
    "options": ["第一聲", "第二聲", "第三聲", "第四聲"],
    "correct_index": 1
  },
  {
    "type": "match_tone_shape",
    "question_zh": "以下哪個走勢代表第二聲？",
    "question_en": "Which contour represents the 2nd tone?",
    "options": ["flat_high", "rising", "dipping", "falling"],
    "option_labels_zh": ["→ 平線", "↗ 上升", "↘↗ 先降後升", "↘ 下降"],
    "option_labels_en": ["→ Flat", "↗ Rising", "↘↗ Dipping", "↘ Falling"],
    "correct_index": 1
  }
]'''
        },
        {
          'role': 'user',
          'content': '詞語：${result.objectNameZh}（${result.pinyin}），'
              '各字聲調：${result.characters.map((c) => "${c.char}=${c.toneNumber}聲").join(", ")}。'
              '請生成 5 道測驗題。'
        }
      ],
      'max_tokens': 2000,
      'temperature': 0.7,
    }),
  );
  
  // 解析 response → List<QuizQuestion>
}
```

### 6.4 API 調用 — 判斷畫的聲調

```dart
Future<ToneJudgmentResult> judgeToneDrawing({
  required int targetTone,
  required List<Offset> strokePoints,
  required Size canvasSize,
}) async {
  // 將軌跡點歸一化描述
  final description = _describeStroke(strokePoints, canvasSize);
  
  final response = await http.post(
    Uri.parse(ApiConfig.baseUrl),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${ApiConfig.apiKey}',
    },
    body: jsonEncode({
      'model': ApiConfig.model,
      'messages': [
        {
          'role': 'system',
          'content': '''你是一個聲調走勢判斷器。用戶在畫布上畫了一條線來表示普通話聲調走勢。
我會告訴你：
- 目標聲調（用戶應該畫的聲調）
- 用戶畫的軌跡描述

聲調走勢規則：
- 第一聲（陰平）：高而平的水平線，起點和終點高度接近，都在偏上方
- 第二聲（陽平）：從中低位上升到高位，起點低於終點
- 第三聲（上聲）：先下降再上升，呈 V 形或 U 形
- 第四聲（去聲）：從高位急降到低位，起點高於終點

請判斷用戶畫的走勢是否正確，返回純 JSON：
{
  "is_correct": true/false,
  "detected_tone": 1-4,
  "feedback_zh": "很棒！你畫的上升走勢正確地表示了第二聲！",
  "feedback_en": "Great! Your rising contour correctly represents the 2nd tone!"
}'''
        },
        {
          'role': 'user',
          'content': '目標聲調：第${targetTone}聲\n用戶畫的軌跡描述：$description'
        }
      ],
      'max_tokens': 300,
      'temperature': 0.3,
    }),
  );
  
  // 解析結果
}

/// 將觸摸點歸一化為方向描述
String _describeStroke(List<Offset> points, Size canvasSize) {
  if (points.isEmpty) return "用戶沒有畫任何東西";
  
  final normalized = points.map((p) => Offset(
    p.dx / canvasSize.width,  // 0.0 ~ 1.0
    1.0 - (p.dy / canvasSize.height),  // 翻轉 Y 軸，0=底部 1=頂部
  )).toList();
  
  final start = normalized.first;
  final end = normalized.last;
  final mid = normalized[normalized.length ~/ 2];
  
  // 找最高點和最低點
  double minY = 1.0, maxY = 0.0;
  int minIdx = 0, maxIdx = 0;
  for (int i = 0; i < normalized.length; i++) {
    if (normalized[i].dy < minY) { minY = normalized[i].dy; minIdx = i; }
    if (normalized[i].dy > maxY) { maxY = normalized[i].dy; maxIdx = i; }
  }
  
  return '''
起點位置：(${start.dx.toStringAsFixed(2)}, ${start.dy.toStringAsFixed(2)})
終點位置：(${end.dx.toStringAsFixed(2)}, ${end.dy.toStringAsFixed(2)})
中間點位置：(${mid.dx.toStringAsFixed(2)}, ${mid.dy.toStringAsFixed(2)})
最高點出現在軌跡的 ${((maxIdx / normalized.length) * 100).toInt()}% 處，高度 ${maxY.toStringAsFixed(2)}
最低點出現在軌跡的 ${((minIdx / normalized.length) * 100).toInt()}% 處，高度 ${minY.toStringAsFixed(2)}
整體高度差：${(end.dy - start.dy).toStringAsFixed(2)}（正數=上升，負數=下降）
軌跡總點數：${normalized.length}
''';
}
```

---

## 七、數據模型

### 7.1 Hive 數據模型

```dart
@HiveType(typeId: 0)
class LearningRecord extends HiveObject {
  @HiveField(0)
  late String id;  // UUID

  @HiveField(1)
  late String imagePath;  // 本地圖片路徑

  @HiveField(2)
  late String objectNameZh;  // 漢字名稱

  @HiveField(3)
  late String objectNameEn;  // 英文名稱

  @HiveField(4)
  late String pinyin;  // 完整拼音（帶聲調）

  @HiveField(5)
  late String pinyinNoTone;  // 無聲調拼音

  @HiveField(6)
  late List<CharacterTone> characters;  // 逐字聲調信息

  @HiveField(7)
  late String cantoneseReference;  // 粵語參考

  @HiveField(8)
  late String exampleSentenceZh;

  @HiveField(9)
  late String exampleSentencePinyin;

  @HiveField(10)
  late String exampleSentenceEn;

  @HiveField(11)
  late DateTime createdAt;

  @HiveField(12)
  late List<QuizAttempt> quizAttempts;  // 歷次測驗記錄
}

@HiveType(typeId: 1)
class CharacterTone {
  @HiveField(0)
  late String char;

  @HiveField(1)
  late String pinyin;

  @HiveField(2)
  late int toneNumber;

  @HiveField(3)
  late String toneNameZh;

  @HiveField(4)
  late String toneNameEn;
}

@HiveType(typeId: 2)
class QuizAttempt {
  @HiveField(0)
  late DateTime attemptedAt;

  @HiveField(1)
  late int totalQuestions;

  @HiveField(2)
  late int correctAnswers;

  @HiveField(3)
  late int starRating;  // 1-3

  @HiveField(4)
  late List<QuizQuestionResult> details;
}

@HiveType(typeId: 3)
class QuizQuestionResult {
  @HiveField(0)
  late String type;  // draw_tone, pick_pinyin, etc.

  @HiveField(1)
  late String questionText;

  @HiveField(2)
  late bool isCorrect;

  @HiveField(3)
  late String userAnswer;

  @HiveField(4)
  late String correctAnswer;
}
```

---

## 八、國際化 (i18n)

### 8.1 支持語言
- `zh_HK`（繁體中文 — 默認）
- `en`（English）

### 8.2 主要翻譯鍵值

```dart
// zh_HK
{
  "app_name": "拼拼樂",
  "home_greeting_morning": "早安！☀️",
  "home_greeting_afternoon": "午安！🌤️",
  "home_greeting_evening": "晚安！🌙",
  "home_subtitle": "準備好學普通話了嗎？",
  "feature_snap": "拍一拍",
  "feature_quiz": "小測驗",
  "feature_history": "歷史記錄",
  "feature_favorites": "收藏夾",
  "feature_coming_soon": "即將推出",
  "camera_title": "拍一拍",
  "camera_hint": "拍下你想學的東西吧！",
  "camera_recognize": "開始辨識",
  "camera_retake": "重新拍攝",
  "loading_recognize": "AI 正在辨識中…",
  "result_title": "學習卡片",
  "result_hanzi": "漢字",
  "result_pinyin": "拼音",
  "result_tone": "聲調",
  "result_listen": "🔊 聽發音",
  "result_start_quiz": "📝 開始測驗",
  "result_retake": "📷 再拍一張",
  "quiz_title": "小測驗",
  "quiz_question_of": "第 {current} 題 / 共 {total} 題",
  "quiz_draw_hint": "用手指在下方畫出聲調走勢",
  "quiz_clear": "清除重畫",
  "quiz_submit": "提交答案",
  "quiz_next": "下一題",
  "quiz_correct": "正確！很棒！🎉",
  "quiz_incorrect": "不對哦～正確答案是：",
  "quiz_result_title": "測驗完成！🎉",
  "quiz_result_score": "你答對了 {correct} / {total} 題！",
  "quiz_result_accuracy": "正確率：{percent}%",
  "quiz_retry": "🔄 再測一次",
  "quiz_go_home": "🏠 回主頁",
  "history_title": "歷史記錄",
  "history_no_quiz": "未測驗",
  "history_search": "搜索…",
  "settings_title": "設定",
  "settings_language": "語言",
  "settings_tts_speed": "語音速度",
  "settings_clear_history": "清除所有歷史記錄",
  "settings_clear_confirm": "確定要清除所有記錄嗎？此操作無法撤銷。",
  "settings_about": "關於",
  "coming_soon_msg": "此功能即將推出，敬請期待！",
  "error_api": "辨識失敗，請重試",
  "error_no_camera": "無法使用相機",
  "stats_words_learned": "已學 {count} 個詞",
  "stats_streak": "連續 {days} 天",
  "recent_learned": "最近學過",
  "more_features": "更多功能"
}

// en — 對應英文翻譯
```

### 8.3 語言切換實現
- 使用 Provider 管理 `Locale` 狀態
- 存入 Hive（`settingsBox`）持久化用戶選擇
- 在 SettingsScreen 提供切換按鈕

---

## 九、項目文件結構

```
lib/
├── main.dart
├── app.dart                          # MaterialApp 配置
├── config/
│   ├── api_config.dart               # API URL, Key, Model
│   ├── theme.dart                    # Claymorphism 主題定義
│   └── routes.dart                   # 路由定義
├── l10n/
│   ├── app_zh_HK.arb                # 繁中翻譯
│   └── app_en.arb                   # 英文翻譯
├── models/
│   ├── recognition_result.dart       # 辨識結果模型
│   ├── quiz_question.dart            # 測驗題模型
│   ├── learning_record.dart          # Hive 學習記錄
│   └── learning_record.g.dart        # Hive generated
├── services/
│   ├── api_service.dart              # 所有 API 調用
│   ├── tts_service.dart              # TTS 文字轉語音
│   ├── storage_service.dart          # Hive CRUD 操作
│   └── image_service.dart            # 圖片拍攝、壓縮、Base64
├── providers/
│   ├── locale_provider.dart          # 語言切換
│   ├── history_provider.dart         # 歷史記錄狀態
│   └── quiz_provider.dart            # 測驗狀態
├── widgets/
│   ├── clay_container.dart           # 粘土風格容器
│   ├── clay_button.dart              # 粘土風格按鈕
│   ├── clay_card.dart                # 粘土風格卡片
│   ├── clay_text_field.dart          # 粘土風格輸入框
│   ├── tone_painter.dart             # 聲調走勢繪製 (CustomPainter)
│   ├── tone_drawing_canvas.dart      # 用戶畫聲調的 Canvas
│   ├── tone_display.dart             # 聲調圖示組件
│   ├── star_rating.dart              # 星星評分組件
│   ├── loading_animation.dart        # 加載動畫
│   └── feature_card.dart             # 主頁功能卡片
├── screens/
│   ├── splash_screen.dart
│   ├── home_screen.dart
│   ├── camera_screen.dart
│   ├── result_screen.dart
│   ├── quiz_screen.dart
│   ├── quiz_result_screen.dart
│   ├── history_screen.dart
│   ├── history_detail_screen.dart
│   └── settings_screen.dart
└── utils/
    ├── stroke_analyzer.dart          # 筆劃軌跡分析工具
    ├── date_formatter.dart           # 日期格式化
    └── constants.dart                # 常量定義
```

---

## 十、TTS 語音配置

```dart
class TtsService {
  final FlutterTts _tts = FlutterTts();

  Future<void> init() async {
    await _tts.setLanguage('zh-CN');  // 普通話
    await _tts.setSpeechRate(0.5);    // 兒童適用慢速
    await _tts.setPitch(1.1);         // 略高音調（更親切）
    await _tts.setVolume(1.0);
  }

  Future<void> speak(String text) async {
    await _tts.speak(text);
  }

  Future<void> setSpeed(double speed) async {
    await _tts.setSpeechRate(speed);
  }
}
```

---

## 十一、關鍵交互 & 動畫要求

1. **頁面轉場：** 使用 `PageRouteBuilder` 加入滑入/淡入效果
2. **按鈕按壓：** Claymorphism 按鈕按下時：
   - 縮放到 0.95
   - 陰影變為內陰影（凹下去的感覺）
   - 使用 `AnimatedContainer` 或 `AnimatedScale`
3. **答對動畫：** 綠色漸變背景 + 星星從按鈕飛出（簡單粒子效果）
4. **答錯動畫：** 卡片左右抖動（ShakeAnimation）
5. **星星評分動畫：** 星星逐個彈入（bounceIn）
6. **主頁卡片：** 進入時各卡片依次從下方滑入（stagger animation）
7. **Loading 動畫：** 3 個粘土圓球交替上下跳動

---

## 十二、錯誤處理

1. **API 調用失敗：** 顯示友好提示 + 重試按鈕（粘土風格對話框）
2. **JSON 解析失敗：** 嘗試重新請求一次，仍失敗則提示用戶
3. **相機權限拒絕：** 引導用戶去設定開啟
4. **TTS 不可用：** 隱藏播放按鈕，不影響其他功能
5. **離線狀態：** 提示需要網絡連接（僅查看歷史記錄可離線）
6. **圖片過大：** 壓縮到 800px 寬度 & 80% JPEG 品質再上傳

---

## 十三、實現優先級

### Phase 1（MVP）
- [x] Claymorphism 設計系統 & 基礎組件
- [x] 主頁佈局
- [x] 拍照 → API 辨識 → 結果展示
- [x] TTS 發音
- [x] 歷史記錄（Hive 存取 & 列表展示）
- [x] 中英文切換

### Phase 2
- [x] 測驗系統（5 種題型全部實現）
- [x] 畫聲調 Canvas + AI 判斷
- [x] 測驗結果頁 & 星星評分
- [x] 歷史記錄詳情頁

### Phase 3（後續擴展）
- [ ] 收藏夾功能
- [ ] 每日一詞推送
- [ ] 成就系統 / 排行榜
- [ ] 趣味遊戲模式
- [ ] 雲端同步 & 用戶帳號

---

## 十四、開發注意事項

1. 所有文字請使用 i18n key，不要 hardcode 中文/英文字串
2. API Key 寫在 `api_config.dart` 中，方便後續改為環境變量
3. 所有 Claymorphism 組件抽成可復用 Widget
4. 圖片保存到 app documents 目錄，路徑存入 Hive
5. 測驗的 AI 生成結果需要 try-catch JSON 解析，並做容錯
6. Canvas 畫聲調時，記錄採樣頻率不需要太高，每 10ms 記錄一個點即可
7. 主頁「最近學過」最多顯示最新 10 條，點擊「歷史記錄」查看全部
8. 聲調顏色必須保持全 APP 統一（一聲紅、二聲青、三聲金、四聲紫）

請按照以上完整規格，使用 Flutter (Dart) 實現這個 APP。先從 Phase 1 開始，逐步構建所有文件。每個文件請提供完整代碼，不要省略。
```

---
