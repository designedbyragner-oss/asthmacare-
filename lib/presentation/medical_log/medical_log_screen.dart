/// السجل الطبي — مخططات المتوسطات الساعية (التنفس / الأكسجين / التزامن البيئي)
/// وتصدير السجل CSV/PDF (§10). معدل التنفس مُقدَّر من إشارة النبض البصرية —
/// شاشة للوعي والمتابعة الشخصية وليست تشخيصًا طبيًا.
library;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:asthma_care/application/providers.dart';
import 'package:asthma_care/application/services/export_service.dart';
import 'package:asthma_care/core/theme/app_theme.dart';
import 'package:asthma_care/core/theme/theme_controller.dart';
import 'package:asthma_care/data/repositories/repositories.dart';
import 'package:asthma_care/presentation/shared_widgets/trend_chart.dart';
import 'package:asthma_care/presentation/shared_widgets/widgets.dart';

// ───────────────────────── بيانات ومزود السجل ─────────────────────────

/// نتيجة جلب مدة تبويب: متوسطات الحيوية + متوسطات البيئة الساعية.
class _LogData {
  final List<HourlyVitalsAvg> vitals;
  final List<HourlyEnvAvg> env;
  const _LogData({required this.vitals, required this.env});
}

Duration _durationFor(int tab) => switch (tab) {
      0 => const Duration(days: 1),
      1 => const Duration(days: 7),
      _ => const Duration(days: 30),
    };

/// يجلب متوسطات الحيوية والبيئة بالتوازي (Future.wait) حسب مدة التبويب.
final _medicalLogProvider =
    FutureProvider.family<_LogData, int>((ref, tab) async {
  final duration = _durationFor(tab);
  final results = await Future.wait<Object?>([
    ref.watch(vitalsRepoProvider).hourlyAverages(duration),
    ref.watch(envRepoProvider).hourlyAverages(duration),
  ]);
  return _LogData(
    vitals: results[0] as List<HourlyVitalsAvg>,
    env: results[1] as List<HourlyEnvAvg>,
  );
});

// ───────────────────────── الشاشة ─────────────────────────

class MedicalLogScreen extends ConsumerStatefulWidget {
  const MedicalLogScreen({super.key});

  @override
  ConsumerState<MedicalLogScreen> createState() => _MedicalLogScreenState();
}

class _MedicalLogScreenState extends ConsumerState<MedicalLogScreen> {
  static const _tabs = ['اليوم', 'الأسبوع', 'الشهر'];

  int _tab = 0;
  bool _exportingCsv = false;
  bool _exportingPdf = false;

  void _onTabChanged(int index) {
    if (index == _tab) return;
    setState(() => _tab = index);
    // إعادة الجلب في كل تبديل (حتى لتبويب زُر سابقًا) — النتيجة تُهمل عمدًا.
    var _ = ref.refresh(_medicalLogProvider(_tab));
  }

  @override
  Widget build(BuildContext context) {
    // اعتماد الستايل — إعادة بناء مضمونة عند التبديل
    ref.watch(themeStyleProvider);
    final log = ref.watch(_medicalLogProvider(_tab));
    return Scaffold(
      body: AppBackground(
        // bottom: false — القائمة تمتد خلف الشريط العائم وتدير المسافة
        // بحشوتها (نفس عقد شاشات التبويبات في MainShell)
        child: SafeArea(
          bottom: false,
          child: ListView(
            padding: EdgeInsets.fromLTRB(Aurora.hPad, 0, Aurora.hPad,
                MediaQuery.paddingOf(context).bottom + 26),
            children: [
              // تبويب جذري — لا زر رجوع ميت فوقه
              const ScreenHeader(title: 'السجل الطبي', showBack: false),
              const SizedBox(height: 8),
              TabPills(options: _tabs, selected: _tab, onChanged: _onTabChanged),
              const SizedBox(height: 12),
              ...log.when(
                loading: () =>
                    List<Widget>.generate(3, (_) => _loadingCard()),
                error: (_, _) => [_errorCard(context)],
                data: (d) => [
                  _vitalsChartCard(
                    context,
                    all: d.vitals,
                    title: 'معدل التنفس',
                    caption: 'متوسط لكل ساعة — مُقدَّر من إشارة النبض البصرية',
                    pick: (r) => r.resp,
                    color: Aurora.airflow,
                    minY: 8,
                    maxY: 32,
                    yInterval: 8,
                  ),
                  _vitalsChartCard(
                    context,
                    all: d.vitals,
                    title: 'مستوى الأكسجين',
                    pick: (r) => r.spo2,
                    color: Aurora.oxygen,
                    minY: 88,
                    maxY: 100,
                    yInterval: 4,
                  ),
                  _envChartCard(context, d.env),
                  _exportCard(context, d.vitals),
                ],
              ),
              Text(
                'للتوعية والمتابعة الشخصية — ليست تشخيصًا طبيًا',
                textAlign: TextAlign.center,
                style: AuroraText.faint(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ───────────────────────── بطاقات المخططات ─────────────────────────

  Widget _chartCard(
    BuildContext context, {
    required String title,
    String? caption,
    required Widget chart,
  }) {
    return SectionCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: AuroraText.section(context).copyWith(fontSize: 14)),
          if (caption != null) ...[
            const SizedBox(height: 3),
            Text(caption, style: AuroraText.faint(context)),
          ],
          const SizedBox(height: 14),
          chart,
        ],
      ),
    );
  }

  /// بطاقة مخطط حيوية — تُبنى من الساعات ذات القيمة الصالحة فقط،
  /// وتسميات المحور من الصفوف المصفاة نفسها ليتطابق الفهرس مع النقاط.
  Widget _vitalsChartCard(
    BuildContext context, {
    required List<HourlyVitalsAvg> all,
    required String title,
    String? caption,
    required double? Function(HourlyVitalsAvg) pick,
    required Color color,
    required double minY,
    required double maxY,
    required double yInterval,
  }) {
    final rows = all.where((r) => pick(r) != null).toList();
    return _chartCard(
      context,
      title: title,
      caption: caption,
      chart: TrendChart(
        spots: [
          for (var i = 0; i < rows.length; i++)
            FlSpot(i.toDouble(), pick(rows[i])!),
        ],
        color: color,
        minY: minY,
        maxY: maxY,
        yInterval: yInterval,
        xLabels: _xLabels(rows, (r) => r.bucketStart),
      ),
    );
  }

  /// بطاقة التزامن البيئي (§10) — PM2.5 خلال الفترة نفسها.
  Widget _envChartCard(BuildContext context, List<HourlyEnvAvg> all) {
    final rows = all.where((r) => r.pm25 != null).toList();
    return _chartCard(
      context,
      title: 'التزامن البيئي',
      caption: 'يربط قراءات جهاز البيئة بالفترة نفسها',
      chart: TrendChart(
        spots: [
          for (var i = 0; i < rows.length; i++)
            FlSpot(i.toDouble(), rows[i].pm25!),
        ],
        color: Aurora.environment,
        minY: 0,
        maxY: 150,
        yInterval: 50,
        xLabels: _xLabels(rows, (r) => r.bucketStart),
        emptyLabel: 'لا توجد بيانات بيئية كافية بعد',
      ),
    );
  }

  /// تسميات محور الزمن — بمحاذاة دقيقة لشبكة fl_chart: الفاصل = n/6 (بحد
  /// أدنى 1) والتراكم يبدأ من الصفر، مع تسمية آخر نقطة دائمًا (maxIncluded).
  /// اليوم 'HH:00' والأسبوع/الشهر 'd/M' — نحو 6 تسميات كحد أقصى.
  Map<int, String> _xLabels<T>(List<T> rows, DateTime Function(T) timeOf) {
    final labels = <int, String>{};
    final count = rows.length;
    if (count == 0) return labels;

    String label(DateTime t) => _tab == 0
        ? '${t.hour.toString().padLeft(2, '0')}:00'
        : '${t.day}/${t.month}';

    final max = (count - 1).toDouble();
    final interval = (count / 6).clamp(1.0, double.infinity);
    final epsilon = interval / 100000;
    var seek = 0.0;
    while (seek <= max + epsilon) {
      labels[seek.toInt()] = label(timeOf(rows[seek.toInt()]));
      seek += interval;
    }
    labels[count - 1] = label(timeOf(rows[count - 1]));
    return labels;
  }

  // ───────────────────────── حالات التحميل والخطأ ─────────────────────────

  Widget _loadingCard() {
    return SectionCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Container(
        height: 190,
        decoration: BoxDecoration(
          color: Aurora.surfaceHi,
          borderRadius: BorderRadius.all(Radius.circular(Aurora.rTile)),
        ),
      ),
    );
  }

  Widget _errorCard(BuildContext context) {
    return SectionCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          Icon(Icons.cloud_off_rounded,
              size: 42, color: Aurora.textFaint),
          const SizedBox(height: 10),
          Text('تعذر تحميل بيانات السجل', style: AuroraText.section(context)),
          const SizedBox(height: 4),
          Text(
            'حدث خطأ أثناء قراءة السجل — تحقق وحاول مجددًا',
            textAlign: TextAlign.center,
            style: AuroraText.secondary(context),
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            label: 'إعادة المحاولة',
            onPressed: () => ref.refresh(_medicalLogProvider(_tab)),
          ),
        ],
      ),
    );
  }

  // ───────────────────────── التصدير ─────────────────────────

  Widget _exportCard(BuildContext context, List<HourlyVitalsAvg> rows) {
    return SectionCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('تصدير البيانات',
              style: AuroraText.section(context).copyWith(fontSize: 14)),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: PrimaryButton(
                  label: 'CSV',
                  icon: Icons.table_view_rounded,
                  color: Aurora.oxygen,
                  loading: _exportingCsv,
                  onPressed:
                      _exportingCsv ? null : () => _export(rows, csv: true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: PrimaryButton(
                  label: 'PDF',
                  icon: Icons.picture_as_pdf_rounded,
                  color: Aurora.danger,
                  loading: _exportingPdf,
                  onPressed:
                      _exportingPdf ? null : () => _export(rows, csv: false),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// تصدير صفوف التبويب الحالي — حارس انشغال مستقل لكل زر.
  Future<void> _export(List<HourlyVitalsAvg> rows, {required bool csv}) async {
    final busy = csv ? _exportingCsv : _exportingPdf;
    if (busy) return;
    setState(() {
      if (csv) {
        _exportingCsv = true;
      } else {
        _exportingPdf = true;
      }
    });
    try {
      final service = ExportService();
      final result =
          csv ? await service.exportCsv(rows) : await service.exportPdf(rows);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('تم الحفظ في مجلد exports'),
        action: SnackBarAction(
          label: 'نسخ المسار',
          onPressed: () =>
              Clipboard.setData(ClipboardData(text: result.file.path)),
        ),
      ));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('تعذر التصدير')));
    } finally {
      if (mounted) {
        setState(() {
          if (csv) {
            _exportingCsv = false;
          } else {
            _exportingPdf = false;
          }
        });
      }
    }
  }
}
