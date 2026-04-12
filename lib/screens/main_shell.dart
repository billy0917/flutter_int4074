import 'package:flutter/material.dart';
import 'package:flutter_app/l10n/app_localizations.dart';

import '../utils/responsive.dart';
import 'home_screen.dart';
import 'camera_screen.dart';
import 'history_screen.dart';

/// 主框架：底部浮動 Dock 風格導覽列
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

  void _onTap(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final bottomPad = MediaQuery.of(context).viewPadding.bottom;
    final horizontalInset = context.s(18);
    final bottomInset = context.s(10);
    final dockHeight = context.s(78);
    final cornerRadius = context.s(30);
    final notchOffsetX = -context.s(17);
    final internalBottomPad = bottomPad > bottomInset ? bottomPad : bottomInset;
    const activeColor = Color(0xFF955825);
    const inactiveColor = Color(0xFFC69A73);

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _CameraDockButton(
        size: context.s(76),
        active: _currentIndex == 1,
        onTap: () => _onTap(1),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(
          horizontalInset,
          0,
          horizontalInset,
          bottomInset,
        ),
        child: BottomAppBar(
          elevation: 22,
          color: const Color.fromARGB(255, 255, 216, 177),
          surfaceTintColor: Colors.transparent,
          shadowColor: const Color(0x332E1605),
          padding: EdgeInsets.zero,
          notchMargin: context.s(7),
          shape: _ShiftedNotchShape(
            offsetX: notchOffsetX,
            base: AutomaticNotchedShape(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(cornerRadius),
                side: BorderSide(
                  color: Colors.white.withValues(alpha: 0.92),
                  width: 1.2,
                ),
              ),
              const StadiumBorder(),
            ),
          ),
          child: SizedBox(
            height: dockHeight + bottomPad,
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  child: IgnorePointer(
                    child: Container(
                      height: context.s(18),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white.withValues(alpha: 0.65),
                            Colors.white.withValues(alpha: 0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    context.s(12),
                    context.s(10),
                    context.s(12),
                    internalBottomPad,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: _DockTab(
                          icon: Icons.explore_rounded,
                          label: l.navHome,
                          active: _currentIndex == 0,
                          activeColor: activeColor,
                          inactiveColor: inactiveColor,
                          onTap: () => _onTap(0),
                        ),
                      ),
                      Expanded(
                        child: _CenterDockLabel(
                          label: l.navCamera,
                          active: _currentIndex == 1,
                          activeColor: activeColor,
                          inactiveColor: inactiveColor,
                          onTap: () => _onTap(1),
                        ),
                      ),
                      Expanded(
                        child: _DockTab(
                          icon: Icons.history_rounded,
                          label: l.navHistory,
                          active: _currentIndex == 2,
                          activeColor: activeColor,
                          inactiveColor: inactiveColor,
                          onTap: () => _onTap(2),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ShiftedNotchShape extends NotchedShape {
  final NotchedShape base;
  final double offsetX;

  const _ShiftedNotchShape({required this.base, required this.offsetX});

  @override
  Path getOuterPath(Rect host, Rect? guest) {
    final shiftedGuest = guest == null ? null : guest.shift(Offset(offsetX, 0));
    return base.getOuterPath(host, shiftedGuest);
  }
}

class _DockTab extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final Color activeColor;
  final Color inactiveColor;
  final VoidCallback onTap;

  const _DockTab({
    required this.icon,
    required this.label,
    required this.active,
    required this.activeColor,
    required this.inactiveColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? activeColor : inactiveColor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(context.s(24)),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: context.s(2)),
          child: AnimatedSlide(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            offset: active ? Offset.zero : const Offset(0, 0.05),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedScale(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  scale: active ? 1.08 : 0.96,
                  child: Icon(
                    icon,
                    size: active ? context.s(24) : context.s(22),
                    color: color,
                  ),
                ),
                SizedBox(height: context.s(4)),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  style: TextStyle(
                    fontSize: context.sp(13),
                    fontWeight: active ? FontWeight.w700 : FontWeight.w600,
                    color: color,
                    letterSpacing: 0.2,
                  ),
                  child:
                      Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CenterDockLabel extends StatelessWidget {
  final String label;
  final bool active;
  final Color activeColor;
  final Color inactiveColor;
  final VoidCallback onTap;

  const _CenterDockLabel({
    required this.label,
    required this.active,
    required this.activeColor,
    required this.inactiveColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? activeColor : inactiveColor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(context.s(18)),
        onTap: onTap,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.only(bottom: context.s(2)),
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              style: TextStyle(
                fontSize: context.sp(13),
                fontWeight: active ? FontWeight.w800 : FontWeight.w700,
                color: color,
                letterSpacing: 0.2,
              ),
              child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ),
        ),
      ),
    );
  }
}

class _CameraDockButton extends StatelessWidget {
  final double size;
  final bool active;
  final VoidCallback onTap;

  const _CameraDockButton({
    required this.size,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final buttonSize = active ? size + context.s(4) : size;
    final glowSize = buttonSize + context.s(16);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: buttonSize,
          height: buttonSize,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              IgnorePointer(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  width: glowSize,
                  height: glowSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withValues(
                          alpha: active ? 0.48 : 0.38,
                        ),
                        blurRadius: active ? 20 : 16,
                        spreadRadius: active ? 1 : 0,
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                width: buttonSize,
                height: buttonSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFFFB35E), Color(0xFFEF7A1F)],
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.96),
                    width: context.s(4),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0x45EF7A1F),
                      blurRadius: active ? 28 : 22,
                      spreadRadius: active ? 4 : 1,
                      offset: const Offset(0, 16),
                    ),
                    BoxShadow(
                      color: const Color(0x332E1605),
                      blurRadius: 18,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.camera_alt_rounded,
                    size: buttonSize * 0.42,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
