/// محرك الخطر القائم على قواعد قابلة للتفسير — الوثيقة الموحدة §9.
/// لا ذكاء اصطناعي في v1: كل تقييم ينتج أسبابًا نصية تُخزَّن مع التنبيه (§8.7).
library;

import 'dart:math' as math;

import 'package:asthma_care/data/models/models.dart';
import 'package:asthma_care/domain/risk_engine/risk_config.dart';

/// حساب خط الأساس الشخصي — الوسيط لا المتوسط (§9.1).
class BaselineCalculator {
  const BaselineCalculator();

  Baseline compute(List<VitalsReading> restingSamples) {
    final hrs = restingSamples.map((r) => r.heartRate).nonNulls.toList();
    final resps = restingSamples.map((r) => r.respRate).nonNulls.toList();
    final spo2s = restingSamples.map((r) => r.spo2).nonNulls.toList();

    if (restingSamples.length < RiskConfig.baselineMinSamples ||
        resps.isEmpty) {
      return Baseline.provisional();
    }

    return Baseline(
      restingHr: hrs.isEmpty ? 80 : _median(hrs),
      restingRespRate: _median(resps),
      restingSpo2: spo2s.isEmpty ? 97 : _median(spo2s),
      sampleCount: restingSamples.length,
      computedAt: DateTime.now(),
    );
  }

  double _median(List<int> values) {
    final sorted = values.toList()..sort();
    final mid = sorted.length ~/ 2;
    if (sorted.length.isOdd) return sorted[mid].toDouble();
    return (sorted[mid - 1] + sorted[mid]) / 2;
  }
}

/// استخراج الميزات من نافذة زمنية (§9.3).
class FeatureExtractor {
  const FeatureExtractor();

  FeatureSet extract({
    required List<VitalsReading> vitalsWindow,
    required EnvReading? latestEnv,
    required Baseline baseline,
  }) {
    final usable =
        vitalsWindow.where((r) => r.isUsable).toList(growable: false);

    if (usable.isEmpty) {
      return FeatureSet(
        respRateDeltaFromBaseline: 0,
        spo2Trend: 0,
        hrRespSyncScore: 0,
        envExposureScore: 0,
        isMotionReliable: false,
        activity: ActivityState.resting,
      );
    }

    final last = usable.last;

    // 1) دلتا معدل التنفس عن خط الأساس
    final respDelta =
        (last.respRate ?? baseline.restingRespRate) - baseline.restingRespRate;

    // 2) اتجاه الأكسجين: انحدار خطي لآخر 5 دقائق (%/5 دقائق)
    final spo2Trend = _spo2Trend(usable, minutes: 5);

    // 3) تزامن النبض والتنفس (ارتباط بيرسون) خلال آخر 10 دقائق
    final sync = _hrRespSync(usable, minutes: 10);

    // 4) التعرض البيئي من آخر قراءة جهاز (0–1)
    final envScore = latestEnv == null
        ? 0.0
        : ((latestEnv.pm25 / 150).clamp(0.0, 1.0) * 0.7 +
                (latestEnv.vocIndex / 500).clamp(0.0, 1.0) * 0.3)
            .clamp(0.0, 1.0);

    // 5) موثوقية الإشارة: نسبة القراءات عالية الجودة في النافذة
    final goodQuality =
        usable.where((r) => r.signalQuality >= 60 && !r.motionNoisy).length;
    final isReliable = goodQuality / usable.length >= 0.6;

    return FeatureSet(
      respRateDeltaFromBaseline: respDelta,
      spo2Trend: spo2Trend,
      hrRespSyncScore: sync,
      envExposureScore: envScore,
      isMotionReliable: isReliable,
      activity: last.activity,
    );
  }

  /// انحدار خطي بسيط: نسبة التغير في الأكسجين لكل 5 دقائق.
  double _spo2Trend(List<VitalsReading> readings, {required int minutes}) {
    final now = readings.last.receivedAt;
    final cutoff = now.subtract(Duration(minutes: minutes));
    final pts = <({double x, double y})>[];
    for (final r in readings) {
      if (r.spo2 == null) continue;
      if (r.receivedAt.isBefore(cutoff)) continue;
      pts.add((
        x: r.receivedAt.difference(cutoff).inMilliseconds / 60000.0,
        y: r.spo2!.toDouble(),
      ));
    }
    if (pts.length < 3) return 0;
    final slope = _linearSlope(pts);
    return slope * minutes; // %/5 دقائق
  }

  /// ارتباط بيرسون بين النبض والتنفس، مقصوص على 0–1 (سلبي → 0).
  double _hrRespSync(List<VitalsReading> readings, {required int minutes}) {
    final cutoff = readings.last.receivedAt.subtract(Duration(minutes: minutes));
    final hrs = <double>[];
    final resps = <double>[];
    for (final r in readings.reversed) {
      if (r.receivedAt.isBefore(cutoff)) break;
      if (r.heartRate == null || r.respRate == null) continue;
      hrs.add(r.heartRate!.toDouble());
      resps.add(r.respRate!.toDouble());
    }
    if (hrs.length < 5) return 0;
    final r = _pearson(hrs, resps);
    return r.isNaN ? 0 : r.clamp(0.0, 1.0);
  }

  double _linearSlope(List<({double x, double y})> pts) {
    final n = pts.length;
    final mx = pts.map((p) => p.x).reduce((a, b) => a + b) / n;
    final my = pts.map((p) => p.y).reduce((a, b) => a + b) / n;
    var num = 0.0, den = 0.0;
    for (final p in pts) {
      num += (p.x - mx) * (p.y - my);
      den += (p.x - mx) * (p.x - mx);
    }
    if (den == 0) return 0;
    return num / den;
  }

  double _pearson(List<double> x, List<double> y) {
    final n = x.length;
    final mx = x.reduce((a, b) => a + b) / n;
    final my = y.reduce((a, b) => a + b) / n;
    var num = 0.0, dx = 0.0, dy = 0.0;
    for (var i = 0; i < n; i++) {
      num += (x[i] - mx) * (y[i] - my);
      dx += (x[i] - mx) * (x[i] - mx);
      dy += (y[i] - my) * (y[i] - my);
    }
    if (dx == 0 || dy == 0) return 0;
    return num / math.sqrt(dx * dy);
  }
}

/// محرك الخطر — القواعد المفسرة (§9.4) بأوزان [RiskConfig].
class RiskEngine {
  const RiskEngine();

  RiskAssessment evaluate(FeatureSet f, Baseline baseline) {
    if (!f.isMotionReliable) {
      return RiskAssessment.attention(reason: 'إشارة غير مستقرة — تحقق من ارتداء السوار');
    }

    var score = 0;
    final reasons = <String>[];
    final contributions = <Map<String, Object?>>[];

    if (f.respRateDeltaFromBaseline > RiskConfig.respDeltaMajor) {
      score += RiskConfig.wRespMajor;
      final r =
          'معدل التنفس أعلى من خط الأساس بـ ${f.respRateDeltaFromBaseline.toStringAsFixed(0)} نفس/دقيقة';
      reasons.add(r);
      contributions.add({'feature': 'respRateDelta', 'value': f.respRateDeltaFromBaseline, 'score': RiskConfig.wRespMajor, 'text': r});
    } else if (f.respRateDeltaFromBaseline > RiskConfig.respDeltaMinor) {
      score += RiskConfig.wRespMinor;
      contributions.add({'feature': 'respRateDelta', 'value': f.respRateDeltaFromBaseline, 'score': RiskConfig.wRespMinor});
    }

    if (f.spo2Trend < RiskConfig.spo2TrendLimit) {
      score += RiskConfig.wSpo2;
      const r = 'انخفاض مستمر في تشبع الأكسجين';
      reasons.add(r);
      contributions.add({'feature': 'spo2Trend', 'value': f.spo2Trend, 'score': RiskConfig.wSpo2, 'text': r});
    }

    if (f.hrRespSyncScore > RiskConfig.hrRespSyncLimit &&
        f.activity == ActivityState.resting) {
      score += RiskConfig.wSync;
      const r = 'تزامن ارتفاع النبض والتنفس دون نشاط';
      reasons.add(r);
      contributions.add({'feature': 'hrRespSync', 'value': f.hrRespSyncScore, 'score': RiskConfig.wSync, 'text': r});
    }

    if (f.envExposureScore > RiskConfig.envExposureLimit) {
      score += RiskConfig.wEnv;
      const r = 'تعرض بيئي مرتفع (PM2.5/VOC من جهاز البيئة)';
      reasons.add(r);
      contributions.add({'feature': 'envExposure', 'value': f.envExposureScore, 'score': RiskConfig.wEnv, 'text': r});
    }

    final level = score >= RiskConfig.highRiskScore
        ? RiskLevel.highRiskPattern
        : score >= RiskConfig.attentionScore
            ? RiskLevel.attention
            : RiskLevel.normal;

    return RiskAssessment(
      level: level,
      score: score,
      reasons: reasons,
      evaluatedAt: DateTime.now(),
    );
  }
}
