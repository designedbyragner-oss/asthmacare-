import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:asthma_care/application/providers.dart';
import 'package:asthma_care/core/theme/app_theme.dart';
import 'package:asthma_care/core/theme/theme_controller.dart';
import 'package:asthma_care/data/models/models.dart';
import 'package:asthma_care/data/repositories/repositories.dart';
import 'package:asthma_care/presentation/shared_widgets/widgets.dart';

/// التنبيهات — قائمة الإنذار المبكر القابل للتفسير (§10).
/// كل تنبيه يعرض سببه وقراءاته السابقة عند اللمس؛ لا تشخيص ولا تنبؤ.
class AlertsScreen extends ConsumerStatefulWidget {
  const AlertsScreen({super.key});

  @override
  ConsumerState<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends ConsumerState<AlertsScreen> {
  static const List<String> _tabs = ['الكل', 'الحالة', 'البيئة', 'النظام'];
  int _tab = 0;

  /// تصفية حسب التبويب: النظام تشمل «النظام» و«الدواء» معًا.
  List<AppAlert> _filter(List<AppAlert> alerts) {
    switch (_tab) {
      case 1:
        return alerts.where((a) => a.category == AlertCategory.asthma).toList();
      case 2:
        return alerts
            .where((a) => a.category == AlertCategory.environment)
            .toList();
      case 3:
        return alerts
            .where((a) =>
                a.category == AlertCategory.system ||
                a.category == AlertCategory.medication)
            .toList();
      default:
        return alerts;
    }
  }

  @override
  Widget build(BuildContext context) {
    // اعتماد الستايل — إعادة بناء مضمونة عند التبديل
    ref.watch(themeStyleProvider);
    final alertsAsync = ref.watch(alertsStreamProvider);
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              const ScreenHeader(title: 'التنبيهات', showBack: true),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    Aurora.hPad, 4, Aurora.hPad, 14),
                child: TabPills(
                  options: _tabs,
                  selected: _tab,
                  onChanged: (i) => setState(() => _tab = i),
                ),
              ),
              Expanded(child: _body(context, alertsAsync)),
            ],
          ),
        ),
      ),
    );
  }

  // ───────────────────────── جسم الشاشة ─────────────────────────

  Widget _body(BuildContext context, AsyncValue<List<AppAlert>> async) {
    if (async.isLoading) return _placeholderList(context);
    final filtered = _filter(async.value ?? const <AppAlert>[]);
    if (filtered.isEmpty) return _emptyState(context);
    return ListView.builder(
      padding:
          const EdgeInsets.fromLTRB(Aurora.hPad, 2, Aurora.hPad, 16),
      itemCount: filtered.length + 1,
      itemBuilder: (context, i) {
        if (i == filtered.length) return _footerCaption(context);
        return _tile(context, filtered[i]);
      },
    );
  }

  /// ثلاث بلاطات رمادية هادئة أثناء التحميل — بلا ظلال.
  Widget _placeholderList(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: Aurora.hPad),
      children: [
        for (var i = 0; i < 3; i++)
          Container(
            height: 78,
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: Aurora.surfaceHi,
              borderRadius: BorderRadius.circular(Aurora.rGroup),
            ),
          ),
      ],
    );
  }

  Widget _emptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Aurora.surface,
              shape: BoxShape.circle,
              border: Border.all(color: Aurora.hairline),
            ),
            child: Icon(
              Icons.notifications_off_rounded,
              size: 30,
              color: Aurora.textFaint,
            ),
          ),
          const SizedBox(height: 16),
          Text('لا تنبيهات بعد', style: AuroraText.section(context)),
          const SizedBox(height: 6),
          Text(
            'ستظهر التنبيهات هنا مع شرح سبب كل تنبيه',
            textAlign: TextAlign.center,
            style: AuroraText.secondary(context),
          ),
        ],
      ),
    );
  }

  Widget _tile(BuildContext context, AppAlert alert) {
    final (icon, color, background) = alert.category == AlertCategory.environment
        ? (Icons.eco_rounded, Aurora.environment, Aurora.environmentSoft)
        : AlertTile.styleFor(alert.severity);
    return AlertTile(
      icon: icon,
      color: color,
      background: background,
      title: alert.title,
      timeLabel: formatTimeLabel(alert.timestamp),
      body: firstContributionText(alert),
      onTap: () => _openDetails(alert),
    );
  }

  Widget _footerCaption(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 10),
      child: Text(
        'التنبيهات إنذار مبكر قابل للتفسير وليست تشخيصًا طبيًا',
        textAlign: TextAlign.center,
        style: AuroraText.faint(context),
      ),
    );
  }

  // ───────────────────────── ورقة التفاصيل ─────────────────────────

  Future<void> _openDetails(AppAlert alert) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Aurora.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(Aurora.rHero)),
      ),
      builder: (_) => _AlertDetailsSheet(alert: alert),
    );
  }
}

/// ورقة تفاصيل التنبيه: الدرجة + الطابع الزمني + الأسباب + القراءات السابقة.
class _AlertDetailsSheet extends ConsumerStatefulWidget {
  final AppAlert alert;

  const _AlertDetailsSheet({required this.alert});

  @override
  ConsumerState<_AlertDetailsSheet> createState() => _AlertDetailsSheetState();
}

class _AlertDetailsSheetState extends ConsumerState<_AlertDetailsSheet> {
  bool _busy = false;

  AppAlert get _alert => widget.alert;

  Color get _severityColor => _alert.severity == AlertSeverity.highRisk
      ? Aurora.danger
      : Aurora.environment;

  Future<void> _acknowledge() async {
    if (_busy) return;
    setState(() => _busy = true);
    final id = _alert.id;
    try {
      if (id != null) await ref.read(alertsRepoProvider).acknowledge(id);
    } catch (e) {
      debugPrint('AlertsScreen acknowledge error: $e');
    }
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final causes = <String>[];
    for (final c in decodeContributions(_alert)) {
      final t = c['text'];
      if (t is String && t.trim().isNotEmpty) causes.add(t);
    }
    if (causes.isEmpty) causes.add(_alert.title);

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // مقبض السحب
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Aurora.hairlineStrong,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _severityChip(context),
                const Spacer(),
                Text(
                  formatFullTimestamp(_alert.timestamp),
                  style: AuroraText.faint(context),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(_alert.title, style: AuroraText.title(context)),
            const SizedBox(height: 18),
            Text('الأسباب', style: AuroraText.section(context)),
            const SizedBox(height: 10),
            for (final cause in causes)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.check_circle_rounded,
                        size: 16, color: Aurora.oxygen),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(cause, style: AuroraText.body(context)),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 10),
            Text('القراءات السابقة', style: AuroraText.section(context)),
            const SizedBox(height: 10),
            _readingsRow(context, 'أكسجين', decodeReadings(_alert, 'spo2')),
            const Hairline(),
            _readingsRow(context, 'نبض', decodeReadings(_alert, 'hr')),
            const Hairline(),
            _readingsRow(context, 'التنفس', decodeReadings(_alert, 'respRate')),
            const SizedBox(height: 18),
            PrimaryButton(
              label: 'تم الاطلاع',
              loading: _busy,
              onPressed: _acknowledge,
            ),
          ],
        ),
      ),
    );
  }

  Widget _severityChip(BuildContext context) {
    return DotChip(
      label: _alert.severity.arLabel,
      color: _severityColor,
      // درجة الحبر الداكنة — النص صغير واللون الكامل لا يبلغ 4.5:1
      ink: switch (_alert.severity) {
        AlertSeverity.attention => Aurora.environmentInk,
        AlertSeverity.highRisk => Aurora.dangerInk,
      },
    );
  }

  Widget _readingsRow(BuildContext context, String label, List<num> values) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 64,
            child: Text(label, style: AuroraText.secondary(context)),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: values.isEmpty
                ? Text('—', style: AuroraText.faint(context))
                : Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final v in values) _readingChip(context, v),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _readingChip(BuildContext context, num v) {
    final text =
        v == v.roundToDouble() ? v.round().toString() : v.toStringAsFixed(1);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Aurora.surfaceHi,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: AuroraText.family,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Aurora.textPrimary,
        ),
      ),
    );
  }
}

// ───────────────────────── مساعدات فك reasonJson ─────────────────────────

/// نص أول مساهمة من reasonJson — يُستخدم كسطر شرح في البلاطة (فك دفاعي).
String? firstContributionText(AppAlert alert) {
  for (final c in decodeContributions(alert)) {
    final t = c['text'];
    if (t is String && t.trim().isNotEmpty) return t;
  }
  return null;
}

/// قائمة المساهمات {text: ...} من reasonJson — لا ترمي أبدًا.
List<Map<String, Object?>> decodeContributions(AppAlert alert) {
  try {
    final reason = AlertReasonBuilder.decode(alert.reasonJson);
    final raw = reason['contributions'];
    if (raw is List) {
      return raw
          .whereType<Map>()
          .map((m) => Map<String, Object?>.from(m))
          .toList();
    }
  } catch (_) {}
  return const [];
}

/// قائمة قراءات سابقة (spo2/hr/respRate) من reasonJson — لا ترمي أبدًا.
List<num> decodeReadings(AppAlert alert, String key) {
  try {
    final reason = AlertReasonBuilder.decode(alert.reasonJson);
    final raw = reason['readingsBefore'];
    if (raw is Map) {
      final list = raw[key];
      if (list is List) return list.whereType<num>().toList();
    }
  } catch (_) {}
  return const [];
}

// ───────────────────────── مساعدات الوقت ─────────────────────────

/// «اليوم 6:32 م» / «أمس 6:32 م» / «24/9 6:32 م» — تنسيق يدوي بلا حزم.
String formatTimeLabel(DateTime t) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(t.year, t.month, t.day);
  final diff = today.difference(day).inDays;
  final clock = _clock12(t);
  if (diff <= 0) return 'اليوم $clock';
  if (diff == 1) return 'أمس $clock';
  return '${t.day}/${t.month} $clock';
}

/// طابع زمني كامل لورقة التفاصيل: «2026/9/24 — 6:32 م».
String formatFullTimestamp(DateTime t) =>
    '${t.year}/${t.month}/${t.day} — ${_clock12(t)}';

String _clock12(DateTime t) {
  final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
  final m = t.minute.toString().padLeft(2, '0');
  return '$h:$m ${t.hour < 12 ? 'ص' : 'م'}';
}
