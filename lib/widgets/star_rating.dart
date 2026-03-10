import 'package:flutter/material.dart';
import '../config/theme.dart';

class StarRating extends StatefulWidget {
  final int stars; // 0-3
  final double size;
  final bool animate;

  const StarRating({
    super.key,
    required this.stars,
    this.size = 48,
    this.animate = true,
  });

  @override
  State<StarRating> createState() => _StarRatingState();
}

class _StarRatingState extends State<StarRating>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      3,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400),
      ),
    );
    _animations = _controllers
        .map((c) => CurvedAnimation(parent: c, curve: Curves.elasticOut))
        .toList();

    if (widget.animate) {
      _startAnimation();
    } else {
      for (int i = 0; i < widget.stars; i++) {
        _controllers[i].value = 1.0;
      }
    }
  }

  Future<void> _startAnimation() async {
    for (int i = 0; i < widget.stars; i++) {
      await Future.delayed(Duration(milliseconds: i * 200));
      if (mounted) _controllers[i].forward();
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        final filled = i < widget.stars;
        return ScaleTransition(
          scale: filled ? _animations[i] : const AlwaysStoppedAnimation(1.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Icon(
              filled ? Icons.star_rounded : Icons.star_outline_rounded,
              color: filled ? AppColors.star : AppColors.textLight,
              size: widget.size,
            ),
          ),
        );
      }),
    );
  }
}
