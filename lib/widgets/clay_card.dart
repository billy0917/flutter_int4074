import 'package:flutter/material.dart';
import '../config/theme.dart';

class ClayCard extends StatelessWidget {
  final Widget child;
  final Color? color;
  final double radius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;

  const ClayCard({
    super.key,
    required this.child,
    this.color,
    this.radius = 24,
    this.padding,
    this.margin,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      margin: margin,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: clayDecoration(
        color: color ?? AppColors.cardBg,
        radius: radius,
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: card);
    }
    return card;
  }
}
