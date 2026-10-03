import 'package:flutter/material.dart';

/// ─────────────────────────────────────────────────────────────
/// نبض — نظام الهوية البصرية لـ AsthmaCare (الإصدار الرابع).
/// المرساة: بنفسجي أيقونة التطبيق (مربع ليلكي بخط نبض أبيض) —
/// بنفسجي مسطّح وبنيوي، لا تدرجات بنفسجية زخرفية.
/// الاتجاه: كانفس فاتح بهمة بنفسجية هادئة، أسطح بيضاء عائمة بظل
/// ناعم، وحبر بنفسجي عميق للفعل الأساسي.
/// الخطوط: Cairo صوت العرض (الأرقام والعناوين) — Tajawal صوت المتن.
/// ألوان وظيفية: كل مؤشر يملك لونه عبر التطبيق كله.
/// القاعدة الذهبية: التدرجات لا تُستخدم زخرفةً — فقط حيث تشفّر البيانات
/// (حلقة القياس، امتلاء المخطط). والجرأة الوحيدة: هالة التنفس الحية.
/// ─────────────────────────────────────────────────────────────
class Aurora {
  Aurora._();

  // ── الطبقات (كانفس فاتح بهمة بنفسجية — لا رمادي مطبع محايد) ──
  static const Color bgHigh = Color(0xFFF8F8FC); // بداية التدرج (أعلى)
  static const Color bgDeep = Color(0xFFEEF0F9); // القاعدة
  static const Color surface = Color(0xFFFFFFFF); // التجميعات
  static const Color surfaceHi = Color(0xFFF4F5FB); // البلاطات داخل التجميعة
  static const Color glowTint = Color(0xFF8F7FE8); // توهج العلامة

  // ── الخطوط الشعرية (بنية لا ظلال — حبر بنفسجي شفاف) ──
  static const Color hairline = Color(0x12201D3D); // 7%
  static const Color hairlineStrong = Color(0x24201D3D); // 14%

  // ── النصوص ──
  static const Color textPrimary = Color(0xFF201D3D);
  static const Color textSecondary = Color(0xFF5D5B79);
  static const Color textFaint = Color(0xFF76748F); // ≥4.5:1 على الأبيض

  // ── العلامة: بنفسجي الأيقونة — لون الفعل ──
  static const Color brand = Color(0xFF6558CE);
  static const Color brandDeep = Color(0xFF473AAE);
  static const Color brandSoft = Color(0x1A6558CE); // 10%
  static const Color navInk = Color(0xFF2B2464); // كبسولة التنقل — حبر عميق

  // ── الألوان الوظيفية (كل مؤشر يملك لونه) ──
  static const Color oxygen = Color(0xFF17A274); // الأكسجين / جيد
  static const Color oxygenSoft = Color(0x1A17A274);
  static const Color heart = Color(0xFFE4506C); // النبض
  static const Color heartSoft = Color(0x1AE4506C);
  static const Color airflow = Color(0xFF4776E0); // التنفس / الهواء المتحرك
  static const Color airflowSoft = Color(0x1A4776E0);
  static const Color environment = Color(0xFFDB6B2A); // البيئة / انتباه
  static const Color environmentSoft = Color(0x1ADB6B2A);
  static const Color danger = Color(0xFFD8434F); // متطلب متابعة
  static const Color dangerSoft = Color(0x1AD8434F);

  // درجات حبر داكنة بنفس العائلة — للنصوص الصغيرة فوق الخلفيات الفاتحة
  // (اللوان الوظيفية الكاملة تبقى للأرقام الكبيرة والنقاط والحدود)
  static const Color oxygenInk = Color(0xFF0F7A57);
  static const Color environmentInk = Color(0xFFA54F1C);
  static const Color dangerInk = Color(0xFFA93340);

  // ── عناصر البيانات على الأسطح الفاتحة ──
  static const Color ringTrack = Color(0x1A473AAE); // مسار الحلقة الخلفي
  static const Color chartGrid = Color(0x14201D3D); // شبكة المخطط المنقطة

  // ── المقاسات ──
  static const double rHero = 28; // مناطق البطل
  static const double rGroup = 20; // التجميعات
  static const double rTile = 12; // البلاطات والأزرار الصغيرة
  static const double rPill = 999; // الكبسولات (أزرار، شارات، تنقل)
  static const double hPad = 20; // حاشية الشاشة

  // ظل البطل الوحيد (لا ظلال على البلاطات الداخلية — البنية تكفي)
  static List<BoxShadow> heroGlow(Color accent) => [
        BoxShadow(color: accent.withValues(alpha: 0.22), blurRadius: 44, spreadRadius: -6),
      ];

  // ظل السطح العائم — توقيع البطاقات البيضاء (واسع ناعم منخفض العتامة)
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x14201D3D), // 8% حبر بنفسجي
      blurRadius: 20,
      offset: Offset(0, 8),
      spreadRadius: -6,
    ),
  ];

  // ظل كبسولة التنقل — أعمق قليلًا لأن الحبر أغمق
  static const List<BoxShadow> navShadow = [
    BoxShadow(
      color: Color(0x382B2464), // 22% حبر
      blurRadius: 24,
      offset: Offset(0, 10),
      spreadRadius: -6,
    ),
  ];

  // محتوى على الحبر الداكن (كبسولة التنقل) — رموز ثابتة لا ألوان عابرة
  static const Color navIdleIcon = Color(0x73FFFFFF); // 45% أبيض
  static const Color navIdleText = Color(0x99FFFFFF); // 60% أبيض
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

  static TextStyle title(BuildContext c) => const TextStyle(
        fontFamily: familyDisplay,
        fontSize: 18,
        height: 1.35,
        fontWeight: FontWeight.w700,
        color: Aurora.textPrimary,
      );

  static TextStyle section(BuildContext c) => const TextStyle(
        fontFamily: familyDisplay,
        fontSize: 15,
        height: 1.4,
        fontWeight: FontWeight.w600,
        color: Aurora.textPrimary,
      );

  static TextStyle body(BuildContext c) => const TextStyle(
        fontFamily: family,
        fontSize: 14,
        height: 1.55,
        fontWeight: FontWeight.w400,
        color: Aurora.textPrimary,
      );

  static TextStyle secondary(BuildContext c) => const TextStyle(
        fontFamily: family,
        fontSize: 12.5,
        height: 1.5,
        fontWeight: FontWeight.w400,
        color: Aurora.textSecondary,
      );

  static TextStyle faint(BuildContext c) => const TextStyle(
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

  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: Aurora.bgDeep,
      fontFamily: AuroraText.family,
    );
    return base.copyWith(
      colorScheme: base.colorScheme.copyWith(
        primary: Aurora.brand,
        secondary: Aurora.oxygen,
        error: Aurora.danger,
        surface: Aurora.surface,
        onSurface: Aurora.textPrimary,
      ),
      scaffoldBackgroundColor: Aurora.bgDeep,
      splashColor: Aurora.brandDeep.withValues(alpha: 0.05),
      highlightColor: Colors.transparent,
      dividerColor: Aurora.hairline,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Aurora.textPrimary),
        titleTextStyle: TextStyle(
          fontFamily: AuroraText.familyDisplay,
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: Aurora.textPrimary,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: Aurora.navInk,
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
        backgroundColor: Aurora.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Aurora.rGroup),
        ),
        titleTextStyle: const TextStyle(
          fontFamily: AuroraText.familyDisplay,
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: Aurora.textPrimary,
        ),
        contentTextStyle: const TextStyle(
          fontFamily: AuroraText.family,
          fontSize: 14,
          height: 1.6,
          color: Aurora.textPrimary,
        ),
      ),
      textTheme: base.textTheme.apply(
        fontFamily: AuroraText.family,
        bodyColor: Aurora.textPrimary,
        displayColor: Aurora.textPrimary,
      ),
    );
  }
}

/// ─── قاعدة ذهبية أخيرة ───
/// Boldness واحدة لكل شاشة: هالة التنفس حول عنصر البطل.
/// كل ما حولها هادئ ومنضبط — العمق بالظل الناعم والبنية بالخطوط الشعرية.
/// (ألوان الحالة تُشتق مباشرة في الواجهة: normal→oxygen، attention→environment،
/// highRisk→danger من نماذج المجال.)
