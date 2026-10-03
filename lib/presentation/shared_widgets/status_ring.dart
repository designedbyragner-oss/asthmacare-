/// ─────────────────────────────────────────────────────────────
/// حلقة الحالة — العنصر البطل للهوية.
/// التوقيع البصري الوحيد المتعمد: هالة «التنفس» حول الحلقة — تتوسع وتتقلص
/// على إيقاع 4 ثوانٍ (معدل تنفس هادئ). الحركة هنا تحكي فكرة المنتج:
/// جهاز يراقب نَفَسك — لا زخرفة.
/// ─────────────────────────────────────────────────────────────
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:asthma_care/core/theme/app_theme.dart';

class StatusRing extends StatelessWidget {
  final double value; // 0–100
  final Color color;
  final IconData icon;
  final String valueLabel;
  final String label;
  final double size;
  final Color? iconBg;
  final bool breathe;

  const StatusRing({
    super.key,
    required this.value,
    required this.color,
    required this.icon,
    required this.valueLabel,
    required this.label,
    this.size = 150,
    this.iconBg,
    this.breathe = true,
  });

  @override
  Widget build(BuildContext context) {
    final clamped = value.clamp(0.0, 100.0);
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // هالة التنفس — العنصر الحي
          if (breathe) _BreathingHalo(color: color, size: size),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: clamped),
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeOutCubic,
            builder: (context, animated, child) => CustomPaint(
              size: Size.square(size),
              painter: _RingPainter(progress: animated / 100, color: color),
            ),
          ),
          child,
        ],
      ),
    );
  }

  /// المحتوى الداخلي محصور هندسيًا داخل الحلقة: القيمة عبر FittedBox داخل
  /// عرض وترٍ واسع، والنص السفلي يلتفّ على سطرين بمقاسه الكامل داخل عرض
  /// وتر موضعِه (FittedBox شبكة أمان عند تكبير خط النظام فقط) — فلا يخرج
  /// نص عن الحلقة ولا يتقلص بلا داعٍ (اختبار: status_ring_fit_test.dart).
  Widget get child => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size * 0.20,
            height: size * 0.20,
            decoration: BoxDecoration(
                color: iconBg ?? Aurora.oxygenSoft, shape: BoxShape.circle),
            child: Icon(icon, size: size * 0.13, color: color),
          ),
          SizedBox(height: size * 0.025),
          SizedBox(
            width: size * 0.76,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                valueLabel,
                style: AuroraText.display(size > 130 ? 40 : 30),
              ),
            ),
          ),
          SizedBox(height: size * 0.009),
          _RingLabel(
            text: label,
            boxWidth: size * 0.60,
            boxHeight: size * 0.20,
            fontFamily: AuroraText.family,
          ),
        ],
      );
}

/// تسمية أسفل الحلقة: تلتفّ على سطرين داخل عرض الوتر بمقاسها الكامل،
/// ولا تُقلَّص إلا إذا تجاوز ارتفاعها الصندوق (تكبير خط النظام).
/// FittedBox وحدها لا تُلزم النص بالالتفاف (قياس بلا حدود) — الصندوق
/// الداخلي هو ما يفرض عرض الالتفاف قبل القياس.
class _RingLabel extends StatelessWidget {
  final String text;
  final double boxWidth;
  final double boxHeight;
  final String fontFamily;

  const _RingLabel({
    required this.text,
    required this.boxWidth,
    required this.boxHeight,
    required this.fontFamily,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: boxWidth,
      height: boxHeight,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: SizedBox(
          width: boxWidth,
          child: Text(
            text,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: fontFamily,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: Aurora.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

/// الهالة الحية: دورة تنفس كاملة كل 4 ثوانٍ — شهيق/زفير بنعومة easeInOut.
class _BreathingHalo extends StatefulWidget {
  final Color color;
  final double size;

  const _BreathingHalo({required this.color, required this.size});

  @override
  State<_BreathingHalo> createState() => _BreathingHaloState();
}

class _BreathingHaloState extends State<_BreathingHalo>
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
        final t = _curve.value; // 0..1 (زفير..شهيق)
        final scale = 1.06 + 0.10 * t;
        final opacity = 0.10 + 0.10 * t;
        return Transform.scale(
          scale: scale,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  widget.color.withValues(alpha: 0),
                  widget.color.withValues(alpha: 0),
                  widget.color.withValues(alpha: opacity),
                ],
                stops: const [0.0, 0.72, 1.0],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;

  _RingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 9;
    const strokeWidth = 9.0;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // المسار الخلفي — شبه محسوس على الكانفس الفاتح
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = Aurora.ringTrack;
    canvas.drawArc(rect, 0, math.pi * 2, false, track);

    // قوس التقدم — تدرج يبدأ شفافًا من الخلف ليحس القوس "منبثقًا"
    final sweep = math.pi * 2 * progress;
    if (sweep > 0.02) {
      final progressPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..shader = SweepGradient(
          startAngle: -math.pi / 2,
          endAngle: 3 * math.pi / 2,
          colors: [
            color.withValues(alpha: 0.35),
            color,
          ],
          transform: const GradientRotation(-math.pi / 2),
        ).createShader(rect);
      canvas.drawArc(rect, -math.pi / 2, sweep, false, progressPaint);

      // نقطة النهاية المتوهجة — تتوهج مع وصول القوس
      final angle = -math.pi / 2 + sweep;
      final dotCenter = center + Offset(math.cos(angle), math.sin(angle)) * radius;
      final halo = Paint()
        ..color = color.withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawCircle(dotCenter, strokeWidth * 0.9, halo);
      canvas.drawCircle(dotCenter, strokeWidth * 0.45, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
