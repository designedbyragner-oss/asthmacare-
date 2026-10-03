/// ترميز وفك حزم BLE مع تحقق CRC8 — مطابق للوثيقة الموحدة §7.4.
/// أي حزمة فاشلة CRC أو بطول خاطئ تُرفض عبر PacketException (§7.5).
library;

import 'dart:convert';
import 'dart:typed_data';

import 'package:asthma_care/data/models/models.dart';

class PacketException implements Exception {
  final String message;
  PacketException(this.message);

  @override
  String toString() => 'PacketException: $message';
}

/// CRC-8 (polynomial 0x07) — متفق عليه مع الفِرموير.
int crc8(List<int> bytes) {
  var crc = 0x00;
  for (final b in bytes) {
    crc ^= b;
    for (var i = 0; i < 8; i++) {
      crc = (crc & 0x80) != 0 ? ((crc << 1) ^ 0x07) & 0xFF : (crc << 1) & 0xFF;
    }
  }
  return crc;
}

/// بناء حزمة جهاز البيئة (16 بايت) — يُستخدم للاختبار والمحاكاة فقط.
Uint8List encodeEnv({
  required int seq,
  required double pm25,
  required double pm10,
  required double tempC,
  required double humidity,
  required int vocIndex,
  required int battery,
  bool sensorFault = false,
  bool lowBattery = false,
}) {
  final b = Uint8List(16);
  final d = ByteData.sublistView(b);
  b[0] = 1; // version
  b[1] = (sensorFault ? 0x01 : 0) | (lowBattery ? 0x02 : 0);
  d.setUint16(2, seq & 0xFFFF, Endian.little);
  d.setUint16(4, (pm25 * 10).round().clamp(0, 0xFFFF), Endian.little);
  d.setUint16(6, (pm10 * 10).round().clamp(0, 0xFFFF), Endian.little);
  d.setInt16(8, (tempC * 100).round().clamp(-32768, 32767), Endian.little);
  d.setUint16(10, (humidity * 100).round().clamp(0, 0xFFFF), Endian.little);
  d.setUint16(12, vocIndex.clamp(0, 0xFFFF), Endian.little);
  b[14] = battery.clamp(0, 100);
  b[15] = crc8(b.sublist(0, 15));
  return b;
}

/// بناء حزمة السوار (14 بايت) — للاختبار والمحاكاة.
Uint8List encodeVitals({
  required int seq,
  required int? heartRate,
  required int? spo2,
  required int? respRate,
  required int signalQuality,
  required ActivityState activity,
  required int battery,
  bool notWorn = false,
  bool motionNoisy = false,
  bool localAlertActive = false,
}) {
  final b = Uint8List(14);
  final d = ByteData.sublistView(b);
  b[0] = 1; // version
  b[1] = (notWorn ? 0x01 : 0) |
      (motionNoisy ? 0x02 : 0) |
      (localAlertActive ? 0x04 : 0);
  d.setUint16(2, seq & 0xFFFF, Endian.little);
  b[4] = (heartRate ?? 0).clamp(0, 255);
  b[5] = (spo2 ?? 0).clamp(0, 255);
  b[6] = (respRate ?? 0).clamp(0, 255);
  b[7] = signalQuality.clamp(0, 100);
  // 8–9 محجوزة (D3/D7) — تُكتب أصفارًا
  b[8] = 0;
  b[9] = 0;
  b[10] = activity.index;
  b[11] = battery.clamp(0, 100);
  b[12] = 0; // محجوز
  b[13] = crc8(b.sublist(0, 13));
  return b;
}

/// فك حزمة جهاز البيئة — 16 بايت مع تحقق CRC.
EnvReading decodeEnv(Uint8List b) {
  if (b.length != 16) {
    throw PacketException('طول غير صحيح: ${b.length} بدل 16');
  }
  final computed = crc8(b.sublist(0, 15));
  if (computed != b[15]) throw PacketException('CRC غير مطابق');

  final d = ByteData.sublistView(b);
  return EnvReading(
    seq: d.getUint16(2, Endian.little),
    sensorFault: (b[1] & 0x01) != 0,
    lowBattery: (b[1] & 0x02) != 0,
    pm25: d.getUint16(4, Endian.little) / 10,
    pm10: d.getUint16(6, Endian.little) / 10,
    tempC: d.getInt16(8, Endian.little) / 100,
    humidity: d.getUint16(10, Endian.little) / 100,
    vocIndex: d.getUint16(12, Endian.little),
    battery: b[14],
    receivedAt: DateTime.now(), // سياسة D3: ختم استقبال
  );
}

/// فك حزمة السوار — 14 بايت مع تحقق CRC.
VitalsReading decodeVitals(Uint8List b) {
  if (b.length != 14) {
    throw PacketException('طول غير صحيح: ${b.length} بدل 14');
  }
  final computed = crc8(b.sublist(0, 13));
  if (computed != b[13]) throw PacketException('CRC غير مطابق');

  final d = ByteData.sublistView(b);
  final activityIndex = b[10];
  final activity = (activityIndex >= 0 && activityIndex < ActivityState.values.length)
      ? ActivityState.values[activityIndex]
      : ActivityState.resting;

  return VitalsReading(
    seq: d.getUint16(2, Endian.little),
    notWorn: (b[1] & 0x01) != 0,
    motionNoisy: (b[1] & 0x02) != 0,
    localAlertActive: (b[1] & 0x04) != 0,
    heartRate: b[4] == 0 ? null : b[4],
    spo2: b[5] == 0 ? null : b[5],
    respRate: b[6] == 0 ? null : b[6],
    signalQuality: b[7],
    activity: activity,
    battery: b[11],
    receivedAt: DateTime.now(), // سياسة D3: ختم استقبال
  );
}

/// فك حزمة خام بأمان — يرجع null بدل الرمي عند التلف (للاستقبال الصامت §7.5).
EnvReading? tryDecodeEnv(List<int> raw) {
  try {
    return decodeEnv(Uint8List.fromList(raw));
  } on PacketException {
    return null;
  }
}

/// فك حزمة حيوية بأمان — يرجع null بدل الرمي عند التلف.
VitalsReading? tryDecodeVitals(List<int> raw) {
  try {
    return decodeVitals(Uint8List.fromList(raw));
  } on PacketException {
    return null;
  }
}

/// تحويل عام للحزم (يُستخدم في DeviceSource).
final packetCodecJsonEncoder = const JsonEncoder.withIndent('  ');
