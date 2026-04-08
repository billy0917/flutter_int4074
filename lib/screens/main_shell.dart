import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../utils/app_icons.dart';
import 'home_screen.dart';
import 'camera_screen.dart';
import 'history_screen.dart';

/// 主框架：底部導覽列包含 首頁 / 拍照 / 歷史
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  static const _screens = <Widget>[
    HomeScreen(),
    CameraScreen(),
    HistoryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              offset: const Offset(0, -3),
              blurRadius: 10,
            ),
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.7),
              offset: const Offset(0, -1),
              blurRadius: 4,
            ),
          ],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (i) => setState(() => _currentIndex = i),
            backgroundColor: AppColors.cardBg,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.textLight,
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            selectedFontSize: 12,
            unselectedFontSize: 11,
            items: [
              BottomNavigationBarItem(
                icon: AppIcons.svg(AppIcons.home, size: 24, color: AppColors.textLight),
                activeIcon: AppIcons.svg(AppIcons.home, size: 24, color: AppColors.primary),
                label: '首頁',
              ),
              BottomNavigationBarItem(
                icon: _CameraNavIcon(isActive: false),
                activeIcon: _CameraNavIcon(isActive: true),
                label: '拍照',
              ),
              BottomNavigationBarItem(
                icon: AppIcons.svg(AppIcons.history, size: 24, color: AppColors.textLight),
                activeIcon: AppIcons.svg(AppIcons.history, size: 24, color: AppColors.primary),
                label: '記錄',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 拍照按鈕 — 在底部導覽列中居中且稍微突出
class _CameraNavIcon extends StatelessWidget {
  final bool isActive;
  const _CameraNavIcon({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isActive
              ? [AppColors.primary, const Color(0xFFFF7535)]
              : [AppColors.textLight.withValues(alpha: 0.3), AppColors.textLight.withValues(alpha: 0.15)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.35),
                  offset: const Offset(0, 4),
                  blurRadius: 10,
                ),
              ]
            : [],
      ),
      child: AppIcons.svg(
        AppIcons.camera,
        size: 22,
        color: isActive ? Colors.white : AppColors.textMedium,
      ),
    );
  }
}
