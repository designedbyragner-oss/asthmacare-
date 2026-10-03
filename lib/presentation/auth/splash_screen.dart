import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:asthma_care/application/providers.dart';
import 'package:asthma_care/core/theme/app_theme.dart';
import 'package:asthma_care/core/theme/theme_controller.dart';
import 'package:asthma_care/presentation/shared_widgets/pulse_line.dart';
import 'package:asthma_care/presentation/shared_widgets/widgets.dart';

/// البداية — علامة النبض فوق هالة تنفس حية، وموجة ECG ترسم نفسها
/// كزخرفة دخول واحدة. توجيه بعد لحظة سكوت مقصودة.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2200), _navigate);
  }

  void _navigate() {
    if (!mounted) return;
    final settings = ref.read(settingsProvider).value;
    if (settings == null || !settings.onboardingDone) {
      context.go('/onboarding');
    } else if (settings.userName.isEmpty) {
      context.go('/login');
    } else {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    // اعتماد الستايل — إعادة بناء مضمونة عند التبديل
    ref.watch(themeStyleProvider);
    // استعارة حلقة الحالة بلا قوس: breathe فقط — الشعار يتنفس
    return Scaffold(
      body: AppBackground(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // العلامة: مربع البنفسجي بخط النبض — نفس الأيقونة، داخل هالة تنفس
              SizedBox(
                width: 200,
                height: 200,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const _HaloOnly(size: 200),
                    const BrandMark(size: 96),
                  ],
                ),
              ),
              const SizedBox(height: 26),
              Text(
                'AsthmaCare',
                style: AuroraText.display(34, color: Aurora.textPrimary),
              ),
              const SizedBox(height: 8),
              Text('نفس أعمق... حياة أفضل', style: AuroraText.secondary(context)),
              const SizedBox(height: 24),
              // زخرفة الدخول الوحيدة: الموجة ترسم نفسها مرة واحدة
              PulseLine(width: 210, height: 38),
            ],
          ),
        ),
      ),
    );
  }
}

/// هالة تنفس مستقلة (بدون حلقة قياس) — تتنفس باستمرار، إيقاع 4 ثوانٍ.
class _HaloOnly extends StatefulWidget {
  final double size;

  const _HaloOnly({required this.size});

  @override
  State<_HaloOnly> createState() => _HaloOnlyState();
}

class _HaloOnlyState extends State<_HaloOnly>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 4),
  )..repeat(reverse: true);

  late final Animation<double> _curve =
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _curve,
      builder: (context, _) {
        final t = _curve.value;
        return Transform.scale(
          scale: 1.04 + 0.08 * t,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Aurora.glowTint.withValues(alpha: 0),
                  Aurora.glowTint.withValues(alpha: 0.12 + 0.10 * t),
                ],
                stops: const [0.55, 1.0],
              ),
            ),
          ),
        );
      },
    );
  }
}
