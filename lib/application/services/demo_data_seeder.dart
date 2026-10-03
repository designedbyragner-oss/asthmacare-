/// بذر البيانات التجريبية — تاريخ واقعي مدة 30 يومًا عند أول تشغيل فقط.
/// الغرض: تجربة المؤشرات والرسوم البيانية والتنبيهات فورًا دون انتظار
/// تراكم القراءات من المحاكاة الحية. البذر حتمي (بذرة عشوائية ثابتة)
/// ويعمل مرة واحدة: إذا وُجد أي سجل حيوي فلا يُبذر شيء — حماية للبيانات
/// الحقيقية عند الانتقال لجهاز فعلي لاحقًا.
/// أنماط الجيل: نوم أهدأ، نشاط نهاري، نوافذ رياضة، ثلاث نوبات ليلية
/// (متسقة زمنيًا مع التنبيهات المبوّرة)، يوم تلوث سيئ، ونوافذ عدم لبس.
library;

import 'dart:math';

import 'package:asthma_care/data/models/models.dart';
import 'package:asthma_care/data/repositories/repositories.dart';

/// يبذر السجل التجريبي عبر المستودعات — يستدعى من main() قبل runApp.
class DemoDataSeeder {
  final VitalsRepository _vitals;
  final EnvRepository _env;
  final AlertsRepository _alerts;

  DemoDataSeeder(this._vitals, this._env, this._alerts);

  /// يبذر فقط إذا كان سجل الحيوية فارغًا (أول تشغيل على قاعدة نظيفة).
  Future<void> seedIfNeeded() async {
    if (await _vitals.latest() != null) return;

    final now = DateTime.now();
    await _vitals.insertAll(DemoDataSet.vitals(anchor: now));
    await _env.insertAll(DemoDataSet.env(anchor: now));
    for (final alert in DemoDataSet.alerts(anchor: now)) {
      await _alerts.insert(alert);
    }
  }
}

/// مولدات البيانات — دوال نقية حتمية ليبقى الاختبار متكررًا ومستقرًا.
class DemoDataSet {
  DemoDataSet._();

  static const int days = 30;
  static const int vitalsStepMin = 2; // قراءة حيوية كل دقيقتين
  static const int envStepMin = 10; // قراءة بيئة كل 10 دقائق

  /// نوبات ليلية: (قبل كم يوم، بداية بالدقيقة من منتصف الليل، المدة بالدقيقة)
  /// — كلها داخل حدود اليوم الواحد كي لا تُقصّها حلقة التوليد.
  static const List<(int, int, int)> _episodes = [
    (3, 150, 75), // 02:30
    (11, 1380, 55), // 23:00
    (19, 300, 60), // 05:00
    (26, 1275, 20), // 21:15 — نوبة مسائية خفيفة تفسّر التنبيه المؤكد
  ];

  /// نوافذ عدم لبس السوار
  static const List<(int, int, int)> _notWorn = [
    (8, 780, 60), // 13:00
    (22, 820, 45), // 13:40
  ];

  /// نوافذ رياضة مسائية
  static const List<(int, int, int)> _workouts = [
    (2, 1050, 40),
    (5, 1060, 35),
    (9, 1045, 45),
    (13, 1065, 40),
    (17, 1055, 50),
    (24, 1050, 40),
    (28, 1060, 35),
  ];

  /// يوم تلوث سيئ: 19:00 لمدة ساعتين — يفسر تنبيه البيئة
  static const (int, int, int) _badAir = (14, 1140, 120);

  static bool _inSpec(List<(int, int, int)> spec, int d, int m) =>
      spec.any(((e) => e.$1 == d && m >= e.$2 && m < e.$2 + e.$3));

  /// قراءات حيوية كل دقيقتين عبر المدة — الأحدث قرب [anchor].
  static List<VitalsReading> vitals({
    required DateTime anchor,
    int days = DemoDataSet.days,
    Random? rng,
  }) {
    final rand = rng ?? Random(20261002);
    final out = <VitalsReading>[];
    var seq = 1;

    for (var d = days; d >= 0; d--) {
      final dayStart =
          DateTime(anchor.year, anchor.month, anchor.day).subtract(Duration(days: d));
      final endMinute =
          d == 0 ? anchor.difference(dayStart).inMinutes : 24 * 60;

      // البطارية تنخفض بثبات عبر الأيام — واقعية بلا تعقيد
      final battery = (95 - (days - d) * 1.7).clamp(35.0, 100.0).round();

      for (var m = 0; m < endMinute; m += vitalsStepMin) {
        final t = dayStart.add(Duration(minutes: m));
        final asleep = m >= 30 && m < 390; // 00:30–06:30
        final lateEvening = m >= 1320; // بعد 22:00
        final inWorkout = _inSpec(_workouts, d, m);
        final inEpisode = _inSpec(_episodes, d, m);
        final notWorn = _inSpec(_notWorn, d, m);

        if (notWorn) {
          out.add(VitalsReading(
            seq: seq++,
            notWorn: true,
            motionNoisy: false,
            localAlertActive: false,
            heartRate: null,
            spo2: null,
            respRate: null,
            signalQuality: 0,
            activity: ActivityState.resting,
            battery: battery,
            receivedAt: t,
          ));
          continue;
        }

        double hr, resp, spo2;
        ActivityState activity;
        if (asleep) {
          hr = 55 + rand.nextDouble() * 8;
          resp = 12.5 + rand.nextDouble() * 3;
          spo2 = 96.8 + rand.nextDouble() * 1.6;
          activity = ActivityState.resting;
        } else if (inWorkout) {
          hr = 102 + rand.nextDouble() * 22;
          resp = 22 + rand.nextDouble() * 6;
          spo2 = 95 + rand.nextDouble() * 2;
          activity = ActivityState.running;
        } else if (lateEvening) {
          hr = 61 + rand.nextDouble() * 9;
          resp = 13.5 + rand.nextDouble() * 3;
          spo2 = 96.8 + rand.nextDouble() * 1.8;
          activity = ActivityState.resting;
        } else {
          hr = 70 + rand.nextDouble() * 14;
          resp = 14.5 + rand.nextDouble() * 4.5;
          spo2 = 96.4 + rand.nextDouble() * 2.4;
          final roll = rand.nextDouble();
          activity = roll < 0.55
              ? ActivityState.resting
              : roll < 0.92
                  ? ActivityState.walking
                  : ActivityState.running;
        }
        if (inEpisode) {
          // النوبة: هبوط تشبع + تسارع تنفس ونبض — قصة تشرح التنبيه المرافق
          spo2 = 92.2 + rand.nextDouble() * 2.6;
          resp += 4 + rand.nextDouble() * 2.5;
          hr += 6 + rand.nextDouble() * 6;
        }

        // الجودة: النوم والراحة أعلى — مع شريحة نهارية أقل من 80 (تخرج من خط الأساس)
        final quality = asleep
            ? (88 + rand.nextDouble() * 10).round()
            : inWorkout
                ? (70 + rand.nextDouble() * 22).round()
                : (rand.nextDouble() < 0.85
                    ? (84 + rand.nextDouble() * 14).round()
                    : (55 + rand.nextDouble() * 24).round());

        out.add(VitalsReading(
          seq: seq++,
          notWorn: false,
          motionNoisy: !asleep && rand.nextDouble() < 0.06,
          localAlertActive: false,
          heartRate: hr.round().clamp(45, 135),
          spo2: spo2.round().clamp(90, 100),
          respRate: resp.round().clamp(10, 30),
          signalQuality: quality.clamp(0, 100),
          activity: activity,
          battery: battery,
          receivedAt: t,
        ));
      }
    }
    return out;
  }

  /// قراءات بيئية كل 10 دقائق عبر المدة — تذبذب نهاري + طبخ + يوم سيئ.
  static List<EnvReading> env({
    required DateTime anchor,
    int days = DemoDataSet.days,
    Random? rng,
  }) {
    final rand = rng ?? Random(777001);
    final out = <EnvReading>[];
    var seq = 1;

    for (var d = days; d >= 0; d--) {
      final dayStart =
          DateTime(anchor.year, anchor.month, anchor.day).subtract(Duration(days: d));
      final endMinute =
          d == 0 ? anchor.difference(dayStart).inMinutes : 24 * 60;
      final battery = (92 - (days - d) * 1.5).clamp(25.0, 100.0).round();

      for (var m = 0; m < endMinute; m += envStepMin) {
        final t = dayStart.add(Duration(minutes: m));

        double pm = 9 +
            5 * _sin01(m / 1440 - 0.15) +
            rand.nextDouble() * 7; // قاعدة ليلية أهدأ
        // ذروتا طبخ ترفعان الجسيمات محليًا
        if (_near(m, 12 * 60 + 40, 25)) pm += 20 + rand.nextDouble() * 22;
        if (_near(m, 19 * 60 + 30, 30)) pm += 24 + rand.nextDouble() * 26;
        if (_inSpec([_badAir], d, m)) pm = 85 + rand.nextDouble() * 45;
        pm = pm.clamp(3.0, 140.0);

        final voc = (55 + pm * 1.15 + rand.nextDouble() * 20).round().clamp(40, 260);
        final pm10 = pm * 1.55 + 6 + rand.nextDouble() * 5;
        final temp =
            22.5 + 4.5 * _sin01(m / 1440 - 0.58) + (rand.nextDouble() - 0.5);
        final humidity = (52 + 8 * _sin01(m / 1440) + (rand.nextDouble() - 0.5) * 5)
            .clamp(35.0, 75.0);

        out.add(EnvReading(
          seq: seq++,
          sensorFault: false,
          lowBattery: false,
          pm25: pm,
          pm10: pm10,
          tempC: temp,
          humidity: humidity,
          vocIndex: voc,
          battery: battery,
          receivedAt: t,
        ));
      }
    }
    return out;
  }

  /// تنبيهات منسجمة مع النوبات المبوّرة — نفس صيغة الأسباب التي يكتبها
  /// المنسق الحي (AlertReasonBuilder) ليعمل ورق التفاصيل على أكمل وجه.
  static List<AppAlert> alerts({required DateTime anchor}) {
    AppAlert at(int daysAgo, int minuteOfDay, AlertCategory category,
            AlertSeverity severity, String title, String reasonJson,
            {bool acknowledged = false}) =>
        AppAlert(
          timestamp: DateTime(anchor.year, anchor.month, anchor.day)
              .subtract(Duration(days: daysAgo))
              .add(Duration(minutes: minuteOfDay)),
          category: category,
          severity: severity,
          title: title,
          reasonJson: reasonJson,
          acknowledged: acknowledged,
        );

    return [
      at(3, 167, AlertCategory.asthma, AlertSeverity.attention,
          'ارتفاع معدل التنفس فوق خط أساسك مع هبوط تشبع خفيف',
          AlertReasonBuilder.encode(
            level: 'attention',
            contributions: [
              {
                'feature': 'respRate',
                'value': 20,
                'text': 'ارتفاع معدل التنفس عن خط أساسك الشخصي',
              },
              {
                'feature': 'spo2Trend',
                'value': -2.4,
                'text': 'هبوط تشبع خفيف ومستمر خلال النافذة',
              },
            ],
            readingsBefore: {
              'respRate': [18, 19, 20, 20, 21],
              'spo2': [97, 96, 95, 94, 94],
              'hr': [68, 70, 73, 75, 74],
            },
            env: {'pm25': 17, 'vocIndex': 88},
          )),
      at(11, 1428, AlertCategory.asthma, AlertSeverity.attention,
          'تسارع التنفس والنبض معًا قبل النوم',
          AlertReasonBuilder.encode(
            level: 'attention',
            contributions: [
              {
                'feature': 'hrRespSync',
                'value': 0.72,
                'text': 'تزامن مرتفع بين النبض والتنفس',
              },
            ],
            readingsBefore: {
              'respRate': [17, 18, 19, 19],
              'spo2': [97, 96, 95, 95],
              'hr': [74, 78, 81, 80],
            },
            env: {'pm25': 21, 'vocIndex': 102},
          )),
      at(14, 1218, AlertCategory.environment, AlertSeverity.attention,
          'جودة هواء سيئة — يُنصح بالبقاء في الداخل',
          AlertReasonBuilder.encode(
            level: 'attention',
            contributions: [
              {
                'feature': 'pm25',
                'value': 104,
                'text': 'تركيز الجسيمات الدقيقة مرتفع',
              },
            ],
            readingsBefore: const {},
            env: {'pm25': 104, 'vocIndex': 187},
          )),
      at(19, 324, AlertCategory.asthma, AlertSeverity.highRisk,
          'نمط يتطلب متابعة — هبوط تشبع متكرر فجرًا',
          AlertReasonBuilder.encode(
            level: 'highRiskPattern',
            contributions: [
              {
                'feature': 'spo2Trend',
                'value': -3.1,
                'text': 'انخفاض تشبع متكرر خلال النافذة',
              },
              {
                'feature': 'respRate',
                'value': 21,
                'text': 'معدل تنفس أعلى من خط أساسك الشخصي',
              },
            ],
            readingsBefore: {
              'respRate': [19, 20, 21, 21, 22],
              'spo2': [96, 95, 93, 92, 93],
              'hr': [70, 73, 76, 78, 77],
            },
            env: {'pm25': 14, 'vocIndex': 79},
          )),
      at(26, 1280, AlertCategory.asthma, AlertSeverity.attention,
          'ارتفاع خفيف في التنفس مساءً — مؤكد يدويًا',
          AlertReasonBuilder.encode(
            level: 'attention',
            contributions: [
              {
                'feature': 'respRate',
                'value': 19,
                'text': 'ارتفاع معدل التنفس عن خط أساسك الشخصي',
              },
            ],
            readingsBefore: {
              'respRate': [17, 18, 19, 19],
              'spo2': [97, 97, 96, 96],
              'hr': [72, 74, 75, 74],
            },
            env: {'pm25': 26, 'vocIndex': 118},
          ),
          acknowledged: true),
      at(6, 1196, AlertCategory.environment, AlertSeverity.attention,
          'ذروة جسيمات محلية — على الأرجح طبخ',
          AlertReasonBuilder.encode(
            level: 'attention',
            contributions: [
              {
                'feature': 'pm25',
                'value': 63,
                'text': 'ارتفاع موضعي للجسيمات الدقيقة',
              },
            ],
            readingsBefore: const {},
            env: {'pm25': 63, 'vocIndex': 141},
          )),
    ];
  }

  /// جيب مضغوط في المدى [0,1] — لصياغة الأنماط اليومية باقتصاد.
  static double _sin01(double phase) => (sin(phase * 2 * pi) + 1) / 2;

  /// هل الدقيقة قريبة من ذروة (لنوافذ الطبخ)؟
  static bool _near(int m, int peak, int halfWidth) =>
      (m - peak).abs() <= halfWidth;
}
