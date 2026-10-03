import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:asthma_care/app.dart';
import 'package:asthma_care/application/providers.dart';
import 'package:asthma_care/application/services/demo_data_seeder.dart';
import 'package:asthma_care/application/services/notification_service.dart';
import 'package:asthma_care/core/security/db_key_manager.dart';
import 'package:asthma_care/core/theme/theme_controller.dart';
import 'package:asthma_care/data/local_db/app_database.dart';
import 'package:asthma_care/data/repositories/repositories.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // الشاشة كاملة الحافة: محتوى الجسم يمتد خلف شريط نظام أندرويد —
  // فلا حزام صلب أسفل الشاشة (overlayStyle يجعل الشريط شفافًا)
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // الستايل المحفوظ قبل أول إطار — لا وميض للستايل الافتراضي
  await loadSavedThemeStyle();

  // مفتاح التشفير قبل فتح قاعدة البيانات (D4) — فشله يوقف التشغيل عمدًا
  final dbKey = await DbKeyManager.loadOrCreate();
  final database = AppDatabase(dbKey);

  // بذر تاريخ تجريبي عند أول تشغيل فقط (السجل فارغ) — المؤشرات والرسوم
  // والتنبيهات جاهزة للتجربة من أول لحظة. إن وُجد سجل حقيقي فلا يُبذر شيء.
  await DemoDataSeeder(
    VitalsRepository(database),
    EnvRepository(database),
    AlertsRepository(database),
  ).seedIfNeeded();

  // الإشعارات المحلية قبل أول تنبيه محتمل (D1)
  final notifications = NotificationService();
  await notifications.init();

  runApp(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(database),
        notificationServiceProvider.overrideWithValue(notifications),
      ],
      child: const AsthmaCareApp(),
    ),
  );
}
