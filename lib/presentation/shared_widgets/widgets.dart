/// ─────────────────────────────────────────────────────────────
/// مكتبة الودجات — نبض (متعددة الستايلات).
/// الفلسفة: بنية بالخطوط الشعرية لا ظلال عائمة، تجميعات بدل
/// بطاقات متفرقة، وتدرج لا يظهر إلا داخل عناصر تشفّر البيانات.
/// البنية تتبع اللوحة النشطة: زجاج مصنفر (isGlass) أو أسطح صلبة
/// عائمة — نفس المكوّنات، فرعان للغراء.
/// ─────────────────────────────────────────────────────────────
library;

import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import 'package:asthma_care/core/theme/app_theme.dart';
import 'package:asthma_care/data/models/models.dart';

/// بطاقة زجاجية — ضباب حقيقي فوق الأورورا + ترويق متدرج بلمعة عليا
/// + حد أبيض + ظل بنفسجي. الضباب للأسطح الكبيرة فقط (قاعدة v5).
Widget _glassCard({
  required double radius,
  required Widget child,
  Color? tint,
}) {
  // ألوان التلوين الواردة ناعمة أصلًا (10%) — تُمزج كما هي وإلا صارت الزجاج صلبًا
  final sheenTop = tint == null
      ? Aurora.glassSheenTop
      : Color.alphaBlend(tint, Aurora.glassSheenTop);
  final sheenBottom = tint == null
      ? Aurora.glassSheenBottom
      : Color.alphaBlend(tint, Aurora.glassSheenBottom);
  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(radius),
      boxShadow: Aurora.glassShadow,
    ),
    child: RepaintBoundary(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [sheenTop, sheenBottom],
              ),
              border: Border.all(color: Aurora.glassBorder),
              borderRadius: BorderRadius.circular(radius),
            ),
            child: child,
          ),
        ),
      ),
    ),
  );
}

/// خلفية العمق: تدرج حبري + توهجان خافتان يحددان منطقة البطل بصمت.
class AppBackground extends StatelessWidget {
  final Widget child;
  final bool decorative;

  const AppBackground({super.key, required this.child, this.decorative = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Aurora.bgHigh, Aurora.bgDeep],
          stops: const [0.0, 0.55],
        ),
      ),
      child: Stack(
        children: [
          // بقع الأورورا من اللوحة النشطة — عدد الوصلات ومواضعها لكل ستايل
          if (decorative)
            for (final blob in Aurora.current.bgBlobs)
              Positioned(
                top: blob.top,
                bottom: blob.bottom,
                left: blob.left,
                right: blob.right,
                child: _radial(blob.color, blob.size, blob.opacity),
              ),
          child,
        ],
      ),
    );
  }

  Widget _radial(Color color, double size, double opacity) => IgnorePointer(
    child: Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withValues(alpha: opacity),
            color.withValues(alpha: 0),
          ],
        ),
      ),
    ),
  );
}

/// حاوية التجميعة: سطح أبيض عائم + خط شعري + ظل ناعم واسع —
/// العمق يأتي من الظل والتباين مع الكانفس (توقيع الهوية الفاتحة).
class SectionCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? background;
  final double radius;

  const SectionCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.onTap,
    this.background,
    this.radius = Aurora.rGroup,
  });

  @override
  Widget build(BuildContext context) {
    // المسار الصلب استثنائي (منادي بقيمة background) أو بستايل صلب؛
    // الافتراضي بالستايل الزجاجي زجاج مضبب.
    final useGlass = Aurora.isGlass && background == null;
    if (!useGlass) {
      final solid = Container(
        width: double.infinity,
        padding: padding,
        decoration: BoxDecoration(
          color: background ?? Aurora.surface,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: Aurora.hairline, width: 1),
          boxShadow: Aurora.cardShadow,
        ),
        child: child,
      );
      if (onTap == null) {
        return Padding(padding: margin ?? EdgeInsets.zero, child: solid);
      }
      return Padding(
        padding: margin ?? EdgeInsets.zero,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(radius),
            child: solid,
          ),
        ),
      );
    }
    final glass = _glassCard(
      radius: radius,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(radius),
          child: SizedBox(
            width: double.infinity,
            child: Padding(padding: padding, child: child),
          ),
        ),
      ),
    );
    return Padding(padding: margin ?? EdgeInsets.zero, child: glass);
  }
}

/// فاصل أفقي شعري — لفصل الصفوف داخل التجميعة.
class Hairline extends StatelessWidget {
  final double indent;
  const Hairline({super.key, this.indent = 0});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(start: indent),
      child: Divider(height: 1, thickness: 1, color: Aurora.hairline),
    );
  }
}

/// رأس الشاشة الداخلية — زر دائري زجاجي + عنوان + إجراء.
class ScreenHeader extends StatelessWidget {
  final String title;
  final Widget? action;
  final bool showBack;

  const ScreenHeader({
    super.key,
    required this.title,
    this.action,
    this.showBack = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 6),
      child: Row(
        children: [
          if (showBack)
            _GlassIconButton(
              icon: Icons.arrow_forward_ios_rounded,
              size: 17,
              onTap: () => Navigator.of(context).maybePop(),
            )
          else
            const SizedBox(width: 42),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: AuroraText.title(context),
            ),
          ),
          action ?? const SizedBox(width: 42),
        ],
      ),
    );
  }
}

class _GlassIconButton extends StatelessWidget {
  final IconData icon;
  final double size;
  final VoidCallback onTap;

  const _GlassIconButton({
    required this.icon,
    required this.onTap,
    this.size = 20,
  });

  @override
  Widget build(BuildContext context) {
    // زجاجي: ضباب حقيقي وحشوة زجاج — صلب: سطح أبيض وخط شعري
    final iconButton = Material(
      color: Aurora.isGlass ? Aurora.glassFill : Aurora.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: Aurora.isGlass ? Aurora.glassBorder : Aurora.hairline,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          width: 42,
          height: 42,
          child: Icon(icon, size: size, color: Aurora.textPrimary),
        ),
      ),
    );
    if (!Aurora.isGlass) return iconButton;
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: iconButton,
      ),
    );
  }
}

/// الزر الأساسي: بنفسجي مسطّح بنيوي (لا تدرج زخرفي) + هالة خفيفة.
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final Color? color;
  final Color? textColor;
  final IconData? icon;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.loading = false,
    this.color,
    this.textColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final accent = color ?? Aurora.brand;
    final isBrand = color == null;
    // بنفسجي مسطّح بنيوي في المسارين (قاعدة CONTEXT.md: لا تدرج زخرفي) —
    // الزجاج يضيف حدًا أبيض فقط، والظل هادئ لا هالة.
    final isGlass = Aurora.isGlass;
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            Aurora.rPill,
          ), // كبسولة كاملة — توقيع الهوية
          color: isBrand
              ? Aurora.brand
              : accent.withValues(alpha: isGlass ? 0.14 : 0.12),
          border: isBrand
              ? (isGlass
                  ? Border.all(
                      color: Colors.white.withValues(alpha: 0.35), // حد الزجاج
                    )
                  : null)
              : Border.all(
                  color: accent.withValues(alpha: isGlass ? 0.32 : 0.30),
                ),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: isBrand ? 0.22 : 0.10),
              blurRadius: 18,
              offset: const Offset(0, 8),
              spreadRadius: -6,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: loading ? null : onPressed,
            borderRadius: BorderRadius.circular(Aurora.rPill),
            child: Center(
              child: loading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: textColor ?? (isBrand ? Colors.white : accent),
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (icon != null) ...[
                          Icon(
                            icon,
                            size: 19,
                            color:
                                textColor ?? (isBrand ? Colors.white : accent),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          label,
                          style: TextStyle(
                            fontFamily: AuroraText.familyDisplay,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color:
                                textColor ?? (isBrand ? Colors.white : accent),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

/// رقاقة نقطة — لغة الحالة الموحدة: نقطة صلبة + مصطلح بحبر داكن داخل
/// كبسولة شفافة. بلا توهج حول النقطة (الوضوح يأتي من اللون الدال لا الهالة).
class DotChip extends StatelessWidget {
  final String label;
  final Color color;
  final Color ink;
  final bool compact;

  const DotChip({
    super.key,
    required this.label,
    required this.color,
    required this.ink,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    // زجاجي: حشوة وحد أوضح قليلًا — صلب: همسة أخف (نغمة v4)
    final fillAlpha = Aurora.isGlass ? 0.14 : 0.10;
    final borderAlpha = Aurora.isGlass ? 0.32 : 0.28;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : 13,
        vertical: compact ? 5 : 7,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: fillAlpha),
        borderRadius: BorderRadius.circular(Aurora.rPill),
        border: Border.all(color: color.withValues(alpha: borderAlpha)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 7),
          Text(
            label,
            style: TextStyle(
              fontFamily: AuroraText.family,
              fontSize: compact ? 11.5 : 12.5,
              fontWeight: FontWeight.w700,
              color: ink,
            ),
          ),
        ],
      ),
    );
  }
}

/// شارة حالة — المصطلح المعتمد لكل درجة من درجات الخطر.
class StatusBadge extends StatelessWidget {
  final RiskLevel level;
  final bool compact;

  const StatusBadge({super.key, required this.level, this.compact = false});

  @override
  Widget build(BuildContext context) {
    // درجات الحبر الداكنة للنص الصغير — تباين يمر WCAG فوق الخلفيات الفاتحة
    final (color, ink) = switch (level) {
      RiskLevel.normal => (Aurora.oxygen, Aurora.oxygenInk),
      RiskLevel.attention => (Aurora.environment, Aurora.environmentInk),
      RiskLevel.highRiskPattern => (Aurora.danger, Aurora.dangerInk),
    };
    return DotChip(
      label: level.arLabel,
      color: color,
      ink: ink,
      compact: compact,
    );
  }
}

/// بلاطة أيقونة — سكويرش ملوّن بمقاسات النظام الثلاثة (كانت تُرسم يدويًا
/// بثلاثة مقاسات متقاربة في أربعة أماكن، صارت مكوّنًا واحدًا بمقياس واحد).
enum IconChipSize { small, medium, large }

class IconChip extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color bg;
  final IconChipSize size;

  const IconChip({
    super.key,
    required this.icon,
    required this.color,
    required this.bg,
    this.size = IconChipSize.medium,
  });

  @override
  Widget build(BuildContext context) {
    final (box, tileRadius, iconSize) = switch (size) {
      IconChipSize.small => (30.0, 9.0, 16.0),
      IconChipSize.medium => (34.0, 10.0, 18.0),
      IconChipSize.large => (38.0, 11.0, 19.0),
    };
    return Container(
      width: box,
      height: box,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(tileRadius),
      ),
      child: Icon(icon, size: iconSize, color: color),
    );
  }
}

/// شريحة صغيرة وظيفية — لون دال على حدود شعرية، بلا خلفية صارخة.
/// (كانت منسوخة في ثلاث شاشات ورقاقة مصدر رابعة — صارت مكوّنًا واحدًا.)
class MiniChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  final Color? bg;
  final int maxLines;

  const MiniChip({
    super.key,
    required this.icon,
    required this.text,
    required this.color,
    this.bg,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: bg ?? color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              maxLines: maxLines,
              style: TextStyle(
                fontFamily: AuroraText.family,
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ملاحظة إرشادية بحافة ملوّنة دالة — لغة النصائح نفسها في كل الشاشات
/// (التطبيق عربي-أولًا بـ RTL مثبت، فالحد الفيزيائي الأيمن هو جهة البداية).
class EdgeNote extends StatelessWidget {
  final String text;
  final Color accent;
  final TextStyle? style;

  /// توسيط اختياري عموديًا/أفقيًا — للنصائح داخل ارتفاع ثابت.
  final AlignmentGeometry? alignment;

  const EdgeNote({
    super.key,
    required this.text,
    required this.accent,
    this.style,
    this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    final note = Text(text, style: style ?? AuroraText.body(context));
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      alignment: alignment,
      decoration: BoxDecoration(
        color: Aurora.surfaceHi,
        borderRadius: BorderRadius.circular(Aurora.rTile),
        border: Border(
          right: BorderSide(color: accent.withValues(alpha: 0.55), width: 3),
        ),
      ),
      child: note,
    );
  }
}

/// بلاطة مؤشر داخل تجميعة — سطح علوي + أيقونة سكويرش ملوّنة + رقم بارز.
class MetricCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String label;
  final String value;
  final String unit;
  final String? subLabel;
  final VoidCallback? onTap;

  const MetricCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.label,
    required this.value,
    required this.unit,
    this.subLabel,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // زجاجي: قِشر زجاجي فوق البطاقة بلا ضباب متداخل — صلب: سطح علوي صلب
    return Material(
      color: Aurora.isGlass ? Aurora.glassFillSoft : Aurora.surfaceHi,
      shape: Aurora.isGlass
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Aurora.rTile),
              side: BorderSide(color: Aurora.hairline),
            )
          : RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Aurora.rTile),
            ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Aurora.rTile),
        child: Padding(
          padding: const EdgeInsets.all(13),
          // mainAxisSize.min + فجوة ثابتة بدل Spacer — البلاطة تعيش داخل
          // قابل للتمرير (ارتفاع غير محدود) ولا يجوز أن تمتد بـ flex رأسي.
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconChip(
                    icon: icon,
                    color: iconColor,
                    bg: iconBg,
                    size: IconChipSize.small,
                  ),
                  const Spacer(),
                  if (subLabel != null)
                    Flexible(
                      child: Text(
                        subLabel!,
                        overflow: TextOverflow.ellipsis,
                        style: AuroraText.faint(
                          context,
                        ).copyWith(fontSize: 10.5),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: AuroraText.faint(context).copyWith(fontSize: 11),
              ),
              const SizedBox(height: 2),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(value, style: AuroraText.display(22)),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      unit,
                      overflow: TextOverflow.ellipsis,
                      style: AuroraText.unit(context),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// مفتاح تبويب نحيل — مقطع مختار يرتفع كسطح أبيض فوق مسار رمادي-منت.
class TabPills extends StatelessWidget {
  final List<String> options;
  final int selected;
  final ValueChanged<int> onChanged;

  const TabPills({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        // زجاجي: مسار زجاجي وقِشر نشط — صلب: مسار صلب وسطح أبيض مرتفع
        color: Aurora.isGlass ? Aurora.glassFillSoft : Aurora.surfaceHi,
        borderRadius: BorderRadius.circular(Aurora.rTile),
        border: Border.all(color: Aurora.hairline),
      ),
      child: Row(
        children: [
          for (var i = 0; i < options.length; i++)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onChanged(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: i == selected
                        ? (Aurora.isGlass
                            ? Aurora.glassFillStrong
                            : Aurora.surface)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(Aurora.rTile - 3),
                    boxShadow: i == selected ? Aurora.cardShadow : null,
                  ),
                  child: Text(
                    options[i],
                    style: TextStyle(
                      fontFamily: AuroraText.family,
                      fontSize: 12.5,
                      fontWeight: i == selected
                          ? FontWeight.w700
                          : FontWeight.w400,
                      color: i == selected
                          ? Aurora.brandDeep
                          : Aurora.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// صف إعداد/ملف — سطح التجميعة + أيقونة + سهم.
class InfoRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final VoidCallback? onTap;
  final Widget? trailing;

  const InfoRow({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.label,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Aurora.rTile),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 13),
          child: Row(
            children: [
              IconChip(
                icon: icon,
                color: iconColor,
                bg: iconColor.withValues(alpha: 0.13),
                size: IconChipSize.medium,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: AuroraText.body(
                    context,
                  ).copyWith(fontWeight: FontWeight.w500),
                ),
              ),
              trailing ??
                  Icon(
                    Icons.chevron_left_rounded,
                    size: 22,
                    color: Aurora.textFaint,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

/// بلاطة تنبيه — حافة دالة بلون الدرجة (شريط 3px) بدل خلفية ملونة صارخة.
class AlertTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color background;
  final String title;
  final String timeLabel;
  final String? body;
  final VoidCallback? onTap;

  const AlertTile({
    super.key,
    required this.icon,
    required this.color,
    required this.background,
    required this.title,
    required this.timeLabel,
    this.body,
    this.onTap,
  });

  static (IconData, Color, Color) styleFor(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.highRisk:
        return (Icons.monitor_heart_rounded, Aurora.danger, Aurora.dangerSoft);
      case AlertSeverity.attention:
        return (
          Icons.error_outline_rounded,
          Aurora.environment,
          Aurora.environmentSoft,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    // محتوى البلاطة واحد — يتغير فقط الغراء حوله حسب الستايل
    final content = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // الحافة الدالة — شريط صلب بلا توهج (الدلالة من اللون لا الهالة)
        Container(
          width: 3,
          height: 44,
          margin: const EdgeInsetsDirectional.only(end: 12, start: 0),
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadiusDirectional.horizontal(
              start: Radius.circular(3),
              end: Radius.circular(3),
            ),
          ),
        ),
        IconChip(
          icon: icon,
          color: color,
          bg: color.withValues(alpha: 0.12),
          size: IconChipSize.large,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AuroraText.section(
                  context,
                ).copyWith(fontSize: 13.5, color: Aurora.textPrimary),
              ),
              const SizedBox(height: 3),
              Text(timeLabel, style: AuroraText.faint(context)),
              if (body != null && body!.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  body!,
                  style: AuroraText.secondary(context),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 6),
        Icon(
          Icons.chevron_left_rounded,
          size: 20,
          color: Aurora.textFaint,
        ),
      ],
    );
    if (!Aurora.isGlass) {
      // صلب: سطح الدرجة الصلب بخط شعري (نغمة v4)
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Material(
          color: background,
          borderRadius: BorderRadius.circular(Aurora.rGroup),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(Aurora.rGroup),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Aurora.rGroup),
                border: Border.all(color: Aurora.hairline),
              ),
              padding: const EdgeInsetsDirectional.only(
                end: 14,
                top: 14,
                bottom: 14,
              ),
              child: content,
            ),
          ),
        ),
      );
    }
    // زجاجي: زجاج مروّق بتلوين الدرجة المخفّف — الحافة والرقاقة تحملان
    // الدلالة، والخلفية تبقى هادئة حتى لا تُغرق لائحة من عدة بلاطات
    final tint = background.withValues(alpha: background.a * 0.55);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: _glassCard(
        radius: Aurora.rGroup,
        tint: tint,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(Aurora.rGroup),
            child: Padding(
              padding: const EdgeInsetsDirectional.only(
                end: 14,
                top: 14,
                bottom: 14,
              ),
              child: content,
            ),
          ),
        ),
      ),
    );
  }
}

/// نقطة حية نابضة — مؤشر البث الفوري (حركة تجيب عن حالة الاتصال).
class LiveDot extends StatelessWidget {
  final Color color;
  final double size;

  const LiveDot({super.key, required this.color, this.size = 8});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeOut,
      builder: (context, t, child) {
        // نبضة واحدة عند الرسم تكفي — لا حلقة مستمرة مزعجة
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.55 + 0.2 * (1 - t)),
                blurRadius: 6 + 6 * (1 - t),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// رقم متحرك — ينبض من القيمة السابقة إلى الجديدة (يجيب وصول البيانات).
class AnimatedNumber extends StatelessWidget {
  final String value;
  final double fontSize;
  final Color? color;

  const AnimatedNumber({
    super.key,
    required this.value,
    this.fontSize = 22,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
      builder: (context, t, child) {
        return Opacity(
          opacity: 0.4 + 0.6 * t,
          child: Transform.translate(
            offset: Offset(0, 4 * (1 - t)),
            child: child,
          ),
        );
      },
      child: Text(
        value,
        key: ValueKey(value),
        style: AuroraText.display(fontSize, color: color),
      ),
    );
  }
}
