/// اختبارات ودجة مؤشر خطر الربو — النسبة واسم المنطقة والسبب والتذييل
/// داخل MaterialApp (RTL) كما تُعرض في الرئيسية.
library;

import 'package:asthma_care/data/models/models.dart';
import 'package:asthma_care/presentation/shared_widgets/risk_gauge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

RiskAssessment _assessment({
  required RiskLevel level,
  required int score,
  List<String> reasons = const [],
}) =>
    RiskAssessment(
      level: level,
      score: score,
      reasons: reasons,
      evaluatedAt: DateTime.now(),
    );

Future<void> _pumpGauge(WidgetTester tester, RiskAssessment assessment) async {
  await tester.pumpWidget(MaterialApp(
    home: Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Center(child: RiskGauge(assessment: assessment)),
      ),
    ),
  ));
  await tester.pumpAndSettle(); // انتهاء حركة القوس (450ms)
}

void main() {
  testWidgets('حالة انتباه بدرجة 5: تعرض 75% واسم المنطقة والسبب والتذييل',
      (tester) async {
    await _pumpGauge(
      tester,
      _assessment(
        level: RiskLevel.attention,
        score: 5,
        reasons: ['معدل التنفس أعلى من خط الأساس بـ 7 نفس/دقيقة'],
      ),
    );

    expect(find.text('مؤشر خطر الربو'), findsOneWidget);
    expect(find.text('75%'), findsOneWidget);
    expect(find.text('احتمال بداية نوبة'), findsOneWidget);
    expect(find.text('معدل التنفس أعلى من خط الأساس بـ 7 نفس/دقيقة'),
        findsOneWidget);
    expect(find.text('مؤشر إرشادي وليس تشخيصًا — يعتمد على خط أساسك الشخصي.'),
        findsOneWidget);
    // النص الافتراضي للمنطقة لا يظهر عندما يوجد سبب من المحرك
    expect(find.text('راقب الأعراض وأبقِ خطة العمل الشخصية قريبة.'),
        findsNothing);
  });

  testWidgets('حالة طبيعية: تعرض 0% و«طبيعي» والنص الافتراضي', (tester) async {
    await _pumpGauge(tester, _assessment(level: RiskLevel.normal, score: 0));

    expect(find.text('0%'), findsOneWidget);
    expect(find.text('طبيعي'), findsOneWidget);
    expect(find.text('لا أنماط تستحق الانتباه الآن — تقييم دوري مستمر.'),
        findsOneWidget);
  });

  testWidgets('حالة خطر مرتفع: تعرض 76% واسم المنطقة الحمراء والسبب',
      (tester) async {
    await _pumpGauge(
      tester,
      _assessment(
        level: RiskLevel.highRiskPattern,
        score: 6,
        reasons: ['انخفاض مستمر في تشبع الأكسجين'],
      ),
    );

    expect(find.text('76%'), findsOneWidget);
    expect(find.text('خطر مرتفع — احتمال نوبة'), findsOneWidget);
    expect(find.text('انخفاض مستمر في تشبع الأكسجين'), findsOneWidget);
    expect(
        find.text('اتبع خطة العمل الشخصية، وتواصل مع طبيبك إذا استمرت الأعراض.'),
        findsNothing); // السبب من المحرك يحل محل النص الافتراضي
  });
}
