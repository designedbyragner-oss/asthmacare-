import 'package:flutter/material.dart';

import 'package:asthma_care/core/theme/app_palette.dart';

/// ─────────────────────────────────────────────────────────────
/// نبض — نظام الهوية البصرية لـ AsthmaCare (متعدد الستايلات).
/// المرساة: بنفسجي أيقونة التطبيق (مربع ليلكي بخط نبض أبيض) —
/// ثابت عبر كل الستايلات. ما يتبدل: الكانفس وغراء البنية
/// (زجاج مصنفر أم أسطح صلبة) — انظر app_palette.dart.
/// الخطوط: Cairo صوت العرض (الأرقام والعناوين) — Tajawal صوت المتن.
/// القاعدة الذهبية: الضباب للأسطح الكبيرة فقط (تجميعة/كبسولة/زر رأس) —
/// لا ضباب متداخل، والبلاطات الصغيرة قروش فوق الزجاج لا زجاجًا آخر.
/// ─────────────────────────────────────────────────────────────
///
/// Aurora واجهة ديناميكية: كل لون يُقرأ من اللوحة النشطة لحظة البناء —
/// لذا لا يجوز استخدام هذه الرموز داخل تعابير `const` (المقاسات ثابتة
/// باستثناءها). إعادة الرسم عند تبديل الستايل مضمونة بمفتاح إعادة
/// التركيب في MainShell وثيم MaterialApp من themeStyleProvider.
class Aurora {
  Aurora._();

  /// اللوحة النشطة حاليًا — تتبدل من «الإعدادات ← ستايل التطبيق».
  static AppPalette get current => ThemeCatalog.current;

  /// غراء البنية: زجاج مصنفر أم أسطح صلبة — يتبع الستايل النشط.
  static bool get isGlass => current.isGlass;

  // ── الطبقات (كانفس كل ستايل) ──
  static Color get bgHigh => current.bgHigh;
  static Color get bgDeep => current.bgDeep;
  static Color get surface => current.surface;
  static Color get surfaceHi => current.surfaceHi;
  static Color get glowTint => current.glowTint;

  // ── الزجاج (زجاج نبض) — حشوات وحدود فوق الخلفية الحية ──
  static Color get glassFill => current.glassFill;
  static Color get glassFillStrong => current.glassFillStrong;
  static Color get glassFillSoft => current.glassFillSoft;
  static Color get glassBorder => current.glassBorder;
  static Color get glassSheenTop => current.glassSheenTop;
  static Color get glassSheenBottom => current.glassSheenBottom;
  static Color get warm => current.warm;
  static Color get warmSoft => current.warmSoft;

  // ── الخطوط الشعرية (بنية لا ظلال — حبر بنفسجي شفاف) ──
  static Color get hairline => current.hairline;
  static Color get hairlineStrong => current.hairlineStrong;

  // ── النصوص ──
  static Color get textPrimary => current.textPrimary;
  static Color get textSecondary => current.textSecondary;
  static Color get textFaint => current.textFaint;

  // ── العلامة: بنفسجي الأيقونة — لون الفعل ──
  static Color get brand => current.brand;
  static Color get brandDeep => current.brandDeep;
  static Color get brandSoft => current.brandSoft;
  static Color get navInk => current.navInk;

  // ── الألوان الوظيفية (كل مؤشر يملك لونه) ──
  static Color get oxygen => current.oxygen;
  static Color get oxygenSoft => current.oxygenSoft;
  static Color get heart => current.heart;
  static Color get heartSoft => current.heartSoft;
  static Color get airflow => current.airflow;
  static Color get airflowSoft => current.airflowSoft;
  static Color get environment => current.environment;
  static Color get environmentSoft => current.environmentSoft;
  static Color get danger => current.danger;
  static Color get dangerSoft => current.dangerSoft;

  // درجات حبر داكنة بنفس العائلة — للنصوص الصغيرة فوق الخلفيات الفاتحة
  // (اللوان الوظيفية الكاملة تبقى للأرقام الكبيرة والنقاط والحدود)
  static Color get oxygenInk => current.oxygenInk;
  static Color get environmentInk => current.environmentInk;
  static Color get dangerInk => current.dangerInk;

  // ── عناصر البيانات على الأسطح الفاتحة ──
  static Color get ringTrack => current.ringTrack;
  static Color get chartGrid => current.chartGrid;

  // محتوى على الحبر الداكن (كبسولة التنقل) — رموز ثابتة لا ألوان عابرة
  static Color get navIdleIcon => current.navIdleIcon;
  static Color get navIdleText => current.navIdleText;

  // ── المقاسات — بنية ثابتة عبر الستايلات (تصلح للـ const) ──
  static const double rHero = 28; // مناطق البطل
  static const double rGroup = 20; // التجميعات
  static const double rTile = 12; // البلاطات والأزرار الصغيرة
  static const double rPill = 999; // الكبسولات (أزرار، شارات، تنقل)
  static const double hPad = 20; // حاشية الشاشة

  // ظل البطل الوحيد (لا ظلال على البلاطات الداخلية — البنية تكفي)
  static List<BoxShadow> heroGlow(Color accent) => [
        BoxShadow(color: accent.withValues(alpha: 0.22), blurRadius: 44, spreadRadius: -6),
      ];

  // ظل السطح العائم — توقيع البطاقات (واسع ناعم منخفض العتامة)
  static List<BoxShadow> get cardShadow => current.cardShadow;

  // ظل الزجاج — بنفسجي العلامة، أرقّ وأعلى من ظل البطاقات الصلب
  static List<BoxShadow> get glassShadow => current.glassShadow;

  // ظل كبسولة التنقل — أعمق قليلًا لأن الحبر أغمق
  static List<BoxShadow> get navShadow => current.navShadow;
}

/// أنماط النص — عائلتان بدورين واضحين:
/// Cairo للعرض (الأرقام البطولية والعناوين — هندسي واثق)
/// وTajawal للمتن (إنساني هادئ وسهل على العين).
/// التباين الضخم بين الأرقام البطولية والنص الصغير هو شخصية النظام.
class AuroraText {
  AuroraText._();

  static const String family = 'Tajawal';
  static const String familyDisplay = 'Cairo';

  // الأرقام البطولية — العنصر الأبرز بعد الحلقة (Cairo الثقيل يمنحها ثقلًا).
  // الارتفاع 1.06 يمنع قص تشكيل Cairo على العناوين العربية دون أن يمس الأرقام.
  static TextStyle display(double size, {Color? color}) => TextStyle(
        fontFamily: familyDisplay,
        fontSize: size,
        height: 1.06,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: color ?? Aurora.textPrimary,
      );

  static TextStyle title(BuildContext c) => TextStyle(
        fontFamily: familyDisplay,
        fontSize: 18,
        height: 1.35,
        fontWeight: FontWeight.w700,
        color: Aurora.textPrimary,
      );

  static TextStyle section(BuildContext c) => TextStyle(
        fontFamily: familyDisplay,
        fontSize: 15,
        height: 1.4,
        fontWeight: FontWeight.w600,
        color: Aurora.textPrimary,
      );

  static TextStyle body(BuildContext c) => TextStyle(
        fontFamily: family,
        fontSize: 14,
        height: 1.55,
        fontWeight: FontWeight.w400,
        color: Aurora.textPrimary,
      );

  static TextStyle secondary(BuildContext c) => TextStyle(
        fontFamily: family,
        fontSize: 12.5,
        height: 1.5,
        fontWeight: FontWeight.w400,
        color: Aurora.textSecondary,
      );

  static TextStyle faint(BuildContext c) => TextStyle(
        fontFamily: family,
        fontSize: 11.5,
        height: 1.4,
        fontWeight: FontWeight.w400,
        color: Aurora.textFaint,
      );

  // وحدة القياس بجانب الرقم — Cairo لتجاور الرقم نفس عائلته
  static TextStyle unit(BuildContext c, {Color? color}) => TextStyle(
        fontFamily: familyDisplay,
        fontSize: 12,
        height: 1.2,
        fontWeight: FontWeight.w600,
        color: color ?? Aurora.textFaint,
      );
}

class AppTheme {
  AppTheme._();

  /// يبني ThemeData من لوحة محددة — يُستهلك من app.dart بستايل المنتقي.
  static ThemeData from(AppPalette p) {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: p.bgDeep,
      fontFamily: AuroraText.family,
    );
    return base.copyWith(
      colorScheme: base.colorScheme.copyWith(
        primary: p.brand,
        secondary: p.oxygen,
        error: p.danger,
        surface: p.surface,
        onSurface: p.textPrimary,
      ),
      scaffoldBackgroundColor: p.bgDeep,
      splashColor: p.brandDeep.withValues(alpha: 0.05),
      highlightColor: Colors.transparent,
      dividerColor: p.hairline,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: p.textPrimary),
        titleTextStyle: TextStyle(
          fontFamily: AuroraText.familyDisplay,
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: p.textPrimary,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: p.navInk,
        contentTextStyle: const TextStyle(
          fontFamily: AuroraText.family,
          color: Colors.white,
          fontSize: 13.5,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Aurora.rTile),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: p.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Aurora.rGroup),
        ),
        titleTextStyle: TextStyle(
          fontFamily: AuroraText.familyDisplay,
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: p.textPrimary,
        ),
        contentTextStyle: TextStyle(
          fontFamily: AuroraText.family,
          fontSize: 14,
          height: 1.6,
          color: p.textPrimary,
        ),
      ),
      textTheme: base.textTheme.apply(
        fontFamily: AuroraText.family,
        bodyColor: p.textPrimary,
        displayColor: p.textPrimary,
      ),
    );
  }

  /// الثيم من اللوحة النشطة — التوافق مع الاستخدام القديم والاختبارات.
  static ThemeData get light => from(ThemeCatalog.current);
}

/// ─── قاعدة ذهبية أخيرة ───
/// Boldness واحدة لكل شاشة: هالة التنفس حول عنصر البطل.
/// كل ما حولها هادئ ومنضبط — العمق بالظل الناعم والبنية بالخطوط الشعرية.
/// (ألوان الحالة تُشتق مباشرة في الواجهة: normal→oxygen، attention→environment،
/// highRisk→danger من نماذج المجال.)
