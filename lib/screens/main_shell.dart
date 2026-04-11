import 'dart:ui';
import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../utils/app_icons.dart';
import '../utils/responsive.dart';
import 'home_screen.dart';
import 'camera_screen.dart';
import 'history_screen.dart';

/// 主框架：底部導覽列 — iOS 26 liquid glass 風格
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late final AnimationController _fabController;
  late final Animation<double> _fabScale;

  static const _screens = <Widget>[
    HomeScreen(),
    CameraScreen(),
    HistoryScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _fabScale = Tween<double>(begin: 1.0, end: 0.88).animate(
      CurvedAnimation(parent: _fabController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  void _onTap(int i) {
    if (i == 1) {
      _fabController.forward().then((_) => _fabController.reverse());
    }
    setState(() => _currentIndex = i);
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;
    final navHeight = context.s(68) + bottomPadding;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      extendBody: false,
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
          child: Container(
            height: navHeight,
            decoration: BoxDecoration(
              // Liquid glass: translucent tinted base
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withValues(alpha: 0.55),
                  Colors.white.withValues(alpha: 0.35),
                  AppColors.background.withValues(alpha: 0.30),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
              // Top specular highlight
              border: Border(
                top: BorderSide(
                  color: Colors.white.withValues(alpha: 0.6),
                  width: 0.5,
                ),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.only(bottom: bottomPadding),
              child: Row(
                children: [
                  // 首頁
                  Expanded(
                    child: _GlassNavItem(
                      iconPath: AppIcons.home,
                      label: '首頁',
                      isActive: _currentIndex == 0,
                      onTap: () => _onTap(0),
                    ),
                  ),
                  // 拍照 (center FAB)
                  Expanded(
                    child: Center(
                      child: GestureDetector(
                        onTap: () => _onTap(1),
                        child: ScaleTransition(
                          scale: _fabScale,
                          child: _GlassCameraFab(isActive: _currentIndex == 1),
                        ),
                      ),
                    ),
                  ),
                  // 記錄
                  Expanded(
                    child: _GlassNavItem(
                      iconPath: AppIcons.history,
                      label: '記錄',
                      isActive: _currentIndex == 2,
                      onTap: () => _onTap(2),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Liquid glass nav item — pill-shaped active indicator
class _GlassNavItem extends StatelessWidget {
  final String iconPath;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _GlassNavItem({
    required this.iconPath,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Pill background for active state
            AnimatedContainer(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOut,
              padding: EdgeInsets.symmetric(
                horizontal: isActive ? 18 : 14,
                vertical: isActive ? 6 : 4,
              ),
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.primary.withValues(alpha: 0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: AppIcons.svg(
                iconPath,
                size: 24,
                color: isActive ? AppColors.primary : AppColors.textLight,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? AppColors.primary : AppColors.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Liquid glass camera FAB
class _GlassCameraFab extends StatelessWidget {
  final bool isActive;
  const _GlassCameraFab({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.s(56),
      height: context.s(56),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isActive
              ? [const Color(0xFFFF9A5C), AppColors.primary]
              : [
                  AppColors.primary.withValues(alpha: 0.65),
                  AppColors.primary.withValues(alpha: 0.45),
                ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: isActive ? 0.40 : 0.18),
            offset: const Offset(0, 4),
            blurRadius: 16,
            spreadRadius: isActive ? 1 : 0,
          ),
        ],
      ),
      // Inner frosted glass overlay
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.center,
            colors: [
              Colors.white.withValues(alpha: 0.30),
              Colors.white.withValues(alpha: 0.0),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppIcons.svg(AppIcons.camera, size: context.s(22), color: Colors.white),
            const SizedBox(height: 1),
            const Text(
              '拍照',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                height: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
