import 'package:flutter/material.dart';

/// Responsive sizing utility based on a 375 px reference design width.
///
/// Usage:
///   context.s(48)  — scale a general dimension (icon size, container, radius)
///   context.sp(16) — scale a font size (slightly tighter upper bound)
extension Responsive on BuildContext {
  double get _sw => MediaQuery.of(this).size.width;

  /// General scale factor — clamped so the UI never shrinks below 82 %
  /// or grows beyond 120 % of the reference design.
  double get sf => (_sw / 375.0).clamp(0.82, 1.2);

  /// Scale a general dimension (spacing, container size, icon size, radius).
  double s(double v) => v * sf;

  /// Scale a font size — tighter upper bound to prevent text overflow.
  double sp(double v) => v * (_sw / 375.0).clamp(0.85, 1.1);
}
