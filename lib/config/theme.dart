import 'package:flutter/material.dart';

class AppColors {
  // 主色
  static const primary = Color(0xFFFF8C42);
  static const primaryLight = Color(0xFFFFAA6B);
  static const secondary = Color(0xFFFF6B8A);

  // 背景
  static const background = Color(0xFFFFF5EB);
  static const cardBg = Color(0xFFFFE8D6);
  static const cardBgAlt = Color(0xFFFFF0E0);

  // 功能色
  static const success = Color(0xFF7EC8A0);
  static const error = Color(0xFFFF7979);
  static const star = Color(0xFFFFD93D);

  // 文字
  static const textDark = Color(0xFF4A3728);
  static const textMedium = Color(0xFF8B7355);
  static const textLight = Color(0xFFBFA98E);

  // 聲調專用色
  static const tone1 = Color(0xFFFF6B6B); // 一聲 紅
  static const tone2 = Color(0xFF4ECDC4); // 二聲 青
  static const tone3 = Color(0xFFFFBE0B); // 三聲 金
  static const tone4 = Color(0xFF7B68EE); // 四聲 紫
  static const toneLight = Color(0xFFCCCCCC); // 輕聲 灰
}

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
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              offset: const Offset(2, 2),
              blurRadius: 4,
              spreadRadius: -1,
            ),
          ]
        : [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              offset: const Offset(4, 4),
              blurRadius: 8,
            ),
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.8),
              offset: const Offset(-3, -3),
              blurRadius: 6,
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              offset: const Offset(0, 8),
              blurRadius: 16,
            ),
          ],
  );
}

ThemeData buildAppTheme() {
  return ThemeData(
    colorSchemeSeed: AppColors.primary,
    scaffoldBackgroundColor: AppColors.background,
    fontFamily: 'sans-serif',
    useMaterial3: true,
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: AppColors.textDark,
      ),
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: AppColors.textDark,
      ),
      bodyLarge: TextStyle(fontSize: 16, color: AppColors.textDark),
      bodyMedium: TextStyle(fontSize: 14, color: AppColors.textMedium),
      bodySmall: TextStyle(fontSize: 12, color: AppColors.textLight),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      elevation: 0,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppColors.textDark,
      ),
      iconTheme: IconThemeData(color: AppColors.textDark),
    ),
  );
}
