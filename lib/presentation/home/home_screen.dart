import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:asthma_care/application/providers.dart';
import 'package:asthma_care/core/theme/app_theme.dart';
import 'package:asthma_care/core/theme/theme_controller.dart';
import 'package:asthma_care/presentation/shared_widgets/risk_gauge.dart';
import 'package:asthma_care/presentation/shared_widgets/status_ring.dart';
import 'package:asthma_care/presentation/shared_widgets/widgets.dart';

/// الرئيسية — البطل: حلقة الأكسجين الحية على الخلفية مباشرة (بلا بطاقة).
/// البنية: تجميعة واحدة للمؤشرات ببلاطات داخلية، لا بطاقات عائمة.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _tipsCtrl = PageController();

  static const _tips = [
    'تجنب الخروج في أوقات ذروة التلوث — جهاز البيئة يخبرك بالوقت الأنسب',
    'احرص على شرب الماء بانتظام، فالترطيب الجيد يخفف تهيج الشعب الهوائية',
    'التزم بجرعات الربو حتى مع تحسن الأعراض، وفق خطة طبيبك',
  ];

  @override
  void dispose() {
    _tipsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // اعتماد الستايل — إعادة بناء مضمونة عند التبديل (يمسح المحلل كل const)
    ref.watch(themeStyleProvider);
    final settings = ref.watch(settingsProvider).value;
    final vitals = ref.watch(latestVitalsProvider);
    final env = ref.watch(latestEnvProvider);
    final risk = ref.watch(riskStateProvider);
    final alertsAsync = ref.watch(alertsStreamProvider);
    final hasUnread = alertsAsync.value?.any((a) => !a.acknowledged) ?? false;

    final spo2 = vitals?.spo2;
    final ringColor = spo2 == null
        ? Aurora.textFaint
        : spo2 >= 95
            ? Aurora.oxygen
            : spo2 >= 90
                ? Aurora.environment
                : Aurora.danger;

    return AppBackground(
      child: ListView(
        // أسفل القائمة = خانة الشريط العائم (يحقنها extendBody في
        // padding.bottom) + فراغ تنفّس — آخر بلاطة تفوق الزجاج
        padding: EdgeInsets.fromLTRB(Aurora.hPad, 12, Aurora.hPad,
            MediaQuery.paddingOf(context).bottom + 26),
        children: [
          // ── الترويسة ──
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'مرحبًا، ${settings?.userName.isNotEmpty == true ? settings!.userName : 'بك'}',
                      style: AuroraText.title(context),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        if (settings?.simulationMode ?? true)
                          Text('جاري الاقتران بالمحاكاة...', style: AuroraText.faint(context))
                        else
                          Text('وضع الجهاز الفعلي — لم يُعثر على أجهزة بعد',
                              style: AuroraText.faint(context)),
                      ],
                    ),
                  ],
                ),
              ),
              Stack(
                children: [
                  _BellButton(onTap: () => context.push('/alerts')),
                  if (hasUnread)
                    Positioned(
                      top: 9,
                      right: 9,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Aurora.brand,
                          shape: BoxShape.circle,
                          border: Border.all(color: Aurora.bgHigh, width: 1.5),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 26),

          // ── البطل: الحلقة الحية + الحالة ──
          Row(
            children: [
              StatusRing(
                value: (spo2 ?? 0).toDouble(),
                color: ringColor,
                icon: Icons.air_rounded,
                valueLabel: spo2 != null ? '$spo2%' : '--',
                label: 'مستوى الأكسجين',
                size: 168,
              ),
              const SizedBox(width: 22),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StatusBadge(level: risk.level),
                    const SizedBox(height: 10),
                    Text('مستوى الحالة', style: AuroraText.faint(context)),
                    const SizedBox(height: 4),
                    Text(
                      'تُقارن قراءاتك بخط أساسك الشخصي — لا بقيم عامة.',
                      style: AuroraText.secondary(context),
                    ),
                    if (settings?.simulationMode ?? true) ...[
                      const SizedBox(height: 12),
                      // سطران بدل القصّ الأحادي — المعلومة كاملة وتبقى ضمن العمود
                      MiniChip(
                        icon: Icons.science_outlined,
                        text: 'وضع تجريبي — بيانات محاكاة',
                        color: Aurora.environment,
                        maxLines: 2,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ── مؤشر خطر الربو: قوس المناطق الثلاث ──
          SectionCard(child: RiskGauge(assessment: risk)),

          const SizedBox(height: 20),

          // ── تجميعة المؤشرات: أربع بلاطات داخل حاوية واحدة ──
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
                        icon: Icons.eco_rounded,
                        iconColor: Aurora.oxygen,
                        iconBg: Aurora.oxygenSoft,
                        label: 'جودة الهواء',
                        value: env?.localAirQualityLabel ?? '--',
                        unit: env != null ? 'PM2.5 ${env.pm25.round()}' : 'من جهاز البيئة',
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
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── النصائح: صفحات بحافة ملوّنة دالة ──
          SectionCard(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text('نصائح يومية', style: AuroraText.section(context)),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 84,
                  child: PageView.builder(
                    controller: _tipsCtrl,
                    itemCount: _tips.length,
                    itemBuilder: (context, i) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: EdgeNote(
                        text: _tips[i],
                        accent: Aurora.airflow,
                        style: AuroraText.secondary(context),
                        alignment: Alignment.center,
                      ),
                    );
                    },
                  ),
                ),
                const SizedBox(height: 10),
                _TipDots(count: _tips.length, controller: _tipsCtrl),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BellButton extends StatelessWidget {
  final VoidCallback onTap;
  const _BellButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Aurora.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Aurora.hairline),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          width: 42,
          height: 42,
          child: Icon(Icons.notifications_rounded,
              size: 21, color: Aurora.textPrimary),
        ),
      ),
    );
  }
}

class _TipDots extends StatelessWidget {
  final int count;
  final PageController controller;

  const _TipDots({required this.count, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final page = controller.hasClients ? (controller.page ?? 0) : 0.0;
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < count; i++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: i == page.round() ? 16 : 5,
                height: 5,
                decoration: BoxDecoration(
                  color: i == page.round()
                      ? Aurora.brand
                      : Aurora.textFaint.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
          ],
        );
      },
    );
  }
}
