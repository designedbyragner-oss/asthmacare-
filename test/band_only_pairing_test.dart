/// اختبارات سياسة الاقتران — السوار أساسي: يُقبل وحده أو مع جهاز البيئة،
/// والبيئة وحدها لا تُقبل. التطابق على الاسم الإعلاني حرفي تام (§2 من المرجع).
library;

import 'package:flutter_test/flutter_test.dart';

import 'package:asthma_care/data/ble/ble_constants.dart';
import 'package:asthma_care/data/ble/real_ble_source.dart';

void main() {
  group('decidePairing — سياسة اقتران الأجهزة', () {
    test('السوار وحده → يوصل السوار فقط (الحالة الجديدة المطلوبة)', () {
      final d = decidePairing({BleUuids.bandDeviceName});
      expect(d.attachBand, isTrue,
          reason: 'السوار جهاز أساسي ويجب أن يقبل الاقتران منفردًا');
      expect(d.attachEnv, isFalse,
          reason: 'لا بيئة في النطاق فلا توصل');
    });

    test('الجهازان معًا → يوصل كلاهما (السلوك الكامل محفوظ)', () {
      final d = decidePairing({
        BleUuids.bandDeviceName,
        BleUuids.envDeviceName,
        'جهاز غريب في النطاق',
      });
      expect(d.attachBand, isTrue);
      expect(d.attachEnv, isTrue);
    });

    test('البيئة وحدها → لا اتصال إطلاقًا (المؤشرات الحيوية هي الأساس)', () {
      final d = decidePairing({BleUuids.envDeviceName});
      expect(d.attachBand, isFalse);
      expect(d.attachEnv, isFalse,
          reason: 'بيئة بلا سوار لا تُقبل — قرار المنتج');
    });

    test('لا أجهزة معروفة → لا اتصال', () {
      final d = decidePairing({'Galaxy Watch 7', 'MI Band 9'});
      expect(d.attachBand, isFalse);
      expect(d.attachEnv, isFalse);
    });

    test('المقارنة حرفية تامة: اختلاف حالة حرف يُفشل التعرف', () {
      final d = decidePairing({'ac-band-01', 'AC-ENV-01 '});
      expect(d.attachBand, isFalse,
          reason: 'التطابق النصي التام موثق في المرجع §2');
      expect(d.attachEnv, isFalse);
    });
  });
}
