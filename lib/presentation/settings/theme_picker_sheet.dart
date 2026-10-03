import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:asthma_care/core/theme/app_palette.dart';
import 'package:asthma_care/core/theme/app_theme.dart';
import 'package:asthma_care/core/theme/theme_controller.dart';

/// يفتح شيت اختيار ستايل التطبيق — يُستهلك من بطاقة «ستايل التطبيق».
/// الخلفية خافتة قليلًا كي يبقى التطبيق خلف الشيت مرئيًا ويتغير حيًّا
/// لحظة اختيار أي ستايل — المعاينة الحية هي التجربة كلها.
Future<void> showThemePickerSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black26,
    builder: (_) => const _ThemePickerSheet(),
  );
}

class _ThemePickerSheet extends ConsumerWidget {
  const _ThemePickerSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // مشاهد المزود — الشيت نفسه يُعاد طلاؤه مع كل تبديل
    ref.watch(themeStyleProvider);
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      decoration: BoxDecoration(
        color: Aurora.surface,
        borderRadius: BorderRadius.circular(Aurora.rGroup),
        border: Border.all(color: Aurora.hairline),
        boxShadow: Aurora.cardShadow,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // مقبض السحب
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 10, bottom: 4),
              decoration: BoxDecoration(
                color: Aurora.hairlineStrong,
                borderRadius: BorderRadius.circular(Aurora.rPill),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 6, 18, 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('اختر ستايل التطبيق', style: AuroraText.title(context)),
                  const SizedBox(height: 3),
                  Text(
                    'يُطبَّق فورًا على التطبيق كاملًا ويُحفظ تلقائيًا — جرّب وشاهد الفرق خلف البطاقات',
                    style: AuroraText.faint(context),
                  ),
                ],
              ),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                children: [
                  for (final palette in ThemeCatalog.all.values)
                    _StyleOption(
                      palette: palette,
                      selected: palette.id == ThemeCatalog.activeId.value,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// صف ستايل واحد: معاينة حية مرسومة من لوحته نفسها + الاسم والوسم + مؤشر الاختيار.
class _StyleOption extends ConsumerWidget {
  final AppPalette palette;
  final bool selected;

  const _StyleOption({required this.palette, required this.selected});

  // وسم الحالة حي: المختار «نشط» الآن — والبقية تحمل أصلها (الحالي/السابق/جديد)
  String get _tagText => selected ? 'نشط' : palette.tag;

  Color get _tagColor => selected
      ? Aurora.brand
      : switch (palette.tag) {
          'الحالي' => Aurora.brand,
          'السابق' => Aurora.textFaint,
          _ => Aurora.oxygen,
        };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: selected ? Aurora.brandSoft : Colors.transparent,
        borderRadius: BorderRadius.circular(Aurora.rTile),
        child: InkWell(
          borderRadius: BorderRadius.circular(Aurora.rTile),
          onTap: () {
            HapticFeedback.selectionClick();
            ref.read(themeStyleProvider.notifier).select(palette.id);
          },
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                _StylePreview(palette: palette),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              palette.label,
                              style: AuroraText.section(context),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2.5,
                            ),
                            decoration: BoxDecoration(
                              color: _tagColor.withValues(alpha: 0.12),
                              borderRadius:
                                  BorderRadius.circular(Aurora.rPill),
                            ),
                            child: Text(
                              _tagText,
                              style: TextStyle(
                                fontFamily: AuroraText.family,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: _tagColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        palette.description,
                        style: AuroraText.faint(context),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected ? Aurora.brand : Colors.transparent,
                    border: selected
                        ? null
                        : Border.all(color: Aurora.hairlineStrong, width: 1.6),
                  ),
                  child: selected
                      ? const Icon(Icons.check_rounded,
                          size: 17, color: Colors.white)
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// معاينة مصغّرة صادقة للستايل — تُرسم من لوحته نفسها فتُظهر الفرق
/// الحقيقي: الكانفس، غراء البطاقة (زجاج/صلب)، غراء زر الفعل، والكبسولة.
class _StylePreview extends StatelessWidget {
  final AppPalette palette;

  const _StylePreview({required this.palette});

  @override
  Widget build(BuildContext context) {
    final p = palette;
    return Container(
      width: 66,
      height: 94,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: p.hairline),
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [p.bgHigh, p.bgDeep],
          stops: const [0.0, 0.55],
        ),
      ),
      child: Stack(
        children: [
          // بقعة توهج مصغّرة — نغمة كانفس الستايل
          Positioned(
            top: -26,
            right: -22,
            child: IgnorePointer(
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      p.glowTint.withValues(alpha: 0.55),
                      p.glowTint.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // بطاقة مصغّرة — زجاج شفاف فوق التوهج أو سطح صلب عائم
          Positioned(
            top: 22,
            right: 7,
            left: 7,
            child: Container(
              height: 36,
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: p.isGlass ? p.glassFill : p.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: p.isGlass ? p.glassBorder : p.hairline,
                ),
              ),
              child: Row(
                children: [
                  // زر فعل مصغّر — بنفسجي مسطّح في المسارين كالزر الحقيقي
                  Container(
                    width: 17,
                    height: 9,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(Aurora.rPill),
                      color: p.brand,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 4,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: p.textSecondary.withValues(alpha: 0.35),
                            borderRadius:
                                BorderRadius.circular(Aurora.rPill),
                          ),
                        ),
                        const SizedBox(height: 3),
                        FractionallySizedBox(
                          widthFactor: 0.6,
                          child: Container(
                            height: 4,
                            decoration: BoxDecoration(
                              color: p.textSecondary.withValues(alpha: 0.20),
                              borderRadius:
                                  BorderRadius.circular(Aurora.rPill),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // كبسولة تنقل مصغّرة بحبر عميق ودائرة نشطة بيضاء
          Positioned(
            bottom: 6,
            left: 9,
            right: 9,
            child: Container(
              height: 13,
              padding: const EdgeInsets.symmetric(horizontal: 7),
              decoration: BoxDecoration(
                color: p.navInk,
                borderRadius: BorderRadius.circular(Aurora.rPill),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                  ),
                  for (var i = 0; i < 3; i++)
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: p.navIdleIcon,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
