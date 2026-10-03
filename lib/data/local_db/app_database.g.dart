// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $VitalsReadingsTable extends VitalsReadings
    with TableInfo<$VitalsReadingsTable, VitalsRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VitalsReadingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _seqMeta = const VerificationMeta('seq');
  @override
  late final GeneratedColumn<int> seq = GeneratedColumn<int>(
    'seq',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _heartRateMeta = const VerificationMeta(
    'heartRate',
  );
  @override
  late final GeneratedColumn<int> heartRate = GeneratedColumn<int>(
    'heart_rate',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _spo2Meta = const VerificationMeta('spo2');
  @override
  late final GeneratedColumn<int> spo2 = GeneratedColumn<int>(
    'spo2',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _respRateMeta = const VerificationMeta(
    'respRate',
  );
  @override
  late final GeneratedColumn<int> respRate = GeneratedColumn<int>(
    'resp_rate',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _signalQualityMeta = const VerificationMeta(
    'signalQuality',
  );
  @override
  late final GeneratedColumn<int> signalQuality = GeneratedColumn<int>(
    'signal_quality',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<ActivityState, int> activity =
      GeneratedColumn<int>(
        'activity',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<ActivityState>($VitalsReadingsTable.$converteractivity);
  static const VerificationMeta _isMotionNoisyMeta = const VerificationMeta(
    'isMotionNoisy',
  );
  @override
  late final GeneratedColumn<bool> isMotionNoisy = GeneratedColumn<bool>(
    'is_motion_noisy',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_motion_noisy" IN (0, 1))',
    ),
  );
  static const VerificationMeta _isNotWornMeta = const VerificationMeta(
    'isNotWorn',
  );
  @override
  late final GeneratedColumn<bool> isNotWorn = GeneratedColumn<bool>(
    'is_not_worn',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_not_worn" IN (0, 1))',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    timestamp,
    seq,
    heartRate,
    spo2,
    respRate,
    signalQuality,
    activity,
    isMotionNoisy,
    isNotWorn,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vitals_readings';
  @override
  VerificationContext validateIntegrity(
    Insertable<VitalsRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('seq')) {
      context.handle(
        _seqMeta,
        seq.isAcceptableOrUnknown(data['seq']!, _seqMeta),
      );
    } else if (isInserting) {
      context.missing(_seqMeta);
    }
    if (data.containsKey('heart_rate')) {
      context.handle(
        _heartRateMeta,
        heartRate.isAcceptableOrUnknown(data['heart_rate']!, _heartRateMeta),
      );
    }
    if (data.containsKey('spo2')) {
      context.handle(
        _spo2Meta,
        spo2.isAcceptableOrUnknown(data['spo2']!, _spo2Meta),
      );
    }
    if (data.containsKey('resp_rate')) {
      context.handle(
        _respRateMeta,
        respRate.isAcceptableOrUnknown(data['resp_rate']!, _respRateMeta),
      );
    }
    if (data.containsKey('signal_quality')) {
      context.handle(
        _signalQualityMeta,
        signalQuality.isAcceptableOrUnknown(
          data['signal_quality']!,
          _signalQualityMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_signalQualityMeta);
    }
    if (data.containsKey('is_motion_noisy')) {
      context.handle(
        _isMotionNoisyMeta,
        isMotionNoisy.isAcceptableOrUnknown(
          data['is_motion_noisy']!,
          _isMotionNoisyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_isMotionNoisyMeta);
    }
    if (data.containsKey('is_not_worn')) {
      context.handle(
        _isNotWornMeta,
        isNotWorn.isAcceptableOrUnknown(data['is_not_worn']!, _isNotWornMeta),
      );
    } else if (isInserting) {
      context.missing(_isNotWornMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VitalsRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VitalsRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
      seq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}seq'],
      )!,
      heartRate: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}heart_rate'],
      ),
      spo2: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}spo2'],
      ),
      respRate: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}resp_rate'],
      ),
      signalQuality: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}signal_quality'],
      )!,
      activity: $VitalsReadingsTable.$converteractivity.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}activity'],
        )!,
      ),
      isMotionNoisy: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_motion_noisy'],
      )!,
      isNotWorn: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_not_worn'],
      )!,
    );
  }

  @override
  $VitalsReadingsTable createAlias(String alias) {
    return $VitalsReadingsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ActivityState, int, int> $converteractivity =
      const EnumIndexConverter<ActivityState>(ActivityState.values);
}

class VitalsRow extends DataClass implements Insertable<VitalsRow> {
  final int id;
  final DateTime timestamp;
  final int seq;
  final int? heartRate;
  final int? spo2;
  final int? respRate;
  final int signalQuality;
  final ActivityState activity;
  final bool isMotionNoisy;
  final bool isNotWorn;
  const VitalsRow({
    required this.id,
    required this.timestamp,
    required this.seq,
    this.heartRate,
    this.spo2,
    this.respRate,
    required this.signalQuality,
    required this.activity,
    required this.isMotionNoisy,
    required this.isNotWorn,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['timestamp'] = Variable<DateTime>(timestamp);
    map['seq'] = Variable<int>(seq);
    if (!nullToAbsent || heartRate != null) {
      map['heart_rate'] = Variable<int>(heartRate);
    }
    if (!nullToAbsent || spo2 != null) {
      map['spo2'] = Variable<int>(spo2);
    }
    if (!nullToAbsent || respRate != null) {
      map['resp_rate'] = Variable<int>(respRate);
    }
    map['signal_quality'] = Variable<int>(signalQuality);
    {
      map['activity'] = Variable<int>(
        $VitalsReadingsTable.$converteractivity.toSql(activity),
      );
    }
    map['is_motion_noisy'] = Variable<bool>(isMotionNoisy);
    map['is_not_worn'] = Variable<bool>(isNotWorn);
    return map;
  }

  VitalsReadingsCompanion toCompanion(bool nullToAbsent) {
    return VitalsReadingsCompanion(
      id: Value(id),
      timestamp: Value(timestamp),
      seq: Value(seq),
      heartRate: heartRate == null && nullToAbsent
          ? const Value.absent()
          : Value(heartRate),
      spo2: spo2 == null && nullToAbsent ? const Value.absent() : Value(spo2),
      respRate: respRate == null && nullToAbsent
          ? const Value.absent()
          : Value(respRate),
      signalQuality: Value(signalQuality),
      activity: Value(activity),
      isMotionNoisy: Value(isMotionNoisy),
      isNotWorn: Value(isNotWorn),
    );
  }

  factory VitalsRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VitalsRow(
      id: serializer.fromJson<int>(json['id']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      seq: serializer.fromJson<int>(json['seq']),
      heartRate: serializer.fromJson<int?>(json['heartRate']),
      spo2: serializer.fromJson<int?>(json['spo2']),
      respRate: serializer.fromJson<int?>(json['respRate']),
      signalQuality: serializer.fromJson<int>(json['signalQuality']),
      activity: $VitalsReadingsTable.$converteractivity.fromJson(
        serializer.fromJson<int>(json['activity']),
      ),
      isMotionNoisy: serializer.fromJson<bool>(json['isMotionNoisy']),
      isNotWorn: serializer.fromJson<bool>(json['isNotWorn']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'seq': serializer.toJson<int>(seq),
      'heartRate': serializer.toJson<int?>(heartRate),
      'spo2': serializer.toJson<int?>(spo2),
      'respRate': serializer.toJson<int?>(respRate),
      'signalQuality': serializer.toJson<int>(signalQuality),
      'activity': serializer.toJson<int>(
        $VitalsReadingsTable.$converteractivity.toJson(activity),
      ),
      'isMotionNoisy': serializer.toJson<bool>(isMotionNoisy),
      'isNotWorn': serializer.toJson<bool>(isNotWorn),
    };
  }

  VitalsRow copyWith({
    int? id,
    DateTime? timestamp,
    int? seq,
    Value<int?> heartRate = const Value.absent(),
    Value<int?> spo2 = const Value.absent(),
    Value<int?> respRate = const Value.absent(),
    int? signalQuality,
    ActivityState? activity,
    bool? isMotionNoisy,
    bool? isNotWorn,
  }) => VitalsRow(
    id: id ?? this.id,
    timestamp: timestamp ?? this.timestamp,
    seq: seq ?? this.seq,
    heartRate: heartRate.present ? heartRate.value : this.heartRate,
    spo2: spo2.present ? spo2.value : this.spo2,
    respRate: respRate.present ? respRate.value : this.respRate,
    signalQuality: signalQuality ?? this.signalQuality,
    activity: activity ?? this.activity,
    isMotionNoisy: isMotionNoisy ?? this.isMotionNoisy,
    isNotWorn: isNotWorn ?? this.isNotWorn,
  );
  VitalsRow copyWithCompanion(VitalsReadingsCompanion data) {
    return VitalsRow(
      id: data.id.present ? data.id.value : this.id,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      seq: data.seq.present ? data.seq.value : this.seq,
      heartRate: data.heartRate.present ? data.heartRate.value : this.heartRate,
      spo2: data.spo2.present ? data.spo2.value : this.spo2,
      respRate: data.respRate.present ? data.respRate.value : this.respRate,
      signalQuality: data.signalQuality.present
          ? data.signalQuality.value
          : this.signalQuality,
      activity: data.activity.present ? data.activity.value : this.activity,
      isMotionNoisy: data.isMotionNoisy.present
          ? data.isMotionNoisy.value
          : this.isMotionNoisy,
      isNotWorn: data.isNotWorn.present ? data.isNotWorn.value : this.isNotWorn,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VitalsRow(')
          ..write('id: $id, ')
          ..write('timestamp: $timestamp, ')
          ..write('seq: $seq, ')
          ..write('heartRate: $heartRate, ')
          ..write('spo2: $spo2, ')
          ..write('respRate: $respRate, ')
          ..write('signalQuality: $signalQuality, ')
          ..write('activity: $activity, ')
          ..write('isMotionNoisy: $isMotionNoisy, ')
          ..write('isNotWorn: $isNotWorn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    timestamp,
    seq,
    heartRate,
    spo2,
    respRate,
    signalQuality,
    activity,
    isMotionNoisy,
    isNotWorn,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VitalsRow &&
          other.id == this.id &&
          other.timestamp == this.timestamp &&
          other.seq == this.seq &&
          other.heartRate == this.heartRate &&
          other.spo2 == this.spo2 &&
          other.respRate == this.respRate &&
          other.signalQuality == this.signalQuality &&
          other.activity == this.activity &&
          other.isMotionNoisy == this.isMotionNoisy &&
          other.isNotWorn == this.isNotWorn);
}

class VitalsReadingsCompanion extends UpdateCompanion<VitalsRow> {
  final Value<int> id;
  final Value<DateTime> timestamp;
  final Value<int> seq;
  final Value<int?> heartRate;
  final Value<int?> spo2;
  final Value<int?> respRate;
  final Value<int> signalQuality;
  final Value<ActivityState> activity;
  final Value<bool> isMotionNoisy;
  final Value<bool> isNotWorn;
  const VitalsReadingsCompanion({
    this.id = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.seq = const Value.absent(),
    this.heartRate = const Value.absent(),
    this.spo2 = const Value.absent(),
    this.respRate = const Value.absent(),
    this.signalQuality = const Value.absent(),
    this.activity = const Value.absent(),
    this.isMotionNoisy = const Value.absent(),
    this.isNotWorn = const Value.absent(),
  });
  VitalsReadingsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime timestamp,
    required int seq,
    this.heartRate = const Value.absent(),
    this.spo2 = const Value.absent(),
    this.respRate = const Value.absent(),
    required int signalQuality,
    required ActivityState activity,
    required bool isMotionNoisy,
    required bool isNotWorn,
  }) : timestamp = Value(timestamp),
       seq = Value(seq),
       signalQuality = Value(signalQuality),
       activity = Value(activity),
       isMotionNoisy = Value(isMotionNoisy),
       isNotWorn = Value(isNotWorn);
  static Insertable<VitalsRow> custom({
    Expression<int>? id,
    Expression<DateTime>? timestamp,
    Expression<int>? seq,
    Expression<int>? heartRate,
    Expression<int>? spo2,
    Expression<int>? respRate,
    Expression<int>? signalQuality,
    Expression<int>? activity,
    Expression<bool>? isMotionNoisy,
    Expression<bool>? isNotWorn,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (timestamp != null) 'timestamp': timestamp,
      if (seq != null) 'seq': seq,
      if (heartRate != null) 'heart_rate': heartRate,
      if (spo2 != null) 'spo2': spo2,
      if (respRate != null) 'resp_rate': respRate,
      if (signalQuality != null) 'signal_quality': signalQuality,
      if (activity != null) 'activity': activity,
      if (isMotionNoisy != null) 'is_motion_noisy': isMotionNoisy,
      if (isNotWorn != null) 'is_not_worn': isNotWorn,
    });
  }

  VitalsReadingsCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? timestamp,
    Value<int>? seq,
    Value<int?>? heartRate,
    Value<int?>? spo2,
    Value<int?>? respRate,
    Value<int>? signalQuality,
    Value<ActivityState>? activity,
    Value<bool>? isMotionNoisy,
    Value<bool>? isNotWorn,
  }) {
    return VitalsReadingsCompanion(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      seq: seq ?? this.seq,
      heartRate: heartRate ?? this.heartRate,
      spo2: spo2 ?? this.spo2,
      respRate: respRate ?? this.respRate,
      signalQuality: signalQuality ?? this.signalQuality,
      activity: activity ?? this.activity,
      isMotionNoisy: isMotionNoisy ?? this.isMotionNoisy,
      isNotWorn: isNotWorn ?? this.isNotWorn,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (seq.present) {
      map['seq'] = Variable<int>(seq.value);
    }
    if (heartRate.present) {
      map['heart_rate'] = Variable<int>(heartRate.value);
    }
    if (spo2.present) {
      map['spo2'] = Variable<int>(spo2.value);
    }
    if (respRate.present) {
      map['resp_rate'] = Variable<int>(respRate.value);
    }
    if (signalQuality.present) {
      map['signal_quality'] = Variable<int>(signalQuality.value);
    }
    if (activity.present) {
      map['activity'] = Variable<int>(
        $VitalsReadingsTable.$converteractivity.toSql(activity.value),
      );
    }
    if (isMotionNoisy.present) {
      map['is_motion_noisy'] = Variable<bool>(isMotionNoisy.value);
    }
    if (isNotWorn.present) {
      map['is_not_worn'] = Variable<bool>(isNotWorn.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VitalsReadingsCompanion(')
          ..write('id: $id, ')
          ..write('timestamp: $timestamp, ')
          ..write('seq: $seq, ')
          ..write('heartRate: $heartRate, ')
          ..write('spo2: $spo2, ')
          ..write('respRate: $respRate, ')
          ..write('signalQuality: $signalQuality, ')
          ..write('activity: $activity, ')
          ..write('isMotionNoisy: $isMotionNoisy, ')
          ..write('isNotWorn: $isNotWorn')
          ..write(')'))
        .toString();
  }
}

class $EnvReadingsTable extends EnvReadings
    with TableInfo<$EnvReadingsTable, EnvRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EnvReadingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _seqMeta = const VerificationMeta('seq');
  @override
  late final GeneratedColumn<int> seq = GeneratedColumn<int>(
    'seq',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pm25Meta = const VerificationMeta('pm25');
  @override
  late final GeneratedColumn<double> pm25 = GeneratedColumn<double>(
    'pm25',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pm10Meta = const VerificationMeta('pm10');
  @override
  late final GeneratedColumn<double> pm10 = GeneratedColumn<double>(
    'pm10',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tempCMeta = const VerificationMeta('tempC');
  @override
  late final GeneratedColumn<double> tempC = GeneratedColumn<double>(
    'temp_c',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _humidityMeta = const VerificationMeta(
    'humidity',
  );
  @override
  late final GeneratedColumn<double> humidity = GeneratedColumn<double>(
    'humidity',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _vocIndexMeta = const VerificationMeta(
    'vocIndex',
  );
  @override
  late final GeneratedColumn<int> vocIndex = GeneratedColumn<int>(
    'voc_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _no2Meta = const VerificationMeta('no2');
  @override
  late final GeneratedColumn<double> no2 = GeneratedColumn<double>(
    'no2',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _so2Meta = const VerificationMeta('so2');
  @override
  late final GeneratedColumn<double> so2 = GeneratedColumn<double>(
    'so2',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('device'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    timestamp,
    seq,
    pm25,
    pm10,
    tempC,
    humidity,
    vocIndex,
    no2,
    so2,
    source,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'env_readings';
  @override
  VerificationContext validateIntegrity(
    Insertable<EnvRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('seq')) {
      context.handle(
        _seqMeta,
        seq.isAcceptableOrUnknown(data['seq']!, _seqMeta),
      );
    } else if (isInserting) {
      context.missing(_seqMeta);
    }
    if (data.containsKey('pm25')) {
      context.handle(
        _pm25Meta,
        pm25.isAcceptableOrUnknown(data['pm25']!, _pm25Meta),
      );
    } else if (isInserting) {
      context.missing(_pm25Meta);
    }
    if (data.containsKey('pm10')) {
      context.handle(
        _pm10Meta,
        pm10.isAcceptableOrUnknown(data['pm10']!, _pm10Meta),
      );
    } else if (isInserting) {
      context.missing(_pm10Meta);
    }
    if (data.containsKey('temp_c')) {
      context.handle(
        _tempCMeta,
        tempC.isAcceptableOrUnknown(data['temp_c']!, _tempCMeta),
      );
    } else if (isInserting) {
      context.missing(_tempCMeta);
    }
    if (data.containsKey('humidity')) {
      context.handle(
        _humidityMeta,
        humidity.isAcceptableOrUnknown(data['humidity']!, _humidityMeta),
      );
    } else if (isInserting) {
      context.missing(_humidityMeta);
    }
    if (data.containsKey('voc_index')) {
      context.handle(
        _vocIndexMeta,
        vocIndex.isAcceptableOrUnknown(data['voc_index']!, _vocIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_vocIndexMeta);
    }
    if (data.containsKey('no2')) {
      context.handle(
        _no2Meta,
        no2.isAcceptableOrUnknown(data['no2']!, _no2Meta),
      );
    }
    if (data.containsKey('so2')) {
      context.handle(
        _so2Meta,
        so2.isAcceptableOrUnknown(data['so2']!, _so2Meta),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EnvRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EnvRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
      seq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}seq'],
      )!,
      pm25: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}pm25'],
      )!,
      pm10: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}pm10'],
      )!,
      tempC: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}temp_c'],
      )!,
      humidity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}humidity'],
      )!,
      vocIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}voc_index'],
      )!,
      no2: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}no2'],
      ),
      so2: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}so2'],
      ),
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
    );
  }

  @override
  $EnvReadingsTable createAlias(String alias) {
    return $EnvReadingsTable(attachedDatabase, alias);
  }
}

class EnvRow extends DataClass implements Insertable<EnvRow> {
  final int id;
  final DateTime timestamp;
  final int seq;
  final double pm25;
  final double pm10;
  final double tempC;
  final double humidity;
  final int vocIndex;
  final double? no2;
  final double? so2;
  final String source;
  const EnvRow({
    required this.id,
    required this.timestamp,
    required this.seq,
    required this.pm25,
    required this.pm10,
    required this.tempC,
    required this.humidity,
    required this.vocIndex,
    this.no2,
    this.so2,
    required this.source,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['timestamp'] = Variable<DateTime>(timestamp);
    map['seq'] = Variable<int>(seq);
    map['pm25'] = Variable<double>(pm25);
    map['pm10'] = Variable<double>(pm10);
    map['temp_c'] = Variable<double>(tempC);
    map['humidity'] = Variable<double>(humidity);
    map['voc_index'] = Variable<int>(vocIndex);
    if (!nullToAbsent || no2 != null) {
      map['no2'] = Variable<double>(no2);
    }
    if (!nullToAbsent || so2 != null) {
      map['so2'] = Variable<double>(so2);
    }
    map['source'] = Variable<String>(source);
    return map;
  }

  EnvReadingsCompanion toCompanion(bool nullToAbsent) {
    return EnvReadingsCompanion(
      id: Value(id),
      timestamp: Value(timestamp),
      seq: Value(seq),
      pm25: Value(pm25),
      pm10: Value(pm10),
      tempC: Value(tempC),
      humidity: Value(humidity),
      vocIndex: Value(vocIndex),
      no2: no2 == null && nullToAbsent ? const Value.absent() : Value(no2),
      so2: so2 == null && nullToAbsent ? const Value.absent() : Value(so2),
      source: Value(source),
    );
  }

  factory EnvRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EnvRow(
      id: serializer.fromJson<int>(json['id']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      seq: serializer.fromJson<int>(json['seq']),
      pm25: serializer.fromJson<double>(json['pm25']),
      pm10: serializer.fromJson<double>(json['pm10']),
      tempC: serializer.fromJson<double>(json['tempC']),
      humidity: serializer.fromJson<double>(json['humidity']),
      vocIndex: serializer.fromJson<int>(json['vocIndex']),
      no2: serializer.fromJson<double?>(json['no2']),
      so2: serializer.fromJson<double?>(json['so2']),
      source: serializer.fromJson<String>(json['source']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'seq': serializer.toJson<int>(seq),
      'pm25': serializer.toJson<double>(pm25),
      'pm10': serializer.toJson<double>(pm10),
      'tempC': serializer.toJson<double>(tempC),
      'humidity': serializer.toJson<double>(humidity),
      'vocIndex': serializer.toJson<int>(vocIndex),
      'no2': serializer.toJson<double?>(no2),
      'so2': serializer.toJson<double?>(so2),
      'source': serializer.toJson<String>(source),
    };
  }

  EnvRow copyWith({
    int? id,
    DateTime? timestamp,
    int? seq,
    double? pm25,
    double? pm10,
    double? tempC,
    double? humidity,
    int? vocIndex,
    Value<double?> no2 = const Value.absent(),
    Value<double?> so2 = const Value.absent(),
    String? source,
  }) => EnvRow(
    id: id ?? this.id,
    timestamp: timestamp ?? this.timestamp,
    seq: seq ?? this.seq,
    pm25: pm25 ?? this.pm25,
    pm10: pm10 ?? this.pm10,
    tempC: tempC ?? this.tempC,
    humidity: humidity ?? this.humidity,
    vocIndex: vocIndex ?? this.vocIndex,
    no2: no2.present ? no2.value : this.no2,
    so2: so2.present ? so2.value : this.so2,
    source: source ?? this.source,
  );
  EnvRow copyWithCompanion(EnvReadingsCompanion data) {
    return EnvRow(
      id: data.id.present ? data.id.value : this.id,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      seq: data.seq.present ? data.seq.value : this.seq,
      pm25: data.pm25.present ? data.pm25.value : this.pm25,
      pm10: data.pm10.present ? data.pm10.value : this.pm10,
      tempC: data.tempC.present ? data.tempC.value : this.tempC,
      humidity: data.humidity.present ? data.humidity.value : this.humidity,
      vocIndex: data.vocIndex.present ? data.vocIndex.value : this.vocIndex,
      no2: data.no2.present ? data.no2.value : this.no2,
      so2: data.so2.present ? data.so2.value : this.so2,
      source: data.source.present ? data.source.value : this.source,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EnvRow(')
          ..write('id: $id, ')
          ..write('timestamp: $timestamp, ')
          ..write('seq: $seq, ')
          ..write('pm25: $pm25, ')
          ..write('pm10: $pm10, ')
          ..write('tempC: $tempC, ')
          ..write('humidity: $humidity, ')
          ..write('vocIndex: $vocIndex, ')
          ..write('no2: $no2, ')
          ..write('so2: $so2, ')
          ..write('source: $source')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    timestamp,
    seq,
    pm25,
    pm10,
    tempC,
    humidity,
    vocIndex,
    no2,
    so2,
    source,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EnvRow &&
          other.id == this.id &&
          other.timestamp == this.timestamp &&
          other.seq == this.seq &&
          other.pm25 == this.pm25 &&
          other.pm10 == this.pm10 &&
          other.tempC == this.tempC &&
          other.humidity == this.humidity &&
          other.vocIndex == this.vocIndex &&
          other.no2 == this.no2 &&
          other.so2 == this.so2 &&
          other.source == this.source);
}

class EnvReadingsCompanion extends UpdateCompanion<EnvRow> {
  final Value<int> id;
  final Value<DateTime> timestamp;
  final Value<int> seq;
  final Value<double> pm25;
  final Value<double> pm10;
  final Value<double> tempC;
  final Value<double> humidity;
  final Value<int> vocIndex;
  final Value<double?> no2;
  final Value<double?> so2;
  final Value<String> source;
  const EnvReadingsCompanion({
    this.id = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.seq = const Value.absent(),
    this.pm25 = const Value.absent(),
    this.pm10 = const Value.absent(),
    this.tempC = const Value.absent(),
    this.humidity = const Value.absent(),
    this.vocIndex = const Value.absent(),
    this.no2 = const Value.absent(),
    this.so2 = const Value.absent(),
    this.source = const Value.absent(),
  });
  EnvReadingsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime timestamp,
    required int seq,
    required double pm25,
    required double pm10,
    required double tempC,
    required double humidity,
    required int vocIndex,
    this.no2 = const Value.absent(),
    this.so2 = const Value.absent(),
    this.source = const Value.absent(),
  }) : timestamp = Value(timestamp),
       seq = Value(seq),
       pm25 = Value(pm25),
       pm10 = Value(pm10),
       tempC = Value(tempC),
       humidity = Value(humidity),
       vocIndex = Value(vocIndex);
  static Insertable<EnvRow> custom({
    Expression<int>? id,
    Expression<DateTime>? timestamp,
    Expression<int>? seq,
    Expression<double>? pm25,
    Expression<double>? pm10,
    Expression<double>? tempC,
    Expression<double>? humidity,
    Expression<int>? vocIndex,
    Expression<double>? no2,
    Expression<double>? so2,
    Expression<String>? source,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (timestamp != null) 'timestamp': timestamp,
      if (seq != null) 'seq': seq,
      if (pm25 != null) 'pm25': pm25,
      if (pm10 != null) 'pm10': pm10,
      if (tempC != null) 'temp_c': tempC,
      if (humidity != null) 'humidity': humidity,
      if (vocIndex != null) 'voc_index': vocIndex,
      if (no2 != null) 'no2': no2,
      if (so2 != null) 'so2': so2,
      if (source != null) 'source': source,
    });
  }

  EnvReadingsCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? timestamp,
    Value<int>? seq,
    Value<double>? pm25,
    Value<double>? pm10,
    Value<double>? tempC,
    Value<double>? humidity,
    Value<int>? vocIndex,
    Value<double?>? no2,
    Value<double?>? so2,
    Value<String>? source,
  }) {
    return EnvReadingsCompanion(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      seq: seq ?? this.seq,
      pm25: pm25 ?? this.pm25,
      pm10: pm10 ?? this.pm10,
      tempC: tempC ?? this.tempC,
      humidity: humidity ?? this.humidity,
      vocIndex: vocIndex ?? this.vocIndex,
      no2: no2 ?? this.no2,
      so2: so2 ?? this.so2,
      source: source ?? this.source,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (seq.present) {
      map['seq'] = Variable<int>(seq.value);
    }
    if (pm25.present) {
      map['pm25'] = Variable<double>(pm25.value);
    }
    if (pm10.present) {
      map['pm10'] = Variable<double>(pm10.value);
    }
    if (tempC.present) {
      map['temp_c'] = Variable<double>(tempC.value);
    }
    if (humidity.present) {
      map['humidity'] = Variable<double>(humidity.value);
    }
    if (vocIndex.present) {
      map['voc_index'] = Variable<int>(vocIndex.value);
    }
    if (no2.present) {
      map['no2'] = Variable<double>(no2.value);
    }
    if (so2.present) {
      map['so2'] = Variable<double>(so2.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EnvReadingsCompanion(')
          ..write('id: $id, ')
          ..write('timestamp: $timestamp, ')
          ..write('seq: $seq, ')
          ..write('pm25: $pm25, ')
          ..write('pm10: $pm10, ')
          ..write('tempC: $tempC, ')
          ..write('humidity: $humidity, ')
          ..write('vocIndex: $vocIndex, ')
          ..write('no2: $no2, ')
          ..write('so2: $so2, ')
          ..write('source: $source')
          ..write(')'))
        .toString();
  }
}

class $AlertsTable extends Alerts with TableInfo<$AlertsTable, AlertRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AlertsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<AlertCategory, int> category =
      GeneratedColumn<int>(
        'category',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<AlertCategory>($AlertsTable.$convertercategory);
  @override
  late final GeneratedColumnWithTypeConverter<AlertSeverity, int> severity =
      GeneratedColumn<int>(
        'severity',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<AlertSeverity>($AlertsTable.$converterseverity);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _acknowledgedMeta = const VerificationMeta(
    'acknowledged',
  );
  @override
  late final GeneratedColumn<bool> acknowledged = GeneratedColumn<bool>(
    'acknowledged',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("acknowledged" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    timestamp,
    category,
    severity,
    title,
    reason,
    acknowledged,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'alerts';
  @override
  VerificationContext validateIntegrity(
    Insertable<AlertRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    } else if (isInserting) {
      context.missing(_reasonMeta);
    }
    if (data.containsKey('acknowledged')) {
      context.handle(
        _acknowledgedMeta,
        acknowledged.isAcceptableOrUnknown(
          data['acknowledged']!,
          _acknowledgedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AlertRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AlertRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
      category: $AlertsTable.$convertercategory.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}category'],
        )!,
      ),
      severity: $AlertsTable.$converterseverity.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}severity'],
        )!,
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      )!,
      acknowledged: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}acknowledged'],
      )!,
    );
  }

  @override
  $AlertsTable createAlias(String alias) {
    return $AlertsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<AlertCategory, int, int> $convertercategory =
      const EnumIndexConverter<AlertCategory>(AlertCategory.values);
  static JsonTypeConverter2<AlertSeverity, int, int> $converterseverity =
      const EnumIndexConverter<AlertSeverity>(AlertSeverity.values);
}

class AlertRow extends DataClass implements Insertable<AlertRow> {
  final int id;
  final DateTime timestamp;
  final AlertCategory category;
  final AlertSeverity severity;
  final String title;
  final String reason;
  final bool acknowledged;
  const AlertRow({
    required this.id,
    required this.timestamp,
    required this.category,
    required this.severity,
    required this.title,
    required this.reason,
    required this.acknowledged,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['timestamp'] = Variable<DateTime>(timestamp);
    {
      map['category'] = Variable<int>(
        $AlertsTable.$convertercategory.toSql(category),
      );
    }
    {
      map['severity'] = Variable<int>(
        $AlertsTable.$converterseverity.toSql(severity),
      );
    }
    map['title'] = Variable<String>(title);
    map['reason'] = Variable<String>(reason);
    map['acknowledged'] = Variable<bool>(acknowledged);
    return map;
  }

  AlertsCompanion toCompanion(bool nullToAbsent) {
    return AlertsCompanion(
      id: Value(id),
      timestamp: Value(timestamp),
      category: Value(category),
      severity: Value(severity),
      title: Value(title),
      reason: Value(reason),
      acknowledged: Value(acknowledged),
    );
  }

  factory AlertRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AlertRow(
      id: serializer.fromJson<int>(json['id']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      category: $AlertsTable.$convertercategory.fromJson(
        serializer.fromJson<int>(json['category']),
      ),
      severity: $AlertsTable.$converterseverity.fromJson(
        serializer.fromJson<int>(json['severity']),
      ),
      title: serializer.fromJson<String>(json['title']),
      reason: serializer.fromJson<String>(json['reason']),
      acknowledged: serializer.fromJson<bool>(json['acknowledged']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'category': serializer.toJson<int>(
        $AlertsTable.$convertercategory.toJson(category),
      ),
      'severity': serializer.toJson<int>(
        $AlertsTable.$converterseverity.toJson(severity),
      ),
      'title': serializer.toJson<String>(title),
      'reason': serializer.toJson<String>(reason),
      'acknowledged': serializer.toJson<bool>(acknowledged),
    };
  }

  AlertRow copyWith({
    int? id,
    DateTime? timestamp,
    AlertCategory? category,
    AlertSeverity? severity,
    String? title,
    String? reason,
    bool? acknowledged,
  }) => AlertRow(
    id: id ?? this.id,
    timestamp: timestamp ?? this.timestamp,
    category: category ?? this.category,
    severity: severity ?? this.severity,
    title: title ?? this.title,
    reason: reason ?? this.reason,
    acknowledged: acknowledged ?? this.acknowledged,
  );
  AlertRow copyWithCompanion(AlertsCompanion data) {
    return AlertRow(
      id: data.id.present ? data.id.value : this.id,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      category: data.category.present ? data.category.value : this.category,
      severity: data.severity.present ? data.severity.value : this.severity,
      title: data.title.present ? data.title.value : this.title,
      reason: data.reason.present ? data.reason.value : this.reason,
      acknowledged: data.acknowledged.present
          ? data.acknowledged.value
          : this.acknowledged,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AlertRow(')
          ..write('id: $id, ')
          ..write('timestamp: $timestamp, ')
          ..write('category: $category, ')
          ..write('severity: $severity, ')
          ..write('title: $title, ')
          ..write('reason: $reason, ')
          ..write('acknowledged: $acknowledged')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    timestamp,
    category,
    severity,
    title,
    reason,
    acknowledged,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AlertRow &&
          other.id == this.id &&
          other.timestamp == this.timestamp &&
          other.category == this.category &&
          other.severity == this.severity &&
          other.title == this.title &&
          other.reason == this.reason &&
          other.acknowledged == this.acknowledged);
}

class AlertsCompanion extends UpdateCompanion<AlertRow> {
  final Value<int> id;
  final Value<DateTime> timestamp;
  final Value<AlertCategory> category;
  final Value<AlertSeverity> severity;
  final Value<String> title;
  final Value<String> reason;
  final Value<bool> acknowledged;
  const AlertsCompanion({
    this.id = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.category = const Value.absent(),
    this.severity = const Value.absent(),
    this.title = const Value.absent(),
    this.reason = const Value.absent(),
    this.acknowledged = const Value.absent(),
  });
  AlertsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime timestamp,
    required AlertCategory category,
    required AlertSeverity severity,
    required String title,
    required String reason,
    this.acknowledged = const Value.absent(),
  }) : timestamp = Value(timestamp),
       category = Value(category),
       severity = Value(severity),
       title = Value(title),
       reason = Value(reason);
  static Insertable<AlertRow> custom({
    Expression<int>? id,
    Expression<DateTime>? timestamp,
    Expression<int>? category,
    Expression<int>? severity,
    Expression<String>? title,
    Expression<String>? reason,
    Expression<bool>? acknowledged,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (timestamp != null) 'timestamp': timestamp,
      if (category != null) 'category': category,
      if (severity != null) 'severity': severity,
      if (title != null) 'title': title,
      if (reason != null) 'reason': reason,
      if (acknowledged != null) 'acknowledged': acknowledged,
    });
  }

  AlertsCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? timestamp,
    Value<AlertCategory>? category,
    Value<AlertSeverity>? severity,
    Value<String>? title,
    Value<String>? reason,
    Value<bool>? acknowledged,
  }) {
    return AlertsCompanion(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      category: category ?? this.category,
      severity: severity ?? this.severity,
      title: title ?? this.title,
      reason: reason ?? this.reason,
      acknowledged: acknowledged ?? this.acknowledged,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (category.present) {
      map['category'] = Variable<int>(
        $AlertsTable.$convertercategory.toSql(category.value),
      );
    }
    if (severity.present) {
      map['severity'] = Variable<int>(
        $AlertsTable.$converterseverity.toSql(severity.value),
      );
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (acknowledged.present) {
      map['acknowledged'] = Variable<bool>(acknowledged.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AlertsCompanion(')
          ..write('id: $id, ')
          ..write('timestamp: $timestamp, ')
          ..write('category: $category, ')
          ..write('severity: $severity, ')
          ..write('title: $title, ')
          ..write('reason: $reason, ')
          ..write('acknowledged: $acknowledged')
          ..write(')'))
        .toString();
  }
}

class $PersonalBaselineTable extends PersonalBaseline
    with TableInfo<$PersonalBaselineTable, BaselineRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PersonalBaselineTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _restingHrMeta = const VerificationMeta(
    'restingHr',
  );
  @override
  late final GeneratedColumn<double> restingHr = GeneratedColumn<double>(
    'resting_hr',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _restingRespRateMeta = const VerificationMeta(
    'restingRespRate',
  );
  @override
  late final GeneratedColumn<double> restingRespRate = GeneratedColumn<double>(
    'resting_resp_rate',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _restingSpo2Meta = const VerificationMeta(
    'restingSpo2',
  );
  @override
  late final GeneratedColumn<double> restingSpo2 = GeneratedColumn<double>(
    'resting_spo2',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _computedAtMeta = const VerificationMeta(
    'computedAt',
  );
  @override
  late final GeneratedColumn<DateTime> computedAt = GeneratedColumn<DateTime>(
    'computed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sampleCountMeta = const VerificationMeta(
    'sampleCount',
  );
  @override
  late final GeneratedColumn<int> sampleCount = GeneratedColumn<int>(
    'sample_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    userId,
    restingHr,
    restingRespRate,
    restingSpo2,
    computedAt,
    sampleCount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'personal_baseline';
  @override
  VerificationContext validateIntegrity(
    Insertable<BaselineRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('resting_hr')) {
      context.handle(
        _restingHrMeta,
        restingHr.isAcceptableOrUnknown(data['resting_hr']!, _restingHrMeta),
      );
    } else if (isInserting) {
      context.missing(_restingHrMeta);
    }
    if (data.containsKey('resting_resp_rate')) {
      context.handle(
        _restingRespRateMeta,
        restingRespRate.isAcceptableOrUnknown(
          data['resting_resp_rate']!,
          _restingRespRateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_restingRespRateMeta);
    }
    if (data.containsKey('resting_spo2')) {
      context.handle(
        _restingSpo2Meta,
        restingSpo2.isAcceptableOrUnknown(
          data['resting_spo2']!,
          _restingSpo2Meta,
        ),
      );
    } else if (isInserting) {
      context.missing(_restingSpo2Meta);
    }
    if (data.containsKey('computed_at')) {
      context.handle(
        _computedAtMeta,
        computedAt.isAcceptableOrUnknown(data['computed_at']!, _computedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_computedAtMeta);
    }
    if (data.containsKey('sample_count')) {
      context.handle(
        _sampleCountMeta,
        sampleCount.isAcceptableOrUnknown(
          data['sample_count']!,
          _sampleCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sampleCountMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId};
  @override
  BaselineRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BaselineRow(
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      restingHr: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}resting_hr'],
      )!,
      restingRespRate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}resting_resp_rate'],
      )!,
      restingSpo2: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}resting_spo2'],
      )!,
      computedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}computed_at'],
      )!,
      sampleCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sample_count'],
      )!,
    );
  }

  @override
  $PersonalBaselineTable createAlias(String alias) {
    return $PersonalBaselineTable(attachedDatabase, alias);
  }
}

class BaselineRow extends DataClass implements Insertable<BaselineRow> {
  final String userId;
  final double restingHr;
  final double restingRespRate;
  final double restingSpo2;
  final DateTime computedAt;
  final int sampleCount;
  const BaselineRow({
    required this.userId,
    required this.restingHr,
    required this.restingRespRate,
    required this.restingSpo2,
    required this.computedAt,
    required this.sampleCount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<String>(userId);
    map['resting_hr'] = Variable<double>(restingHr);
    map['resting_resp_rate'] = Variable<double>(restingRespRate);
    map['resting_spo2'] = Variable<double>(restingSpo2);
    map['computed_at'] = Variable<DateTime>(computedAt);
    map['sample_count'] = Variable<int>(sampleCount);
    return map;
  }

  PersonalBaselineCompanion toCompanion(bool nullToAbsent) {
    return PersonalBaselineCompanion(
      userId: Value(userId),
      restingHr: Value(restingHr),
      restingRespRate: Value(restingRespRate),
      restingSpo2: Value(restingSpo2),
      computedAt: Value(computedAt),
      sampleCount: Value(sampleCount),
    );
  }

  factory BaselineRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BaselineRow(
      userId: serializer.fromJson<String>(json['userId']),
      restingHr: serializer.fromJson<double>(json['restingHr']),
      restingRespRate: serializer.fromJson<double>(json['restingRespRate']),
      restingSpo2: serializer.fromJson<double>(json['restingSpo2']),
      computedAt: serializer.fromJson<DateTime>(json['computedAt']),
      sampleCount: serializer.fromJson<int>(json['sampleCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<String>(userId),
      'restingHr': serializer.toJson<double>(restingHr),
      'restingRespRate': serializer.toJson<double>(restingRespRate),
      'restingSpo2': serializer.toJson<double>(restingSpo2),
      'computedAt': serializer.toJson<DateTime>(computedAt),
      'sampleCount': serializer.toJson<int>(sampleCount),
    };
  }

  BaselineRow copyWith({
    String? userId,
    double? restingHr,
    double? restingRespRate,
    double? restingSpo2,
    DateTime? computedAt,
    int? sampleCount,
  }) => BaselineRow(
    userId: userId ?? this.userId,
    restingHr: restingHr ?? this.restingHr,
    restingRespRate: restingRespRate ?? this.restingRespRate,
    restingSpo2: restingSpo2 ?? this.restingSpo2,
    computedAt: computedAt ?? this.computedAt,
    sampleCount: sampleCount ?? this.sampleCount,
  );
  BaselineRow copyWithCompanion(PersonalBaselineCompanion data) {
    return BaselineRow(
      userId: data.userId.present ? data.userId.value : this.userId,
      restingHr: data.restingHr.present ? data.restingHr.value : this.restingHr,
      restingRespRate: data.restingRespRate.present
          ? data.restingRespRate.value
          : this.restingRespRate,
      restingSpo2: data.restingSpo2.present
          ? data.restingSpo2.value
          : this.restingSpo2,
      computedAt: data.computedAt.present
          ? data.computedAt.value
          : this.computedAt,
      sampleCount: data.sampleCount.present
          ? data.sampleCount.value
          : this.sampleCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BaselineRow(')
          ..write('userId: $userId, ')
          ..write('restingHr: $restingHr, ')
          ..write('restingRespRate: $restingRespRate, ')
          ..write('restingSpo2: $restingSpo2, ')
          ..write('computedAt: $computedAt, ')
          ..write('sampleCount: $sampleCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    userId,
    restingHr,
    restingRespRate,
    restingSpo2,
    computedAt,
    sampleCount,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BaselineRow &&
          other.userId == this.userId &&
          other.restingHr == this.restingHr &&
          other.restingRespRate == this.restingRespRate &&
          other.restingSpo2 == this.restingSpo2 &&
          other.computedAt == this.computedAt &&
          other.sampleCount == this.sampleCount);
}

class PersonalBaselineCompanion extends UpdateCompanion<BaselineRow> {
  final Value<String> userId;
  final Value<double> restingHr;
  final Value<double> restingRespRate;
  final Value<double> restingSpo2;
  final Value<DateTime> computedAt;
  final Value<int> sampleCount;
  final Value<int> rowid;
  const PersonalBaselineCompanion({
    this.userId = const Value.absent(),
    this.restingHr = const Value.absent(),
    this.restingRespRate = const Value.absent(),
    this.restingSpo2 = const Value.absent(),
    this.computedAt = const Value.absent(),
    this.sampleCount = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PersonalBaselineCompanion.insert({
    required String userId,
    required double restingHr,
    required double restingRespRate,
    required double restingSpo2,
    required DateTime computedAt,
    required int sampleCount,
    this.rowid = const Value.absent(),
  }) : userId = Value(userId),
       restingHr = Value(restingHr),
       restingRespRate = Value(restingRespRate),
       restingSpo2 = Value(restingSpo2),
       computedAt = Value(computedAt),
       sampleCount = Value(sampleCount);
  static Insertable<BaselineRow> custom({
    Expression<String>? userId,
    Expression<double>? restingHr,
    Expression<double>? restingRespRate,
    Expression<double>? restingSpo2,
    Expression<DateTime>? computedAt,
    Expression<int>? sampleCount,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (restingHr != null) 'resting_hr': restingHr,
      if (restingRespRate != null) 'resting_resp_rate': restingRespRate,
      if (restingSpo2 != null) 'resting_spo2': restingSpo2,
      if (computedAt != null) 'computed_at': computedAt,
      if (sampleCount != null) 'sample_count': sampleCount,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PersonalBaselineCompanion copyWith({
    Value<String>? userId,
    Value<double>? restingHr,
    Value<double>? restingRespRate,
    Value<double>? restingSpo2,
    Value<DateTime>? computedAt,
    Value<int>? sampleCount,
    Value<int>? rowid,
  }) {
    return PersonalBaselineCompanion(
      userId: userId ?? this.userId,
      restingHr: restingHr ?? this.restingHr,
      restingRespRate: restingRespRate ?? this.restingRespRate,
      restingSpo2: restingSpo2 ?? this.restingSpo2,
      computedAt: computedAt ?? this.computedAt,
      sampleCount: sampleCount ?? this.sampleCount,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (restingHr.present) {
      map['resting_hr'] = Variable<double>(restingHr.value);
    }
    if (restingRespRate.present) {
      map['resting_resp_rate'] = Variable<double>(restingRespRate.value);
    }
    if (restingSpo2.present) {
      map['resting_spo2'] = Variable<double>(restingSpo2.value);
    }
    if (computedAt.present) {
      map['computed_at'] = Variable<DateTime>(computedAt.value);
    }
    if (sampleCount.present) {
      map['sample_count'] = Variable<int>(sampleCount.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PersonalBaselineCompanion(')
          ..write('userId: $userId, ')
          ..write('restingHr: $restingHr, ')
          ..write('restingRespRate: $restingRespRate, ')
          ..write('restingSpo2: $restingSpo2, ')
          ..write('computedAt: $computedAt, ')
          ..write('sampleCount: $sampleCount, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MedicationsTable extends Medications
    with TableInfo<$MedicationsTable, MedicationRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MedicationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dosageMeta = const VerificationMeta('dosage');
  @override
  late final GeneratedColumn<String> dosage = GeneratedColumn<String>(
    'dosage',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scheduleTimesMeta = const VerificationMeta(
    'scheduleTimes',
  );
  @override
  late final GeneratedColumn<String> scheduleTimes = GeneratedColumn<String>(
    'schedule_times',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, dosage, scheduleTimes];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'medications';
  @override
  VerificationContext validateIntegrity(
    Insertable<MedicationRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('dosage')) {
      context.handle(
        _dosageMeta,
        dosage.isAcceptableOrUnknown(data['dosage']!, _dosageMeta),
      );
    } else if (isInserting) {
      context.missing(_dosageMeta);
    }
    if (data.containsKey('schedule_times')) {
      context.handle(
        _scheduleTimesMeta,
        scheduleTimes.isAcceptableOrUnknown(
          data['schedule_times']!,
          _scheduleTimesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_scheduleTimesMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MedicationRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MedicationRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      dosage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dosage'],
      )!,
      scheduleTimes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}schedule_times'],
      )!,
    );
  }

  @override
  $MedicationsTable createAlias(String alias) {
    return $MedicationsTable(attachedDatabase, alias);
  }
}

class MedicationRow extends DataClass implements Insertable<MedicationRow> {
  final int id;
  final String name;
  final String dosage;
  final String scheduleTimes;
  const MedicationRow({
    required this.id,
    required this.name,
    required this.dosage,
    required this.scheduleTimes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['dosage'] = Variable<String>(dosage);
    map['schedule_times'] = Variable<String>(scheduleTimes);
    return map;
  }

  MedicationsCompanion toCompanion(bool nullToAbsent) {
    return MedicationsCompanion(
      id: Value(id),
      name: Value(name),
      dosage: Value(dosage),
      scheduleTimes: Value(scheduleTimes),
    );
  }

  factory MedicationRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MedicationRow(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      dosage: serializer.fromJson<String>(json['dosage']),
      scheduleTimes: serializer.fromJson<String>(json['scheduleTimes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'dosage': serializer.toJson<String>(dosage),
      'scheduleTimes': serializer.toJson<String>(scheduleTimes),
    };
  }

  MedicationRow copyWith({
    int? id,
    String? name,
    String? dosage,
    String? scheduleTimes,
  }) => MedicationRow(
    id: id ?? this.id,
    name: name ?? this.name,
    dosage: dosage ?? this.dosage,
    scheduleTimes: scheduleTimes ?? this.scheduleTimes,
  );
  MedicationRow copyWithCompanion(MedicationsCompanion data) {
    return MedicationRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      dosage: data.dosage.present ? data.dosage.value : this.dosage,
      scheduleTimes: data.scheduleTimes.present
          ? data.scheduleTimes.value
          : this.scheduleTimes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MedicationRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('dosage: $dosage, ')
          ..write('scheduleTimes: $scheduleTimes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, dosage, scheduleTimes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MedicationRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.dosage == this.dosage &&
          other.scheduleTimes == this.scheduleTimes);
}

class MedicationsCompanion extends UpdateCompanion<MedicationRow> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> dosage;
  final Value<String> scheduleTimes;
  const MedicationsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.dosage = const Value.absent(),
    this.scheduleTimes = const Value.absent(),
  });
  MedicationsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String dosage,
    required String scheduleTimes,
  }) : name = Value(name),
       dosage = Value(dosage),
       scheduleTimes = Value(scheduleTimes);
  static Insertable<MedicationRow> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? dosage,
    Expression<String>? scheduleTimes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (dosage != null) 'dosage': dosage,
      if (scheduleTimes != null) 'schedule_times': scheduleTimes,
    });
  }

  MedicationsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? dosage,
    Value<String>? scheduleTimes,
  }) {
    return MedicationsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      scheduleTimes: scheduleTimes ?? this.scheduleTimes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (dosage.present) {
      map['dosage'] = Variable<String>(dosage.value);
    }
    if (scheduleTimes.present) {
      map['schedule_times'] = Variable<String>(scheduleTimes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MedicationsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('dosage: $dosage, ')
          ..write('scheduleTimes: $scheduleTimes')
          ..write(')'))
        .toString();
  }
}

class $AsthmaActionPlanTable extends AsthmaActionPlan
    with TableInfo<$AsthmaActionPlanTable, ActionPlanRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AsthmaActionPlanTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _zonesMeta = const VerificationMeta('zones');
  @override
  late final GeneratedColumn<String> zones = GeneratedColumn<String>(
    'zones',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [userId, zones];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'asthma_action_plan';
  @override
  VerificationContext validateIntegrity(
    Insertable<ActionPlanRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('zones')) {
      context.handle(
        _zonesMeta,
        zones.isAcceptableOrUnknown(data['zones']!, _zonesMeta),
      );
    } else if (isInserting) {
      context.missing(_zonesMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId};
  @override
  ActionPlanRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ActionPlanRow(
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      zones: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}zones'],
      )!,
    );
  }

  @override
  $AsthmaActionPlanTable createAlias(String alias) {
    return $AsthmaActionPlanTable(attachedDatabase, alias);
  }
}

class ActionPlanRow extends DataClass implements Insertable<ActionPlanRow> {
  final String userId;
  final String zones;
  const ActionPlanRow({required this.userId, required this.zones});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<String>(userId);
    map['zones'] = Variable<String>(zones);
    return map;
  }

  AsthmaActionPlanCompanion toCompanion(bool nullToAbsent) {
    return AsthmaActionPlanCompanion(
      userId: Value(userId),
      zones: Value(zones),
    );
  }

  factory ActionPlanRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ActionPlanRow(
      userId: serializer.fromJson<String>(json['userId']),
      zones: serializer.fromJson<String>(json['zones']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<String>(userId),
      'zones': serializer.toJson<String>(zones),
    };
  }

  ActionPlanRow copyWith({String? userId, String? zones}) =>
      ActionPlanRow(userId: userId ?? this.userId, zones: zones ?? this.zones);
  ActionPlanRow copyWithCompanion(AsthmaActionPlanCompanion data) {
    return ActionPlanRow(
      userId: data.userId.present ? data.userId.value : this.userId,
      zones: data.zones.present ? data.zones.value : this.zones,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ActionPlanRow(')
          ..write('userId: $userId, ')
          ..write('zones: $zones')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(userId, zones);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ActionPlanRow &&
          other.userId == this.userId &&
          other.zones == this.zones);
}

class AsthmaActionPlanCompanion extends UpdateCompanion<ActionPlanRow> {
  final Value<String> userId;
  final Value<String> zones;
  final Value<int> rowid;
  const AsthmaActionPlanCompanion({
    this.userId = const Value.absent(),
    this.zones = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AsthmaActionPlanCompanion.insert({
    required String userId,
    required String zones,
    this.rowid = const Value.absent(),
  }) : userId = Value(userId),
       zones = Value(zones);
  static Insertable<ActionPlanRow> custom({
    Expression<String>? userId,
    Expression<String>? zones,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (zones != null) 'zones': zones,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AsthmaActionPlanCompanion copyWith({
    Value<String>? userId,
    Value<String>? zones,
    Value<int>? rowid,
  }) {
    return AsthmaActionPlanCompanion(
      userId: userId ?? this.userId,
      zones: zones ?? this.zones,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (zones.present) {
      map['zones'] = Variable<String>(zones.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AsthmaActionPlanCompanion(')
          ..write('userId: $userId, ')
          ..write('zones: $zones, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $VitalsReadingsTable vitalsReadings = $VitalsReadingsTable(this);
  late final $EnvReadingsTable envReadings = $EnvReadingsTable(this);
  late final $AlertsTable alerts = $AlertsTable(this);
  late final $PersonalBaselineTable personalBaseline = $PersonalBaselineTable(
    this,
  );
  late final $MedicationsTable medications = $MedicationsTable(this);
  late final $AsthmaActionPlanTable asthmaActionPlan = $AsthmaActionPlanTable(
    this,
  );
  late final Index idxVitalsTs = Index(
    'idx_vitals_ts',
    'CREATE INDEX idx_vitals_ts ON vitals_readings (timestamp)',
  );
  late final Index idxEnvTs = Index(
    'idx_env_ts',
    'CREATE INDEX idx_env_ts ON env_readings (timestamp)',
  );
  late final Index idxAlertsTs = Index(
    'idx_alerts_ts',
    'CREATE INDEX idx_alerts_ts ON alerts (timestamp)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    vitalsReadings,
    envReadings,
    alerts,
    personalBaseline,
    medications,
    asthmaActionPlan,
    idxVitalsTs,
    idxEnvTs,
    idxAlertsTs,
  ];
}

typedef $$VitalsReadingsTableCreateCompanionBuilder =
    VitalsReadingsCompanion Function({
      Value<int> id,
      required DateTime timestamp,
      required int seq,
      Value<int?> heartRate,
      Value<int?> spo2,
      Value<int?> respRate,
      required int signalQuality,
      required ActivityState activity,
      required bool isMotionNoisy,
      required bool isNotWorn,
    });
typedef $$VitalsReadingsTableUpdateCompanionBuilder =
    VitalsReadingsCompanion Function({
      Value<int> id,
      Value<DateTime> timestamp,
      Value<int> seq,
      Value<int?> heartRate,
      Value<int?> spo2,
      Value<int?> respRate,
      Value<int> signalQuality,
      Value<ActivityState> activity,
      Value<bool> isMotionNoisy,
      Value<bool> isNotWorn,
    });

class $$VitalsReadingsTableFilterComposer
    extends Composer<_$AppDatabase, $VitalsReadingsTable> {
  $$VitalsReadingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get seq => $composableBuilder(
    column: $table.seq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get heartRate => $composableBuilder(
    column: $table.heartRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get spo2 => $composableBuilder(
    column: $table.spo2,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get respRate => $composableBuilder(
    column: $table.respRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get signalQuality => $composableBuilder(
    column: $table.signalQuality,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ActivityState, ActivityState, int>
  get activity => $composableBuilder(
    column: $table.activity,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<bool> get isMotionNoisy => $composableBuilder(
    column: $table.isMotionNoisy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isNotWorn => $composableBuilder(
    column: $table.isNotWorn,
    builder: (column) => ColumnFilters(column),
  );
}

class $$VitalsReadingsTableOrderingComposer
    extends Composer<_$AppDatabase, $VitalsReadingsTable> {
  $$VitalsReadingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get seq => $composableBuilder(
    column: $table.seq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get heartRate => $composableBuilder(
    column: $table.heartRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get spo2 => $composableBuilder(
    column: $table.spo2,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get respRate => $composableBuilder(
    column: $table.respRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get signalQuality => $composableBuilder(
    column: $table.signalQuality,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get activity => $composableBuilder(
    column: $table.activity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isMotionNoisy => $composableBuilder(
    column: $table.isMotionNoisy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isNotWorn => $composableBuilder(
    column: $table.isNotWorn,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VitalsReadingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $VitalsReadingsTable> {
  $$VitalsReadingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<int> get seq =>
      $composableBuilder(column: $table.seq, builder: (column) => column);

  GeneratedColumn<int> get heartRate =>
      $composableBuilder(column: $table.heartRate, builder: (column) => column);

  GeneratedColumn<int> get spo2 =>
      $composableBuilder(column: $table.spo2, builder: (column) => column);

  GeneratedColumn<int> get respRate =>
      $composableBuilder(column: $table.respRate, builder: (column) => column);

  GeneratedColumn<int> get signalQuality => $composableBuilder(
    column: $table.signalQuality,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<ActivityState, int> get activity =>
      $composableBuilder(column: $table.activity, builder: (column) => column);

  GeneratedColumn<bool> get isMotionNoisy => $composableBuilder(
    column: $table.isMotionNoisy,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isNotWorn =>
      $composableBuilder(column: $table.isNotWorn, builder: (column) => column);
}

class $$VitalsReadingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VitalsReadingsTable,
          VitalsRow,
          $$VitalsReadingsTableFilterComposer,
          $$VitalsReadingsTableOrderingComposer,
          $$VitalsReadingsTableAnnotationComposer,
          $$VitalsReadingsTableCreateCompanionBuilder,
          $$VitalsReadingsTableUpdateCompanionBuilder,
          (
            VitalsRow,
            BaseReferences<_$AppDatabase, $VitalsReadingsTable, VitalsRow>,
          ),
          VitalsRow,
          PrefetchHooks Function()
        > {
  $$VitalsReadingsTableTableManager(
    _$AppDatabase db,
    $VitalsReadingsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VitalsReadingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VitalsReadingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VitalsReadingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
                Value<int> seq = const Value.absent(),
                Value<int?> heartRate = const Value.absent(),
                Value<int?> spo2 = const Value.absent(),
                Value<int?> respRate = const Value.absent(),
                Value<int> signalQuality = const Value.absent(),
                Value<ActivityState> activity = const Value.absent(),
                Value<bool> isMotionNoisy = const Value.absent(),
                Value<bool> isNotWorn = const Value.absent(),
              }) => VitalsReadingsCompanion(
                id: id,
                timestamp: timestamp,
                seq: seq,
                heartRate: heartRate,
                spo2: spo2,
                respRate: respRate,
                signalQuality: signalQuality,
                activity: activity,
                isMotionNoisy: isMotionNoisy,
                isNotWorn: isNotWorn,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime timestamp,
                required int seq,
                Value<int?> heartRate = const Value.absent(),
                Value<int?> spo2 = const Value.absent(),
                Value<int?> respRate = const Value.absent(),
                required int signalQuality,
                required ActivityState activity,
                required bool isMotionNoisy,
                required bool isNotWorn,
              }) => VitalsReadingsCompanion.insert(
                id: id,
                timestamp: timestamp,
                seq: seq,
                heartRate: heartRate,
                spo2: spo2,
                respRate: respRate,
                signalQuality: signalQuality,
                activity: activity,
                isMotionNoisy: isMotionNoisy,
                isNotWorn: isNotWorn,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$VitalsReadingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VitalsReadingsTable,
      VitalsRow,
      $$VitalsReadingsTableFilterComposer,
      $$VitalsReadingsTableOrderingComposer,
      $$VitalsReadingsTableAnnotationComposer,
      $$VitalsReadingsTableCreateCompanionBuilder,
      $$VitalsReadingsTableUpdateCompanionBuilder,
      (
        VitalsRow,
        BaseReferences<_$AppDatabase, $VitalsReadingsTable, VitalsRow>,
      ),
      VitalsRow,
      PrefetchHooks Function()
    >;
typedef $$EnvReadingsTableCreateCompanionBuilder =
    EnvReadingsCompanion Function({
      Value<int> id,
      required DateTime timestamp,
      required int seq,
      required double pm25,
      required double pm10,
      required double tempC,
      required double humidity,
      required int vocIndex,
      Value<double?> no2,
      Value<double?> so2,
      Value<String> source,
    });
typedef $$EnvReadingsTableUpdateCompanionBuilder =
    EnvReadingsCompanion Function({
      Value<int> id,
      Value<DateTime> timestamp,
      Value<int> seq,
      Value<double> pm25,
      Value<double> pm10,
      Value<double> tempC,
      Value<double> humidity,
      Value<int> vocIndex,
      Value<double?> no2,
      Value<double?> so2,
      Value<String> source,
    });

class $$EnvReadingsTableFilterComposer
    extends Composer<_$AppDatabase, $EnvReadingsTable> {
  $$EnvReadingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get seq => $composableBuilder(
    column: $table.seq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get pm25 => $composableBuilder(
    column: $table.pm25,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get pm10 => $composableBuilder(
    column: $table.pm10,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get tempC => $composableBuilder(
    column: $table.tempC,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get humidity => $composableBuilder(
    column: $table.humidity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get vocIndex => $composableBuilder(
    column: $table.vocIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get no2 => $composableBuilder(
    column: $table.no2,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get so2 => $composableBuilder(
    column: $table.so2,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EnvReadingsTableOrderingComposer
    extends Composer<_$AppDatabase, $EnvReadingsTable> {
  $$EnvReadingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get seq => $composableBuilder(
    column: $table.seq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get pm25 => $composableBuilder(
    column: $table.pm25,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get pm10 => $composableBuilder(
    column: $table.pm10,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get tempC => $composableBuilder(
    column: $table.tempC,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get humidity => $composableBuilder(
    column: $table.humidity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get vocIndex => $composableBuilder(
    column: $table.vocIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get no2 => $composableBuilder(
    column: $table.no2,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get so2 => $composableBuilder(
    column: $table.so2,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EnvReadingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $EnvReadingsTable> {
  $$EnvReadingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<int> get seq =>
      $composableBuilder(column: $table.seq, builder: (column) => column);

  GeneratedColumn<double> get pm25 =>
      $composableBuilder(column: $table.pm25, builder: (column) => column);

  GeneratedColumn<double> get pm10 =>
      $composableBuilder(column: $table.pm10, builder: (column) => column);

  GeneratedColumn<double> get tempC =>
      $composableBuilder(column: $table.tempC, builder: (column) => column);

  GeneratedColumn<double> get humidity =>
      $composableBuilder(column: $table.humidity, builder: (column) => column);

  GeneratedColumn<int> get vocIndex =>
      $composableBuilder(column: $table.vocIndex, builder: (column) => column);

  GeneratedColumn<double> get no2 =>
      $composableBuilder(column: $table.no2, builder: (column) => column);

  GeneratedColumn<double> get so2 =>
      $composableBuilder(column: $table.so2, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);
}

class $$EnvReadingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EnvReadingsTable,
          EnvRow,
          $$EnvReadingsTableFilterComposer,
          $$EnvReadingsTableOrderingComposer,
          $$EnvReadingsTableAnnotationComposer,
          $$EnvReadingsTableCreateCompanionBuilder,
          $$EnvReadingsTableUpdateCompanionBuilder,
          (EnvRow, BaseReferences<_$AppDatabase, $EnvReadingsTable, EnvRow>),
          EnvRow,
          PrefetchHooks Function()
        > {
  $$EnvReadingsTableTableManager(_$AppDatabase db, $EnvReadingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EnvReadingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EnvReadingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EnvReadingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
                Value<int> seq = const Value.absent(),
                Value<double> pm25 = const Value.absent(),
                Value<double> pm10 = const Value.absent(),
                Value<double> tempC = const Value.absent(),
                Value<double> humidity = const Value.absent(),
                Value<int> vocIndex = const Value.absent(),
                Value<double?> no2 = const Value.absent(),
                Value<double?> so2 = const Value.absent(),
                Value<String> source = const Value.absent(),
              }) => EnvReadingsCompanion(
                id: id,
                timestamp: timestamp,
                seq: seq,
                pm25: pm25,
                pm10: pm10,
                tempC: tempC,
                humidity: humidity,
                vocIndex: vocIndex,
                no2: no2,
                so2: so2,
                source: source,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime timestamp,
                required int seq,
                required double pm25,
                required double pm10,
                required double tempC,
                required double humidity,
                required int vocIndex,
                Value<double?> no2 = const Value.absent(),
                Value<double?> so2 = const Value.absent(),
                Value<String> source = const Value.absent(),
              }) => EnvReadingsCompanion.insert(
                id: id,
                timestamp: timestamp,
                seq: seq,
                pm25: pm25,
                pm10: pm10,
                tempC: tempC,
                humidity: humidity,
                vocIndex: vocIndex,
                no2: no2,
                so2: so2,
                source: source,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EnvReadingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EnvReadingsTable,
      EnvRow,
      $$EnvReadingsTableFilterComposer,
      $$EnvReadingsTableOrderingComposer,
      $$EnvReadingsTableAnnotationComposer,
      $$EnvReadingsTableCreateCompanionBuilder,
      $$EnvReadingsTableUpdateCompanionBuilder,
      (EnvRow, BaseReferences<_$AppDatabase, $EnvReadingsTable, EnvRow>),
      EnvRow,
      PrefetchHooks Function()
    >;
typedef $$AlertsTableCreateCompanionBuilder =
    AlertsCompanion Function({
      Value<int> id,
      required DateTime timestamp,
      required AlertCategory category,
      required AlertSeverity severity,
      required String title,
      required String reason,
      Value<bool> acknowledged,
    });
typedef $$AlertsTableUpdateCompanionBuilder =
    AlertsCompanion Function({
      Value<int> id,
      Value<DateTime> timestamp,
      Value<AlertCategory> category,
      Value<AlertSeverity> severity,
      Value<String> title,
      Value<String> reason,
      Value<bool> acknowledged,
    });

class $$AlertsTableFilterComposer
    extends Composer<_$AppDatabase, $AlertsTable> {
  $$AlertsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<AlertCategory, AlertCategory, int>
  get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<AlertSeverity, AlertSeverity, int>
  get severity => $composableBuilder(
    column: $table.severity,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get acknowledged => $composableBuilder(
    column: $table.acknowledged,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AlertsTableOrderingComposer
    extends Composer<_$AppDatabase, $AlertsTable> {
  $$AlertsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get severity => $composableBuilder(
    column: $table.severity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get acknowledged => $composableBuilder(
    column: $table.acknowledged,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AlertsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AlertsTable> {
  $$AlertsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumnWithTypeConverter<AlertCategory, int> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumnWithTypeConverter<AlertSeverity, int> get severity =>
      $composableBuilder(column: $table.severity, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<bool> get acknowledged => $composableBuilder(
    column: $table.acknowledged,
    builder: (column) => column,
  );
}

class $$AlertsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AlertsTable,
          AlertRow,
          $$AlertsTableFilterComposer,
          $$AlertsTableOrderingComposer,
          $$AlertsTableAnnotationComposer,
          $$AlertsTableCreateCompanionBuilder,
          $$AlertsTableUpdateCompanionBuilder,
          (AlertRow, BaseReferences<_$AppDatabase, $AlertsTable, AlertRow>),
          AlertRow,
          PrefetchHooks Function()
        > {
  $$AlertsTableTableManager(_$AppDatabase db, $AlertsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AlertsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AlertsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AlertsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
                Value<AlertCategory> category = const Value.absent(),
                Value<AlertSeverity> severity = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> reason = const Value.absent(),
                Value<bool> acknowledged = const Value.absent(),
              }) => AlertsCompanion(
                id: id,
                timestamp: timestamp,
                category: category,
                severity: severity,
                title: title,
                reason: reason,
                acknowledged: acknowledged,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime timestamp,
                required AlertCategory category,
                required AlertSeverity severity,
                required String title,
                required String reason,
                Value<bool> acknowledged = const Value.absent(),
              }) => AlertsCompanion.insert(
                id: id,
                timestamp: timestamp,
                category: category,
                severity: severity,
                title: title,
                reason: reason,
                acknowledged: acknowledged,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AlertsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AlertsTable,
      AlertRow,
      $$AlertsTableFilterComposer,
      $$AlertsTableOrderingComposer,
      $$AlertsTableAnnotationComposer,
      $$AlertsTableCreateCompanionBuilder,
      $$AlertsTableUpdateCompanionBuilder,
      (AlertRow, BaseReferences<_$AppDatabase, $AlertsTable, AlertRow>),
      AlertRow,
      PrefetchHooks Function()
    >;
typedef $$PersonalBaselineTableCreateCompanionBuilder =
    PersonalBaselineCompanion Function({
      required String userId,
      required double restingHr,
      required double restingRespRate,
      required double restingSpo2,
      required DateTime computedAt,
      required int sampleCount,
      Value<int> rowid,
    });
typedef $$PersonalBaselineTableUpdateCompanionBuilder =
    PersonalBaselineCompanion Function({
      Value<String> userId,
      Value<double> restingHr,
      Value<double> restingRespRate,
      Value<double> restingSpo2,
      Value<DateTime> computedAt,
      Value<int> sampleCount,
      Value<int> rowid,
    });

class $$PersonalBaselineTableFilterComposer
    extends Composer<_$AppDatabase, $PersonalBaselineTable> {
  $$PersonalBaselineTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get restingHr => $composableBuilder(
    column: $table.restingHr,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get restingRespRate => $composableBuilder(
    column: $table.restingRespRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get restingSpo2 => $composableBuilder(
    column: $table.restingSpo2,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get computedAt => $composableBuilder(
    column: $table.computedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sampleCount => $composableBuilder(
    column: $table.sampleCount,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PersonalBaselineTableOrderingComposer
    extends Composer<_$AppDatabase, $PersonalBaselineTable> {
  $$PersonalBaselineTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get restingHr => $composableBuilder(
    column: $table.restingHr,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get restingRespRate => $composableBuilder(
    column: $table.restingRespRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get restingSpo2 => $composableBuilder(
    column: $table.restingSpo2,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get computedAt => $composableBuilder(
    column: $table.computedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sampleCount => $composableBuilder(
    column: $table.sampleCount,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PersonalBaselineTableAnnotationComposer
    extends Composer<_$AppDatabase, $PersonalBaselineTable> {
  $$PersonalBaselineTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<double> get restingHr =>
      $composableBuilder(column: $table.restingHr, builder: (column) => column);

  GeneratedColumn<double> get restingRespRate => $composableBuilder(
    column: $table.restingRespRate,
    builder: (column) => column,
  );

  GeneratedColumn<double> get restingSpo2 => $composableBuilder(
    column: $table.restingSpo2,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get computedAt => $composableBuilder(
    column: $table.computedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sampleCount => $composableBuilder(
    column: $table.sampleCount,
    builder: (column) => column,
  );
}

class $$PersonalBaselineTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PersonalBaselineTable,
          BaselineRow,
          $$PersonalBaselineTableFilterComposer,
          $$PersonalBaselineTableOrderingComposer,
          $$PersonalBaselineTableAnnotationComposer,
          $$PersonalBaselineTableCreateCompanionBuilder,
          $$PersonalBaselineTableUpdateCompanionBuilder,
          (
            BaselineRow,
            BaseReferences<_$AppDatabase, $PersonalBaselineTable, BaselineRow>,
          ),
          BaselineRow,
          PrefetchHooks Function()
        > {
  $$PersonalBaselineTableTableManager(
    _$AppDatabase db,
    $PersonalBaselineTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PersonalBaselineTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PersonalBaselineTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PersonalBaselineTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> userId = const Value.absent(),
                Value<double> restingHr = const Value.absent(),
                Value<double> restingRespRate = const Value.absent(),
                Value<double> restingSpo2 = const Value.absent(),
                Value<DateTime> computedAt = const Value.absent(),
                Value<int> sampleCount = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PersonalBaselineCompanion(
                userId: userId,
                restingHr: restingHr,
                restingRespRate: restingRespRate,
                restingSpo2: restingSpo2,
                computedAt: computedAt,
                sampleCount: sampleCount,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String userId,
                required double restingHr,
                required double restingRespRate,
                required double restingSpo2,
                required DateTime computedAt,
                required int sampleCount,
                Value<int> rowid = const Value.absent(),
              }) => PersonalBaselineCompanion.insert(
                userId: userId,
                restingHr: restingHr,
                restingRespRate: restingRespRate,
                restingSpo2: restingSpo2,
                computedAt: computedAt,
                sampleCount: sampleCount,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PersonalBaselineTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PersonalBaselineTable,
      BaselineRow,
      $$PersonalBaselineTableFilterComposer,
      $$PersonalBaselineTableOrderingComposer,
      $$PersonalBaselineTableAnnotationComposer,
      $$PersonalBaselineTableCreateCompanionBuilder,
      $$PersonalBaselineTableUpdateCompanionBuilder,
      (
        BaselineRow,
        BaseReferences<_$AppDatabase, $PersonalBaselineTable, BaselineRow>,
      ),
      BaselineRow,
      PrefetchHooks Function()
    >;
typedef $$MedicationsTableCreateCompanionBuilder =
    MedicationsCompanion Function({
      Value<int> id,
      required String name,
      required String dosage,
      required String scheduleTimes,
    });
typedef $$MedicationsTableUpdateCompanionBuilder =
    MedicationsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> dosage,
      Value<String> scheduleTimes,
    });

class $$MedicationsTableFilterComposer
    extends Composer<_$AppDatabase, $MedicationsTable> {
  $$MedicationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dosage => $composableBuilder(
    column: $table.dosage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scheduleTimes => $composableBuilder(
    column: $table.scheduleTimes,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MedicationsTableOrderingComposer
    extends Composer<_$AppDatabase, $MedicationsTable> {
  $$MedicationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dosage => $composableBuilder(
    column: $table.dosage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scheduleTimes => $composableBuilder(
    column: $table.scheduleTimes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MedicationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MedicationsTable> {
  $$MedicationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get dosage =>
      $composableBuilder(column: $table.dosage, builder: (column) => column);

  GeneratedColumn<String> get scheduleTimes => $composableBuilder(
    column: $table.scheduleTimes,
    builder: (column) => column,
  );
}

class $$MedicationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MedicationsTable,
          MedicationRow,
          $$MedicationsTableFilterComposer,
          $$MedicationsTableOrderingComposer,
          $$MedicationsTableAnnotationComposer,
          $$MedicationsTableCreateCompanionBuilder,
          $$MedicationsTableUpdateCompanionBuilder,
          (
            MedicationRow,
            BaseReferences<_$AppDatabase, $MedicationsTable, MedicationRow>,
          ),
          MedicationRow,
          PrefetchHooks Function()
        > {
  $$MedicationsTableTableManager(_$AppDatabase db, $MedicationsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MedicationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MedicationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MedicationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> dosage = const Value.absent(),
                Value<String> scheduleTimes = const Value.absent(),
              }) => MedicationsCompanion(
                id: id,
                name: name,
                dosage: dosage,
                scheduleTimes: scheduleTimes,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String dosage,
                required String scheduleTimes,
              }) => MedicationsCompanion.insert(
                id: id,
                name: name,
                dosage: dosage,
                scheduleTimes: scheduleTimes,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MedicationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MedicationsTable,
      MedicationRow,
      $$MedicationsTableFilterComposer,
      $$MedicationsTableOrderingComposer,
      $$MedicationsTableAnnotationComposer,
      $$MedicationsTableCreateCompanionBuilder,
      $$MedicationsTableUpdateCompanionBuilder,
      (
        MedicationRow,
        BaseReferences<_$AppDatabase, $MedicationsTable, MedicationRow>,
      ),
      MedicationRow,
      PrefetchHooks Function()
    >;
typedef $$AsthmaActionPlanTableCreateCompanionBuilder =
    AsthmaActionPlanCompanion Function({
      required String userId,
      required String zones,
      Value<int> rowid,
    });
typedef $$AsthmaActionPlanTableUpdateCompanionBuilder =
    AsthmaActionPlanCompanion Function({
      Value<String> userId,
      Value<String> zones,
      Value<int> rowid,
    });

class $$AsthmaActionPlanTableFilterComposer
    extends Composer<_$AppDatabase, $AsthmaActionPlanTable> {
  $$AsthmaActionPlanTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get zones => $composableBuilder(
    column: $table.zones,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AsthmaActionPlanTableOrderingComposer
    extends Composer<_$AppDatabase, $AsthmaActionPlanTable> {
  $$AsthmaActionPlanTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get zones => $composableBuilder(
    column: $table.zones,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AsthmaActionPlanTableAnnotationComposer
    extends Composer<_$AppDatabase, $AsthmaActionPlanTable> {
  $$AsthmaActionPlanTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get zones =>
      $composableBuilder(column: $table.zones, builder: (column) => column);
}

class $$AsthmaActionPlanTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AsthmaActionPlanTable,
          ActionPlanRow,
          $$AsthmaActionPlanTableFilterComposer,
          $$AsthmaActionPlanTableOrderingComposer,
          $$AsthmaActionPlanTableAnnotationComposer,
          $$AsthmaActionPlanTableCreateCompanionBuilder,
          $$AsthmaActionPlanTableUpdateCompanionBuilder,
          (
            ActionPlanRow,
            BaseReferences<
              _$AppDatabase,
              $AsthmaActionPlanTable,
              ActionPlanRow
            >,
          ),
          ActionPlanRow,
          PrefetchHooks Function()
        > {
  $$AsthmaActionPlanTableTableManager(
    _$AppDatabase db,
    $AsthmaActionPlanTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AsthmaActionPlanTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AsthmaActionPlanTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AsthmaActionPlanTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> userId = const Value.absent(),
                Value<String> zones = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AsthmaActionPlanCompanion(
                userId: userId,
                zones: zones,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String userId,
                required String zones,
                Value<int> rowid = const Value.absent(),
              }) => AsthmaActionPlanCompanion.insert(
                userId: userId,
                zones: zones,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AsthmaActionPlanTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AsthmaActionPlanTable,
      ActionPlanRow,
      $$AsthmaActionPlanTableFilterComposer,
      $$AsthmaActionPlanTableOrderingComposer,
      $$AsthmaActionPlanTableAnnotationComposer,
      $$AsthmaActionPlanTableCreateCompanionBuilder,
      $$AsthmaActionPlanTableUpdateCompanionBuilder,
      (
        ActionPlanRow,
        BaseReferences<_$AppDatabase, $AsthmaActionPlanTable, ActionPlanRow>,
      ),
      ActionPlanRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$VitalsReadingsTableTableManager get vitalsReadings =>
      $$VitalsReadingsTableTableManager(_db, _db.vitalsReadings);
  $$EnvReadingsTableTableManager get envReadings =>
      $$EnvReadingsTableTableManager(_db, _db.envReadings);
  $$AlertsTableTableManager get alerts =>
      $$AlertsTableTableManager(_db, _db.alerts);
  $$PersonalBaselineTableTableManager get personalBaseline =>
      $$PersonalBaselineTableTableManager(_db, _db.personalBaseline);
  $$MedicationsTableTableManager get medications =>
      $$MedicationsTableTableManager(_db, _db.medications);
  $$AsthmaActionPlanTableTableManager get asthmaActionPlan =>
      $$AsthmaActionPlanTableTableManager(_db, _db.asthmaActionPlan);
}
