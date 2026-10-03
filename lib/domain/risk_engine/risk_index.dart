/// مؤشر خطر الربو المئوي — نسبة مشتقة بصدق من درجة محرك الخطر (خطة 2026-09-28).
/// لا أرقام منفصلة: الدرجة 0–9 تُختم إلى نطاقات مناطق ثابتة في [RiskConfig]
/// (مصدر وحيد للحقيقة)، والمستوى هو المرجع للون والنص. أرضيات المناطق تعالج
/// حالة «الإشارة غير المستقرة» (انتباه بدرجة 0 → 40% برتقالي).
library;

import 'dart:math' as math;

import 'package:asthma_care/data/models/models.dart';
import 'package:asthma_care/domain/risk_engine/risk_config.dart';

/// مناطق المؤشر الثلاث — تقابل التوكنات الوظيفية
/// (طبيعي → oxygen / احتمال بداية نوبة → environment / خطر مرتفع → danger).
enum RiskIndexZone { normal, onset, high }

class AsthmaRiskIndex {
  final int percent; // 0–100
  final RiskIndexZone zone;
  final RiskLevel level;

  const AsthmaRiskIndex({
    required this.percent,
    required this.zone,
    required this.level,
  });

  /// الخريطة الدقيقة من الدرجة — المثال الحاكم: الدرجة 5 → 75% برتقالي.
  ///
  /// - الدرجة 0–2 → 0% / 13% / 26% (طبيعي)
  /// - الدرجة 3–5 → 40% / 58% / 75% (احتمال بداية نوبة)
  /// - الدرجة 6–9 → 76% / 84% / 92% / 100% (خطر مرتفع)
  static AsthmaRiskIndex fromScore(int score) {
    final s = math.max(0, math.min(9, score)); // قصّ إلى النطاق 0–9
    final RiskIndexZone zone;
    final int percent;
    if (s <= 2) {
      zone = RiskIndexZone.normal;
      percent = s * 13;
    } else if (s <= 5) {
      zone = RiskIndexZone.onset;
      percent = 40 + ((s - 3) * 35 / 2).round();
    } else {
      zone = RiskIndexZone.high;
      percent = 76 + (s - 6) * 8;
    }
    return AsthmaRiskIndex(
      percent: percent,
      zone: zone,
      level: _zoneLevel(zone),
    );
  }

  /// من تقييم المحرك مباشرة: أعلى النسبة المشتقة من الدرجة وأرضية منطقة
  /// المستوى — عتبة الانتباه ⇒ ≥40% وعتبة الخطر ⇒ ≥76%.
  static AsthmaRiskIndex fromAssessment(RiskAssessment a) {
    final zone = switch (a.level) {
      RiskLevel.normal => RiskIndexZone.normal,
      RiskLevel.attention => RiskIndexZone.onset,
      RiskLevel.highRiskPattern => RiskIndexZone.high,
    };
    final floor = switch (a.level) {
      RiskLevel.normal => 0,
      RiskLevel.attention => RiskConfig.indexGreenMax + 1, // 40
      RiskLevel.highRiskPattern => RiskConfig.indexOrangeMax + 1, // 76
    };
    return AsthmaRiskIndex(
      percent: math.max(fromScore(a.score).percent, floor),
      zone: zone,
      level: a.level,
    );
  }

  static RiskLevel _zoneLevel(RiskIndexZone zone) => switch (zone) {
        RiskIndexZone.normal => RiskLevel.normal,
        RiskIndexZone.onset => RiskLevel.attention,
        RiskIndexZone.high => RiskLevel.highRiskPattern,
      };
}
