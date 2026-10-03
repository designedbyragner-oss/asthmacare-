/// واجهة مصدر الأجهزة — تجريد BLE عن المحاكاة (§12).
/// يفصل طبقة العرض والمنطق تمامًا عن تفاصيل الاتصال.
library;

import 'dart:async';

import 'package:asthma_care/data/models/models.dart';

/// وضع الاتصال المدمج للجهازين.
class DeviceLinkState {
  final LinkState env;
  final LinkState band;

  const DeviceLinkState({required this.env, required this.band});

  bool get anyConnected => env == LinkState.connected || band == LinkState.connected;

  bool get allConnected =>
      env == LinkState.connected && band == LinkState.connected;
}

abstract class DeviceSource {
  /// تيار القراءات الحيوية من السوار.
  Stream<VitalsReading> get vitalsStream;

  /// تيار القراءات البيئية من جهاز البيئة.
  Stream<EnvReading> get envStream;

  /// حالة الارتباط الحالية (قيمة أولية ثم تحديثات).
  Stream<DeviceLinkState> get linkStateStream;

  DeviceLinkState get currentLinkState;

  /// بدء الارتباط (بعد الأذونات). آمن للاستدعاء المتكرر.
  Future<void> connect();

  Future<void> disconnect();

  /// تحرير الموارد — لا استخدام بعده.
  void dispose();
}
