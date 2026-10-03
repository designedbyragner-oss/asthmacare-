/// إدارة مفتاح تشفير قاعدة البيانات (D4) — توليد لمرة واحدة وتخزين آمن.
library;

import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DbKeyManager {
  DbKeyManager._();

  static const String _keyName = 'ac_db_key_v1';
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  /// يقرأ المفتاح أو يولّد 32 بايت عشوائية (256-bit) ويثبّتها.
  /// يُستدعى مرة واحدة في main قبل فتح قاعدة البيانات.
  static Future<String> loadOrCreate() async {
    var key = await _storage.read(key: _keyName);
    if (key == null || key.length < 32) {
      final rnd = Random.secure();
      key = List.generate(32, (_) => rnd.nextInt(256))
          .map((b) => b.toRadixString(16).padLeft(2, '0'))
          .join();
      await _storage.write(key: _keyName, value: key);
    }
    return key;
  }
}
