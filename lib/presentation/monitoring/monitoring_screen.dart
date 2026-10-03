import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:asthma_care/application/providers.dart';
import 'package:asthma_care/core/theme/app_theme.dart';
import 'package:asthma_care/core/theme/theme_controller.dart';
import 'package:asthma_care/data/models/models.dart';
import 'package:asthma_care/presentation/shared_widgets/device_images.dart';
import 'package:asthma_care/presentation/shared_widgets/widgets.dart';

/// المراقبة الحية — لوحة الجهازين ثم القراءات ثم الحالة.
/// البنية: تجميعتان محكمتان ببنية شعرية؛ النقطة الحية تخبر بحالة البث.
class MonitoringScreen extends ConsumerStatefulWidget {
  const MonitoringScreen({super.key});

  @override
  ConsumerState<MonitoringScreen> createState() => _MonitoringScreenState();
}

class _MonitoringScreenState extends ConsumerState<MonitoringScreen> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    // اعتماد الستايل — إعادة بناء مضمونة عند التبديل
    ref.watch(themeStyleProvider);
    final vitals = ref.watch(latestVitalsProvider);
    final env = ref.watch(latestEnvProvider);
    final link = ref.watch(linkStateProvider);
    final risk = ref.watch(riskStateProvider);
    final settings = ref.watch(settingsProvider).value;

    // Scaffold مطلوب: بقية الشاشات المفروضة تملكه — بدونه تفقد النصوص
    // سلف Material فتظهر تحت خط التحذير الأصفر الافتراضي.
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(Aurora.hPad, 8, Aurora.hPad, 40),
            children: [
              ScreenHeader(title: 'المراقبة الحية'),

              const SizedBox(height: 8),

              // ── لوحة الأجهزة ──
              SectionCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 4,
                ),
                child: Column(
                  children: [
                    _DeviceRow(
                      icon: Icons.watch_rounded,
                      iconColor: Aurora.brand,
                      photo: DeviceImages.band,
                      name: 'سوار المراقبة',
                      state: link.band,
                      battery: vitals?.battery,
                    ),
                    const Hairline(indent: 60),
                    _DeviceRow(
                      icon: Icons.sensors_rounded,
                      iconColor: Aurora.oxygen,
                      photo: DeviceImages.env,
                      name: 'جهاز البيئة',
                      state: link.env,
                      battery: env?.battery,
                    ),
                  ],
                ),
              ),

              if (settings?.simulationMode ?? true) ...[
                const SizedBox(height: 10),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: MiniChip(
                    icon: Icons.science_outlined,
                    text: 'وضع تجريبي — بيانات محاكاة',
                    color: Aurora.environment,
                  ),
                ),
              ],

              const SizedBox(height: 16),

              // ── القراءات الحالية ──
              SectionCard(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: MetricCard(
                            icon: Icons.favorite_rounded,
                            iconColor: Aurora.heart,
                            iconBg: Aurora.heartSoft,
                            label: 'النبض',
                            value: vitals?.heartRate?.toString() ?? '--',
                            unit: 'ن/د',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: MetricCard(
                            icon: Icons.waves_rounded,
                            iconColor: Aurora.airflow,
                            iconBg: Aurora.airflowSoft,
                            label: 'التنفس',
                            value: vitals?.respRate?.toString() ?? '--',
                            unit: 'ن/د',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: MetricCard(
                            icon: Icons.water_drop_rounded,
                            iconColor: Aurora.oxygen,
                            iconBg: Aurora.oxygenSoft,
                            label: 'الأكسجين',
                            value: vitals?.spo2?.toString() ?? '--',
                            unit: '%',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: MetricCard(
                            icon: Icons.device_thermostat_rounded,
                            iconColor: Aurora.environment,
                            iconBg: Aurora.environmentSoft,
                            label: 'حرارة البيئة',
                            value: env != null ? '${env.tempC.round()}' : '--',
                            unit: '°م',
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(6, 10, 6, 4),
                      child: Text(
                        vitals == null
                            ? 'بانتظار أول قراءة من السوار...'
                            : 'معدل التنفس مُقدَّر من إشارة النبض البصرية',
                        style: AuroraText.faint(context),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── جودة الإشارة ──
              SectionCard(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'جودة الإشارة',
                          style: AuroraText.section(context),
                        ),
                        const Spacer(),
                        AnimatedNumber(
                          value: vitals != null
                              ? '${vitals.signalQuality}'
                              : '--',
                          fontSize: 18,
                          color: _qualityColor(vitals?.signalQuality),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 5,
                      decoration: BoxDecoration(
                        color: Aurora.hairline,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: FractionallySizedBox(
                          widthFactor: ((vitals?.signalQuality ?? 0) / 100)
                              .clamp(0.0, 1.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: _qualityColor(vitals?.signalQuality),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── الحالة + سببها (شفافية §8.7) ──
              SectionCard(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StatusBadge(level: risk.level),
                    if (risk.reasons.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        risk.reasons.first,
                        style: AuroraText.secondary(context),
                      ),
                    ] else ...[
                      const SizedBox(height: 10),
                      Text(
                        'لا أنماط تستحق الانتباه الآن — تقييم دوري كل 15 ثانية.',
                        style: AuroraText.faint(context),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 20),

              PrimaryButton(
                label: settings?.monitoringEnabled == true
                    ? 'إيقاف المراقبة'
                    : 'ابدأ المراقبة الآن',
                icon: settings?.monitoringEnabled == true
                    ? Icons.stop_rounded
                    : Icons.play_arrow_rounded,
                color: settings?.monitoringEnabled == true
                    ? Aurora.danger
                    : null,
                loading: _busy,
                onPressed: _busy ? null : _toggle,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _qualityColor(int? q) {
    if (q == null) return Aurora.textFaint;
    if (q >= 60) return Aurora.oxygen;
    if (q >= 30) return Aurora.environment;
    return Aurora.danger;
  }

  Future<void> _toggle() async {
    setState(() => _busy = true);
    try {
      final settings = ref.read(settingsProvider).value;
      final enabled = settings?.monitoringEnabled ?? false;
      await ref.read(coordinatorProvider).setMonitoring(!enabled);
      await ref.read(settingsProvider.notifier).setMonitoringEnabled(!enabled);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}

/// صف جهاز: صورة العتاد الحقيقية (أو أيقونة احتياطية) + حالة الارتباط النابضة + البطارية.
class _DeviceRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String? photo;
  final String name;
  final LinkState state;
  final int? battery;

  const _DeviceRow({
    required this.icon,
    required this.iconColor,
    this.photo,
    required this.name,
    required this.state,
    required this.battery,
  });

  Color get _stateColor => switch (state) {
    LinkState.connected => Aurora.oxygen,
    LinkState.scanning || LinkState.connecting => Aurora.environment,
    LinkState.disconnected => Aurora.textFaint,
  };

  IconData _batteryIcon(int b) {
    if (b >= 90) return Icons.battery_full_rounded;
    if (b >= 70) return Icons.battery_6_bar_rounded;
    if (b >= 50) return Icons.battery_4_bar_rounded;
    if (b >= 30) return Icons.battery_3_bar_rounded;
    if (b >= 15) return Icons.battery_2_bar_rounded;
    return Icons.battery_1_bar_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          // صورة العتاد الحقيقية تتعرّف بها العين فورًا — والأيقونة احتياط إن غابت
          if (photo != null)
            DevicePhoto(asset: photo!, size: 48)
          else
            IconChip(
              icon: icon,
              color: iconColor,
              bg: iconColor.withValues(alpha: 0.13),
              size: IconChipSize.medium,
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AuroraText.section(context).copyWith(fontSize: 14),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    if (state == LinkState.connected)
                      LiveDot(color: Aurora.oxygen, size: 6)
                    else
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _stateColor.withValues(alpha: 0.5),
                        ),
                      ),
                    const SizedBox(width: 6),
                    Text(state.arLabel, style: AuroraText.faint(context)),
                  ],
                ),
              ],
            ),
          ),
          if (battery != null && battery! > 0)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // أيقونة البطارية تصدق المستوى — ولا «ممتازة» على 29%
                Icon(
                  _batteryIcon(battery!),
                  size: 15,
                  color: battery! < 15 ? Aurora.danger : Aurora.textFaint,
                ),
                const SizedBox(width: 3),
                Text('$battery%', style: AuroraText.faint(context)),
              ],
            ),
        ],
      ),
    );
  }
}

