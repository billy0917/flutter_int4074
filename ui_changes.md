# UI 優化調整記錄

## 1. 新增常數定義 (`lib/utils/constants.dart`)

- 新增 **8點格間距系統**：`spacingXs=4`、`spacingSm=8`、`spacingMd=16`、`spacingLg=24`、`spacingXl=32`
- 新增 **按鈕最低高度**：`buttonHeightLg=56px`、`buttonHeightSm=48px`、`touchTargetMin=48px`
- 新增 **響應式輔助方法**：
  - `imageHeight(context)`：圖片高度改為螢幕高度的 25%
  - `starSize(context)`：星星大小改為螢幕寬度的 12%
- 新增 **標準動畫時長**：`animFast=250ms`、`animNormal=500ms`、`animSlow=900ms`

---

## 2. 觸控目標修正（無障礙）

| 檔案 | 項目 | 修改前 | 修改後 |
|------|------|--------|--------|
| `history_screen.dart` | 星星圖示大小 | 16px | 20px |
| `home_screen.dart` | 設定按鈕 | 44×44 | 48×48（符合 WCAG 最低標準）|

---

## 3. 響應式尺寸修正（移除硬編碼數值）

| 檔案 | 項目 | 修改前 | 修改後 |
|------|------|--------|--------|
| `history_detail_screen.dart` | 物件圖片高度 | `height: 200` | `AppConstants.imageHeight(context)` |
| `result_screen.dart` | 物件圖片高度 | `height: 200` | `AppConstants.imageHeight(context)` |
| `splash_screen.dart` | 啟動畫面 Logo | `width: 120, height: 120` | 螢幕寬度的 30% |
| `quiz_result_screen.dart` | 結果星星大小 | `size: 56` | `AppConstants.starSize(context)` |
| `quiz_screen.dart` | 聲調繪圖畫布 | `Size(300, 180)` | 由 `LayoutBuilder` 動態計算 |

---

## 4. 間距統一（8點格系統）

| 檔案 | 修改 |
|------|------|
| `home_screen.dart` | 統計列間距 `width:10` → `8`；主功能卡內距 `22` → `24`；區塊間距 `18` → `16`、`22` → `24` |
| `history_screen.dart` | 歷史項目底部間距 `bottom:10` → `8` |
| `history_detail_screen.dart` | 測驗記錄列間距 `bottom:10` → `8`；時間戳字體 `11px` → `12px`（無障礙最低要求） |

---

## 5. 圓角標準化

| 檔案 | 修改前 | 修改後 |
|------|--------|--------|
| `camera_screen.dart` | `BorderRadius.circular(24)` | `AppConstants.cardRadius` |
| `home_screen.dart` 主功能卡 | `BorderRadius.circular(24)` | `AppConstants.cardRadius` |
| `home_screen.dart` 次要功能磚 | `BorderRadius.circular(22)` | `AppConstants.cardRadius` |
| `result_screen.dart` | `BorderRadius.circular(20)` | `AppConstants.cardRadius` |
| `history_detail_screen.dart` | `BorderRadius.circular(20)` | `AppConstants.cardRadius` |

---

## 6. 載入狀態統一

| 檔案 | 修改前 | 修改後 |
|------|--------|--------|
| `quiz_screen.dart` | `CircularProgressIndicator()` | `LoadingAnimation(message: ...)` |
| `phrase_learning_screen.dart` | 轉錄中 spinner 無顏色 | 加入 `color: AppColors.primary` |

---

## 7. 空白狀態統一

| 檔案 | 修改前 | 修改後 |
|------|--------|--------|
| `history_screen.dart` | 純文字提示 | 改為 📸 Emoji + 加粗文字，與 `phrase_history_screen` 風格一致 |

---

## 8. 動畫時長標準化

| 檔案 | 修改前 | 修改後 |
|------|--------|--------|
| `home_screen.dart` | `Duration(milliseconds: 900)` | `AppConstants.animSlow` |
| `phrase_categories_screen.dart` | `Duration(milliseconds: 600)` | `AppConstants.animNormal` |
| `phrase_history_screen.dart` | `Duration(milliseconds: 600)` | `AppConstants.animNormal` |

---

## 9. 抽取共用元件

新建 `lib/widgets/info_row.dart`，將原本分別定義在 `history_detail_screen.dart` 及 `result_screen.dart` 的私有 `_InfoRow` 元件合併為共用 `InfoRow`，避免重複程式碼。

---

## 10. Color API 一致性修正

將所有 `.withOpacity()` 改為 `.withValues(alpha:)`（Flutter 3.x 的新 API，避免精度損失與棄用警告），涉及檔案如下：

- `config/theme.dart`
- `screens/camera_screen.dart`
- `screens/history_detail_screen.dart`
- `screens/history_screen.dart`
- `screens/phrase_categories_screen.dart`
- `screens/phrase_learning_screen.dart`
- `screens/quiz_screen.dart`
- `screens/quiz_result_screen.dart`
- `screens/result_screen.dart`
- `screens/settings_screen.dart`
- `screens/splash_screen.dart`
- `widgets/clay_button.dart`
- `widgets/clay_text_field.dart`
- `widgets/feature_card.dart`
- `widgets/loading_animation.dart`
- `widgets/tone_display.dart`
- `widgets/tone_drawing_canvas.dart`

> 修改後 `flutter analyze` 結果：棄用警告從 **16 個**降至 **7 個**（剩餘皆為原有的 style 資訊，無錯誤及警告）。
