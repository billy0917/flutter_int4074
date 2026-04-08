import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// 集中管理所有圖示路徑與快捷方法（SVG + PNG 混合）
class AppIcons {
  AppIcons._();

  // ── 路徑常數 ──────────────────────────────────────
  // Stats
  static const fire = 'assets/icons/fire.png';
  static const star = 'assets/icons/star.png';
  static const starOutline = 'assets/icons/star_outline.png';
  static const book = 'assets/icons/book.png';

  // Features
  static const camera = 'assets/icons/camera.svg'; // 保留 SVG
  static const chat = 'assets/icons/chat.png';
  static const scroll = 'assets/icons/scroll.png';
  static const rocket = 'assets/icons/rocket.png';

  // Levels
  static const chickHatching = 'assets/icons/chick_hatching.png';
  static const chick = 'assets/icons/chick.png';
  static const fox = 'assets/icons/fox.png';
  static const lion = 'assets/icons/lion.png';
  static const dragon = 'assets/icons/dragon.png';
  static const sparkle = 'assets/icons/sparkle.png';
  static const crown = 'assets/icons/crown.png';

  // Categories
  static const wave = 'assets/icons/wave.png';
  static const burger = 'assets/icons/burger.png';
  static const school = 'assets/icons/school.png';
  static const cart = 'assets/icons/cart.png';
  static const bus = 'assets/icons/bus.png';
  static const hospital = 'assets/icons/hospital.png';
  static const house = 'assets/icons/house.png';
  static const weather = 'assets/icons/weather.png';

  // Feedback
  static const party = 'assets/icons/party.png';
  static const thumbsup = 'assets/icons/thumbsup.png';
  static const flex = 'assets/icons/flex.png';
  static const refresh = 'assets/icons/refresh.png';

  // Other
  static const pencil = 'assets/icons/pencil.png';
  static const globe = 'assets/icons/globe.png';
  static const speaker = 'assets/icons/speaker.png';
  static const music = 'assets/icons/music.png';
  static const home = 'assets/icons/home.png';
  static const history = 'assets/icons/history.png';
  static const trash = 'assets/icons/trash.png';
  static const info = 'assets/icons/info.png';
  static const check = 'assets/icons/check.png';

  // ── 等級對應圖示 ─────────────────────────────────
  static const _levelIcons = <int, String>{
    1: chickHatching,
    2: chick,
    3: fox,
    4: lion,
    5: dragon,
    6: sparkle,
    7: crown,
  };

  static String levelIcon(int level) =>
      _levelIcons[level] ?? chickHatching;

  // ── 分類對應圖示 ─────────────────────────────────
  static const categoryIcons = <String, String>{
    'greetings': wave,
    'restaurant': burger,
    'school': school,
    'shopping': cart,
    'transport': bus,
    'hospital': hospital,
    'home_life': house,
    'weather': weather,
  };

  static String categoryIcon(String categoryId) =>
      categoryIcons[categoryId] ?? book;

  // ── 回饋對應圖示 ─────────────────────────────────
  static String feedbackIcon(double score) {
    if (score >= 80) return party;
    if (score >= 60) return thumbsup;
    if (score >= 30) return flex;
    return refresh;
  }

  // ── 快捷 Widget（自動判斷 SVG / PNG）──────────────
  static Widget svg(
    String assetPath, {
    double size = 24,
    Color? color,
    BoxFit fit = BoxFit.contain,
  }) {
    if (assetPath.endsWith('.svg')) {
      return SvgPicture.asset(
        assetPath,
        width: size,
        height: size,
        fit: fit,
        colorFilter:
            color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
      );
    }
    return Image.asset(
      assetPath,
      width: size,
      height: size,
      fit: fit,
      color: color,
      colorBlendMode: color != null ? BlendMode.srcIn : null,
    );
  }

  /// 生成星星列 (用 SVG 取代 ⭐/☆)
  static Widget starRow(int filledCount, {int maxStars = 3, double size = 20}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxStars, (i) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 1),
          child: svg(
            i < filledCount ? star : starOutline,
            size: size,
            color: i < filledCount ? const Color(0xFFFFD93D) : const Color(0xFFBFA98E),
          ),
        );
      }),
    );
  }
}
