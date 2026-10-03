// اختبار دخان أساسي — يتحقق من زر الفعل الأساسي (المكوّن المحوري للهوية).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:asthma_care/core/theme/app_theme.dart';
import 'package:asthma_care/presentation/shared_widgets/widgets.dart';

void main() {
  testWidgets('PrimaryButton يعرض نصه ويستجيب للضغط', (tester) async {
    var pressed = false;
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: Center(
          child: PrimaryButton(label: 'ابدأ', onPressed: () => pressed = true),
        ),
      ),
    ));

    expect(find.text('ابدأ'), findsOneWidget);
    await tester.tap(find.text('ابدأ'));
    expect(pressed, isTrue);
  });

  testWidgets('الثيم الفاتح يشتق ألوان النص من نظام الهوية', (tester) async {
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
}
