/// أوزان محرك الخطر المركزية — قرار D9: **مؤقتة** حتى بروتوكول المعايرة.
/// المرجع: الوثيقة الموحدة §9 / docx §9 — "تُحدد الأوزان بعد اختبار البيانات".
/// أي تعديل يحدث هنا فقط (مصدر وحيد للحقيقة) ويُوثق في سجل القرارات.
library;

class RiskConfig {
  RiskConfig._();

  // عتبات الميزات
  static const double respDeltaMajor = 6.0; // نفس/دقيقة فوق خط الأساس
  static const double respDeltaMinor = 3.0;
  static const double spo2TrendLimit = -1.5; // %/5 دقائق — انخفاض مستمر
  static const double hrRespSyncLimit = 0.7; // تزامن بلا نشاط (0–1)
  static const double envExposureLimit = 0.6; // 0–1

  // الأوزان
  static const int wRespMajor = 3;
  static const int wRespMinor = 1;
  static const int wSpo2 = 3;
  static const int wSync = 2;
  static const int wEnv = 1;

  // عتبات المستوى (§9.4)
  static const int attentionScore = 3;
  static const int highRiskScore = 6;

  // حدود مناطق مؤشر الخطر المئوي (طلب المالك 2026-09-28): درجات 0–9 تُختم
  // إلى نطاقات 0–39 أخضر / 40–75 برتقالي / 76–100 أحمر — المثال الحاكم:
  // الدرجة 5 → 75% برتقالي «احتمال بداية نوبة». تُستهلك في risk_index.dart.
  static const int indexGreenMax = 39;
  static const int indexOrangeMax = 75;

  // عتبات خط الأساس (§9.1)
  static const int baselineMinSamples = 30;

  // نافذة تهدئة التنبيهات (ثوانٍ) — لمنع الإغراق
  static const int attentionCooldownSec = 600; // 10 دقائق
  static const int highRiskCooldownSec = 300; // 5 دقائق
  static const int minAnyAlertGapSec = 60;
}
