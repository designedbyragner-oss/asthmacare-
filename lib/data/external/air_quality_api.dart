/// جودة الهواء الخارجية (NO₂/SO₂) — قرار D5: من مصدر خارجي موسوم دائمًا.
/// المصدر: Open-Meteo Air Quality API (مجاني، بلا مفتاح). عند تعذر الشبكة:
/// تقدير إقليمي ثابت موسوم — لا يُنسب للجهاز إطلاقًا.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:asthma_care/data/models/models.dart';

class AirQualityApi {
  final HttpClient _client;
  final double latitude;
  final double longitude;

  /// إحداثيات افتراضية — نقطة توسعة مستقبلية: موقع المستخدم بإذنه.
  AirQualityApi({
    this.latitude = 24.7136,
    this.longitude = 46.6753,
    HttpClient? client,
  }) : _client = client ?? HttpClient() {
    _client.connectionTimeout = const Duration(seconds: 5);
  }

  Future<ExternalAirQuality> fetchCurrent() async {
    try {
      final uri = Uri.https(
        'air-quality-api.open-meteo.com',
        '/v1/air-quality',
        {
          'latitude': latitude.toStringAsFixed(4),
          'longitude': longitude.toStringAsFixed(4),
          'current': 'no2,so2',
          'timezone': 'auto',
        },
      );
      final req = await _client.getUrl(uri).timeout(const Duration(seconds: 6));
      final res = await req.close().timeout(const Duration(seconds: 6));
      if (res.statusCode != 200) throw const HttpException('bad status');
      final body = await res.transform(utf8.decoder).join();
      final json = jsonDecode(body) as Map<String, Object?>;
      final current = json['current'] as Map<String, Object?>?;
      return ExternalAirQuality(
        no2: (current?['no2'] as num?)?.toDouble(),
        so2: (current?['so2'] as num?)?.toDouble(),
        sourceLabel: 'شبكة المراقبة العامة',
        fetchedAt: DateTime.now(),
        isEstimate: false,
      );
    } on TimeoutException {
      return _regionalEstimate();
    } on SocketException {
      return _regionalEstimate();
    } on HttpException {
      return _regionalEstimate();
    } on FormatException {
      return _regionalEstimate();
    }
  }

  /// تقدير إقليمي ثابت — موسوم صراحة كتقدير وليس قياسًا.
  ExternalAirQuality _regionalEstimate() => ExternalAirQuality(
        no2: 22,
        so2: 6,
        sourceLabel: 'تقدير إقليمي (تعذر الاتصال)',
        fetchedAt: DateTime.now(),
        isEstimate: true,
      );

  void dispose() => _client.close(force: true);
}
