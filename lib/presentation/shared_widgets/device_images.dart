import 'package:flutter/material.dart';

import 'package:asthma_care/core/theme/app_theme.dart';

/// مسارات صور العتاد الحقيقي — مقصوصة من لقطات المنتج المعتمدة
/// (السوار بتشكيلته الرمادية، ومكعب جهاز البيئة) وتُخزّن في
/// assets/images/devices/.
class DeviceImages {
  DeviceImages._();

  static const String band = 'assets/images/devices/band_front.png';
  static const String env = 'assets/images/devices/env_cube.png';
}

/// بلاطة صورة جهاز — العتاد الفعلي بدل الأيقونة المجردة.
/// لحظة «ما الجهاز الذي أربطه؟» تستحق صورة حقيقية: على شاشة الاقتران
/// تُعرض كاملة (contain)، وفي صفوف المراقبة تملأ البلاطة (cover).
class DevicePhoto extends StatelessWidget {
  final String asset;
  final double size;
  final BoxFit fit;
  final double radius;

  const DevicePhoto({
    super.key,
    required this.asset,
    this.size = 48,
    this.fit = BoxFit.cover,
    this.radius = Aurora.rTile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Aurora.surface,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: Aurora.hairline),
      ),
      child: Image.asset(asset, fit: fit, width: size, height: size),
    );
  }
}
