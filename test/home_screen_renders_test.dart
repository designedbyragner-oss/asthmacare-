// اختبار انحدار — الرئيسية ترسم كل محتواها داخل قابل للتمرير.
// جذر الإصلاح (2026-10-02): MetricCard استخدمت Spacer رأسيًا داخل ListView
// (ارتفاع غير محدود) فكان تخطيط القائمة كله يفشل بصمت ولا يُرسم شيء.
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import 'package:asthma_care/application/providers.dart';
import 'package:asthma_care/core/theme/app_theme.dart';
import 'package:asthma_care/data/models/models.dart';
import 'package:asthma_care/presentation/home/home_screen.dart';

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  Future<void> pumpHome(WidgetTester tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        alertsStreamProvider.overrideWith((ref) => Stream.value(<AppAlert>[])),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        locale: const Locale('ar'),
        supportedLocales: const [Locale('ar'), Locale('en')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const Scaffold(body: HomeScreen()),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 300));
  }

  testWidgets('الرئيسية ترسم الترويسة والحلقة أعلى الشاشة', (tester) async {
    await pumpHome(tester);
    expect(find.textContaining('مرحبًا'), findsWidgets);
    expect(find.text('مستوى الأكسجين'), findsOneWidget);
  });

  testWidgets('الرئيسية ترسم مؤشر الخطر وبلاطات المؤشرات بعد التمرير',
      (tester) async {
    await pumpHome(tester);

    // مؤشر خطر الربو — القسم الذي كان يكشف فشل التخطيط الصامت
    await tester.scrollUntilVisible(
      find.text('مؤشر خطر الربو'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('مؤشر خطر الربو'), findsOneWidget);

    // بلاطات المؤشرات — كانت Spacer داخلها تُفجّر تخطيط القائمة
    await tester.scrollUntilVisible(
      find.text('النبض'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('النبض'), findsOneWidget);
    expect(find.text('التنفس'), findsOneWidget);

    // النصائح اليومية في آخر القائمة
    await tester.scrollUntilVisible(
      find.text('نصائح يومية'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('نصائح يومية'), findsOneWidget);
  });
}
