/// اختبار انحدار هندسي لحلقة الحالة: كل نصوص الحلقة (القيمة الكبيرة
/// ونص المصدر) يجب أن تبقى داخل نصف القطر الداخلي للحلقة المرسومة —
/// لا خروج للنص عن الدائرة مهما طال النص أو كُبِّر خط النظام.
/// يعتمد خطوط الإنتاج الحقيقية (Cairo/Tajawal) لقياسات مطابقة للجهاز.
library;

import 'dart:io';

import 'package:asthma_care/presentation/shared_widgets/status_ring.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _loadFont(String family, List<String> files) async {
  final loader = FontLoader(family);
  for (final f in files) {
    final bytes = File('assets/fonts/$f').readAsBytesSync();
    loader.addFont(Future.value(ByteData.view(bytes.buffer)));
  }
  await loader.load();
}

Future<void> _pumpRing(
  WidgetTester tester, {
  required double size,
  required String valueLabel,
  required String label,
  double textScale = 1.0,
}) async {
  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Center(
          child: StatusRing(
            size: size,
            value: 76,
            color: const Color(0xFF39C48F),
            icon: Icons.eco_rounded,
            valueLabel: valueLabel,
            label: label,
            // هالة التنفس أنيميشن لا نهائي — يُعطَّل ليتسنى pumpAndSettle
            breathe: false,
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// يتحقق أن كل حرف مرسومٍ من النص داخل الدائرة الداخلية للحلقة.
/// نصف القطر الداخلي = size/2 − 9 (إزاحة مركز قوس الرسام) − 4.5 (نصف
/// سمك الحلقة) — مطابق لثوابت _RingPainter.
/// المعيار على مستوى الحبر المرسوم: أفقيًا صناديق الحروف الدقيقة من
/// getBoxesForSelection، وعموديًا مقصوصة على مستطيل الفقرة المرسوم —
/// لأن مقاييس خط Cairo المترية (1.54em) تتجاوز مستطيل السطر المرسوم
/// بذيل نزول فارغ لا يحمل حروفًا (بلا تشكيل)، بينما مستطيل الفقرة
/// (ارتفاع السطر الفعلي) هو ما يشغله النص رسمًا.
void _expectInsideRing(WidgetTester tester, Finder textFinder, double size,
    {double tolerance = 0.5}) {
  final ringRect = tester.getRect(find.byType(StatusRing));
  final center = ringRect.center;
  final innerRadius = size / 2 - 13.5;
  final paraRect = tester.getRect(textFinder);
  final para = tester.renderObject<RenderParagraph>(textFinder);
  final textLength = para.text.toPlainText().length;
  final boxes = para.getBoxesForSelection(
    TextSelection(baseOffset: 0, extentOffset: textLength),
  );
  expect(boxes, isNotEmpty, reason: 'النص يجب أن يُرسل صناديق حروف');
  for (final box in boxes) {
    // localToGlobal يمرّ عبر تحويل FittedBox (تقليص القيمة الطويلة)
    final glyphLeft = para.localToGlobal(Offset(box.left, 0)).dx;
    final glyphRight = para.localToGlobal(Offset(box.right, 0)).dx;
    // عموديًا: التقاطع بين الصندوق المتري ومستطيل الفقرة المرسوم
    final glyphTop =
        para.localToGlobal(Offset(0, box.top)).dy.clamp(paraRect.top, paraRect.bottom);
    final glyphBottom =
        para.localToGlobal(Offset(0, box.bottom)).dy.clamp(paraRect.top, paraRect.bottom);
    for (final corner in [
      Offset(glyphLeft, glyphTop),
      Offset(glyphRight, glyphTop),
      Offset(glyphLeft, glyphBottom),
      Offset(glyphRight, glyphBottom),
    ]) {
      final dist = (corner - center).distance;
      expect(
        dist,
        lessThan(innerRadius + tolerance),
        reason:
            'زاوية حروف مرسومة (${(glyphRight - glyphLeft).toStringAsFixed(1)}px '
            'عرضًا) على بعد ${dist.toStringAsFixed(1)} من المركز تتجاوز نصف '
            'القطر الداخلي $innerRadius — حروف النص تخرج من الدائرة.',
      );
    }
  }
}

void main() {
  setUpAll(() async {
    await _loadFont('Cairo',
        ['Cairo-Regular.ttf', 'Cairo-SemiBold.ttf', 'Cairo-Bold.ttf']);
    await _loadFont('Tajawal', [
      'Tajawal-Regular.ttf',
      'Tajawal-Medium.ttf',
      'Tajawal-Bold.ttf',
      'Tajawal-ExtraBold.ttf',
    ]);
  });

  testWidgets('نص المصدر الطويل في تبويبة البيئة يبقى داخل الحلقة',
      (tester) async {
    tester.view.physicalSize = const Size(720, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await _pumpRing(
      tester,
      size: 170,
      valueLabel: 'جيدة',
      label: 'من جهاز البيئة — قراءة مباشرة',
    );

    _expectInsideRing(
        tester, find.text('من جهاز البيئة — قراءة مباشرة'), 170);
    _expectInsideRing(tester, find.text('جيدة'), 170);
  });

  testWidgets('أطول قيمة قيمة جودة الهواء (متوسطة) تبقى داخل الحلقة',
      (tester) async {
    tester.view.physicalSize = const Size(720, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await _pumpRing(
      tester,
      size: 170,
      valueLabel: 'متوسطة',
      label: 'من جهاز البيئة — قراءة مباشرة',
    );

    _expectInsideRing(tester, find.text('متوسطة'), 170);
  });

  testWidgets('حلقة الرئيسية (مستوى الأكسجين) تبقى سليمة بعد الإصلاح',
      (tester) async {
    tester.view.physicalSize = const Size(720, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await _pumpRing(
      tester,
      size: 168,
      valueLabel: '98%',
      label: 'مستوى الأكسجين',
    );

    _expectInsideRing(tester, find.text('98%'), 168);
    _expectInsideRing(tester, find.text('مستوى الأكسجين'), 168);
  });

  testWidgets('تكبير خط النظام 1.3× لا يخرج النصوص عن الحلقة (وصولية)',
      (tester) async {
    tester.view.physicalSize = const Size(720, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await _pumpRing(
      tester,
      size: 170,
      valueLabel: 'متوسطة',
      label: 'من جهاز البيئة — قراءة مباشرة',
      textScale: 1.3,
    );

    _expectInsideRing(
        tester, find.text('من جهاز البيئة — قراءة مباشرة'), 170);
    _expectInsideRing(tester, find.text('متوسطة'), 170);
  });
}
