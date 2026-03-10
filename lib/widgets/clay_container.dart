import 'package:flutter/material.dart';
import '../config/theme.dart';

class ClayContainer extends StatelessWidget {
  final Widget child;
  final Color? color;
  final double radius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;

  const ClayContainer({
    super.key,
    required this.child,
    this.color,
    this.radius = 24,
    this.padding,
    this.margin,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: clayDecoration(
        color: color ?? AppColors.cardBg,
        radius: radius,
      ),
      child: child,
    );
  }
}
