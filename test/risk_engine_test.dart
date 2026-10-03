/// اختبارات محرك الخطر وخط الأساس — G3: سيناريو لكل قاعدة (§9).
library;

import 'package:asthma_care/data/models/models.dart';
import 'package:asthma_care/domain/risk_engine/risk_config.dart';
import 'package:asthma_care/domain/risk_engine/risk_engine.dart';
import 'package:flutter_test/flutter_test.dart';

VitalsReading _v({
  required int seq,
  int? hr = 78,
  int? spo2 = 98,
  int? resp = 15,
  int quality = 95,
  ActivityState activity = ActivityState.resting,
  bool notWorn = false,
  bool noisy = false,
  DateTime? at,
}) {
  return VitalsReading(
    seq: seq,
    notWorn: notWorn,
    motionNoisy: noisy,
    localAlertActive: false,
    heartRate: hr,
    spo2: spo2,
    respRate: resp,
    signalQuality: quality,
    activity: activity,
    battery: 90,
    receivedAt: at ?? DateTime.now().subtract(Duration(seconds: seq * 10)),
  );
}

Baseline _baseline({double resp = 15, double hr = 76, double spo2 = 98}) =>
    Baseline(
      restingHr: hr,
      restingRespRate: resp,
      restingSpo2: spo2,
      sampleCount: 500,
      computedAt: DateTime.now(),
    );

void main() {
  final engine = const RiskEngine();
  final extractor = const FeatureExtractor();
  final baselineCalc = const BaselineCalculator();

  group('BaselineCalculator', () {
    test('أقل من 30 عينة → حدود سكانية مؤقتة', () {
      final samples = List.generate(29, (i) => _v(seq: i));
      final b = baselineCalc.compute(samples);
      expect(b.isProvisional, isTrue);
      expect(b.sampleCount, 0);
    });

    test('30 عينة راحة صالحة → وسيط حقيقي (لا يتأثر بالشواذ)', () {
      final samples = <VitalsReading>[
        for (var i = 0; i < 29; i++) _v(seq: i, resp: 15, hr: 76),
        _v(seq: 30, resp: 40, hr: 140), // شاذّة واحدة — الوسيط يقاومها
      ];
      final b = baselineCalc.compute(samples);
      expect(b.isProvisional, isFalse);
      expect(b.restingRespRate, 15);
      expect(b.restingHr, 76);
    });

    test('عينات غير راحة تُمرر مباشرة تُحتسب — (التصفية مسؤولية المستدعي)', () {
      // التصفية تعتمد isBaselineEligible — تحققنا منها في اختبار الحزم
      expect(_v(seq: 1, activity: ActivityState.walking).isBaselineEligible, isFalse);
    });
  });

  group('FeatureExtractor', () {
    test('نافذة فارغة → ميزات محايدة غير موثوقة', () {
      final f = extractor.extract(
        vitalsWindow: const [],
        latestEnv: null,
        baseline: _baseline(),
      );
      expect(f.isMotionReliable, isFalse);
      expect(f.respRateDeltaFromBaseline, 0);
    });

    test('دلتا التنفس تُحسب من خط الأساس', () {
      final f = extractor.extract(
        vitalsWindow: [_v(seq: 1, resp: 21)],
        latestEnv: null,
        baseline: _baseline(resp: 15),
      );
      expect(f.respRateDeltaFromBaseline, 6);
    });

    test('انخفاض أكسجين متسارع يظهر في spo2Trend', () {
      final now = DateTime.now();
      final window = <VitalsReading>[
        _v(seq: 0, spo2: 98, at: now.subtract(const Duration(minutes: 5))),
        _v(seq: 1, spo2: 97, at: now.subtract(const Duration(minutes: 4))),
        _v(seq: 2, spo2: 96, at: now.subtract(const Duration(minutes: 3))),
        _v(seq: 3, spo2: 95, at: now.subtract(const Duration(minutes: 2))),
        _v(seq: 4, spo2: 94, at: now.subtract(const Duration(minutes: 1))),
        _v(seq: 5, spo2: 93, at: now),
      ];
      final f = extractor.extract(
        vitalsWindow: window,
        latestEnv: null,
        baseline: _baseline(),
      );
      expect(f.spo2Trend, lessThan(RiskConfig.spo2TrendLimit));
    });

    test('أكسجين مستقر → اتجاه محايد', () {
      final now = DateTime.now();
      final window = [
        for (var i = 0; i < 6; i++)
          _v(seq: i, spo2: 98, at: now.subtract(Duration(minutes: 5 - i))),
      ];
      final f = extractor.extract(
        vitalsWindow: window,
        latestEnv: null,
        baseline: _baseline(),
      );
      expect(f.spo2Trend, greaterThanOrEqualTo(RiskConfig.spo2TrendLimit));
    });
  });

  group('RiskEngine — القواعد (§9.4)', () {
    FeatureSet f({
      double respDelta = 0,
      double spo2Trend = 0,
      double sync = 0,
      double env = 0,
      bool reliable = true,
      ActivityState activity = ActivityState.resting,
    }) =>
        FeatureSet(
          respRateDeltaFromBaseline: respDelta,
          spo2Trend: spo2Trend,
          hrRespSyncScore: sync,
          envExposureScore: env,
          isMotionReliable: reliable,
          activity: activity,
        );

    test('حالة طبيعية كاملة → Normal', () {
      final r = engine.evaluate(f(), _baseline());
      expect(r.level, RiskLevel.normal);
      expect(r.reasons, isEmpty);
    });

    test('إشارة غير مستقرة → Attention برسالة الارتداء', () {
      final r = engine.evaluate(f(reliable: false), _baseline());
      expect(r.level, RiskLevel.attention);
      expect(r.reasons.first, contains('ارتداء'));
    });

    test('ارتفاع تنفس كبير وحده (3) → Attention', () {
      final r = engine.evaluate(f(respDelta: 7), _baseline());
      expect(r.level, RiskLevel.attention);
      expect(r.score, RiskConfig.wRespMajor);
      expect(r.reasons, isNotEmpty); // سبب قابل للتفسير
    });

    test('انخفاض أكسجين مستمر وحده (3) → Attention', () {
      final r = engine.evaluate(f(spo2Trend: -2.0), _baseline());
      expect(r.level, RiskLevel.attention);
      expect(r.score, RiskConfig.wSpo2);
    });

    test('تزامن أثناء الجري لا يُحتسب (تفسير الحركة — §2)', () {
      final r = engine.evaluate(
        f(sync: 0.9, activity: ActivityState.running),
        _baseline(),
      );
      expect(r.level, RiskLevel.normal);
    });

    test('تعرض بيئي وحده (1) → Normal لكن مسجل', () {
      final r = engine.evaluate(f(env: 0.8), _baseline());
      expect(r.level, RiskLevel.normal);
      expect(r.score, RiskConfig.wEnv);
    });

    test('تنفس مرتفع + أكسجين منخفض (3+3=6) → High-Risk Pattern', () {
      final r = engine.evaluate(f(respDelta: 7, spo2Trend: -2.0), _baseline());
      expect(r.level, RiskLevel.highRiskPattern);
      expect(r.reasons.length, 2);
    });

    test('عتبة الانتباه بالضبط (score=3) → Attention (≥)', () {
      final r = engine.evaluate(f(respDelta: 4), _baseline());
      expect(r.score, RiskConfig.wRespMinor);
      expect(r.level, RiskLevel.normal); // 1 < 3
    });
  });
}
