// اختبارات نظام تبديل ستايل التطبيق — الكتالوج، بناء الثيم،
// التخزين والاسترجاع، ومنتقي الستايل بالمعاينات الحية.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import 'package:asthma_care/core/theme/app_palette.dart';
import 'package:asthma_care/core/theme/app_theme.dart';
import 'package:asthma_care/core/theme/theme_controller.dart';
import 'package:asthma_care/presentation/main_shell.dart';
import 'package:asthma_care/presentation/settings/theme_picker_sheet.dart';

void main() {
  setUp(() {
    // الكتالوج حالة عامة — يُعاد للافتراضي قبل كل اختبار
    ThemeCatalog.apply(ThemeCatalog.defaultId);
    // التخزين غير المتزامن يُحاكى في الذاكرة لكل اختبار
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  group('كتالوج الستايلات', () {
    test('خمسة ستايلات بمعرفات فريدة وبيانات عرض مكتملة', () {
      expect(ThemeCatalog.all.length, 5);
      expect(ThemeCatalog.all.keys.toSet().length, 5);
      for (final p in ThemeCatalog.all.values) {
        expect(p.label.trim(), isNotEmpty);
        expect(p.description.trim(), isNotEmpty);
        expect(p.tag.trim(), isNotEmpty);
        expect(p.bgBlobs, isNotEmpty);
      }
    });

    test('ترتيب العرض: الحالي ثم السابق ثم الجديدة', () {
      expect(
        ThemeCatalog.all.keys.toList(),
        ['glass', 'solid', 'mint', 'dawn', 'dusk'],
      );
    });

    test('غراء البنية: زجاج لثلاثة وصلب لاثنين', () {
      expect(ThemeCatalog.all['glass']!.isGlass, isTrue);
      expect(ThemeCatalog.all['mint']!.isGlass, isTrue);
      expect(ThemeCatalog.all['dawn']!.isGlass, isTrue);
      expect(ThemeCatalog.all['solid']!.isGlass, isFalse);
      expect(ThemeCatalog.all['dusk']!.isGlass, isFalse);
    });

    test('استعادة v4 بدقة — قيم «نبض صلب» التاريخية كما حُفظت', () {
      final solid = ThemeCatalog.all['solid']!;
      expect(solid.bgHigh, const Color(0xFFF8F8FC));
      expect(solid.bgDeep, const Color(0xFFEEF0F9));
      expect(solid.glowTint, const Color(0xFF8F7FE8));
      expect(solid.surface, const Color(0xFFFFFFFF));
      expect(solid.surfaceHi, const Color(0xFFF4F5FB));
      expect(solid.brand, const Color(0xFF6558CE));
      expect(solid.textPrimary, const Color(0xFF201D3D));
      // بقعتان خافتتان فقط — نغمة v4 الهادئة
      expect(solid.bgBlobs.length, 2);
      expect(solid.bgBlobs[0].opacity, closeTo(0.10, 0.001));
      expect(solid.bgBlobs[1].opacity, closeTo(0.05, 0.001));
    });

    test('زجاج v5 بقيمه الحالية — الافتراضي لا يتغير', () {
      final glass = ThemeCatalog.all['glass']!;
      expect(glass.bgHigh, const Color(0xFFF5F6FD));
      expect(glass.bgDeep, const Color(0xFFE9ECF8));
      expect(glass.glassFill, const Color(0xA6FFFFFF));
      expect(glass.bgBlobs.length, 4);
      expect(ThemeCatalog.current.id, 'glass');
    });

    test('الهوية ثابتة عبر كل الستايلات — العلامة والوظيفية والحبر', () {
      final reference = ThemeCatalog.all['glass']!;
      for (final p in ThemeCatalog.all.values) {
        expect(p.brand, reference.brand, reason: 'brand of ${p.id}');
        expect(p.brandDeep, reference.brandDeep);
        expect(p.oxygen, reference.oxygen, reason: 'oxygen of ${p.id}');
        expect(p.heart, reference.heart);
        expect(p.airflow, reference.airflow);
        expect(p.environment, reference.environment);
        expect(p.danger, reference.danger);
        expect(p.textPrimary, reference.textPrimary);
        expect(p.textSecondary, reference.textSecondary);
        expect(p.textFaint, reference.textFaint);
        expect(p.navInk, reference.navInk);
      }
    });

    test('apply يتجاهل المعرّفات غير المعروفة بأمان', () {
      ThemeCatalog.apply('nonexistent');
      expect(ThemeCatalog.activeId.value, ThemeCatalog.defaultId);
    });
  });

  group('بناء الثيم', () {
    test('كل لوحة تنتج ThemeData مطابقًا لقيمها', () {
      for (final p in ThemeCatalog.all.values) {
        final theme = AppTheme.from(p);
        expect(theme.scaffoldBackgroundColor, p.bgDeep);
        expect(theme.colorScheme.primary, p.brand);
        expect(theme.colorScheme.secondary, p.oxygen);
        expect(theme.colorScheme.error, p.danger);
        expect(theme.colorScheme.surface, p.surface);
      }
    });

    test('الستايلات تختلف فعليًا في الكانفس', () {
      final glass = AppTheme.from(ThemeCatalog.all['glass']!);
      final solid = AppTheme.from(ThemeCatalog.all['solid']!);
      final mint = AppTheme.from(ThemeCatalog.all['mint']!);
      expect(
        glass.scaffoldBackgroundColor,
        isNot(solid.scaffoldBackgroundColor),
      );
      expect(
        mint.scaffoldBackgroundColor,
        isNot(glass.scaffoldBackgroundColor),
      );
    });

    testWidgets('AppTheme.light يطابق اللوحة النشطة — توافق الاستخدام القديم',
        (tester) async {
      late ThemeData captured;
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light,
        home: Builder(
          builder: (context) {
            captured = Theme.of(context);
            return const SizedBox.shrink();
          },
        ),
      ));
      expect(captured.colorScheme.primary, Aurora.brand);
      expect(captured.scaffoldBackgroundColor, Aurora.bgDeep);
    });
  });

  group('التخزين والاسترجاع', () {
    test('الستايل المحفوظ يُطبَّق قبل أول إطار', () async {
      await SharedPreferencesAsync().setString('themeStyle', 'dusk');
      await loadSavedThemeStyle();
      expect(ThemeCatalog.activeId.value, 'dusk');
    });

    test('القيم غير المعروفة أو المفقودة تُسقط للافتراضي', () async {
      await SharedPreferencesAsync().setString('themeStyle', 'hacked');
      await loadSavedThemeStyle();
      expect(ThemeCatalog.activeId.value, ThemeCatalog.defaultId);
    });

    test('select يبدّل الكتالوج والمزود ويحفظ الاختيار', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(themeStyleProvider), 'glass');
      await container.read(themeStyleProvider.notifier).select('solid');

      expect(container.read(themeStyleProvider), 'solid');
      expect(ThemeCatalog.activeId.value, 'solid');
      final saved = await SharedPreferencesAsync().getString('themeStyle');
      expect(saved, 'solid');
    });
  });

  group('منتقي الستايل', () {
    testWidgets('الخيارات الخمسة ظاهرة والضغط يطبّق فورًا ويحفظ والشيت يبقى',
        (tester) async {
      await tester.pumpWidget(ProviderScope(
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => showThemePickerSheet(context),
                  child: const Text('افتح'),
                ),
              ),
            ),
          ),
        ),
      ));

      await tester.tap(find.text('افتح'));
      await tester.pumpAndSettle();

      // كل الستايلات السابقة والحالية ظاهرة بالمعاينات الحية
      expect(find.text('زجاج نبض'), findsOneWidget);
      expect(find.text('نبض صلب'), findsOneWidget);
      expect(find.text('نبض منعش'), findsOneWidget);
      expect(find.text('نبض الفجر'), findsOneWidget);
      expect(find.text('نبض الغسق'), findsOneWidget);

      await tester.tap(find.text('نبض صلب'));
      await tester.pumpAndSettle();

      expect(ThemeCatalog.activeId.value, 'solid');
      final saved = await SharedPreferencesAsync().getString('themeStyle');
      expect(saved, 'solid');
      // الشيت يبقى مفتوحًا — التبديل حي والمقارنة مستمرة
      expect(find.text('اختر ستايل التطبيق'), findsOneWidget);
    });
  });

  group('إعادة رسم الشاشات عند التبديل', () {
    // فرع مُصغّر بمحتوى يشاهد مزود الستايل — نفس نمط كل شاشات التطبيق:
    // الاعتماد العنصري على المزود هو آلية إعادة الرسم المضمونة.
    GoRouter probeRouter() => GoRouter(
          initialLocation: '/probe',
          routes: [
            StatefulShellRoute.indexedStack(
              builder: (context, state, shell) =>
                  MainShell(navigationShell: shell),
              branches: [
                StatefulShellBranch(routes: [
                  GoRoute(
                    path: '/probe',
                    builder: (_, _) => const _ProbeBranch(),
                  ),
                ]),
              ],
            ),
          ],
        );

    testWidgets('التبديل يعيد رسم محتوى الفرع داخل الهيكل — وعد النظام',
        (tester) async {
      await tester.pumpWidget(ProviderScope(
        child: MaterialApp.router(routerConfig: probeRouter()),
      ));
      await tester.pumpAndSettle();

      Color probeColor() => tester
          .widget<Container>(find.ancestor(
            of: find.text('PROBE'),
            matching: find.byType(Container),
          ).first)
          .color!;

      expect(probeColor(), const Color(0xFFE9ECF8)); // كانفس زجاج نبض

      final container =
          ProviderScope.containerOf(tester.element(find.text('PROBE')));
      await container.read(themeStyleProvider.notifier).select('solid');
      await tester.pumpAndSettle();

      expect(probeColor(), const Color(0xFFEEF0F9)); // كانفس نبض صلب
    });

    testWidgets('الزجاج: كبسولة زجاجية بضباب حقيقي — الصلب: كبسولة حبر بلا ضباب',
        (tester) async {
      await tester.pumpWidget(ProviderScope(
        child: MaterialApp.router(routerConfig: probeRouter()),
      ));
      await tester.pumpAndSettle();

      final container =
          ProviderScope.containerOf(tester.element(find.text('PROBE')));

      // زجاج: كبسولة الشريط زجاج حقيقي — تضباب المحتوى خلفها وتُقص بأركانها
      expect(find.byType(BackdropFilter), findsOneWidget,
          reason: 'كبسولة الزجاج بضباب 24 فوق المحتوى المار خلفها');
      expect(find.byType(ClipRRect), findsOneWidget,
          reason: 'الكبسولة تُقص بأركانها');

      await container.read(themeStyleProvider.notifier).select('solid');
      await tester.pumpAndSettle();

      // صلب: كبسولة الحبر تُقص بأركانها — وما زال بلا ضباب
      expect(find.byType(BackdropFilter), findsNothing);
      expect(find.byType(ClipRRect), findsOneWidget);
    });

    testWidgets('شريط التنقل: كبسولة عائمة بملء العرض بأيقونات وأسماء — والنشط كبسولة مضيئة',
        (tester) async {
      await tester.pumpWidget(ProviderScope(
        child: MaterialApp.router(routerConfig: probeRouter()),
      ));
      await tester.pumpAndSettle();

      // الأسماء ظاهرة تحت الأيقونات (مرجع ذكاري الذي اعتمده المالك)
      for (final label in ['الرئيسية', 'البيانات', 'البيئة', 'الإعدادات']) {
        expect(find.text(label), findsOneWidget,
            reason: 'كل تبويب أيقونة + اسم — «$label» ظاهر');
      }

      // كبسولة النشط الداخلية — المؤشر الوحيد
      Color? activePillColor() => (tester
              .widget<AnimatedContainer>(find
                  .ancestor(
                    of: find.byIcon(Icons.home_rounded),
                    matching: find.byType(AnimatedContainer),
                  )
                  .first)
              .decoration as BoxDecoration)
          .color;
      Color? activeIconColor() =>
          tester.widget<Icon>(find.byIcon(Icons.home_rounded)).color;

      // زجاج: كبسولة النشط بيضاء مضيئة ومحتوانا بنفسجي العلامة العميق
      expect(activePillColor(), Colors.white.withValues(alpha: 0.88));
      expect(activeIconColor(), const Color(0xFF473AAE)); // brandDeep

      // الهندسة: الشريط يكاد يبلغ حاشية الشاشة، متمركز، مثبت أسفلها
      final screenW =
          tester.view.physicalSize.width / tester.view.devicePixelRatio;
      final screenH =
          tester.view.physicalSize.height / tester.view.devicePixelRatio;
      final barRect = tester.getRect(find.byType(BackdropFilter));
      expect(barRect.width, greaterThan(screenW * 0.8),
          reason: 'الشريط بملء العرض تقريبًا — بهامش الحاشية فقط');
      expect((barRect.center.dx - screenW / 2).abs(), lessThan(1.0),
          reason: 'الشريط متمركز أفقيا');
      expect(barRect.bottom, greaterThan(screenH - 100),
          reason: 'الشريط مثبت أسفل الشاشة لا بمنتصفها');
      expect(barRect.height, greaterThan(48),
          reason: 'الشريط يحمل أيقونة واسم لا أيقونة فقط');
      expect(barRect.height, lessThan(76), reason: 'الشريط كبسولة مضغوطة');

      // الخامل على الزجاج بحبر خافت واحد للأيقونة والاسم
      expect(tester.widget<Text>(find.text('الإعدادات')).style?.color,
          const Color(0xFF76748F)); // textFaint
      // أسماء التنقل بصوت العرض Cairo — ثبت العائلة ضد الانحدار الصامت
      expect(tester.widget<Text>(find.text('الرئيسية')).style?.fontFamily,
          'Cairo');

      final container =
          ProviderScope.containerOf(tester.element(find.text('PROBE')));
      await container.read(themeStyleProvider.notifier).select('solid');
      await tester.pumpAndSettle();

      // صلب: كبسولة الحبر البنفسجي التاريخي والنشط كبسولة بيضاء
      final solidBody = find
          .ancestor(
            of: find.byIcon(Icons.home_rounded),
            matching: find.byType(Container),
          )
          .evaluate()
          .map((e) => e.widget as Container)
          .firstWhere(
            (c) => (c.decoration as BoxDecoration?)?.border != null,
          )
          .decoration! as BoxDecoration;
      expect(solidBody.color, const Color(0xFF2B2464)); // navInk
      expect(solidBody.gradient, isNull);
      expect((solidBody.border! as Border).top.color, Colors.transparent);
      expect(activePillColor(), Colors.white);
      expect(activeIconColor(), const Color(0xFF473AAE)); // brandDeep
      // الخامل على الصلب بدرجات الحبر الأبيض التاريخية
      expect(tester.widget<Text>(find.text('الإعدادات')).style?.color,
          const Color(0x99FFFFFF)); // navIdleText
    });
  });
}

/// فرع الاختبار — يطابق نمط الشاشات الحقيقي (watch للستايل + قراءة Aurora).
class _ProbeBranch extends ConsumerWidget {
  const _ProbeBranch();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeStyleProvider);
    return Container(
      color: Aurora.bgDeep,
      alignment: Alignment.center,
      child: const Text('PROBE'),
    );
  }
}
