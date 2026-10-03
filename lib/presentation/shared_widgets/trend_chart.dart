/// ─────────────────────────────────────────────────────────────
/// المخطط الخطي — Aurora v2 (fl_chart 0.69.x).
/// لغة المخطط: خط متوهج مزدوج + امتلاء متدرج يشفّر البيانات + شبكة منقطة
/// خافتة + نقطة هالة عند آخر قراءة فقط. الرسم يبقى LTR داخل واجهة RTL.
/// ─────────────────────────────────────────────────────────────
library;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'package:asthma_care/core/theme/app_theme.dart';

class TrendChart extends StatelessWidget {
  final List<FlSpot> spots;
  final Color color;
  final double minY;
  final double maxY;
  final double yInterval;
  final Map<int, String> xLabels;
  final String? emptyLabel;
  final double height;

  const TrendChart({
    super.key,
    required this.spots,
    required this.color,
    required this.minY,
    required this.maxY,
    required this.yInterval,
    required this.xLabels,
    this.emptyLabel,
    this.height = 190,
  });

  @override
  Widget build(BuildContext context) {
    if (spots.length < 2) {
      return SizedBox(
        height: height,
        child: Center(
          child: Text(
            emptyLabel ?? 'لا توجد بيانات كافية بعد',
            style: AuroraText.secondary(context),
          ),
        ),
      );
    }

    return SizedBox(
      height: height,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: LineChart(
          LineChartData(
            minX: spots.first.x,
            maxX: spots.last.x,
            minY: minY,
            maxY: maxY,
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: yInterval,
              getDrawingHorizontalLine: (v) => FlLine(
                color: Aurora.chartGrid,
                strokeWidth: 1,
                dashArray: [3, 5],
              ),
            ),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 32,
                  interval: yInterval,
                  getTitlesWidget: (v, meta) => Text(
                    v.toStringAsFixed(0),
                    style: TextStyle(
                      fontFamily: AuroraText.family,
                      fontSize: 10,
                      color: Aurora.textFaint,
                    ),
                  ),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 24,
                  interval: (spots.length / 6).clamp(1, double.infinity),
                  getTitlesWidget: (v, meta) {
                    final label = xLabels[v.toInt()];
                    if (label == null) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Text(
                        label,
                        style: TextStyle(
                          fontFamily: AuroraText.family,
                          fontSize: 10,
                          color: Aurora.textFaint,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipColor: (spot) => Aurora.surfaceHi,
                getTooltipItems: (spots) => spots
                    .map((s) => LineTooltipItem(
                          s.y.toStringAsFixed(0),
                          TextStyle(
                            fontFamily: AuroraText.family,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: color,
                          ),
                        ))
                    .toList(),
              ),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                curveSmoothness: 0.3,
                preventCurveOverShooting: true,
                barWidth: 2.4,
                color: color,
                // هالة تحت الخط — توهج وظيفي (يبرز مسار البيانات)
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      color.withValues(alpha: 0.22),
                      color.withValues(alpha: 0.0),
                    ],
                  ),
                ),
                dotData: FlDotData(
                  show: true,
                  // نقطة واحدة فقط: آخر قراءة — بهالة
                  getDotPainter: (spot, percent, bar, index) {
                    final isLast = index == spots.length - 1;
                    return FlDotCirclePainter(
                      radius: isLast ? 4.5 : 0,
                      color: isLast ? color : Colors.transparent,
                      strokeWidth: isLast ? 0 : 0,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
