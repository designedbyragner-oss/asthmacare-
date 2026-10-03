// اختبار سلكة — صفحة الاقتران «سوارك وجهاز البيئة» تعرض صور العتاد
// الحقيقية لا أيقونة عامة (2026-10-02: دمج صور الأجهزة في الواجهات).
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import 'package:asthma_care/core/theme/app_theme.dart';
import 'package:asthma_care/presentation/onboarding/pairing_screen.dart';
import 'package:asthma_care/presentation/shared_widgets/device_images.dart';

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  Future<void> pumpPairing(WidgetTester tester) async {
    await tester.pumpWidget(ProviderScope(
      child: MaterialApp(
        theme: AppTheme.light,
        locale: const Locale('ar'),
        supportedLocales: const [Locale('ar'), Locale('en')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const Scaffold(body: PairingScreen()),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 300));
  }

  Finder assetImage(String asset) => find.byWidgetPredicate(
        (w) =>
            w is Image &&
            w.image is AssetImage &&
            (w.image as AssetImage).assetName == asset,
      );

  testWidgets('صفحة الأجهزة ترسم صورتي السوار وجهاز البيئة',
      (tester) async {
    await pumpPairing(tester);

    // الصفحة الأولى ترحيبية بأيقونة — ننتقل إلى صفحة الأجهزة
    await tester.tap(find.text('التالي'));
    await tester.pumpAndSettle();

    expect(find.byType(DevicePhoto), findsNWidgets(2));
    expect(assetImage(DeviceImages.band), findsOneWidget);
    expect(assetImage(DeviceImages.env), findsOneWidget);
    expect(find.text('سوار المراقبة'), findsOneWidget);
    expect(find.text('جهاز البيئة'), findsOneWidget);
  });
}
