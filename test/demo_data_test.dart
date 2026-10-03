// اختبارات مولدات البيانات التجريبية — حتمية، فحص النطاقات والترتيب
// والعدد والاتساق بين النوبات والتنبيهات.
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:asthma_care/application/services/demo_data_seeder.dart';
import 'package:asthma_care/data/models/models.dart';
import 'package:asthma_care/data/repositories/repositories.dart';

void main() {
  // مرساة زمنية ثابتة: 2026-10-02 14:30 — العدد والحدود دقيقة ومتكررة
  final anchor = DateTime(2026, 10, 2, 14, 30);
  final vitals = DemoDataSet.vitals(anchor: anchor);
  final env = DemoDataSet.env(anchor: anchor);
  final alerts = DemoDataSet.alerts(anchor: anchor);

  group('مولد القراءات الحيوية', () {
    test('العدد مطابق للخطوة الزمنية عبر 30 يومًا + يوم اليوم الجزئي', () {
      // 30 يومًا كاملة × 720 قراءة/يوم (كل دقيقتين) + 435 ليوم الجزئي
      expect(vitals.length, 30 * 720 + 435);
    });

    test('الطوابع الزمنية صاعدة بلا تكرار والأحدث قبل المرساة', () {
      for (var i = 1; i < vitals.length; i++) {
        expect(
          vitals[i].receivedAt.isAfter(vitals[i - 1].receivedAt),
          isTrue,
          reason: 'غير متسلسل عند $i',
        );
      }
      expect(vitals.last.receivedAt.isBefore(anchor), isTrue);
    });

    test('القيم داخل النطاقات الفسيولوجية', () {
      for (final r in vitals) {
        if (r.notWorn) {
          expect(r.heartRate, isNull);
          expect(r.spo2, isNull);
          expect(r.respRate, isNull);
          expect(r.signalQuality, 0);
          continue;
        }
        expect(r.heartRate, inInclusiveRange(45, 135), reason: 'hr @${r.receivedAt}');
        expect(r.spo2, inInclusiveRange(90, 100), reason: 'spo2 @${r.receivedAt}');
        expect(r.respRate, inInclusiveRange(10, 30), reason: 'resp @${r.receivedAt}');
        expect(r.signalQuality, inInclusiveRange(0, 100));
        expect(r.battery, inInclusiveRange(20, 100));
      }
    });

    test('نوافذ عدم اللبس تُفرغ القيم فعليًا', () {
      final notWorn = vitals.where((r) => r.notWorn).toList();
      expect(notWorn, isNotEmpty);
      // نوافذ 60 و45 دقيقة × قراءة كل دقيقتين = 30 + 23 تقريبًا
      expect(notWorn.length, inInclusiveRange(45, 60));
    });

    test('النوبات المزروعة تُظهر هبوط تشبع حقيقي يشرح التنبيهات', () {
      final minSpo2 =
          vitals.where((r) => r.spo2 != null).map((r) => r.spo2!).reduce(min);
      expect(minSpo2, lessThan(95));
    });

    test('خط الأساس: أغلب قراءات الأيام السبعة الأخيرة مؤهلة للراحة', () {
      final last7 = vitals
          .where((r) =>
              r.receivedAt.isAfter(anchor.subtract(const Duration(days: 7))) &&
              !r.notWorn)
          .toList();
      final eligible = last7.where((r) => r.isBaselineEligible).length;
      expect(eligible, greaterThan(30)); // شرط عدم الافتراضية (30 عينة)
      expect(eligible / last7.length, greaterThan(0.3));
    });
  });

  group('مولد القراءات البيئية', () {
    test('العدد مطابق للخطوة الزمنية', () {
      expect(env.length, 30 * 144 + 87);
    });

    test('النطاقات سليمة ويوم التلوث السيئ يبلغ عتبة التنبيه', () {
      var maxPm25 = 0.0;
      for (final r in env) {
        expect(r.pm25, inInclusiveRange(3.0, 140.0));
        expect(r.pm10, greaterThanOrEqualTo(r.pm25));
        expect(r.tempC, inInclusiveRange(17.0, 32.0));
        expect(r.humidity, inInclusiveRange(35.0, 75.0));
        expect(r.vocIndex, inInclusiveRange(40, 260));
        expect(r.receivedAt.isBefore(anchor), isTrue);
        if (r.pm25 > maxPm25) maxPm25 = r.pm25;
      }
      expect(maxPm25, greaterThan(75)); // يفسر تنبيه البيئة
    });
  });

  group('التنبيهات المبوّرة', () {
    test('ستة تنبيهات بصيغة أسباب متوافقة مع ورقة التفاصيل', () {
      expect(alerts.length, 6);
      var highRisk = 0;
      var acknowledged = 0;
      for (final a in alerts) {
        expect(a.timestamp.isBefore(anchor), isTrue);
        expect(a.timestamp.isAfter(anchor.subtract(const Duration(days: 30))),
            isTrue);
        final decoded = AlertReasonBuilder.decode(a.reasonJson);
        expect(decoded['level'], isNotNull);
        expect(decoded['contributions'], isA<List<dynamic>>());
        if (a.severity == AlertSeverity.highRisk) highRisk++;
        if (a.acknowledged) acknowledged++;
      }
      expect(highRisk, 1);
      expect(acknowledged, 1);
    });

    test('التنبيهات منسجمة مع نوافذ النوبات في القراءات الحيوية', () {
      // كل تنبيه ربو يجب أن تجاوره قراءات بهبوط تشبع
      for (final a
          in alerts.where((a) => a.category == AlertCategory.asthma)) {
        final nearby = vitals
            .where((r) =>
                r.receivedAt
                    .isAfter(a.timestamp.subtract(const Duration(minutes: 30))) &&
                r.receivedAt.isBefore(a.timestamp.add(const Duration(minutes: 30))))
            .toList();
        final minSpo2 = nearby
            .map((r) => r.spo2 ?? 100)
            .reduce((x, y) => x < y ? x : y);
        expect(minSpo2, lessThan(96),
            reason: 'تنبيه بلا هبوط تشبع مجاور @${a.timestamp}');
      }
    });
  });
}
