import 'package:flutter/material.dart';
import '../config/theme.dart';

class AppConstants {
  // ── 圓角
  static const double cardRadius = 24.0;
  static const double buttonRadius = 20.0;
  static const double smallRadius = 16.0;

  // ── 間距 (8-point grid)
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;

  // ── 頁面內距
  static const double pagePadding = 20.0;
  static const double cardPadding = 16.0;

  // ── 按鈕尺寸
  static const double buttonHeightLg = 56.0;
  static const double buttonHeightSm = 48.0;
  static const double touchTargetMin = 48.0;

  // ── 圖示
  static const double iconSize = 28.0;
  static const double iconSizeSm = 22.0;

  // ── 動畫時長
  static const Duration animFast = Duration(milliseconds: 250);
  static const Duration animNormal = Duration(milliseconds: 500);
  static const Duration animSlow = Duration(milliseconds: 900);
  // 向後相容
  static const Duration animDuration = animFast;
  static const Duration pageDuration = Duration(milliseconds: 300);

  // ── 圖片高度（響應式）
  static double imageHeight(BuildContext context) =>
      MediaQuery.of(context).size.height * 0.25;

  // ── 星星評分尺寸（響應式）
  static double starSize(BuildContext context) =>
      MediaQuery.of(context).size.width * 0.12;

  static Color toneColor(int toneNumber) {
    switch (toneNumber) {
      case 1:
        return AppColors.tone1;
      case 2:
        return AppColors.tone2;
      case 3:
        return AppColors.tone3;
      case 4:
        return AppColors.tone4;
      default:
        return AppColors.toneLight;
    }
  }

  static String toneShape(int toneNumber) {
    switch (toneNumber) {
      case 1:
        return '→';
      case 2:
        return '↗';
      case 3:
        return '↘↗';
      case 4:
        return '↘';
      default:
        return '·';
    }
  }
}
