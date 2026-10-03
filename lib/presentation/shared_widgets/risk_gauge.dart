/// ─────────────────────────────────────────────────────────────
/// مؤشر خطر الربو — قوس نصف دائري بثلاث مناطق (نبض v4).
/// لغة شكل مميزة عن حلقة البطل: الحلقة = قياس، القوس = مؤشر.
/// الاتجاه: تقنية العقارب يسارًا→يمينًا فوق القبة — اصطلاح المقاييس
/// لا يُعكس في RTL. الحركة تجيب عن وصول البيانات فقط (450ms) وتبقى هادئة —
/// الجرأة الوحيدة للهوية تبقى هالة حلقة البطل.
/// ─────────────────────────────────────────────────────────────
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:asthma_care/core/theme/app_theme.dart';
import 'package:asthma_care/data/models/models.dart';
import 'package:asthma_care/domain/risk_engine/risk_index.dart';

/// محتوى بطاقة المؤشر — الرئيسية تلفّه داخل SectionCard خاصة به.
class RiskGauge extends StatelessWidget {
  final RiskAssessment assessment;

  const RiskGauge({super.key, required this.assessment});

  @override
  Widget build(BuildContext context) {
    final index = AsthmaRiskIndex.fromAssessment(assessment);
    final reason = assessment.reasons.isNotEmpty
        ? assessment.reasons.first
        : switch (index.zone) {
            RiskIndexZone.normal =>
              'لا أنماط تستحق الانتباه الآن — تقييم دوري مستمر.',
            RiskIndexZone.onset => 'راقب الأعراض وأبقِ خطة العمل الشخصية قريبة.',
            RiskIndexZone.high =>
              'اتبع خطة العمل الشخصية، وتواصل مع طبيبك إذا استمرت الأعراض.',
          };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('مؤشر خطر الربو', style: AuroraText.section(context)),
        const SizedBox(height: 8),
        // القوس ينبثق من الصفر عند وصول تقييم جديد — حركة تشرح لا تزخرف
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: index.percent.toDouble()),
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeOutCubic,
          builder: (context, sweep, _) =>
              _Dome(index: index, sweep: sweep),
        ),
        const SizedBox(height: 8),
        Text(
          reason,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AuroraText.secondary(context),
        ),
        const SizedBox(height: 8),
        Text(
          'مؤشر إرشادي وليس تشخيصًا — يعتمد على خط أساسك الشخصي.',
          textAlign: TextAlign.center,
          style: AuroraText.faint(context),
        ),
      ],
    );
  }
}

/// قبة القوس: مسار بثلاث شرائح منطقة + قوس نشط + الرقم واسم المنطقة في الداخل.
class _Dome extends StatelessWidget {
  final AsthmaRiskIndex index;
  final double sweep; // القيمة المتحركة للقوس 0–100

  const _Dome({required this.index, required this.sweep});

  Color get _color => switch (index.zone) {
        RiskIndexZone.normal => Aurora.oxygen,
        RiskIndexZone.onset => Aurora.environment,
        RiskIndexZone.high => Aurora.danger,
      };

  // نص المنطقة صغير — درجة الحبر الداكنة لتباين يمر WCAG (كالشارات)
  Color get _ink => switch (index.zone) {
        RiskIndexZone.normal => Aurora.oxygenInk,
        RiskIndexZone.onset => Aurora.environmentInk,
        RiskIndexZone.high => Aurora.dangerInk,
      };

  String get _zoneLabel => switch (index.zone) {
        RiskIndexZone.normal => 'طبيعي',
        RiskIndexZone.onset => 'احتمال بداية نوبة',
        RiskIndexZone.high => 'خطر مرتفع — احتمال نوبة',
      };

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 230,
      height: 122,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          CustomPaint(
            size: const Size(230, 122),
            painter: _GaugePainter(sweep: sweep, zoneColor: _color),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 10,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${index.percent}%', style: AuroraText.display(40)),
                const SizedBox(height: 2),
                Text(
                  _zoneLabel,
                  style: TextStyle(
                    fontFamily: AuroraText.familyDisplay,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: _ink,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double sweep; // 0–100
  final Color zoneColor;

  static const double _stroke = 14;

  _GaugePainter({required this.sweep, required this.zoneColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height - 10);
    final radius = size.width / 2 - _stroke;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // المسار الخلفي: ثلاث شرائح منطقة بنسب 0–39 / 39–75 / 75–100 بشفافية
    void track(double from, double to, Color color) {
      final p = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = _stroke
        ..strokeCap = StrokeCap.butt
        ..color = color.withValues(alpha: 0.16);
      canvas.drawArc(
        rect,
        math.pi + math.pi * from / 100,
        math.pi * (to - from) / 100,
        false,
        p,
      );
    }

    track(0, 39, Aurora.oxygen);
    track(39, 75, Aurora.environment);
    track(75, 100, Aurora.danger);

    // القوس النشط — من الصفر حتى النسبة بلون المنطقة الصلب
    final active = math.pi * sweep / 100;
    if (active > 0.02) {
      final p = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = _stroke
        ..strokeCap = StrokeCap.round
        ..color = zoneColor;
      canvas.drawArc(rect, math.pi, active, false, p);

      // نقطة النهاية المتوهجة — قلب أبيض + هالة بلون المنطقة (تشفير بيانات)
      final angle = math.pi + active;
      final dot = center + Offset(math.cos(angle), math.sin(angle)) * radius;
      final halo = Paint()
        ..color = zoneColor.withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawCircle(dot, _stroke * 0.9, halo);
      canvas.drawCircle(dot, _stroke * 0.45, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(_GaugePainter oldDelegate) =>
      oldDelegate.sweep != sweep || oldDelegate.zoneColor != zoneColor;
}
