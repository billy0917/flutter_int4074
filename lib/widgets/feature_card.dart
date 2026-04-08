import 'package:flutter/material.dart';
import '../config/theme.dart';
import 'clay_button.dart';

class FeatureCard extends StatelessWidget {
  final Widget icon;
  final String titleZh;
  final String titleEn;
  final Color color;
  final VoidCallback? onTap;
  final bool comingSoon;
  final bool isWide;

  const FeatureCard({
    super.key,
    required this.icon,
    required this.titleZh,
    required this.titleEn,
    required this.color,
    this.onTap,
    this.comingSoon = false,
    this.isWide = false,
  });

  @override
  Widget build(BuildContext context) {
    return ClayButton(
      color: comingSoon ? AppColors.cardBgAlt : color.withValues(alpha: 0.9),
      radius: 20,
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: Container(
        height: 110,
        width: isWide ? double.infinity : null,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            icon,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titleZh,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: comingSoon
                        ? AppColors.textLight
                        : AppColors.textDark,
                  ),
                ),
                Text(
                  titleEn,
                  style: TextStyle(
                    fontSize: 11,
                    color: comingSoon
                        ? AppColors.textLight
                        : AppColors.textMedium,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
