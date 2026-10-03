/// مستودعات البيانات — كل استعلامات SQLite عبر Drift مع فهارس زمنية (§8).
/// التجميعات الزمنية تُحسب في SQL لا في Dart — كفاءة مع تزايد سجل القراءات.
library;

import 'dart:convert';

import 'package:drift/drift.dart';

import 'package:asthma_care/data/local_db/app_database.dart';
import 'package:asthma_care/data/models/models.dart';

class VitalsRepository {
  final AppDatabase _db;
  VitalsRepository(this._db);

  Future<void> insert(VitalsReading r) {
    return _db.into(_db.vitalsReadings).insert(VitalsReadingsCompanion.insert(
          timestamp: r.receivedAt,
          seq: r.seq,
          heartRate: Value(r.heartRate),
          spo2: Value(r.spo2),
          respRate: Value(r.respRate),
          signalQuality: r.signalQuality,
          activity: r.activity,
          isMotionNoisy: r.motionNoisy,
          isNotWorn: r.notWorn,
        ));
  }

  /// إدخال دفعي في معاملة واحدة — لبذر البيانات التجريبية بكفاءة.
  Future<void> insertAll(List<VitalsReading> readings) {
    return _db.batch((b) {
      b.insertAll(
        _db.vitalsReadings,
        readings.map((r) => VitalsReadingsCompanion.insert(
              timestamp: r.receivedAt,
              seq: r.seq,
              heartRate: Value(r.heartRate),
              spo2: Value(r.spo2),
              respRate: Value(r.respRate),
              signalQuality: r.signalQuality,
              activity: r.activity,
              isMotionNoisy: r.motionNoisy,
              isNotWorn: r.notWorn,
            )),
      );
    });
  }

  /// آخر قراءة صالحة.
  Future<VitalsReading?> latest() async {
    final q = _db.select(_db.vitalsReadings)
      ..where((t) => t.isNotWorn.equals(false))
      ..orderBy([(t) => OrderingTerm.desc(t.timestamp)])
      ..limit(1);
    final row = await q.getSingleOrNull();
    if (row == null) return null;
    return _toModel(row);
  }

  /// نافذة زمنية للقراءات الصالحة فقط (§7.5).
  Future<List<VitalsReading>> window(Duration duration) async {
    final since = DateTime.now().subtract(duration);
    final q = _db.select(_db.vitalsReadings)
      ..where((t) => t.timestamp.isBiggerOrEqualValue(since) & t.isNotWorn.equals(false))
      ..orderBy([(t) => OrderingTerm.asc(t.timestamp)]);
    final rows = await q.get();
    return rows.map(_toModel).toList();
  }

  /// عينات خط الأساس: راحة + جودة عالية خلال مدة (§9.1).
  Future<List<VitalsReading>> baselineSamples(
      {Duration duration = const Duration(days: 7), int limit = 20000}) async {
    final since = DateTime.now().subtract(duration);
    final q = _db.select(_db.vitalsReadings)
      ..where((t) =>
          t.timestamp.isBiggerOrEqualValue(since) &
          t.activity.equalsValue(ActivityState.resting) &
          t.signalQuality.isBiggerThanValue(80) &
          t.isNotWorn.equals(false))
      ..orderBy([(t) => OrderingTerm.desc(t.timestamp)])
      ..limit(limit);
    final rows = await q.get();
    return rows.map(_toModel).toList();
  }

  /// متوسطات ساعية للمخططات — تجميع في SQL (كفاءة مع سجل ضخم).
  Future<List<HourlyVitalsAvg>> hourlyAverages(Duration duration) async {
    final since = DateTime.now().subtract(duration);
    final rows = await _db.customSelect(
      '''
      SELECT (timestamp / 3600) AS bucket,
             AVG(heart_rate) AS hr,
             AVG(resp_rate)  AS resp,
             AVG(spo2)       AS spo2
      FROM vitals_readings
      WHERE timestamp >= ? AND resp_rate IS NOT NULL AND is_not_worn = 0
      GROUP BY bucket ORDER BY bucket ASC
      ''',
      variables: [Variable.withDateTime(since)],
      readsFrom: {_db.vitalsReadings},
    ).get();

    return rows
        .map((r) => HourlyVitalsAvg(
              bucketStart:
                  DateTime.fromMillisecondsSinceEpoch((r.read<int>('bucket')) * 3600 * 1000),
              hr: (r.read<double>('hr') as num?)?.toDouble(),
              resp: (r.read<double>('resp') as num?)?.toDouble(),
              spo2: (r.read<double>('spo2') as num?)?.toDouble(),
            ))
        .toList();
  }

  VitalsReading _toModel(VitalsRow row) => VitalsReading(
        seq: row.seq,
        notWorn: row.isNotWorn,
        motionNoisy: row.isMotionNoisy,
        localAlertActive: false,
        heartRate: row.heartRate,
        spo2: row.spo2,
        respRate: row.respRate,
        signalQuality: row.signalQuality,
        activity: row.activity,
        battery: 0,
        receivedAt: row.timestamp,
      );
}

/// متوسط ساعي لمخططات السجل الطبي.
class HourlyVitalsAvg {
  final DateTime bucketStart;
  final double? hr;
  final double? resp;
  final double? spo2;
  const HourlyVitalsAvg({
    required this.bucketStart,
    this.hr,
    this.resp,
    this.spo2,
  });
}

class EnvRepository {
  final AppDatabase _db;
  EnvRepository(this._db);

  Future<void> insert(EnvReading r) {
    return _db.into(_db.envReadings).insert(EnvReadingsCompanion.insert(
          timestamp: r.receivedAt,
          seq: r.seq,
          pm25: r.pm25,
          pm10: r.pm10,
          tempC: r.tempC,
          humidity: r.humidity,
          vocIndex: r.vocIndex,
        ));
  }

  /// إدخال دفعي في معاملة واحدة — لبذر البيانات التجريبية بكفاءة.
  Future<void> insertAll(List<EnvReading> readings) {
    return _db.batch((b) {
      b.insertAll(
        _db.envReadings,
        readings.map((r) => EnvReadingsCompanion.insert(
              timestamp: r.receivedAt,
              seq: r.seq,
              pm25: r.pm25,
              pm10: r.pm10,
              tempC: r.tempC,
              humidity: r.humidity,
              vocIndex: r.vocIndex,
            )),
      );
    });
  }

  Future<EnvReading?> latest() async {
    final q = _db.select(_db.envReadings)
      ..orderBy([(t) => OrderingTerm.desc(t.timestamp)])
      ..limit(1);
    final row = await q.getSingleOrNull();
    if (row == null) return null;
    return EnvReading(
      seq: row.seq,
      sensorFault: false,
      lowBattery: false,
      pm25: row.pm25,
      pm10: row.pm10,
      tempC: row.tempC,
      humidity: row.humidity,
      vocIndex: row.vocIndex,
      battery: 0,
      receivedAt: row.timestamp,
    );
  }

  /// متوسطات ساعية بيئية لمخطط التزامن (§10).
  Future<List<HourlyEnvAvg>> hourlyAverages(Duration duration) async {
    final since = DateTime.now().subtract(duration);
    final rows = await _db.customSelect(
      '''
      SELECT (timestamp / 3600) AS bucket,
             AVG(pm25)     AS pm25,
             AVG(voc_index) AS voc
      FROM env_readings
      WHERE timestamp >= ? AND source = 'device'
      GROUP BY bucket ORDER BY bucket ASC
      ''',
      variables: [Variable.withDateTime(since)],
      readsFrom: {_db.envReadings},
    ).get();
    return rows
        .map((r) => HourlyEnvAvg(
              bucketStart:
                  DateTime.fromMillisecondsSinceEpoch((r.read<int>('bucket')) * 3600 * 1000),
              pm25: (r.read<double>('pm25') as num?)?.toDouble(),
              vocIndex: (r.read<double>('voc') as num?)?.toDouble(),
            ))
        .toList();
  }
}

class HourlyEnvAvg {
  final DateTime bucketStart;
  final double? pm25;
  final double? vocIndex;
  const HourlyEnvAvg({required this.bucketStart, this.pm25, this.vocIndex});
}

class AlertsRepository {
  final AppDatabase _db;
  AlertsRepository(this._db);

  Future<int> insert(AppAlert a) {
    return _db.into(_db.alerts).insert(AlertsCompanion.insert(
          timestamp: a.timestamp,
          category: a.category,
          severity: a.severity,
          title: a.title,
          reason: a.reasonJson,
        ));
  }

  /// تيار التنبيهات الحديثة — يحدّث الواجهة تلقائيًا.
  Stream<List<AppAlert>> watchRecent({int limit = 100}) {
    final q = _db.select(_db.alerts)
      ..orderBy([(t) => OrderingTerm.desc(t.timestamp), (t) => OrderingTerm.desc(t.id)])
      ..limit(limit);
    return q.watch().map((rows) => rows
        .map((row) => AppAlert(
              id: row.id,
              timestamp: row.timestamp,
              category: row.category,
              severity: row.severity,
              title: row.title,
              reasonJson: row.reason,
              acknowledged: row.acknowledged,
            ))
        .toList());
  }

  Future<void> acknowledge(int id) {
    return (_db.update(_db.alerts)..where((t) => t.id.equals(id)))
        .write(AlertsCompanion(acknowledged: const Value(true)));
  }

  /// آخر تنبيه من فئة — لمنع تكرار التنبيهات (نافذة التهدئة).
  Future<AppAlert?> lastByCategory(AlertCategory category) async {
    final q = _db.select(_db.alerts)
      ..where((t) => t.category.equalsValue(category))
      ..orderBy([(t) => OrderingTerm.desc(t.timestamp)])
      ..limit(1);
    final row = await q.getSingleOrNull();
    if (row == null) return null;
    return AppAlert(
      id: row.id,
      timestamp: row.timestamp,
      category: row.category,
      severity: row.severity,
      title: row.title,
      reasonJson: row.reason,
      acknowledged: row.acknowledged,
    );
  }
}

class BaselineRepository {
  final AppDatabase _db;
  BaselineRepository(this._db);

  static const String _localUser = 'local';

  Future<Baseline?> get() async {
    final q = _db.select(_db.personalBaseline)
      ..where((t) => t.userId.equals(_localUser))
      ..limit(1);
    final row = await q.getSingleOrNull();
    if (row == null) return null;
    return Baseline(
      restingHr: row.restingHr,
      restingRespRate: row.restingRespRate,
      restingSpo2: row.restingSpo2,
      sampleCount: row.sampleCount,
      computedAt: row.computedAt,
    );
  }

  Future<void> save(Baseline b) async {
    await _db.into(_db.personalBaseline).insertOnConflictUpdate(
          PersonalBaselineCompanion.insert(
            userId: _localUser,
            restingHr: b.restingHr,
            restingRespRate: b.restingRespRate,
            restingSpo2: b.restingSpo2,
            computedAt: b.computedAt,
            sampleCount: b.sampleCount,
          ),
        );
  }
}

/// مساعد تسلسل JSON للأسباب (§8.7).
class AlertReasonBuilder {
  AlertReasonBuilder._();

  static String encode({
    required String level,
    required List<Map<String, Object?>> contributions,
    required Map<String, List<num>> readingsBefore,
    Map<String, Object?>? env,
    int windowMinutes = 10,
  }) {
    return jsonEncode({
      'level': level,
      'contributions': contributions,
      'readingsBefore': readingsBefore,
      'env': ?env,
      'windowMinutes': windowMinutes,
    });
  }

  static Map<String, Object?> decode(String json) {
    final decoded = jsonDecode(json);
    return decoded is Map<String, Object?> ? decoded : <String, Object?>{};
  }
}
