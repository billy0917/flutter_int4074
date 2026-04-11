import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_app/l10n/app_localizations.dart';
import '../utils/responsive.dart';
import 'home_screen.dart';
import 'camera_screen.dart';
import 'history_screen.dart';

/// 主框架：底部浮動暗色玻璃 Dock 風格導覽列
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late final AnimationController _hlCtrl;
  late Animation<double> _hlAnim; // 0.0 → 1.0 → 2.0  (tab index as double)

  static const _screens = <Widget>[
    HomeScreen(),
    CameraScreen(),
    HistoryScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _hlCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _hlAnim = const AlwaysStoppedAnimation(0.0);
  }

  @override
  void dispose() {
    _hlCtrl.dispose();
    super.dispose();
  }

  void _onTap(int i) {
    if (i == _currentIndex) return;
    _hlAnim = Tween<double>(
            begin: _currentIndex.toDouble(), end: i.toDouble())
        .animate(
            CurvedAnimation(parent: _hlCtrl, curve: Curves.easeInOutCubic));
    _hlCtrl.forward(from: 0);
    setState(() => _currentIndex = i);
  }

  static const _icons = <IconData>[
    Icons.explore_outlined,
    Icons.camera_alt_rounded,
    Icons.history_rounded,
  ];
  static const _activeIcons = <IconData>[
    Icons.explore,
    Icons.camera_alt_rounded,
    Icons.history_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final bottomPad = MediaQuery.of(context).viewPadding.bottom;
    final dockH = context.s(68);
    final hMargin = context.s(16);
    final dockRadius = dockH / 2; // full pill
    final labels = <String>[l.navHome, l.navCamera, l.navHistory];

    return Scaffold(
      extendBody: false,
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
          left: hMargin,
          right: hMargin,
          bottom: bottomPad + context.s(10),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(dockRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 38, sigmaY: 38),
            child: Container(
              height: dockH,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(dockRadius),
                // Dark semi-transparent glass
                color: const Color.fromARGB(255, 255, 232, 214).withValues(alpha: 1), //透明度
                border: Border.all(
                  color: const Color.fromARGB(255, 255, 170, 107).withValues(alpha: 0.12),
                  width: 0.8,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 24,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: LayoutBuilder(builder: (ctx, box) {
                final slotW = box.maxWidth / 3;
                final hlW = slotW - context.s(10);
                final hlH = dockH - context.s(12);

                return AnimatedBuilder(
                  animation: _hlAnim,
                  builder: (_, __) {
                    final t = _hlAnim.value; // 0..2
                    final hlLeft =
                        (slotW - hlW) / 2 + t * slotW;

                    return Stack(
                      children: [
                        // ── Active highlight pill
                        Positioned(
                          left: hlLeft,
                          top: (dockH - hlH) / 2,
                          child: Container(
                            width: hlW,
                            height: hlH,
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(hlH / 2),
                              color: const Color.fromARGB(255, 255, 219, 191),
                              border: Border.all(
                                color:
                                    Colors.white.withValues(alpha: 0.08),
                                width: 0.5,
                              ),
                            ),
                          ),
                        ),
                        // ── Icons row
                        Row(
                          children: List.generate(3, (i) {
                            final active = _currentIndex == i;
                            final itemColor = i == 1
                                ? const Color.fromARGB(255, 255, 140, 66)
                                : const Color(0xFF9C5C2A);
                            return Expanded(
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () => _onTap(i),
                                child: AnimatedScale(
                                  scale: active ? 1.3 : 1.0,
                                  duration: const Duration(milliseconds: 260),
                                  curve: Curves.easeOutCubic,
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        active
                                            ? _activeIcons[i]
                                            : _icons[i],
                                        size: context.s(24),
                                        color: itemColor,
                                        shadows: null,
                                      ),
                                      SizedBox(height: context.s(3)),
                                      Text(
                                        labels[i],
                                        style: TextStyle(
                                          fontSize: context.sp(10),
                                          fontWeight: active
                                              ? FontWeight.w600
                                              : FontWeight.w400,
                                          color: itemColor,
                                          shadows: null,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    );
                  },
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
