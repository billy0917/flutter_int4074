import '../utils/app_icons.dart';

class GameLevel {
  final int level;
  final String titleZh;
  final String iconPath;
  final int xpRequired;

  const GameLevel({
    required this.level,
    required this.titleZh,
    required this.iconPath,
    required this.xpRequired,
  });
}

class GameConfig {
  static const List<GameLevel> levels = [
    GameLevel(level: 1, titleZh: '小新手', iconPath: AppIcons.chickHatching, xpRequired: 0),
    GameLevel(level: 2, titleZh: '小學生', iconPath: AppIcons.chick, xpRequired: 50),
    GameLevel(level: 3, titleZh: '小達人', iconPath: AppIcons.fox, xpRequired: 150),
    GameLevel(level: 4, titleZh: '詞語高手', iconPath: AppIcons.lion, xpRequired: 350),
    GameLevel(level: 5, titleZh: '語言大師', iconPath: AppIcons.dragon, xpRequired: 600),
    GameLevel(level: 6, titleZh: '中文天才', iconPath: AppIcons.sparkle, xpRequired: 1000),
    GameLevel(level: 7, titleZh: '超級學霸', iconPath: AppIcons.crown, xpRequired: 1500),
  ];

  static GameLevel levelForXp(int xp) {
    var result = levels.first;
    for (final l in levels) {
      if (xp >= l.xpRequired) result = l;
    }
    return result;
  }

  static GameLevel? nextLevel(int xp) {
    for (final l in levels) {
      if (xp < l.xpRequired) return l;
    }
    return null;
  }

  static double levelProgress(int xp) {
    final current = levelForXp(xp);
    final next = nextLevel(xp);
    if (next == null) return 1.0;
    final range = next.xpRequired - current.xpRequired;
    if (range <= 0) return 1.0;
    return ((xp - current.xpRequired) / range).clamp(0.0, 1.0);
  }

  static int starsForScore(double score) {
    if (score >= 80) return 3;
    if (score >= 60) return 2;
    if (score >= 30) return 1;
    return 0;
  }

  static String starDisplay(int stars, {int maxStars = 3}) {
    return '⭐' * stars + '☆' * (maxStars - stars);
  }

  static int xpForAttempt(double score, {bool isFirstAttempt = false}) {
    int xp = (score * 0.3).round();
    if (isFirstAttempt) xp += 10;
    if (score >= 80) xp += 15;
    return xp;
  }
}
