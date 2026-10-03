import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// ─────────────────────────────────────────────────────────────
/// لوحات ستايل «نبض» — نظام متعدد الستايلات لـ AsthmaCare.
/// الهوية الثابتة عبر كل الستايلات (لا تُستبدل أبدًا):
/// بنفسجي العلامة (#6558CE) · Cairo للعرض وTajawal للمتن ·
/// الألوان الوظيفية (كل مؤشر يملك لونه) · حبر النصوص الداكن.
/// ما يتفاوت بين الستايلات: الكانفس (التدرج والبقع الحية)،
/// وغراء البنية (زجاج مصنفر أم أسطح صلبة عائمة).
/// الالتزام: كانفس فاتح دائمًا — لا وضع داكن (ملف الهوية CONTEXT.md).
/// ─────────────────────────────────────────────────────────────

/// بقعة أورورا حية على الكانفس — موضعها وحجمها وشفافيتها لكل ستايل.
class BgBlob {
  final Color color;
  final double size;
  final double opacity;
  final double? top;
  final double? bottom;
  final double? left;
  final double? right;

  const BgBlob({
    required this.color,
    required this.size,
    required this.opacity,
    this.top,
    this.bottom,
    this.left,
    this.right,
  });
}

/// عقد اللوحة: قيم مشتركة للهوية + ما يتجاوزه كل ستايل من كانفس وبنية.
abstract class AppPalette {
  const AppPalette();

  // ── الهوية التعريفية ──
  String get id;
  String get label;
  String get tag; // «الحالي» / «السابق» / «جديد»
  String get description;
  bool get isGlass; // زجاج مصنفر أم أسطح صلبة

  // ── الكانفس (ما يتميز به كل ستايل) ──
  Color get bgHigh;
  Color get bgDeep;
  Color get glowTint;
  List<BgBlob> get bgBlobs;

  /// ألوان شريط النظام — شريط التنقل السفلي شفاف: الجسم يمتد خلفه
  /// فلا طبقة صلبة منفصلة أسفل الشاشة. أيقونات النظام داكنة (كانفس فاتح).
  SystemUiOverlayStyle get overlayStyle => const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarContrastEnforced: false,
      );

  // ── الأسطح والحبر — هوية ثابتة عبر الستايلات ──
  Color get surface => const Color(0xFFFFFFFF);
  Color get surfaceHi => const Color(0xFFF4F5FB);
  Color get warm => const Color(0xFFF2A65E);
  Color get warmSoft => const Color(0x2EF2A65E);

  // الزجاج (يُستهلك في مسار الزجاج فقط)
  Color get glassFill => const Color(0xA6FFFFFF);
  Color get glassFillStrong => const Color(0xC7FFFFFF);
  Color get glassFillSoft => const Color(0x59FFFFFF);
  Color get glassBorder => const Color(0x8CFFFFFF);
  Color get glassSheenTop => const Color(0xB4FFFFFF);
  Color get glassSheenBottom => const Color(0x82FFFFFF);

  // الخطوط الشعرية
  Color get hairline => const Color(0x12201D3D);
  Color get hairlineStrong => const Color(0x24201D3D);

  // النصوص
  Color get textPrimary => const Color(0xFF201D3D);
  Color get textSecondary => const Color(0xFF5D5B79);
  Color get textFaint => const Color(0xFF76748F);

  // العلامة: بنفسجي الأيقونة — لون الفعل
  Color get brand => const Color(0xFF6558CE);
  Color get brandDeep => const Color(0xFF473AAE);
  Color get brandSoft => const Color(0x1A6558CE);
  Color get navInk => const Color(0xFF2B2464);

  // الألوان الوظيفية (معنى ثابت عبر التطبيق كله)
  Color get oxygen => const Color(0xFF17A274);
  Color get oxygenSoft => const Color(0x1A17A274);
  Color get heart => const Color(0xFFE4506C);
  Color get heartSoft => const Color(0x1AE4506C);
  Color get airflow => const Color(0xFF4776E0);
  Color get airflowSoft => const Color(0x1A4776E0);
  Color get environment => const Color(0xFFDB6B2A);
  Color get environmentSoft => const Color(0x1ADB6B2A);
  Color get danger => const Color(0xFFD8434F);
  Color get dangerSoft => const Color(0x1AD8434F);

  Color get oxygenInk => const Color(0xFF0F7A57);
  Color get environmentInk => const Color(0xFFA54F1C);
  Color get dangerInk => const Color(0xFFA93340);

  Color get ringTrack => const Color(0x1A473AAE);
  Color get chartGrid => const Color(0x14201D3D);

  Color get navIdleIcon => const Color(0x73FFFFFF);
  Color get navIdleText => const Color(0x99FFFFFF);

  // الظلال
  List<BoxShadow> get cardShadow => const [
        BoxShadow(
          color: Color(0x14201D3D),
          blurRadius: 20,
          offset: Offset(0, 8),
          spreadRadius: -6,
        ),
      ];

  List<BoxShadow> get glassShadow => const [
        BoxShadow(
          color: Color(0x2E6558CE),
          blurRadius: 28,
          offset: Offset(0, 10),
          spreadRadius: -8,
        ),
      ];

  List<BoxShadow> get navShadow => const [
        BoxShadow(
          color: Color(0x382B2464),
          blurRadius: 24,
          offset: Offset(0, 10),
          spreadRadius: -6,
        ),
      ];
}

/// ── زجاج نبض — الإصدار الخامس (الحالي) ──
/// كانفس أورورا غني + زجاج مصنفر حقيقي للأسطح الكبيرة.
class GlassPulsePalette extends AppPalette {
  const GlassPulsePalette();

  @override
  final String id = 'glass';
  @override
  final String label = 'زجاج نبض';
  @override
  final String tag = 'الحالي';
  @override
  final String description = 'زجاج مصنفر فوق كانفس أورورا حي — الإصدار الخامس';
  @override
  final bool isGlass = true;

  @override
  final Color bgHigh = const Color(0xFFF5F6FD);
  @override
  final Color bgDeep = const Color(0xFFE9ECF8);
  @override
  final Color glowTint = const Color(0xFF8F7FE8);

  @override
  final List<BgBlob> bgBlobs = const [
    BgBlob(color: Color(0xFF8F7FE8), size: 380, opacity: 0.52, top: -140, right: -100),
    BgBlob(color: Color(0xFF4776E0), size: 300, opacity: 0.34, top: -60, left: -110),
    BgBlob(color: Color(0xFF17A274), size: 320, opacity: 0.30, bottom: -140, right: -90),
    BgBlob(color: Color(0xFFF2A65E), size: 240, opacity: 0.26, bottom: -100, left: -90),
  ];
}

/// ── نبض صلب — الإصدار الرابع (السابق، مستعاد من الملفات المحفوظة) ──
/// بنفسجي مسطّح بنيوي، أسطح بيضاء عائمة، لا زجاج ولا تدرجات زخرفية.
class SolidPulsePalette extends AppPalette {
  const SolidPulsePalette();

  @override
  final String id = 'solid';
  @override
  final String label = 'نبض صلب';
  @override
  final String tag = 'السابق';
  @override
  final String description = 'بنفسجي مسطّح وأسطح بيضاء عائمة — الإصدار الرابع';
  @override
  final bool isGlass = false;

  @override
  final Color bgHigh = const Color(0xFFF8F8FC);
  @override
  final Color bgDeep = const Color(0xFFEEF0F9);
  @override
  final Color glowTint = const Color(0xFF8F7FE8);

  @override
  final List<BgBlob> bgBlobs = const [
    BgBlob(color: Color(0xFF8F7FE8), size: 320, opacity: 0.10, top: -140, right: -100),
    BgBlob(color: Color(0xFF4776E0), size: 340, opacity: 0.05, bottom: -180, left: -120),
  ];
}

/// ── نبض منعش — جديد ──
/// كانفس نعناعي بروح الهواء النقي — هدوء التنفس بلا ضيق.
class MintPulsePalette extends AppPalette {
  const MintPulsePalette();

  @override
  final String id = 'mint';
  @override
  final String label = 'نبض منعش';
  @override
  final String tag = 'جديد';
  @override
  final String description = 'كانفس نعناعي بروح الهواء النقي — زجاج لطيف';
  @override
  final bool isGlass = true;

  @override
  final Color bgHigh = const Color(0xFFF1FAF6);
  @override
  final Color bgDeep = const Color(0xFFE1F2EB);
  @override
  final Color glowTint = const Color(0xFF7CCDB9);

  @override
  final List<BgBlob> bgBlobs = const [
    BgBlob(color: Color(0xFF7CCDB9), size: 380, opacity: 0.50, top: -140, right: -100),
    BgBlob(color: Color(0xFF4776E0), size: 300, opacity: 0.24, top: -60, left: -110),
    BgBlob(color: Color(0xFF17A274), size: 320, opacity: 0.34, bottom: -140, right: -90),
    BgBlob(color: Color(0xFF9ADCC8), size: 240, opacity: 0.34, bottom: -100, left: -90),
  ];
}

/// ── نبض الفجر — جديد ──
/// دفء صباحي هادئ بلون الفجر — أقرب ما يكون إلى «دافئ وإنساني».
class DawnPulsePalette extends AppPalette {
  const DawnPulsePalette();

  @override
  final String id = 'dawn';
  @override
  final String label = 'نبض الفجر';
  @override
  final String tag = 'جديد';
  @override
  final String description = 'دفء صباحي هادئ بلون الفجر — زجاج مشمس';
  @override
  final bool isGlass = true;

  @override
  final Color bgHigh = const Color(0xFFFDF6F1);
  @override
  final Color bgDeep = const Color(0xFFF8EAE3);
  @override
  final Color glowTint = const Color(0xFFF2B49B);

  @override
  final List<BgBlob> bgBlobs = const [
    BgBlob(color: Color(0xFFF2B49B), size: 380, opacity: 0.50, top: -140, right: -100),
    BgBlob(color: Color(0xFFE4506C), size: 300, opacity: 0.20, top: -60, left: -110),
    BgBlob(color: Color(0xFFF2A65E), size: 320, opacity: 0.30, bottom: -140, right: -90),
    BgBlob(color: Color(0xFF8F7FE8), size: 240, opacity: 0.24, bottom: -100, left: -90),
  ];
}

/// ── نبض الغسق — جديد ──
/// بنفسجي أعمق وهدوء المساء — الأسطح الصلبة بأقصى حضور بنفسجي.
class DuskPulsePalette extends AppPalette {
  const DuskPulsePalette();

  @override
  final String id = 'dusk';
  @override
  final String label = 'نبض الغسق';
  @override
  final String tag = 'جديد';
  @override
  final String description = 'بنفسجي أعمق وهدوء المساء — أسطح صلبة';
  @override
  final bool isGlass = false;

  @override
  final Color bgHigh = const Color(0xFFF1EFFB);
  @override
  final Color bgDeep = const Color(0xFFE0DCF5);
  @override
  final Color glowTint = const Color(0xFF7B6AE0);

  @override
  final List<BgBlob> bgBlobs = const [
    BgBlob(color: Color(0xFF7B6AE0), size: 360, opacity: 0.16, top: -140, right: -100),
    BgBlob(color: Color(0xFF6558CE), size: 300, opacity: 0.09, top: -40, left: -110),
    BgBlob(color: Color(0xFF4776E0), size: 340, opacity: 0.06, bottom: -180, left: -120),
  ];
}

/// كتالوج الستايلات — مصدر الحقيقة الوحيد للقيمة النشطة.
/// الترتيب هنا هو ترتيب العرض في المنتقي: الحالي، السابق، ثم الجديدة.
class ThemeCatalog {
  ThemeCatalog._();

  static const String defaultId = 'glass';

  static final Map<String, AppPalette> all = {
    for (final p in const [
      GlassPulsePalette(),
      SolidPulsePalette(),
      MintPulsePalette(),
      DawnPulsePalette(),
      DuskPulsePalette(),
    ])
      p.id: p,
  };

  /// قابل للاستماع — آلية إعادة الرسم الموحدة.
  static final ValueNotifier<String> activeId = ValueNotifier(defaultId);

  static AppPalette get current => all[activeId.value] ?? all[defaultId]!;

  /// يطبّق معرّفًا محفوظًا — يتجاهل القيم غير المعروفة بأمان.
  static void apply(String? id) {
    if (id == null || !all.containsKey(id)) return;
    activeId.value = id;
  }
}
