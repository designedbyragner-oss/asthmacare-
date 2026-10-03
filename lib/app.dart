import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:asthma_care/application/providers.dart';
import 'package:asthma_care/application/router.dart';
import 'package:asthma_care/core/theme/app_palette.dart';
import 'package:asthma_care/core/theme/app_theme.dart';
import 'package:asthma_care/core/theme/theme_controller.dart';

/// جذر التطبيق — يشغّل منسق المراقبة ويضبط العربية RTL والثيم.
/// الستايل يُشاهد من هنا: تبديله يعيد بناء MaterialApp بثيم اللوحة
/// الجديدة ويحدّث شريط النظام، بينما يعيد MainShell تركيب محتواه
/// بمفتاح الستايل فيُعاد رسم كل شيء حتى الودجات الثابتة.
class AsthmaCareApp extends ConsumerStatefulWidget {
  const AsthmaCareApp({super.key});

  @override
  ConsumerState<AsthmaCareApp> createState() => _AsthmaCareAppState();
}

class _AsthmaCareAppState extends ConsumerState<AsthmaCareApp> {
  @override
  void initState() {
    super.initState();
    // المنسق يبدأ بعد أول إطار حتى لا يقرأ المزودات أثناء البناء
    Future.microtask(() {
      if (mounted) ref.read(coordinatorProvider).start();
    });
  }

  @override
  Widget build(BuildContext context) {
    final styleId = ref.watch(themeStyleProvider);
    final palette = ThemeCatalog.all[styleId] ?? ThemeCatalog.current;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: palette.overlayStyle,
      child: MaterialApp.router(
        title: 'AsthmaCare',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.from(palette),
        routerConfig: appRouter,
        locale: const Locale('ar'),
        supportedLocales: const [Locale('ar'), Locale('en')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
      ),
    );
  }
}
