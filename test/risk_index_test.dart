/// اختبارات مؤشر خطر الربو المئوي — الخريطة الصادقة من درجة محرك الخطر
/// (خطة 2026-09-28): المثال الحاكم هو الدرجة 5 → 75% برتقالي.
library;

import 'package:asthma_care/data/models/models.dart';
import 'package:asthma_care/domain/risk_engine/risk_index.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AsthmaRiskIndex.fromScore — جدول الخريطة الدقيق', () {
    test('الدرجة 0 → 0% طبيعي', () {
      final i = AsthmaRiskIndex.fromScore(0);
      expect(i.percent, 0);
      expect(i.zone, RiskIndexZone.normal);
      expect(i.level, RiskLevel.normal);
    });

    test('الدرجة 2 → 26% طبيعي', () {
      final i = AsthmaRiskIndex.fromScore(2);
      expect(i.percent, 26);
      expect(i.zone, RiskIndexZone.normal);
      expect(i.level, RiskLevel.normal);
    });

    test('الدرجة 3 → 40% احتمال بداية نوبة', () {
      final i = AsthmaRiskIndex.fromScore(3);
      expect(i.percent, 40);
      expect(i.zone, RiskIndexZone.onset);
      expect(i.level, RiskLevel.attention);
    });

    test('الدرجة 4 → 58% احتمال بداية نوبة', () {
      final i = AsthmaRiskIndex.fromScore(4);
      expect(i.percent, 58);
      expect(i.zone, RiskIndexZone.onset);
      expect(i.level, RiskLevel.attention);
    });

    test('الدرجة 5 → 75% احتمال بداية نوبة (المثال الحاكم)', () {
      final i = AsthmaRiskIndex.fromScore(5);
      expect(i.percent, 75);
      expect(i.zone, RiskIndexZone.onset);
      expect(i.level, RiskLevel.attention);
    });

    test('الدرجة 6 → 76% خطر مرتفع', () {
      final i = AsthmaRiskIndex.fromScore(6);
      expect(i.percent, 76);
      expect(i.zone, RiskIndexZone.high);
      expect(i.level, RiskLevel.highRiskPattern);
    });

    test('الدرجة 9 → 100% خطر مرتفع', () {
      final i = AsthmaRiskIndex.fromScore(9);
      expect(i.percent, 100);
      expect(i.zone, RiskIndexZone.high);
      expect(i.level, RiskLevel.highRiskPattern);
    });

    test('الدرجة السالبة (-5) تُقص إلى 0% طبيعي', () {
      final i = AsthmaRiskIndex.fromScore(-5);
      expect(i.percent, 0);
      expect(i.zone, RiskIndexZone.normal);
    });

    test('الدرجة الزائدة (50) تُقص إلى 100% خطر مرتفع', () {
      final i = AsthmaRiskIndex.fromScore(50);
      expect(i.percent, 100);
      expect(i.zone, RiskIndexZone.high);
    });

    test('جدول شامل: كل الدرجات 0–9 تثبّت الخريطة كاملة', () {
      const expected = [
        (0, RiskIndexZone.normal),
        (13, RiskIndexZone.normal),
        (26, RiskIndexZone.normal),
        (40, RiskIndexZone.onset),
        (58, RiskIndexZone.onset),
        (75, RiskIndexZone.onset),
        (76, RiskIndexZone.high),
        (84, RiskIndexZone.high),
        (92, RiskIndexZone.high),
        (100, RiskIndexZone.high),
      ];
      for (var s = 0; s <= 9; s++) {
        final i = AsthmaRiskIndex.fromScore(s);
        expect(i.percent, expected[s].$1, reason: 'النسبة للدرجة $s');
        expect(i.zone, expected[s].$2, reason: 'المنطقة للدرجة $s');
      }
    });
  });

  group('AsthmaRiskIndex.fromAssessment — أرضيات المناطق', () {
    test('إشارة غير مستقرة: انتباه بدرجة 0 → 40% برتقالي (الأرضية تعمل)', () {
      final a = RiskAssessment.attention(
        reason: 'إشارة غير مستقرة — تحقق من ارتداء السوار',
      );
      final i = AsthmaRiskIndex.fromAssessment(a);
      expect(i.percent, 40);
      expect(i.zone, RiskIndexZone.onset);
      expect(i.level, RiskLevel.attention);
    });

    test('تقييم طبيعي بدرجة 0 → 0% طبيعي', () {
      final i = AsthmaRiskIndex.fromAssessment(RiskAssessment.normal());
      expect(i.percent, 0);
      expect(i.zone, RiskIndexZone.normal);
      expect(i.level, RiskLevel.normal);
    });
  });
}
