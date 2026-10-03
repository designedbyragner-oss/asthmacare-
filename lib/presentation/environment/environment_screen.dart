import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:asthma_care/application/providers.dart';
import 'package:asthma_care/core/theme/app_theme.dart';
import 'package:asthma_care/core/theme/theme_controller.dart';
import 'package:asthma_care/data/models/models.dart';
import 'package:asthma_care/presentation/shared_widgets/status_ring.dart';
import 'package:asthma_care/presentation/shared_widgets/widgets.dart';

/// البيئة المحيطة — جودة الهواء والطقس من جهاز البيئة (قراءة مباشرة)،
/// وNO₂/SO₂ من مصدر خارجي موسوم دائمًا (قرار D5). النصائح إرشادية وليست تشخيصًا.
class EnvironmentScreen extends ConsumerStatefulWidget {
  const EnvironmentScreen({super.key});

  @override
  ConsumerState<EnvironmentScreen> createState() => _EnvironmentScreenState();
}

class _EnvironmentScreenState extends ConsumerState<EnvironmentScreen> {
  /// جلب الملوثات الغازية (NO₂/SO₂) من المصدر الخارجي مرة واحدة عند الفتح (D5).
  Future<ExternalAirQuality>? _externalFuture;

  @override
  void initState() {
    super.initState();
    _externalFuture = ref.read(airQualityApiProvider).fetchCurrent();
  }

  // ───────────────────────── مشتقات القراءة ─────────────────────────

  /// مؤشر جودة الهواء المحلي: 100 − (PM2.5/150×100) مقصود على 0–100.
  double _airScore(EnvReading? env) {
    if (env == null) return 0;
    return (100 - env.pm25 / 150 * 100).clamp(0.0, 100.0).toDouble();
  }

  /// لون الحلقة: لا قراءة بعد = محايد، ثم عتبات PM2.5 المعتمدة.
  Color _airColor(EnvReading? env) {
    if (env == null) return Aurora.textFaint;
    if (env.pm25 <= 35) return Aurora.oxygen;
    if (env.pm25 <= 75) return Aurora.environment;
    return Aurora.danger;
  }

  String _advice(EnvReading? env) {
    if (env == null) return 'بانتظار جهاز البيئة ليخبرك بحالة الهواء';
    if (env.pm25 <= 35) return 'الهواء مناسب للنشاط الخارجي';
    if (env.pm25 <= 75) return 'يُفضل تقصير النشاط الخارجي وأخذ دوائك معك';
    return 'الهواء سيئ — يُنصح بالبقاء في الداخل وإغلاق النوافذ';
  }

  @override
  Widget build(BuildContext context) {
    // اعتماد الستايل — إعادة بناء مضمونة عند التبديل
    ref.watch(themeStyleProvider);
    final env = ref.watch(latestEnvProvider);
    return ListView(
      // أسفل القائمة = خانة الشريط العائم + فراغ تنفّس — انظر MainShell
      padding: EdgeInsets.fromLTRB(Aurora.hPad, 8, Aurora.hPad,
          MediaQuery.paddingOf(context).bottom + 26),
      children: [
        // تبويب جذري — لا زر رجوع ميت فوقه
        const ScreenHeader(title: 'البيئة المحيطة', showBack: false),
        const SizedBox(height: 8),
        _hero(context, env),
        const SizedBox(height: 24),
        _pollutantGroup(context, env),
        const SizedBox(height: 16),
        _externalCard(context),
        const SizedBox(height: 16),
        _weatherCard(context, env),
        const SizedBox(height: 16),
        _adviceCard(context, env),
        const SizedBox(height: 20),
        Text(
          'جودة الهواء تؤثر على أعراض الربو — التتبع يساعدك على التخطيط',
          textAlign: TextAlign.center,
          style: AuroraText.faint(context),
        ),
      ],
    );
  }

  // ───────────────────────── الأقسام ─────────────────────────

  /// البطل: الحلقة الحية على الخلفية مباشرة (بلا بطاقة) + إسناد الجهاز.
  /// الإسناد مرة واحدة داخل الحلقة — لا تكرار نصي تحتها.
  Widget _hero(BuildContext context, EnvReading? env) {
    return Center(
      child: StatusRing(
        size: 170,
        value: _airScore(env),
        color: _airColor(env),
        icon: Icons.eco_rounded,
        iconBg: Aurora.environmentSoft,
        valueLabel: env?.localAirQualityLabel ?? '--',
        label: 'من جهاز البيئة — قراءة مباشرة',
      ),
    );
  }

  /// تجميعة الملوثات: أربع بلاطات داخل حاوية واحدة.
  Widget _pollutantGroup(BuildContext context, EnvReading? env) {
    return SectionCard(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: MetricCard(
                  icon: Icons.blur_on_rounded,
                  iconColor: Aurora.environment,
                  iconBg: Aurora.environmentSoft,
                  label: 'PM2.5',
                  value: env?.pm25.round().toString() ?? '--',
                  unit: 'µg/m³',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: MetricCard(
                  icon: Icons.blur_linear_rounded,
                  iconColor: Aurora.environment,
                  iconBg: Aurora.environmentSoft,
                  label: 'PM10',
                  value: env?.pm10.round().toString() ?? '--',
                  unit: 'µg/m³',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _ExternalMetricSlot(
                  future: _externalFuture,
                  title: 'NO₂',
                  icon: Icons.air_rounded,
                  pick: (e) => e?.no2,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ExternalMetricSlot(
                  future: _externalFuture,
                  title: 'SO₂',
                  icon: Icons.cloud_rounded,
                  pick: (e) => e?.so2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// بطاقة المصدر الخارجي (D5) — رقاقة الإسناد مرئية دائمًا، وليست عند التقدير فقط.
  Widget _externalCard(BuildContext context) {
    return SectionCard(
      padding: const EdgeInsets.all(14),
      child: FutureBuilder<ExternalAirQuality>(
        future: _externalFuture,
        builder: (context, snap) {
          final ext = snap.data;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'NO₂ و SO₂ الخارجية',
                      style:
                          AuroraText.section(context).copyWith(fontSize: 14),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _sourceChip(estimate: ext?.isEstimate ?? false),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(child: _externalValue(context, 'NO₂', ext?.no2)),
                  const SizedBox(width: 12),
                  Expanded(child: _externalValue(context, 'SO₂', ext?.so2)),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _sourceChip({required bool estimate}) {
    final color = estimate ? Aurora.danger : Aurora.airflow;
    final bg = estimate ? Aurora.dangerSoft : Aurora.airflowSoft;
    final text =
        estimate ? 'تقدير إقليمي — تعذر الاتصال' : 'من مصدر خارجي — ليس من جهازك';
    return MiniChip(
      icon: Icons.info_outline_rounded,
      text: text,
      color: color,
      bg: bg,
    );
  }

  Widget _externalValue(BuildContext context, String title, double? value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AuroraText.secondary(context)),
        const SizedBox(height: 3),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            AnimatedNumber(
              value: value?.round().toString() ?? '--',
              fontSize: 21,
            ),
            const SizedBox(width: 4),
            Text('µg/m³', style: AuroraText.unit(context)),
          ],
        ),
      ],
    );
  }

  Widget _weatherCard(BuildContext context, EnvReading? env) {
    final temp = env != null ? env.tempC.round().toString() : '--';
    final humidity = env == null ? '--' : env.humidity.round().toString();
    return SectionCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          IconChip(
            icon: Icons.device_thermostat_rounded,
            color: Aurora.environment,
            bg: Aurora.environmentSoft,
            size: IconChipSize.medium,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'الطقس الآن',
                  style: AuroraText.section(context).copyWith(fontSize: 13.5),
                ),
                const SizedBox(height: 2),
                Text(
                  'الحرارة $temp°م · الرطوبة $humidity% — من جهاز البيئة',
                  style: AuroraText.faint(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// الإرشاد الديناميكي — حافة دالة بلون الهواء المتحرك كنصائح الرئيسية.
  Widget _adviceCard(BuildContext context, EnvReading? env) {
    return SectionCard(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: EdgeNote(
          text: _advice(env),
          accent: Aurora.airflow,
        ),
      ),
    );
  }
}

/// بلاطة ملوث خارجي (NO₂/SO₂) — تُملأ من المصدر الخارجي الموسوم (D5).
/// أيقونة لكل غاز — لا أيقونة واحدة لملوّثين مختلفين.
class _ExternalMetricSlot extends StatelessWidget {
  final Future<ExternalAirQuality>? future;
  final String title;
  final IconData icon;
  final double? Function(ExternalAirQuality?) pick;

  const _ExternalMetricSlot({
    required this.future,
    required this.title,
    required this.icon,
    required this.pick,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ExternalAirQuality>(
      future: future,
      builder: (context, snap) {
        final value = pick(snap.data);
        return MetricCard(
          icon: icon,
          iconColor: Aurora.airflow,
          iconBg: Aurora.airflowSoft,
          label: title,
          value: value?.round().toString() ?? '--',
          unit: 'µg/m³',
          // الشارة الكاملة «من مصدر خارجي» في بطاقة المصدر أسفل الشبكة (D5)
        );
      },
    );
  }
}
