/// خدمة التنبيهات المحلية — تعمل بلا إنترنت (شرط D1).
/// النمط موثق لإصدار flutter_local_notifications 17.x: initialize موضعي + طلب إذن Android 13+.
library;

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;

  static const String _criticalChannel = 'ac_critical';
  static const String _infoChannel = 'ac_info';

  Future<void> init() async {
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );
    await _plugin.initialize(settings);
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    _ready = true;
  }

  Future<void> showCritical({required String title, required String body}) async {
    if (!_ready) return;
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _criticalChannel,
        'تنبيهات حرجة',
        channelDescription: 'تنبيهات النمط المتطلب للمتابعة',
        importance: Importance.max,
        priority: Priority.high,
        enableVibration: true,
        playSound: true,
        channelShowBadge: true,
      ),
    );
    try {
      await _plugin.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000 % 2147483647,
        title,
        body,
        details,
      );
    } catch (_) {
      // الإشعار فشل — التنبيه يبقى محفوظًا في قاعدة البيانات (مصدر الحقيقة)
    }
  }

  Future<void> showInfo({required String title, required String body}) async {
    if (!_ready) return;
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _infoChannel,
        'تنبيهات عامة',
        channelDescription: 'تذكيرات وتنبيهات بيئية',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      ),
    );
    try {
      await _plugin.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000 % 2147483647,
        title,
        body,
        details,
      );
    } catch (_) {
      // تجاهل — نفس منطق الأعلاه
    }
  }
}
