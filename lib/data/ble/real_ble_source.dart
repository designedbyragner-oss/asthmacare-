/// مصدر BLE حقيقي عبر flutter_blue_plus — السوار جهاز أساسي: يُقبل اقترانه
/// وحده أو مع جهاز البيئة، والبيئة وحدها لا تُقبل (§7.1).
/// مسارات الدفاع: مهلة مسح، إعادة اتصال يدوية من المستخدم، تجاهل الحزم التالفة صامتًا (§7.5).
library;

import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'package:asthma_care/data/ble/ble_constants.dart';
import 'package:asthma_care/data/ble/device_source.dart';
import 'package:asthma_care/data/ble/packet_codec.dart';
import 'package:asthma_care/data/models/models.dart';

/// قرار الاقتران من أسماء الأجهزة المُعلنة في نتائج المسح:
/// السوار وحده يكفي (هو مصدر المؤشرات الحيوية الأساسية)، والبيئة تُوصل
/// استكمالًا له فقط — بلا سوار لا يُفتح أي اتصال. دالة نقية قابلة للاختبار.
({bool attachBand, bool attachEnv}) decidePairing(Set<String> advNames) => (
      attachBand: advNames.contains(BleUuids.bandDeviceName),
      attachEnv: advNames.contains(BleUuids.bandDeviceName) &&
          advNames.contains(BleUuids.envDeviceName),
    );

class RealBleSource implements DeviceSource {
  final StreamController<VitalsReading> _vitalsCtrl =
      StreamController<VitalsReading>.broadcast();
  final StreamController<EnvReading> _envCtrl =
      StreamController<EnvReading>.broadcast();
  final StreamController<DeviceLinkState> _linkCtrl =
      StreamController<DeviceLinkState>.broadcast();

  DeviceLinkState _link = const DeviceLinkState(
      env: LinkState.disconnected, band: LinkState.disconnected);

  BluetoothDevice? _envDevice;
  BluetoothDevice? _bandDevice;
  StreamSubscription<List<ScanResult>>? _scanSub;
  final List<StreamSubscription<FlutterBluePlusException>> _errorSubs = [];
  bool _disposed = false;

  @override
  Stream<VitalsReading> get vitalsStream => _vitalsCtrl.stream;

  @override
  Stream<EnvReading> get envStream => _envCtrl.stream;

  @override
  Stream<DeviceLinkState> get linkStateStream => _linkCtrl.stream;

  @override
  DeviceLinkState get currentLinkState => _link;

  void _setLink({LinkState? env, LinkState? band}) {
    _link = DeviceLinkState(
      env: env ?? _link.env,
      band: band ?? _link.band,
    );
    if (!_linkCtrl.isClosed) _linkCtrl.add(_link);
  }

  @override
  Future<void> connect() async {
    if (_disposed) return;
    try {
      _setLink(env: LinkState.scanning, band: LinkState.scanning);

      await FlutterBluePlus.stopScan();
      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 12),
        withServices: [], // مسح عام — الأسماء الإعلانية فقط (D4)
      );

      // نافذة انتظار كريمة: الجهازان يُربطان فور اكتمالهما في اللقطة،
      // وإلا تُربط قائمة آخر لقطة بعد 3 ثوانٍ (السوار وحده مقبول).
      final found = <ScanResult>[];
      final bothSeen = Completer<void>();
      final scanSub = FlutterBluePlus.scanResults.listen((list) {
        found
          ..clear()
          ..addAll(list);
        if (list.any(_isEnvDevice) &&
            list.any(_isBandDevice) &&
            !bothSeen.isCompleted) {
          bothSeen.complete();
        }
      });
      try {
        await bothSeen.future.timeout(const Duration(seconds: 3),
            onTimeout: () {});
      } finally {
        await scanSub.cancel();
      }

      await FlutterBluePlus.stopScan();

      // سياسة الاقتران سلطة واحدة: decidePairing (سوار وحده أو الجهازان).
      final decision = decidePairing(
          found.map((r) => r.advertisementData.advName).toSet());
      final band = decision.attachBand
          ? found.where(_isBandDevice).map((r) => r.device).firstOrNull
          : null;
      final env = decision.attachEnv
          ? found.where(_isEnvDevice).map((r) => r.device).firstOrNull
          : null;

      if (band == null) {
        _setLink(env: LinkState.disconnected, band: LinkState.disconnected);
        return;
      }

      _bandDevice = band;

      _setLink(band: LinkState.connecting);
      await _attach(band, BleUuids.bandService, BleUuids.vitalsChar,
          (raw) => _onVitalsPacket(raw));
      _setLink(band: LinkState.connected);

      if (env == null) {
        _setLink(env: LinkState.disconnected);
        return;
      }

      _envDevice = env;

      _setLink(env: LinkState.connecting);
      await _attach(env, BleUuids.envService, BleUuids.envReadingChar,
          (raw) => _onEnvPacket(raw));
      _setLink(env: LinkState.connected);
    } on FlutterBluePlusException {
      _setLink(env: LinkState.disconnected, band: LinkState.disconnected);
    }
  }

  bool _isEnvDevice(ScanResult r) =>
      (r.advertisementData.advName == BleUuids.envDeviceName);

  bool _isBandDevice(ScanResult r) =>
      (r.advertisementData.advName == BleUuids.bandDeviceName);

  Future<void> _attach(
    BluetoothDevice device,
    String serviceUuid,
    String charUuid,
    void Function(List<int>) onValue,
  ) async {
    await device.connect(timeout: const Duration(seconds: 10));
    final services = await device.discoverServices();
    for (final s in services) {
      if (s.uuid.str128.toLowerCase() != serviceUuid) continue;
      for (final c in s.characteristics) {
        if (c.uuid.str128.toLowerCase() != charUuid) continue;
        await c.setNotifyValue(true);
        c.onValueReceived.listen(onValue);
      }
    }
  }

  void _onVitalsPacket(List<int> raw) {
    if (_disposed) return;
    final reading = tryDecodeVitals(Uint8List.fromList(raw));
    if (reading != null && !_vitalsCtrl.isClosed) _vitalsCtrl.add(reading);
    // الحزم التالفة تُرفض بصمت — عدادات الفقدان في واجهة التشخيص (§7.5)
  }

  void _onEnvPacket(List<int> raw) {
    if (_disposed) return;
    final reading = tryDecodeEnv(Uint8List.fromList(raw));
    if (reading != null && !_envCtrl.isClosed) _envCtrl.add(reading);
  }

  @override
  Future<void> disconnect() async {
    try {
      await _bandDevice?.disconnect();
      await _envDevice?.disconnect();
    } on FlutterBluePlusException {
      // تجاهل — نحن نفصل أصلاً
    }
    _setLink(env: LinkState.disconnected, band: LinkState.disconnected);
  }

  @override
  void dispose() {
    _disposed = true;
    _scanSub?.cancel();
    for (final s in _errorSubs) {
      s.cancel();
    }
    _vitalsCtrl.close();
    _envCtrl.close();
    _linkCtrl.close();
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
