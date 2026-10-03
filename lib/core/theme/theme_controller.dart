import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:asthma_care/core/theme/app_palette.dart';

/// متحكم ستايل التطبيق — الحالة للعرض، والتخزين للدوام.
/// اللوحة الفعلية تعيش في ThemeCatalog.activeId (تُقرأ عبر Aurora)،
/// وهذا المتحكم مصدر تغييرها الوحيد وقت التشغيل + يكتب الاختيار.
final themeStyleProvider =
    NotifierProvider<ThemeStyleController, String>(ThemeStyleController.new);

class ThemeStyleController extends Notifier<String> {
  static const _key = 'themeStyle';

  @override
  String build() => ThemeCatalog.activeId.value;

  Future<void> select(String id) async {
    if (!ThemeCatalog.all.containsKey(id)) return;
    ThemeCatalog.apply(id);
    state = id;
    try {
      await SharedPreferencesAsync().setString(_key, id);
    } catch (e) {
      // فشل التخزين لا يعطل التبديل الحي — الأثر فقط: يُفقد الاختيار عند الإقلاع
      debugPrint('ThemeStyleController persist error: $e');
    }
  }
}

/// يُستدعى مرة واحدة في main() قبل runApp — الستايل المحفوظ يُطبَّق
/// من أول إطار، فلا وميض للستايل الافتراضي عند الإقلاع.
Future<void> loadSavedThemeStyle() async {
  final saved = await SharedPreferencesAsync().getString(ThemeStyleController._key);
  ThemeCatalog.apply(saved);
}
