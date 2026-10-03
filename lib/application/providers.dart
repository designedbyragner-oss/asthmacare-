/// مزودات التطبيق — Riverpod 2 (بلا codegen) حسب الوثيقة §3.
/// المنسق (MonitoringCoordinator) يربط مصدر الأجهزة بقاعدة البيانات ومحرك الخطر.
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:asthma_care/data/ble/device_source.dart';
import 'package:asthma_care/data/ble/fake_device_source.dart';
import 'package:asthma_care/data/ble/real_ble_source.dart';
import 'package:asthma_care/data/external/air_quality_api.dart';
import 'package:asthma_care/data/local_db/app_database.dart';
import 'package:asthma_care/data/models/models.dart';
import 'package:asthma_care/data/repositories/repositories.dart';
import 'package:asthma_care/domain/risk_engine/risk_config.dart';
import 'package:asthma_care/domain/risk_engine/risk_engine.dart';
import 'package:asthma_care/application/services/notification_service.dart';

// ───────────────────────── الإعدادات ─────────────────────────

class AppSettings {
  final bool simulationMode;
  final SimScenario scenario;
  final String userName;
  final bool onboardingDone;
  final bool monitoringEnabled; // زر «ابدأ المراقبة الآن»

  const AppSettings({
    required this.simulationMode,
    required this.scenario,
    required this.userName,
    required this.onboardingDone,
    required this.monitoringEnabled,
  });

  static const AppSettings defaults = AppSettings(
    simulationMode: true,
    scenario: SimScenario.stable,
    userName: '',
    onboardingDone: false,
    monitoringEnabled: false,
  );

  AppSettings copyWith({
    bool? simulationMode,
    SimScenario? scenario,
    String? userName,
    bool? onboardingDone,
    bool? monitoringEnabled,
  }) {
    return AppSettings(
      simulationMode: simulationMode ?? this.simulationMode,
      scenario: scenario ?? this.scenario,
      userName: userName ?? this.userName,
      onboardingDone: onboardingDone ?? this.onboardingDone,
      monitoringEnabled: monitoringEnabled ?? this.monitoringEnabled,
    );
  }
}

class SettingsController extends AsyncNotifier<AppSettings> {
  @override
  Future<AppSettings> build() async {
    final prefs = SharedPreferencesAsync();
    return AppSettings(
      simulationMode: await prefs.getBool('simulationMode') ?? true,
      scenario: SimScenario
          .values[await prefs.getInt('scenarioIdx') ?? 0],
      userName: await prefs.getString('userName') ?? '',
      onboardingDone: await prefs.getBool('onboardingDone') ?? false,
      monitoringEnabled: await prefs.getBool('monitoringEnabled') ?? false,
    );
  }

  Future<void> setUserName(String name) => _update((s) => s.copyWith(userName: name), 'userName', name);
  Future<void> setSimulationMode(bool v) => _update((s) => s.copyWith(simulationMode: v), 'simulationMode', v);
  Future<void> setOnboardingDone() => _update((s) => s.copyWith(onboardingDone: true), 'onboardingDone', true);
  Future<void> setMonitoringEnabled(bool v) => _update((s) => s.copyWith(monitoringEnabled: v), 'monitoringEnabled', v);

  Future<void> setScenario(SimScenario scenario) async {
    final prefs = SharedPreferencesAsync();
    await prefs.setInt('scenarioIdx', scenario.index);
    state = AsyncData((state.value ?? AppSettings.defaults).copyWith(scenario: scenario));
    // تبديل السيناريو على مصدر المحاكاة الحي دون إعادة اقتران (D10)
    try {
      ref.read(fakeSourceProvider).applyScenario(scenario);
    } catch (_) {}
  }

  Future<void> _update<T>(
    AppSettings Function(AppSettings) transform,
    String key,
    T value,
  ) async {
    final prefs = SharedPreferencesAsync();
    if (value is bool) {
      await prefs.setBool(key, value as bool);
    } else if (value is String) {
      await prefs.setString(key, value as String);
    }
    state = AsyncData(transform(state.value ?? AppSettings.defaults));
  }
}

final settingsProvider =
    AsyncNotifierProvider<SettingsController, AppSettings>(SettingsController.new);

// ───────────────────────── قاعدة البيانات والمستودعات ─────────────────────────

/// يُستبدل في main بقيمة مهيأة (overrideWithValue) — لا يُقرأ قبل ذلك.
final databaseProvider = Provider<AppDatabase>((ref) {
  throw UnimplementedError('databaseProvider يجب أن يُوفر في main()');
});

final vitalsRepoProvider =
    Provider<VitalsRepository>((ref) => VitalsRepository(ref.watch(databaseProvider)));
final envRepoProvider =
    Provider<EnvRepository>((ref) => EnvRepository(ref.watch(databaseProvider)));
final alertsRepoProvider =
    Provider<AlertsRepository>((ref) => AlertsRepository(ref.watch(databaseProvider)));
final baselineRepoProvider =
    Provider<BaselineRepository>((ref) => BaselineRepository(ref.watch(databaseProvider)));

final notificationServiceProvider = Provider<NotificationService>((ref) {
  throw UnimplementedError('notificationServiceProvider يجب أن يُوفر في main()');
});

final airQualityApiProvider = Provider<AirQualityApi>((ref) {
  final api = AirQualityApi();
  ref.onDispose(api.dispose);
  return api;
});

// ───────────────────────── مصادر الأجهزة ─────────────────────────

final fakeSourceProvider = Provider<FakeDeviceSource>((ref) {
  final src = FakeDeviceSource();
  ref.onDispose(src.dispose);
  return src;
});

final realSourceProvider = Provider<RealBleSource>((ref) {
  final src = RealBleSource();
  ref.onDispose(src.dispose);
  return src;
});

final deviceSourceProvider = Provider<DeviceSource>((ref) {
  final sim = ref.watch(settingsProvider).value?.simulationMode ?? true;
  return sim ? ref.watch(fakeSourceProvider) : ref.watch(realSourceProvider);
});

// ───────────────────────── الحالة الحية ─────────────────────────

final latestVitalsProvider = StateProvider<VitalsReading?>((ref) => null);
final latestEnvProvider = StateProvider<EnvReading?>((ref) => null);
final linkStateProvider = StateProvider<DeviceLinkState>(
  (ref) => const DeviceLinkState(env: LinkState.disconnected, band: LinkState.disconnected),
);
final riskStateProvider = StateProvider<RiskAssessment>((ref) => RiskAssessment.normal());
final baselineProvider = StateProvider<Baseline?>((ref) => null);

/// تيار التنبيهات للواجهة — يتحدث تلقائيًا من قاعدة البيانات.
final alertsStreamProvider = StreamProvider<List<AppAlert>>((ref) {
  return ref.watch(alertsRepoProvider).watchRecent();
});

// ───────────────────────── المنسق ─────────────────────────

/// يربط مصدر الأجهزة بالتخزين ومحرك الخطر — يعمل طوال عمر التطبيق.
class MonitoringCoordinator {
  final Ref _ref;
  StreamSubscription<VitalsReading>? _vSub;
  StreamSubscription<EnvReading>? _eSub;
  StreamSubscription<DeviceLinkState>? _lSub;
  Timer? _evalTimer;

  Baseline? _baselineCache;
  DateTime? _baselineComputedAt;
  DateTime? _lastAnyAlert;
  DateTime? _lastAttentionAlert;
  DateTime? _lastHighRiskAlert;
  bool _started = false;

  final _engine = const RiskEngine();
  final _extractor = const FeatureExtractor();
  final _baselineCalc = const BaselineCalculator();

  MonitoringCoordinator(this._ref);

  void start() {
    if (_started) return;
    _started = true;

    _ref.listen<DeviceSource>(
      deviceSourceProvider,
      (prev, next) => _rebind(next),
      fireImmediately: true,
    );

    _evalTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      _evaluate();
    });
  }

  Future<void> _rebind(DeviceSource source) async {
    await _vSub?.cancel();
    await _eSub?.cancel();
    await _lSub?.cancel();

    _ref.read(linkStateProvider.notifier).state = const DeviceLinkState(
      env: LinkState.scanning,
      band: LinkState.scanning,
    );

    // الاشتراك قبل الاتصال — أحداث البث broadcast لا تُلتقط متأخرًا
    _vSub = source.vitalsStream.listen((r) {
      debugPrint('AC-DIAG vitals seq=${r.seq} hr=${r.heartRate}');
      _ref.read(latestVitalsProvider.notifier).state = r;
      unawaited(_ref.read(vitalsRepoProvider).insert(r));
    });

    _eSub = source.envStream.listen((r) {
      debugPrint('AC-DIAG env seq=${r.seq} pm25=${r.pm25}');
      _ref.read(latestEnvProvider.notifier).state = r;
      unawaited(_ref.read(envRepoProvider).insert(r));
    });

    _lSub = source.linkStateStream.listen((s) {
      debugPrint('AC-DIAG link band=${s.band} env=${s.env}');
      _ref.read(linkStateProvider.notifier).state = s;
    });

    final settings = _ref.read(settingsProvider).value;
    debugPrint('AC-DIAG rebind: settings=${settings != null} sim=${settings?.simulationMode} mon=${settings?.monitoringEnabled}');
    final monitoringOn = settings?.monitoringEnabled ?? false;
    final simOn = settings?.simulationMode ?? true;
    if (monitoringOn || simOn) {
      // في المحاكاة يتدفق البث تلقائيًا (عرض حي فوري) — زر البدء لمسار BLE الحقيقي
      await source.connect();
    }
  }

  /// تفعيل/إيقاف المراقبة من زر الشاشة الرئيسية.
  Future<void> setMonitoring(bool enabled) async {
    final source = _ref.read(deviceSourceProvider);
    if (enabled) {
      await source.connect();
    } else {
      await source.disconnect();
    }
  }

  /// إيقاف كامل (يُستخدم في الاختبارات وإعادة الربط).
  void stop() {
    _evalTimer?.cancel();
    _evalTimer = null;
  }

  Future<void> _evaluate() async {
    try {
      final settings = _ref.read(settingsProvider).value;
      if (settings == null) return;
      if (!settings.monitoringEnabled && !settings.simulationMode) return;

      final vitalsRepo = _ref.read(vitalsRepoProvider);
      final window = await vitalsRepo.window(const Duration(minutes: 10));
      if (window.isEmpty) return;

      final env = await _ref.read(envRepoProvider).latest();
      final baseline = await _ensureBaseline();
      if (baseline == null) return;

      final features = _extractor.extract(
        vitalsWindow: window,
        latestEnv: env,
        baseline: baseline,
      );
      final assessment = _engine.evaluate(features, baseline);
      _ref.read(riskStateProvider.notifier).state = assessment;

      if (assessment.level == RiskLevel.attention) {
        await _maybeStoreAlert(assessment, window, env);
      } else if (assessment.level == RiskLevel.highRiskPattern) {
        await _maybeStoreAlert(assessment, window, env);
      }
      await _checkEnvironmentAlert(env);
    } catch (e, st) {
      // خدمة المراقبة لا تسقط التطبيق أبدًا — يُسجل ويُعاد لاحقًا
      debugPrint('RiskService evaluation error: $e\n$st');
    }
  }

  Future<Baseline?> _ensureBaseline() async {
    final repo = _ref.read(baselineRepoProvider);
    final now = DateTime.now();

    if (_baselineCache == null ||
        _baselineComputedAt == null ||
        now.difference(_baselineComputedAt!).inMinutes >= 5) {
      final stored = await repo.get();
      if (stored != null && !stored.isProvisional) {
        _baselineCache = stored;
      } else {
        final samples = await _ref.read(vitalsRepoProvider).baselineSamples();
        final computed = _baselineCalc.compute(samples);
        _baselineCache = computed;
        if (!computed.isProvisional) {
          unawaited(repo.save(computed));
        }
      }
      _baselineComputedAt = now;
    }
    _ref.read(baselineProvider.notifier).state = _baselineCache;
    return _baselineCache;
  }

  Future<void> _maybeStoreAlert(
    RiskAssessment assessment,
    List<VitalsReading> window,
    EnvReading? env,
  ) async {
    final now = DateTime.now();
    final isHigh = assessment.level == RiskLevel.highRiskPattern;

    // بوابات التهدئة (RiskConfig) — لا إغراق تنبيهات
    final lastSame = isHigh ? _lastHighRiskAlert : _lastAttentionAlert;
    final cooldown = Duration(
      seconds: isHigh
          ? RiskConfig.highRiskCooldownSec
          : RiskConfig.attentionCooldownSec,
    );
    if (lastSame != null && now.difference(lastSame) < cooldown) return;
    if (_lastAnyAlert != null &&
        now.difference(_lastAnyAlert!) <
            const Duration(seconds: RiskConfig.minAnyAlertGapSec)) {
      return;
    }

    final last4 = window.length <= 4 ? window : window.sublist(window.length - 4);
    final reasonJson = AlertReasonBuilder.encode(
      level: assessment.level.enLabel,
      contributions: assessment.reasons
          .map((r) => {'text': r} as Map<String, Object?>)
          .toList(),
      readingsBefore: {
        'respRate': last4.map((r) => r.respRate ?? 0).toList(),
        'spo2': last4.map((r) => r.spo2 ?? 0).toList(),
        'hr': last4.map((r) => r.heartRate ?? 0).toList(),
      },
      env: env == null
          ? null
          : {'pm25': env.pm25.round(), 'vocIndex': env.vocIndex},
      windowMinutes: 10,
    );

    final severity =
        isHigh ? AlertSeverity.highRisk : AlertSeverity.attention;
    final title = assessment.reasons.isEmpty
        ? assessment.level.arLabel
        : assessment.reasons.first;

    await _ref.read(alertsRepoProvider).insert(AppAlert(
          timestamp: now,
          category: AlertCategory.asthma,
          severity: severity,
          title: title,
          reasonJson: reasonJson,
          acknowledged: false,
        ));

    await _ref.read(notificationServiceProvider).showCritical(
          title: severity.arLabel,
          body: title,
        );

    _lastAnyAlert = now;
    if (isHigh) {
      _lastHighRiskAlert = now;
    } else {
      _lastAttentionAlert = now;
    }
  }

  Future<void> _checkEnvironmentAlert(EnvReading? env) async {
    if (env == null || env.pm25 < 75) return;

    final now = DateTime.now();
    final last = await _ref.read(alertsRepoProvider).lastByCategory(
          AlertCategory.environment,
        );
    if (last != null && now.difference(last.timestamp).inMinutes < 30) return;

    await _ref.read(alertsRepoProvider).insert(AppAlert(
          timestamp: now,
          category: AlertCategory.environment,
          severity: AlertSeverity.attention,
          title: 'جودة هواء سيئة — يُنصح بالبقاء في الداخل',
          reasonJson: AlertReasonBuilder.encode(
            level: 'environment',
            contributions: [
              {'feature': 'pm25', 'value': env.pm25, 'text': 'تركيز الجسيمات الدقيقة مرتفع'},
            ],
            readingsBefore: const {},
            env: {'pm25': env.pm25.round(), 'vocIndex': env.vocIndex},
          ),
          acknowledged: false,
        ));
    await _ref.read(notificationServiceProvider).showInfo(
          title: 'تنبيه بيئي',
          body: 'جودة هواء سيئة — يُنصح بالبقاء في الداخل',
        );
    _lastAnyAlert = now;
  }
}

final coordinatorProvider = Provider<MonitoringCoordinator>((ref) {
  return MonitoringCoordinator(ref);
});
