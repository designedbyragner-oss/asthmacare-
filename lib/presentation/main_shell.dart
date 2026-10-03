/// ─────────────────────────────────────────────────────────────
/// الهيكل الرئيسي — كبسولة تنقل عائمة بملء العرض (مرجع المالك
/// 2026-10-03: شريط «ذكاري» الزجاجي):
/// شريط كبسولة عائم أسفل الصفحة يكاد يبلغ حاشية الشاشة، والمحتوى
/// يمر خلفه فيظهر مضبّبًا عبر الزجاج. كل تبويب أيقونة + اسم،
/// والنشط داخل كبسولة داخلية أشد لمعانًا هي المؤشر الوحيد —
/// بلا نقاط ولا هالات.
/// الستايل الزجاجي: زجاج أبيض مضيء بمفردات بطاقات الزجاج نفسها
/// (تدرج glassFillStrong→glassFill، حد glassBorder، ظل glassShadow،
/// ضباب 24) والنشط كبسولة بيضاء بمحتوى brandDeep.
/// الستايل الصلب: كبسولة بحبر بنفسجي عميق مسطّح والنشط كبسولة
/// بيضاء بمحتوى البنفسجي العميق — نفس الهندسة، انعكاس الأسطح.
/// كلٌّ من الشريط والشاشات تعتمد مزود الستايل (ref.watch) — فيُعاد
/// بناؤها فور التبديل من اللوحة الجديدة.
/// ─────────────────────────────────────────────────────────────
library;

import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:asthma_care/core/theme/app_theme.dart';
import 'package:asthma_care/core/theme/theme_controller.dart';
import 'package:asthma_care/presentation/shared_widgets/widgets.dart';

class MainShell extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const MainShell({super.key, required this.navigationShell});

  static const _items = [
    (Icons.home_rounded, 'الرئيسية'),
    (Icons.insert_chart_rounded, 'البيانات'),
    (Icons.eco_rounded, 'البيئة'),
    (Icons.settings_rounded, 'الإعدادات'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // اعتماد الهيكل على الستايل — الكبسولة والخلفية يُعادان بناءهما هنا،
    // وكل شاشة تعتمد المزود بنفسها (انظر نمط ref.watch في الشاشات).
    ref.watch(themeStyleProvider);
    final currentIndex = navigationShell.currentIndex;
    // مع الشاشة كاملة الحافة، الكبسولة يجب أن ترتفع فوق مساحة أزرار
    // النظام — وإلا تراكبت معها (لا تضيف Scaffold المسافة تلقائيًا)
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    return Scaffold(
      // bottom: false — نافذة المحتوى تمتد خلف الكبسولة الزجاجية فيظهر
      // ما تحتويه مضبّبًا عبرها (extendBody يحقن حشوة سفلية تساوي
      // خانة الشريط، وكل شاشة تبويب تديرها بحشوة قائمتها نفسها).
      body: AppBackground(
        child: SafeArea(bottom: false, child: navigationShell),
      ),
      extendBody: true,
      bottomNavigationBar: _buildBar(currentIndex, bottomInset),
    );
  }

  Widget _buildBar(int currentIndex, double bottomInset) {
    final onGlass = Aurora.isGlass;
    // heightFactor: 1 يُصغّر خانة الشريط لحجم المحتوى — فما حوله يبقى
    // كانفس الجسم (Center وحدها تمتد لملء الارتفاع وتبتلع الجسم).
    return Align(
      alignment: Alignment.bottomCenter,
      heightFactor: 1,
      child: Container(
        margin: EdgeInsets.fromLTRB(20, 0, 20, 14 + bottomInset),
        // ظل الكبسولة على الحاوية الخارجية — القصّ الداخلي يبتلع ظل
        // ما بداخله.
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Aurora.rPill),
          boxShadow: onGlass ? Aurora.glassShadow : Aurora.navShadow,
        ),
        child: RepaintBoundary(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(Aurora.rPill),
            child: onGlass
                ? BackdropFilter(
                    // الضباب للأسطح الكبيرة فقط — والكبسولة من ضمنها
                    filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                    child: _barBody(currentIndex, onGlass),
                  )
                : _barBody(currentIndex, onGlass),
          ),
        ),
      ),
    );
  }

  /// جسم الكبسولة: زجاج أبيض مضيء فوق الخلفية الحية، أو حبر بنفسجي
  /// مسطّح في الصلب — والتبويبات موزعة بانتظام على كامل العرض.
  Widget _barBody(int currentIndex, bool onGlass) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: onGlass ? null : Aurora.navInk,
        gradient: onGlass
            ? LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Aurora.glassFillStrong, Aurora.glassFill],
              )
            : null,
        borderRadius: BorderRadius.circular(Aurora.rPill),
        border: Border.all(
          color: onGlass ? Aurora.glassBorder : Colors.transparent,
        ),
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

  const _NavItem({
    required this.item,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // أيقونة + اسم — الكبسولة المضيئة حول النشط هي المؤشر الوحيد.
    // محتوى النشط brandDeep على السطحين (كبسولته بيضاء)، والخامل
    // بحبر السطح: textFaint على الزجاج، ودرجات الحبر الأبيض على الصلب.
    final onGlass = Aurora.isGlass;
    final contentColor = active
        ? Aurora.brandDeep
        : (onGlass ? Aurora.textFaint : Aurora.navIdleIcon);
    final labelColor = active
        ? Aurora.brandDeep
        : (onGlass ? Aurora.textFaint : Aurora.navIdleText);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Aurora.rPill),
            color: active
                ? (onGlass
                      ? Colors.white.withValues(alpha: 0.88)
                      : Colors.white)
                : Colors.transparent,
            boxShadow: active
                ? [
                    BoxShadow(
                      color: onGlass
                          // ارتفاع خاطف تحت الكبسولة — لا توهج زخرفي
                          ? Aurora.brandDeep.withValues(alpha: 0.22)
                          : Colors.white.withValues(alpha: 0.25),
                      blurRadius: 10,
                      spreadRadius: -2,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(item.$1, size: 22, color: contentColor),
              const SizedBox(height: 4),
              Text(
                item.$2,
                style: TextStyle(
                  fontFamily: AuroraText.familyDisplay,
                  fontSize: 11,
                  height: 1.15,
                  fontWeight: FontWeight.w600,
                  color: labelColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
