import 'package:flutter/material.dart';

class StrokeAnalyzer {
  /// Converts raw points into a human-readable direction description
  static String describe(List<Offset> points, Size canvasSize) {
    if (points.isEmpty) return 'no stroke';

    final norm = points
        .map((p) => Offset(
              p.dx / canvasSize.width,
              1.0 - (p.dy / canvasSize.height),
            ))
        .toList();

    final start = norm.first;
    final end = norm.last;

    double minY = 1.0, maxY = 0.0;
    int minIdx = 0;
    for (int i = 0; i < norm.length; i++) {
      if (norm[i].dy < minY) {
        minY = norm[i].dy;
        minIdx = i;
      }
      if (norm[i].dy > maxY) {
        maxY = norm[i].dy;
      }
    }

    final heightDiff = end.dy - start.dy;
    String trend;
    if (heightDiff.abs() < 0.1) {
      trend = '水平';
    } else if (heightDiff > 0) {
      trend = '上升';
    } else {
      trend = '下降';
    }

    // Check for V/U shape (tone 3)
    final lowestPos = (minIdx / norm.length);
    final isVShape =
        lowestPos > 0.2 && lowestPos < 0.8 && (maxY - minY) > 0.2;

    return '起點(${start.dx.toStringAsFixed(2)},${start.dy.toStringAsFixed(2)}) '
        '終點(${end.dx.toStringAsFixed(2)},${end.dy.toStringAsFixed(2)}) '
        '趨勢:$trend ${isVShape ? "V形" : ""} '
        '高度差:${heightDiff.toStringAsFixed(2)}';
  }

  /// Heuristic-based local tone detection (no API needed for quick feedback)
  static int? detectToneLocally(List<Offset> points, Size canvasSize) {
    if (points.length < 3) return null;

    final norm = points
        .map((p) => Offset(
              p.dx / canvasSize.width,
              1.0 - (p.dy / canvasSize.height),
            ))
        .toList();

    final startY = norm.first.dy;
    final endY = norm.last.dy;
    double minY = 1.0, maxY = 0.0;
    int minIdx = 0;
    for (int i = 0; i < norm.length; i++) {
      if (norm[i].dy < minY) {
        minY = norm[i].dy;
        minIdx = i;
      }
      if (norm[i].dy > maxY) maxY = norm[i].dy;
    }

    final diff = endY - startY;
    final lowestRelPos = minIdx / norm.length;
    final avgY = norm.map((p) => p.dy).reduce((a, b) => a + b) / norm.length;
    final isVShape = lowestRelPos > 0.15 &&
        lowestRelPos < 0.85 &&
        (maxY - minY) > 0.25;

    if (isVShape) return 3; // 三聲
    if (diff.abs() < 0.12 && avgY > 0.55) return 1; // 一聲 (high flat)
    if (diff > 0.15) return 2; // 二聲 rising
    if (diff < -0.15) return 4; // 四聲 falling
    return 1; // fallback
  }
}
