import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/theme.dart';

class ClayButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color color;
  final double? width;
  final double? height;
  final double radius;
  final EdgeInsetsGeometry padding;

  const ClayButton({
    super.key,
    required this.child,
    this.onTap,
    this.color = AppColors.primary,
    this.width,
    this.height,
    this.radius = 20,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
  });

  @override
  State<ClayButton> createState() => _ClayButtonState();
}

class _ClayButtonState extends State<ClayButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 150),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(_) {
    if (widget.onTap == null) return;
    setState(() => _isPressed = true);
    _controller.forward();
    HapticFeedback.lightImpact();
  }

  void _onTapUp(_) {
    if (widget.onTap == null) return;
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  void _onTapCancel() {
    if (widget.onTap == null) return;
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    final effectiveColor =
        enabled ? widget.color : widget.color.withOpacity(0.5);

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnim.value,
          child: container(effectiveColor),
        ),
      ),
    );
  }

  Widget container(Color color) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      width: widget.width,
      height: widget.height,
      padding: widget.padding,
      decoration: clayDecoration(
        color: color,
        radius: widget.radius,
        isPressed: _isPressed,
      ),
      child: widget.child,
    );
  }
}
