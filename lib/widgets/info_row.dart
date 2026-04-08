import 'package:flutter/material.dart';
import '../config/theme.dart';

class InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const InfoRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label：',
            style: const TextStyle(
                fontSize: 13, color: AppColors.textMedium)),
        Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w500))),
      ],
    );
  }
}
