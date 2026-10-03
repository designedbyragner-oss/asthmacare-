import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:asthma_care/application/providers.dart';
import 'package:asthma_care/core/theme/app_palette.dart';
import 'package:asthma_care/core/theme/app_theme.dart';
import 'package:asthma_care/core/theme/theme_controller.dart';
import 'package:asthma_care/data/ble/fake_device_source.dart';
import 'package:asthma_care/presentation/settings/theme_picker_sheet.dart';
import 'package:asthma_care/presentation/shared_widgets/widgets.dart';

/// الملف الشخصي/الإعدادات — حساب محلي بالكامل، وقسم «وضع المطوّر (تجريبي)»
/// يظهر فقط عند تفعيل وضع المحاكاة (قرار D10: البيانات التجريبية موسومة دائمًا).
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider).value;
    final userName = settings?.userName ?? '';
    final displayName = userName.isEmpty ? 'مستخدم' : userName;

    return ListView(
      // أسفل القائمة = خانة الشريط العائم + فراغ تنفّس — انظر MainShell
      padding: EdgeInsets.fromLTRB(Aurora.hPad, 8, Aurora.hPad,
          MediaQuery.paddingOf(context).bottom + 26),
      children: [
        _hero(context, displayName),
        const SizedBox(height: 20),
        _styleCard(context, ref),
        const SizedBox(height: 16),
        _navigationGroup(context),
        if (settings?.simulationMode ?? false) ...[
          const SizedBox(height: 16),
          _developerCard(context, ref, settings!),
        ],
        const SizedBox(height: 16),
        _accountGroup(context, ref, userName),
        const SizedBox(height: 24),
        Text(
          'AsthmaCare v1.0.0',
          textAlign: TextAlign.center,
          style: AuroraText.faint(context),
        ),
        const SizedBox(height: 6),
        Text(
          'نظام مراقبة وتنبيه مبكر — ليس جهاز تشخيص طبي',
          textAlign: TextAlign.center,
          style: AuroraText.faint(context).copyWith(fontSize: 10.5),
        ),
      ],
    );
  }

  // ───────────────────────── الأقسام ─────────────────────────

  /// البطل: هوية الحساب على الخلفية مباشرة (بلا بطاقة).
  Widget _hero(BuildContext context, String displayName) {
    return Row(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: Aurora.surface,
            shape: BoxShape.circle,
            border: Border.all(color: Aurora.hairlineStrong),
          ),
          child: Icon(Icons.person_rounded, size: 30, color: Aurora.brand),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(displayName, style: AuroraText.title(context)),
              const SizedBox(height: 3),
              Text(
                'حساب محلي — بياناتك على جهازك فقط',
                style: AuroraText.faint(context),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// بطاقة «ستايل التطبيق» — الزر إلى منتقي الستايلات. تعرض الستايل
  /// الحالي باسمه ووسمه وشريط عيّنات حي من لوحته النشطة.
  Widget _styleCard(BuildContext context, WidgetRef ref) {
    final styleId = ref.watch(themeStyleProvider);
    final palette = ThemeCatalog.all[styleId] ?? ThemeCatalog.current;
    return SectionCard(
      padding: const EdgeInsets.all(14),
      onTap: () => showThemePickerSheet(context),
      child: Row(
        children: [
          // بنفسجي مسطّح بنيوي — العلامة لون قرار لا تدرج زخرفي (CONTEXT.md)
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: Aurora.brand,
              border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
            ),
            child: const Icon(
              Icons.palette_rounded,
              size: 22,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ستايل التطبيق',
                  style:
                      AuroraText.body(context).copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  '${palette.label} · نشط الآن',
                  style: AuroraText.faint(context),
                ),
              ],
            ),
          ),
          _paletteSwatches(palette),
          const SizedBox(width: 8),
          Icon(
            Icons.chevron_left_rounded,
            size: 22,
            color: Aurora.textFaint,
          ),
        ],
      ),
    );
  }

  /// شريط عيّنات مصغّر من اللوحة النشطة — لمحة فورية عن هوية الستايل.
  Widget _paletteSwatches(AppPalette palette) {
    Widget dot(Color color) => Container(
          width: 13,
          height: 13,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            border: Border.all(color: Colors.white, width: 1.4),
          ),
        );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        dot(palette.bgDeep),
        dot(palette.brand),
        dot(palette.oxygen),
        dot(palette.heart),
      ],
    );
  }

  Widget _navigationGroup(BuildContext context) {
    return SectionCard(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(12, 10, 12, 6),
            child: Text('التنقل', style: AuroraText.faint(context)),
          ),
          InfoRow(
            icon: Icons.show_chart_rounded,
            iconColor: Aurora.oxygen,
            label: 'خط الأساس الشخصي',
            onTap: () => context.push('/baseline'),
          ),
          const Hairline(indent: 50),
          InfoRow(
            icon: Icons.notifications_rounded,
            iconColor: Aurora.environment,
            label: 'التنبيهات',
            onTap: () => context.push('/alerts'),
          ),
          const Hairline(indent: 50),
          InfoRow(
            icon: Icons.monitor_heart_rounded,
            iconColor: Aurora.brand,
            label: 'المراقبة الحية',
            onTap: () => context.push('/monitoring'),
          ),
        ],
      ),
    );
  }

  /// قسم المطوّر — يظهر فقط عند تفعيل وضع المحاكاة (D10).
  Widget _developerCard(BuildContext context, WidgetRef ref, AppSettings settings) {
    return SectionCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('وضع المطوّر (تجريبي)', style: AuroraText.faint(context)),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('وضع المحاكاة', style: AuroraText.body(context)),
                    const SizedBox(height: 3),
                    Text(
                      'بيانات تجريبية موسومة — لا جهاز فعلي',
                      style: AuroraText.faint(context),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: settings.simulationMode,
                activeThumbColor: Aurora.brand,
                activeTrackColor: Aurora.brandSoft,
                onChanged: (v) =>
                    ref.read(settingsProvider.notifier).setSimulationMode(v),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Aurora.surfaceHi,
              borderRadius: BorderRadius.circular(Aurora.rTile),
            ),
            child: DropdownButton<SimScenario>(
              value: settings.scenario,
              isDense: true,
              isExpanded: true,
              underline: const SizedBox.shrink(),
              dropdownColor: Aurora.surface,
              style: AuroraText.secondary(context),
              icon: Icon(Icons.keyboard_arrow_down_rounded,
                  color: Aurora.textFaint),
              items: [
                for (final s in SimScenario.values)
                  DropdownMenuItem(value: s, child: Text(s.arLabel)),
              ],
              onChanged: (s) {
                if (s != null) ref.read(settingsProvider.notifier).setScenario(s);
              },
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'السيناريو الحالي: ${settings.scenario.arLabel}',
            style: AuroraText.faint(context),
          ),
        ],
      ),
    );
  }

  Widget _accountGroup(BuildContext context, WidgetRef ref, String userName) {
    return SectionCard(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(12, 10, 12, 6),
            child: Text('الحساب', style: AuroraText.faint(context)),
          ),
          InfoRow(
            icon: Icons.edit_rounded,
            iconColor: Aurora.airflow,
            label: 'تغيير الاسم',
            onTap: () => _rename(context, ref, userName),
          ),
          const Hairline(indent: 50),
          InfoRow(
            icon: Icons.logout_rounded,
            iconColor: Aurora.danger,
            label: 'تسجيل الخروج',
            onTap: () => _logout(context, ref),
          ),
        ],
      ),
    );
  }

  // ───────────────────────── الحساب ─────────────────────────

  Future<void> _rename(BuildContext context, WidgetRef ref, String current) async {
    final notifier = ref.read(settingsProvider.notifier);
    final ctrl = TextEditingController(text: current);
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تغيير الاسم'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          textInputAction: TextInputAction.done,
          onSubmitted: (v) {
            final t = v.trim();
            if (t.isNotEmpty) Navigator.of(ctx).pop(t);
          },
          style: AuroraText.body(context),
          decoration: InputDecoration(
            hintText: 'اسمك الظاهر',
            hintStyle: AuroraText.faint(context),
            filled: true,
            fillColor: Aurora.surfaceHi,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Aurora.rTile),
              borderSide: BorderSide(color: Aurora.hairline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Aurora.rTile),
              borderSide: BorderSide(color: Aurora.hairline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Aurora.rTile),
              borderSide: BorderSide(color: Aurora.brand, width: 1.4),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('إلغاء'),
          ),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: ctrl,
            builder: (ctx, v, _) => TextButton(
              // التحقق: لا اسم فارغ — زر الحفظ معطّل حتى يُدخل اسم صالح
              onPressed:
                  v.text.trim().isEmpty ? null : () => Navigator.of(ctx).pop(v.text.trim()),
              child: const Text('حفظ'),
            ),
          ),
        ],
      ),
    );
    ctrl.dispose();
    if (name == null || name.isEmpty || !context.mounted) return;
    await notifier.setUserName(name);
  }

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    final notifier = ref.read(settingsProvider.notifier);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text(
          'سيتم مسح اسمك من هذا الجهاز والعودة إلى شاشة الدخول. بياناتك تبقى محفوظة محليًا على جهازك.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'تسجيل الخروج',
              style: TextStyle(
                fontFamily: AuroraText.family,
                fontWeight: FontWeight.w700,
                color: Aurora.danger,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await notifier.setUserName('');
    if (!context.mounted) return;
    context.go('/login');
  }
}
