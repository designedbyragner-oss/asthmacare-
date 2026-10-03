import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:asthma_care/application/providers.dart';
import 'package:asthma_care/core/theme/app_theme.dart';
import 'package:asthma_care/core/theme/theme_controller.dart';
import 'package:asthma_care/data/ble/ble_constants.dart';
import 'package:asthma_care/presentation/shared_widgets/device_images.dart';
import 'package:asthma_care/presentation/shared_widgets/widgets.dart';

/// الإعداد الأول — شرح النظام والأذونات (الإقران اللاحق من الإعدادات).
class PairingScreen extends ConsumerStatefulWidget {
  const PairingScreen({super.key});

  @override
  ConsumerState<PairingScreen> createState() => _PairingScreenState();
}

class _PairingScreenState extends ConsumerState<PairingScreen> {
  final _controller = PageController();
  int _page = 0;

  static final _steps = <({IconData icon, Color color, String title, String body})>[
    (
      icon: Icons.air_rounded,
      color: Aurora.brand,
      title: 'مرحبًا بك في AsthmaCare',
      body: 'نظامك الذكي لمراقبة مؤشرات التنفس وجودة الهواء المحيط، مع إنذار مبكر قابل للتفسير.',
    ),
    (
      icon: Icons.watch_rounded,
      color: Aurora.oxygen,
      title: 'سوارك وجهاز البيئة',
      body: 'يراقب السوار نبضك وتشبع الأكسجين ومعدل تنفسك، وجهاز البيئة يقيس جسيمات الهواء حولك.',
    ),
    (
      icon: Icons.notifications_active_rounded,
      color: Aurora.environment,
      title: 'إنذار مبكر مُفسَّر',
      body: 'عند ظهور نمط يستحق الانتباه، يصلك تنبيه مع سبب واضح — وليس تشخيصًا طبيًا.',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await ref.read(settingsProvider.notifier).setOnboardingDone();
    if (!mounted) return;
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    // اعتماد الستايل — إعادة بناء مضمونة عند التبديل
    ref.watch(themeStyleProvider);
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextButton(
                    onPressed: _finish,
                    child: Text('تخطي', style: AuroraText.faint(context)),
                  ),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  onPageChanged: (i) => setState(() => _page = i),
                  itemCount: _steps.length,
                  itemBuilder: (context, i) {
                    final s = _steps[i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // صفحة الأجهزة تُريهما لا أيقونة عامة عنهما
                          if (i == 1)
                            const _DeviceDuo()
                          else
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: Aurora.surface,
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Aurora.hairlineStrong),
                              ),
                              child: Icon(s.icon, size: 52, color: s.color),
                            ),
                          const SizedBox(height: 28),
                          Text(
                            s.title,
                            textAlign: TextAlign.center,
                            style: AuroraText.display(22),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            s.body,
                            textAlign: TextAlign.center,
                            style: AuroraText.secondary(context),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (var i = 0; i < _steps.length; i++)
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: i == _page ? 18 : 5,
                            height: 5,
                            decoration: BoxDecoration(
                              color: i == _page
                                  ? Aurora.brand
                                  : Aurora.textFaint.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    PrimaryButton(
                      label: _page == _steps.length - 1 ? 'لنبدأ' : 'التالي',
                      onPressed: () {
                        if (_page == _steps.length - 1) {
                          _finish();
                        } else {
                          _controller.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'أسماء الأجهزة: ${BleUuids.bandDeviceName} و ${BleUuids.envDeviceName}',
                      style: AuroraText.faint(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ثنائية الأجهزة الحقيقية — الصفحة التي تسمّيهما بالاسم تُراهما بالعين:
/// تعريف العتاد في اللحظة الأولى يبني الثقة ويجيب «أي جهاز أربط؟» قبل سؤاله.
class _DeviceDuo extends StatelessWidget {
  const _DeviceDuo();

  @override
  Widget build(BuildContext context) {
    Widget tile(String asset, String label) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DevicePhoto(
            asset: asset,
            size: 128,
            fit: BoxFit.contain,
            radius: Aurora.rGroup,
          ),
          const SizedBox(height: 8),
          Text(label, style: AuroraText.faint(context)),
        ],
      );
    }

    // FittedBox يتكيّف مع الشاشات الضيقة (320dp) دون كسر التخطيط
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          tile(DeviceImages.band, 'سوار المراقبة'),
          const SizedBox(width: 14),
          tile(DeviceImages.env, 'جهاز البيئة'),
        ],
      ),
    );
  }
}
