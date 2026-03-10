import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../utils/constants.dart';
import 'tone_painter.dart';

class ToneDisplay extends StatelessWidget {
  final int toneNumber;
  final String? toneNameZh;
  final String? toneNameEn;
  final bool showLabel;

  const ToneDisplay({
    super.key,
    required this.toneNumber,
    this.toneNameZh,
    this.toneNameEn,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppConstants.toneColor(toneNumber);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.5)),
          ),
          child: Column(
            children: [
              ToneContourWidget(toneNumber: toneNumber, width: 60, height: 30),
              const SizedBox(height: 4),
              Text(
                AppConstants.toneShape(toneNumber),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
        if (showLabel && toneNameZh != null) ...[
          const SizedBox(height: 4),
          Text(
            toneNameZh!,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textMedium,
            ),
          ),
        ],
      ],
    );
  }
}
