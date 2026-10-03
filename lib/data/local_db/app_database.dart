/// قاعدة البيانات المحلية المشفرة — Drift + SQLite3MultipleCiphers (D4).
/// المخطط مطابق للوثيقة الموحدة §8، مع فهارس على timestamp لكل جداول القراءات.
library;

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'package:asthma_care/data/models/models.dart';

part 'app_database.g.dart';

@DataClassName('VitalsRow')
@TableIndex(name: 'idx_vitals_ts', columns: {#timestamp})
class VitalsReadings extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get timestamp => dateTime()();
  IntColumn get seq => integer()();
  IntColumn get heartRate => integer().nullable()();
  IntColumn get spo2 => integer().nullable()();
  IntColumn get respRate => integer().nullable()();
  IntColumn get signalQuality => integer()();
  IntColumn get activity => intEnum<ActivityState>()();
  BoolColumn get isMotionNoisy => boolean()();
  BoolColumn get isNotWorn => boolean()();
}

@DataClassName('EnvRow')
@TableIndex(name: 'idx_env_ts', columns: {#timestamp})
class EnvReadings extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get timestamp => dateTime()();
  IntColumn get seq => integer()();
  RealColumn get pm25 => real()();
  RealColumn get pm10 => real()();
  RealColumn get tempC => real()();
  RealColumn get humidity => real()();
  IntColumn get vocIndex => integer()();
  RealColumn get no2 => real().nullable()(); // من مصدر خارجي فقط (D5)
  RealColumn get so2 => real().nullable()(); // من مصدر خارجي فقط (D5)
  TextColumn get source => text().withDefault(const Constant('device'))();
}

@DataClassName('AlertRow')
@TableIndex(name: 'idx_alerts_ts', columns: {#timestamp})
class Alerts extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get timestamp => dateTime()();
  IntColumn get category => intEnum<AlertCategory>()();
  IntColumn get severity => intEnum<AlertSeverity>()();
  TextColumn get title => text()();
  TextColumn get reason => text()(); // JSON: المساهمات + القراءات السابقة (§8.7)
  BoolColumn get acknowledged => boolean().withDefault(const Constant(false))();
}

@DataClassName('BaselineRow')
class PersonalBaseline extends Table {
  TextColumn get userId => text()();
  RealColumn get restingHr => real()();
  RealColumn get restingRespRate => real()();
  RealColumn get restingSpo2 => real()();
  DateTimeColumn get computedAt => dateTime()();
  IntColumn get sampleCount => integer()();

  @override
  Set<Column> get primaryKey => {userId};
}

@DataClassName('MedicationRow')
class Medications extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get dosage => text()();
  TextColumn get scheduleTimes => text()(); // JSON list "08:00,20:00"
}

@DataClassName('ActionPlanRow')
class AsthmaActionPlan extends Table {
  TextColumn get userId => text()();
  TextColumn get zones => text()(); // JSON: green/yellow/red

  @override
  Set<Column> get primaryKey => {userId};
}

@DriftDatabase(
  tables: [VitalsReadings, EnvReadings, Alerts, PersonalBaseline, Medications, AsthmaActionPlan],
)
class AppDatabase extends _$AppDatabase {
  /// الاتصال المشفر الإنتاجي — المفتاح يُمرر من DbKeyManager قبل الفتح (D4).
  AppDatabase(String passphrase) : super(_openEncrypted(passphrase));

  /// اتصال اختباري (ذاكرة) — بلا تشفير لسرعة الاختبارات.
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openEncrypted(String passphrase) {
    return driftDatabase(
      name: 'asthma_care',
      native: DriftNativeOptions(
        // PRAGMA key يجب أن يكون أول أمر — تشفير SQLite3MultipleCiphers (D4)
        setup: (db) => db.execute("PRAGMA key = '$passphrase';"),
      ),
    );
  }

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
      );
}
