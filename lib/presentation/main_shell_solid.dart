/// ─────────────────────────────────────────────────────────────
/// الهيكل الرئيسي — شريط تنقل كبسولي عائم (توقيع الهوية):
/// كبسولة بحبر بنفسجي عميق تطفو فوق المحتوى بظل ناعم، والعنصر النشط
/// دائرة بيضاء تحمل أيقونة داكنة — عكس الألوان كحالة اختيار.
/// ─────────────────────────────────────────────────────────────
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:asthma_care/core/theme/app_theme.dart';
import 'package:asthma_care/presentation/shared_widgets/widgets.dart';

class MainShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainShell({super.key, required this.navigationShell});

  static const _items = [
    (Icons.home_rounded, 'الرئيسية'),
    (Icons.insert_chart_rounded, 'البيانات'),
    (Icons.eco_rounded, 'البيئة'),
    (Icons.settings_rounded, 'الإعدادات'),
  ];

  @override
  Widget build(BuildContext context) {
    final currentIndex = navigationShell.currentIndex;
    return Scaffold(
      body: AppBackground(child: SafeArea(child: navigationShell)),
      extendBody: true,
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 14),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
        decoration: BoxDecoration(
          color: Aurora.navInk,
          borderRadius: BorderRadius.circular(Aurora.rPill),
          boxShadow: Aurora.navShadow,
        ),
        child: Row(
          children: [
            for (var i = 0; i < _items.length; i++)
              Expanded(
                child: _NavItem(
                  item: _items[i],
                  active: i == currentIndex,
                  onTap: () => _tap(i),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _tap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}

class _NavItem extends StatelessWidget {
  final (IconData, String) item;
  final bool active;
  final VoidCallback onTap;

  const _NavItem({required this.item, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // الدائرة البيضاء — تعلن الموقع بعكس الألوان
          AnimatedContainer(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: active ? Colors.white : Colors.transparent,
              boxShadow: active
                  ? [
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.25),
                        blurRadius: 10,
                        spreadRadius: -2,
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              item.$1,
              size: 20,
              color: active ? Aurora.brandDeep : Aurora.navIdleIcon,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            item.$2,
            style: TextStyle(
              fontFamily: AuroraText.family,
              fontSize: 11,
              fontWeight: active ? FontWeight.w700 : FontWeight.w400,
              color: active ? Colors.white : Aurora.navIdleText,
            ),
          ),
        ],
      ),
    );
  }
}
