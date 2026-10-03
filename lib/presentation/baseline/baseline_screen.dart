import 'package:flutter/material.dart' hide Baseline;
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:asthma_care/application/providers.dart';
import 'package:asthma_care/core/theme/app_theme.dart';
import 'package:asthma_care/core/theme/theme_controller.dart';
import 'package:asthma_care/data/models/models.dart';
import 'package:asthma_care/presentation/shared_widgets/widgets.dart';

/// خط الأساس الشخصي — تقدم المعايرة (§9.1): حدود مؤقتة حتى اكتمال 30 عينة راحة،
/// ثم حدود شخصية يُعاد حسابها تلقائيًا. عرض إرشادي وليس تشخيصًا.
class BaselineScreen extends ConsumerWidget {
  const BaselineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // اعتماد الستايل — إعادة بناء مضمونة عند التبديل
    ref.watch(themeStyleProvider);
    final baseline = ref.watch(baselineProvider);
    final provisional = baseline == null || baseline.isProvisional;
    final sampleCount = baseline?.sampleCount ?? 0;
    final progress = (sampleCount / 30).clamp(0.0, 1.0).toDouble();

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: ListView(
            padding:
                const EdgeInsets.fromLTRB(Aurora.hPad, 0, Aurora.hPad, 32),
            children: [
              const ScreenHeader(title: 'خط الأساس الشخصي'),
              _explainerCard(context),
              const SizedBox(height: 12),
              _progressCard(context, sampleCount, provisional, progress),
              const SizedBox(height: 12),
              _valuesRow(context, baseline),
              const SizedBox(height: 16),
              Text(
                'يُعاد الحساب تلقائيًا كل 5 دقائق من آخر 7 أيام عالية الجودة',
                textAlign: TextAlign.center,
                style: AuroraText.faint(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _explainerCard(BuildContext context) {
    return SectionCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconChip(
            icon: Icons.psychology_rounded,
            color: Aurora.brand,
            bg: Aurora.brandSoft,
            size: IconChipSize.medium,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('لماذا خط الأساس؟', style: AuroraText.section(context)),
                const SizedBox(height: 4),
                Text(
                  'يقارن النظام قراءاتك بمعدل راحتك الشخصي — لا بقيم عامة — لإنذار مبكر قابل للتفسير.',
                  style: AuroraText.secondary(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _progressCard(
    BuildContext context,
    int sampleCount,
    bool provisional,
    double progress,
  ) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('عينات الراحة', style: AuroraText.faint(context)),
              const Spacer(),
              AnimatedNumber(value: sampleCount.toString(), fontSize: 20),
            ],
          ),
          const SizedBox(height: 10),
          // مسار تقدم شعري مخصص — لا LinearProgressIndicator.
          Container(
            width: double.infinity,
            height: 6,
            decoration: BoxDecoration(
              color: Aurora.hairline,
              borderRadius: BorderRadius.circular(3),
            ),
            child: FractionallySizedBox(
              alignment: AlignmentDirectional.centerStart,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  color: Aurora.brand,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (provisional)
            Row(
              children: [
                MiniChip(
                  icon: Icons.hourglass_top_rounded,
                  text: 'حدود مؤقتة مفعلة',
                  color: Aurora.environment,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'استمر بارتداء السوار أثناء الراحة حتى 30 عينة',
                    style: AuroraText.secondary(context),
                  ),
                ),
              ],
            )
          else
            MiniChip(
              icon: Icons.check_circle_outline_rounded,
              text: 'خط أساسك جاهز',
              color: Aurora.oxygen,
            ),
        ],
      ),
    );
  }

  Widget _valuesRow(BuildContext context, Baseline? baseline) {
    return Row(
      children: [
        Expanded(
          child: MetricCard(
            icon: Icons.favorite_rounded,
            iconColor: Aurora.heart,
            iconBg: Aurora.heartSoft,
            label: 'نبض الراحة',
            value: baseline?.restingHr.round().toString() ?? '--',
            unit: 'bpm',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: MetricCard(
            icon: Icons.waves_rounded,
            iconColor: Aurora.airflow,
            iconBg: Aurora.airflowSoft,
            label: 'تنفس الراحة',
            value: baseline?.restingRespRate.round().toString() ?? '--',
            unit: 'نفَس/د',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: MetricCard(
            icon: Icons.water_drop_rounded,
            iconColor: Aurora.oxygen,
            iconBg: Aurora.oxygenSoft,
            label: 'أكسجين الراحة',
            value: baseline?.restingSpo2.round().toString() ?? '--',
            unit: '%',
          ),
        ),
      ],
    );
  }
}
