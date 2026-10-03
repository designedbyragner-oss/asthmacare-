/// نماذج المجال (Domain Models) — مطابقة لمواصفات الوثيقة الموحدة §7–§9.
library;

/// حالة النشاط من وحدة IMU.
enum ActivityState {
  resting('راحة'),
  walking('مشي'),
  running('جري');

  final String arLabel;
  const ActivityState(this.arLabel);
}

/// مستويات الحالة الثلاثة الرسمية — §8.6 (المصطلحات فقط، بلا ادعاء تشخيصي).
enum RiskLevel {
  normal('طبيعي', 'Normal'),
  attention('يستحق الانتباه', 'Attention'),
  highRiskPattern('نمط يتطلب متابعة', 'High-Risk Pattern');

  final String arLabel;
  final String enLabel;
  const RiskLevel(this.arLabel, this.enLabel);
}

/// فئات التنبيه.
enum AlertCategory {
  asthma('ربو'),
  environment('بيئة'),
  medication('دواء'),
  system('النظام');

  final String arLabel;
  const AlertCategory(this.arLabel);
}

/// درجة التنبيه — «يستحق الانتباه» أو «نمط يتطلب متابعة» فقط.
enum AlertSeverity {
  attention('يستحق الانتباه'),
  highRisk('نمط يتطلب متابعة');

  final String arLabel;
  const AlertSeverity(this.arLabel);
}

/// قراءة حيوية من السوار — حزمة 14 بايت، بايتات محجوزة تُهمل (§7.3).
class VitalsReading {
  final int seq;
  final bool notWorn;
  final bool motionNoisy;
  final bool localAlertActive;
  final int? heartRate; // 0 => null (غير صالح)
  final int? spo2; // 0 => null (غير صالح)
  final int? respRate; // 0 => null (غير صالح)
  final int signalQuality; // 0–100
  final ActivityState activity;
  final int battery; // %
  final DateTime receivedAt;

  const VitalsReading({
    required this.seq,
    required this.notWorn,
    required this.motionNoisy,
    required this.localAlertActive,
    required this.heartRate,
    required this.spo2,
    required this.respRate,
    required this.signalQuality,
    required this.activity,
    required this.battery,
    required this.receivedAt,
  });

  /// هل القراءة صالحة للدخول في خط الأساس وتقييم الخطر؟ (§7.5)
  bool get isUsable =>
      !notWorn &&
      signalQuality >= 30 &&
      respRate != null &&
      respRate! > 0;

  /// هل هي مؤهلة لبناء خط الأساس؟ (راحة + جودة عالية)
  bool get isBaselineEligible =>
      isUsable && activity == ActivityState.resting && signalQuality > 80;
}

/// قراءة بيئية من جهاز البيئة — حزمة 16 بايت (§7.2).
class EnvReading {
  final int seq;
  final bool sensorFault;
  final bool lowBattery;
  final double pm25; // µg/m³
  final double pm10; // µg/m³
  final double tempC;
  final double humidity; // %
  final int vocIndex; // 0–500 (محسوب على الجهاز)
  final int battery; // %
  final DateTime receivedAt;

  const EnvReading({
    required this.seq,
    required this.sensorFault,
    required this.lowBattery,
    required this.pm25,
    required this.pm10,
    required this.tempC,
    required this.humidity,
    required this.vocIndex,
    required this.battery,
    required this.receivedAt,
  });

  bool get isUsable => !sensorFault;

  /// جودة الهواء المحلية المبسطة من PM2.5 (مؤشر تشغيلي داخلي، ليس معيارًا رسميًا).
  String get localAirQualityLabel {
    if (pm25 <= 35) return 'جيدة';
    if (pm25 <= 75) return 'متوسطة';
    return 'سيئة';
  }
}

/// مجموعة الميزات المستخرجة لنافذة زمنية (§9.3).
class FeatureSet {
  final double respRateDeltaFromBaseline;
  final double spo2Trend; // %/5 دقائق
  final double hrRespSyncScore; // 0–1
  final double envExposureScore; // 0–1
  final bool isMotionReliable;
  final ActivityState activity;

  const FeatureSet({
    required this.respRateDeltaFromBaseline,
    required this.spo2Trend,
    required this.hrRespSyncScore,
    required this.envExposureScore,
    required this.isMotionReliable,
    required this.activity,
  });
}

/// خط الأساس الشخصي (§9.1).
class Baseline {
  final double restingHr;
  final double restingRespRate;
  final double restingSpo2;
  final int sampleCount;
  final DateTime computedAt;

  const Baseline({
    required this.restingHr,
    required this.restingRespRate,
    required this.restingSpo2,
    required this.sampleCount,
    required this.computedAt,
  });

  /// حدود سكانية مؤقتة حتى اكتمال 30 قراءة راحة.
  factory Baseline.provisional() => Baseline(
        restingHr: 80,
        restingRespRate: 16,
        restingSpo2: 97,
        sampleCount: 0,
        computedAt: DateTime.fromMillisecondsSinceEpoch(0),
      );

  bool get isProvisional => sampleCount < 30;
}

/// نتيجة تقييم الخطر مع أسبابها (§8.7).
class RiskAssessment {
  final RiskLevel level;
  final int score;
  final List<String> reasons;
  final DateTime evaluatedAt;

  const RiskAssessment({
    required this.level,
    required this.score,
    required this.reasons,
    required this.evaluatedAt,
  });

  factory RiskAssessment.attention({required String reason, DateTime? at}) =>
      RiskAssessment(
        level: RiskLevel.attention,
        score: 0,
        reasons: [reason],
        evaluatedAt: at ?? DateTime.now(),
      );

  factory RiskAssessment.normal() => RiskAssessment(
        level: RiskLevel.normal,
        score: 0,
        reasons: const [],
        evaluatedAt: DateTime.now(),
      );
}

/// تنبيه مخزَّن.
class AppAlert {
  final int? id;
  final DateTime timestamp;
  final AlertCategory category;
  final AlertSeverity severity;
  final String title;
  final String reasonJson; // المساهمات + القراءات السابقة (§8.7)
  final bool acknowledged;

  const AppAlert({
    this.id,
    required this.timestamp,
    required this.category,
    required this.severity,
    required this.title,
    required this.reasonJson,
    required this.acknowledged,
  });
}

/// بيانات هواء خارجية موسومة (D5) — لا تُنسب للجهاز إطلاقًا.
class ExternalAirQuality {
  final double? no2;
  final double? so2;
  final String sourceLabel; // دائمًا «من مصدر خارجي»
  final DateTime fetchedAt;
  final bool isEstimate; // true عند تعذر الشبكة (تقدير إقليمي)

  const ExternalAirQuality({
    required this.no2,
    required this.so2,
    required this.sourceLabel,
    required this.fetchedAt,
    required this.isEstimate,
  });
}

/// حالة الارتباط بأجهزة BLE (تسمية مختلفة عن ConnectionState في Flutter).
enum LinkState {
  disconnected('غير متصل'),
  scanning('جاري البحث...'),
  connecting('جاري الاتصال...'),
  connected('متصل');

  final String arLabel;
  const LinkState(this.arLabel);
}
