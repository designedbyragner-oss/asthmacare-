/// محرك المحاكاة — يولّد بيانات فسيولوجية وبيئية واقعية بستة سيناريوهات (§12).
/// يستخدم فقط في وضع المحاكاة الموسوم بوضوح في الواجهة (D10).
library;

import 'dart:async';
import 'dart:math';

import 'package:asthma_care/data/ble/device_source.dart';
import 'package:asthma_care/data/models/models.dart';

/// سيناريوهات المحاكاة المعتمدة.
enum SimScenario {
  stable('مستقرة'),
  gradualAttack('نمط تدريجي يستحق الانتباه'),
  motionNoise('ضجيج حركة'),
  connectionDrop('انقطاع وإعادة اتصال'),
  lowBattery('بطارية ضعيفة'),
  badAir('تلوث بيئي مرتفع');

  final String arLabel;
  const SimScenario(this.arLabel);
}

/// توليد ضجيج شبه طبيعي حول قيمة هدف.
double _jitter(Random rnd, double base, double spread) =>
    base + (rnd.nextDouble() - 0.5) * 2 * spread;

/// مصدر محاكاة يطابق عقد [DeviceSource] بالكامل.
class FakeDeviceSource implements DeviceSource {
  final Random _rnd;
  SimScenario _scenario;

  Timer? _vitalsTimer;
  Timer? _envTimer;
  Timer? _linkTimer;
  Timer? _attackTimer;

  final StreamController<VitalsReading> _vitalsCtrl =
      StreamController<VitalsReading>.broadcast();
  final StreamController<EnvReading> _envCtrl =
      StreamController<EnvReading>.broadcast();
  final StreamController<DeviceLinkState> _linkCtrl =
      StreamController<DeviceLinkState>.broadcast();

  DeviceLinkState _link =
      const DeviceLinkState(env: LinkState.disconnected, band: LinkState.disconnected);

  // حالة المحاكاة الفسيولوجية
  double _resp = 15;
  double _hr = 76;
  double _spo2 = 98;
  int _vitalsSeq = 0;
  int _envSeq = 0;
  int _bandBattery = 80;
  int _envBattery = 65;
  DateTime _startedAt = DateTime.now();
  bool _dropActive = false;

  // تلمس التلوث البيئي
  double _pm25 = 18;

  FakeDeviceSource({
    SimScenario initialScenario = SimScenario.stable,
    int? seed,
  })  : _scenario = initialScenario,
        _rnd = Random(seed);

  SimScenario get scenario => _scenario;

  /// تبديل السيناريو أثناء التشغيل (يُستخدم من شاشة الإعدادات التجريبية).
  void applyScenario(SimScenario s) {
    _scenario = s;
    _startedAt = DateTime.now();
    _resp = 15;
    _hr = 76;
    _spo2 = 98;
    _pm25 = 18;
  }

  @override
  Stream<VitalsReading> get vitalsStream => _vitalsCtrl.stream;

  @override
  Stream<EnvReading> get envStream => _envCtrl.stream;

  @override
  Stream<DeviceLinkState> get linkStateStream => _linkCtrl.stream;

  @override
  DeviceLinkState get currentLinkState => _link;

  @override
  Future<void> connect() async {
    if (_link.allConnected) return;
    _emitLink(const DeviceLinkState(env: LinkState.scanning, band: LinkState.scanning));
    await Future<void>.delayed(const Duration(milliseconds: 900));
    _emitLink(const DeviceLinkState(env: LinkState.connecting, band: LinkState.connecting));
    await Future<void>.delayed(const Duration(milliseconds: 900));
    _startedAt = DateTime.now();
    _emitLink(const DeviceLinkState(env: LinkState.connected, band: LinkState.connected));

    _vitalsTimer?.cancel();
    _envTimer?.cancel();
    _vitalsTimer = Timer.periodic(const Duration(seconds: 3), (_) => _emitVitals());
    _envTimer = Timer.periodic(const Duration(seconds: 5), (_) => _emitEnv());

    if (_scenario == SimScenario.connectionDrop) {
      _linkTimer?.cancel();
      _linkTimer = Timer.periodic(const Duration(seconds: 45), (_) => _simulateDrop());
    }
  }

  @override
  Future<void> disconnect() async {
    _stopTimers();
    _emitLink(const DeviceLinkState(
        env: LinkState.disconnected, band: LinkState.disconnected));
  }

  void _simulateDrop() {
    if (_dropActive) return;
    _dropActive = true;
    _emitLink(const DeviceLinkState(env: LinkState.connected, band: LinkState.disconnected));
    Timer(const Duration(seconds: 8), () {
      if (!_dropActive) return;
      _emitLink(const DeviceLinkState(env: LinkState.connected, band: LinkState.connected));
      _dropActive = false;
    });
  }

  void _emitLink(DeviceLinkState s) {
    _link = s;
    if (!_linkCtrl.isClosed) _linkCtrl.add(s);
  }

  void _stopTimers() {
    _vitalsTimer?.cancel();
    _envTimer?.cancel();
    _linkTimer?.cancel();
    _attackTimer?.cancel();
    _vitalsTimer = null;
    _envTimer = null;
    _linkTimer = null;
    _attackTimer = null;
  }

  /// نموذج القيم الحيوية حسب السيناريو.
  ({double resp, double hr, double spo2, ActivityState activity, bool noisy, int quality})
      _targets() {
    final elapsed = DateTime.now().difference(_startedAt);
    switch (_scenario) {
      case SimScenario.gradualAttack:
        // تدرّج واقعي: ثبات 60ث ثم ارتفاع تنفس وانخفاض أكسجين على 150ث ثم استقرار مرتفع
        if (elapsed.inSeconds < 60) {
          return (resp: 15, hr: 76, spo2: 98, activity: ActivityState.resting, noisy: false, quality: 92);
        }
        if (elapsed.inSeconds < 210) {
          final t = (elapsed.inSeconds - 60) / 150; // 0..1
          return (
            resp: 15 + t * 9, // 15 → 24
            hr: 76 + t * 29, // 76 → 105
            spo2: 98 - t * 6, // 98 → 92
            activity: ActivityState.resting,
            noisy: false,
            quality: 90,
          );
        }
        return (resp: 24, hr: 105, spo2: 92, activity: ActivityState.resting, noisy: false, quality: 88);

      case SimScenario.motionNoise:
        final phase = (elapsed.inSeconds ~/ 30) % 2;
        return (
          resp: phase == 0 ? 18.0 : 21.0,
          hr: phase == 0 ? 95.0 : 108.0,
          spo2: 97,
          activity: phase == 0 ? ActivityState.walking : ActivityState.running,
          noisy: true,
          quality: _rnd.nextInt(25) + 30, // 30–55
        );

      case SimScenario.lowBattery:
        return (resp: 15, hr: 76, spo2: 98, activity: ActivityState.resting, noisy: false, quality: 90);

      default:
        return (resp: 15, hr: 76, spo2: 98, activity: ActivityState.resting, noisy: false, quality: 93);
    }
  }

  void _emitVitals() {
    if (_vitalsCtrl.isClosed || _dropActive) return;
    final t = _targets();
    _vitalsSeq++;

    // اقتراب سلس من الهدف + ضجيج طبيعي
    _resp += (t.resp - _resp) * 0.35 + _jitter(_rnd, 0, 0.6);
    _hr += (t.hr - _hr) * 0.35 + _jitter(_rnd, 0, 1.4);
    _spo2 += (t.spo2 - _spo2) * 0.30 + _jitter(_rnd, 0, 0.35);
    _spo2 = _spo2.clamp(85, 100);

    if (_scenario == SimScenario.lowBattery && _vitalsSeq % 10 == 0 && _bandBattery > 8) {
      _bandBattery--;
    }

    final reading = VitalsReading(
      seq: _vitalsSeq,
      notWorn: false,
      motionNoisy: t.noisy,
      localAlertActive: false,
      heartRate: _hr.round(),
      spo2: _spo2.round(),
      respRate: _resp.round(),
      signalQuality: t.quality,
      activity: t.activity,
      battery: _bandBattery,
      receivedAt: DateTime.now(),
    );
    _vitalsCtrl.add(reading);
  }

  void _emitEnv() {
    if (_envCtrl.isClosed || _dropActive) return;
    _envSeq++;

    final target = _scenario == SimScenario.badAir ? 105.0 : 18.0;
    _pm25 += (target - _pm25) * 0.15 + _jitter(_rnd, 0, 1.8);
    _pm25 = _pm25.clamp(5, 180);

    if (_envSeq % 24 == 0 && _envBattery > 5) _envBattery--;

    final vocTarget = _scenario == SimScenario.badAir ? 320 : 110;
    final reading = EnvReading(
      seq: _envSeq,
      sensorFault: false,
      lowBattery: _envBattery <= 15,
      pm25: _pm25,
      pm10: _pm25 * 1.6 + _jitter(_rnd, 0, 3),
      tempC: _jitter(_rnd, 32, 0.8),
      humidity: _jitter(_rnd, 42, 3),
      vocIndex: (vocTarget + _jitter(_rnd, 0, 25)).round().clamp(0, 500),
      battery: _envBattery,
      receivedAt: DateTime.now(),
    );
    _envCtrl.add(reading);
  }

  @override
  void dispose() {
    _stopTimers();
    _vitalsCtrl.close();
    _envCtrl.close();
    _linkCtrl.close();
  }
}
