import 'package:flutter/material.dart';
import '../config/theme.dart';

class AppConstants {
  static const double cardRadius = 24.0;
  static const double buttonRadius = 20.0;
  static const double smallRadius = 16.0;
  static const double pagePadding = 20.0;
  static const double cardPadding = 16.0;
  static const double iconSize = 28.0;
  static const Duration animDuration = Duration(milliseconds: 250);
  static const Duration pageDuration = Duration(milliseconds: 300);

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
