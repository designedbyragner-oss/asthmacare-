/// اختبارات ترميز الحزم — G1: صحيح/تالف CRC/مكرر/طول خطأ/قيم غير صالحة (§7).
library;

import 'dart:typed_data';

import 'package:asthma_care/data/ble/packet_codec.dart';
import 'package:asthma_care/data/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('crc8', () {
    test('قيمة معروفة للتحقق من كثير الحدود 0x07', () {
      // "123456789" مع CRC-8/ATM يعطي 0xF4 — مرجع قياسي
      final bytes = '123456789'.codeUnits;
      expect(crc8(bytes), 0xF4);
    });
  });

  group('decodeEnv', () {
    test('حزمة صحيحة تُفك بقيم مطابقة', () {
      final raw = encodeEnv(
        seq: 42,
        pm25: 23.4,
        pm10: 41.2,
        tempC: 32.15,
        humidity: 42.5,
        vocIndex: 132,
        battery: 77,
      );
      final r = decodeEnv(raw);
      expect(r.seq, 42);
      expect(r.pm25, closeTo(23.4, 0.11));
      expect(r.pm10, closeTo(41.2, 0.11));
      expect(r.tempC, closeTo(32.15, 0.02));
      expect(r.humidity, closeTo(42.5, 0.02));
      expect(r.vocIndex, 132);
      expect(r.battery, 77);
      expect(r.sensorFault, isFalse);
      expect(r.isUsable, isTrue);
    });

    test('طول خاطئ يرفض', () {
      final raw = Uint8List(10);
      expect(() => decodeEnv(raw), throwsA(isA<PacketException>()));
    });

    test('بايت تالف (CRC مكسور) يرفض', () {
      final raw = encodeEnv(
        seq: 1,
        pm25: 10,
        pm10: 10,
        tempC: 30,
        humidity: 40,
        vocIndex: 100,
        battery: 50,
      );
      raw[4] = raw[4] ^ 0xFF; // إفساد pm25
      expect(() => decodeEnv(raw), throwsA(isA<PacketException>()));
    });

    test('tryDecodeEnv يرجع null بدل الرمي عند التلف (§7.5)', () {
      final raw = encodeEnv(
        seq: 2,
        pm25: 10,
        pm10: 10,
        tempC: 30,
        humidity: 40,
        vocIndex: 100,
        battery: 50,
      );
      raw[7] = raw[7] ^ 0xFF; // إفساد بايت
      expect(tryDecodeEnv(raw), isNull);
    });
  });

  group('decodeVitals', () {
    test('حزمة صحيحة تُفك بقيم مطابقة', () {
      final raw = encodeVitals(
        seq: 7,
        heartRate: 78,
        spo2: 98,
        respRate: 16,
        signalQuality: 92,
        activity: ActivityState.resting,
        battery: 80,
      );
      final r = decodeVitals(raw);
      expect(r.seq, 7);
      expect(r.heartRate, 78);
      expect(r.spo2, 98);
      expect(r.respRate, 16);
      expect(r.signalQuality, 92);
      expect(r.activity, ActivityState.resting);
      expect(r.battery, 80);
      expect(r.notWorn, isFalse);
      expect(r.isUsable, isTrue);
      expect(r.isBaselineEligible, isTrue);
    });

    test('صفر يعني قيمة غير صالحة → null (0 = invalid)', () {
      final raw = encodeVitals(
        seq: 8,
        heartRate: 0,
        spo2: 0,
        respRate: 0,
        signalQuality: 10,
        activity: ActivityState.resting,
        battery: 50,
      );
      final r = decodeVitals(raw);
      expect(r.heartRate, isNull);
      expect(r.spo2, isNull);
      expect(r.respRate, isNull);
      expect(r.isUsable, isFalse); // جودة 10 + قيم فارغة
    });

    test('غير ملبس مرفوض من الاستخدام وخط الأساس', () {
      final raw = encodeVitals(
        seq: 9,
        heartRate: 70,
        spo2: 97,
        respRate: 15,
        signalQuality: 95,
        activity: ActivityState.resting,
        battery: 60,
        notWorn: true,
      );
      final r = decodeVitals(raw);
      expect(r.notWorn, isTrue);
      expect(r.isUsable, isFalse);
      expect(r.isBaselineEligible, isFalse);
    });

    test('مشي مؤهل للاستخدام لكنه غير مؤهل لخط الأساس', () {
      final raw = encodeVitals(
        seq: 10,
        heartRate: 95,
        spo2: 97,
        respRate: 19,
        signalQuality: 85,
        activity: ActivityState.walking,
        battery: 60,
      );
      final r = decodeVitals(raw);
      expect(r.isUsable, isTrue);
      expect(r.isBaselineEligible, isFalse); // ليس راحة
    });

    test('طول خاطئ يرفض', () {
      expect(() => decodeVitals(Uint8List(12)), throwsA(isA<PacketException>()));
    });
  });
}
