import 'package:flutter/material.dart';

import 'package:asthma_care/core/theme/app_theme.dart';

/// خط النبض — توقيع الهوية المأخوذ من أيقونة التطبيق (موجة ECG).
/// يُرسم مرة واحدة عند الظهور ثم يبقى منتهيًا بنقطة متوهجة —
/// لحظة دخول واحدة مدروسة، لا حلقة حركة مستمرة.
class PulseLine extends StatefulWidget {
  final double width;
  final double height;
  final Color? color;
  final double strokeWidth;
  final Duration duration;

  const PulseLine({
    super.key,
    this.width = 220,
    this.height = 40,
    this.color,
    this.strokeWidth = 2.6,
    this.duration = const Duration(milliseconds: 1700),
  });

  @override
  State<PulseLine> createState() => _PulseLineState();
}

class _PulseLineState extends State<PulseLine>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: widget.duration,
  );

  late final CurvedAnimation _curve =
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);

  @override
  void initState() {
    super.initState();
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _curve,
      builder: (context, _) => CustomPaint(
        size: Size(widget.width, widget.height),
        painter: _AnimatedPulsePainter(
          t: _curve.value,
          color: widget.color ?? Aurora.brand,
          strokeWidth: widget.strokeWidth,
        ),
      ),
    );
  }
}

/// موجة PQRST واحدة ممتدة على العرض — إحداثيات معيارية (كسور من
/// العرض والسعة). اتجاه الرسم يسار→يمين ثابت: خط طبي لا يُعكس في RTL.
Path _pulsePath(Size size) {
  final w = size.width;
  final midY = size.height * 0.58;
  final amp = size.height * 0.42;
  const beat = <(double, double)>[
    (0.00, 0.00),
    (0.16, 0.00),
    (0.20, -0.22), // موجة P
    (0.24, 0.00),
    (0.28, 0.00),
    (0.30, 0.18), // Q
    (0.34, -1.00), // R
    (0.38, 0.52), // S
    (0.41, 0.00),
    (0.50, 0.00),
    (0.58, -0.34), // موجة T
    (0.66, 0.00),
    (1.00, 0.00),
  ];
  final path = Path();
  var first = true;
  for (final (fx, fy) in beat) {
    final p = Offset(fx * w, midY + fy * amp);
    if (first) {
      path.moveTo(p.dx, p.dy);
      first = false;
    } else {
      path.lineTo(p.dx, p.dy);
    }
  }
  return path;
}

class _AnimatedPulsePainter extends CustomPainter {
  final double t;
  final Color color;
  final double strokeWidth;

  _AnimatedPulsePainter({
    required this.t,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = _pulsePath(size);
    final metrics = path.computeMetrics().toList();
    if (metrics.isEmpty) return;
    final total = metrics.first.length;
    final drawn = metrics.first.extractPath(0, total * t.clamp(0.0, 1.0));

    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = color;

    // هالة خفيفة تحت الخط — صدى التوهج دون زخرفة
    canvas.drawPath(
      drawn,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth * 2.4
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = color.withValues(alpha: 0.18),
    );
    canvas.drawPath(drawn, line);

    // النقطة المتوهجة عند رأس الرسم — تختفي عند اكتمال الموجة
    if (t < 1.0) {
      final tangent = metrics.first.getTangentForOffset(total * t);
      if (tangent != null) {
        canvas.drawCircle(
          tangent.position,
          strokeWidth * 1.6,
          Paint()..color = color.withValues(alpha: 0.9),
        );
        canvas.drawCircle(
          tangent.position,
          strokeWidth * 3.2,
          Paint()..color = color.withValues(alpha: 0.18),
        );
      }
    }
  }

  @override
  bool shouldRepaint(_AnimatedPulsePainter oldDelegate) =>
      oldDelegate.t != t || oldDelegate.color != color;
}

/// العلامة الثابتة — مربع البنفسجي بخط النبض الأبيض، نداء مباشر لأيقونة التطبيق.
class BrandMark extends StatelessWidget {
  final double size;

  const BrandMark({super.key, this.size = 96});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Aurora.brand,
        borderRadius: BorderRadius.circular(size * 0.28),
        border: Border.all(color: Aurora.hairlineStrong),
        boxShadow: [
          BoxShadow(
            color: Aurora.brand.withValues(alpha: 0.30),
            blurRadius: 30,
            offset: const Offset(0, 10),
            spreadRadius: -4,
          ),
        ],
      ),
      child: CustomPaint(painter: _StaticPulsePainter(color: Colors.white)),
    );
  }
}

class _StaticPulsePainter extends CustomPainter {
  final Color color;
  _StaticPulsePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.075
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = color;
    canvas.save();
    canvas.translate(0, -size.height * 0.08);
    canvas.drawPath(_pulsePath(size), paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_StaticPulsePainter oldDelegate) =>
      oldDelegate.color != color;
}
