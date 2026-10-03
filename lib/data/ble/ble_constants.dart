/// معرّفات GATT الثابتة — جزء من العقد مع شركة الأجهزة (§7.1).
/// لا تُعدَّل دون تحديث وثيقة التعاقد.
class BleUuids {
  BleUuids._();

  // خدمة جهاز البيئة
  static const String envService = '6a4e0001-0000-1000-8000-00805f9b34fb';
  static const String envReadingChar = '6a4e0002-0000-1000-8000-00805f9b34fb'; // Notify
  static const String envCommandChar = '6a4e0003-0000-1000-8000-00805f9b34fb'; // Write

  // خدمة السوار
  static const String bandService = '6a4e1001-0000-1000-8000-00805f9b34fb';
  static const String vitalsChar = '6a4e1002-0000-1000-8000-00805f9b34fb'; // Notify
  static const String bandEventChar = '6a4e1003-0000-1000-8000-00805f9b34fb'; // Indicate
  static const String bandCommandChar = '6a4e1004-0000-1000-8000-00805f9b34fb'; // Write

  // خاصية البيانات الخام PPG للتصحيح والتحقق (O1)
  static const String ppgRawChar = '6a4e1005-0000-1000-8000-00805f9b34fb'; // Notify

  // أسماء إعلانية محايدة — لا اسم مريض (D4)
  static const String envDeviceName = 'AC-ENV-01';
  static const String bandDeviceName = 'AC-BAND-01';

  // خدمة البطارية القياسية
  static const String batteryService = '0000180f-0000-1000-8000-00805f9b34fb';
}
