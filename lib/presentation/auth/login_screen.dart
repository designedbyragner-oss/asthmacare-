import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:asthma_care/application/providers.dart';
import 'package:asthma_care/core/theme/app_theme.dart';
import 'package:asthma_care/core/theme/theme_controller.dart';
import 'package:asthma_care/presentation/shared_widgets/pulse_line.dart';
import 'package:asthma_care/presentation/shared_widgets/widgets.dart';

/// تسجيل الدخول — إعداد محلي بلا خادم (نسخة العرض): الاسم يُحفظ محليًا.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _nameCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    await ref.read(settingsProvider.notifier).setUserName(_nameCtrl.text.trim());
    if (!mounted) return;
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    // اعتماد الستايل — إعادة بناء مضمونة عند التبديل
    ref.watch(themeStyleProvider);
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: Aurora.hPad),
            child: Column(
              children: [
                const SizedBox(height: 60),
                // الشعار — علامة النبض، نداء مباشر لأيقونة التطبيق
                const BrandMark(size: 64),
                const SizedBox(height: 20),
                Text('مرحبًا بعودتك', style: AuroraText.display(26)),
                const SizedBox(height: 6),
                Text('سجّل الدخول للمتابعة', style: AuroraText.secondary(context)),
                const SizedBox(height: 28),
                SectionCard(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('اسمك', style: AuroraText.faint(context)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _nameCtrl,
                          textInputAction: TextInputAction.done,
                          validator: (v) =>
                              (v == null || v.trim().isEmpty) ? 'أدخل اسمك' : null,
                          decoration: _inputDecoration(),
                        ),
                        const SizedBox(height: 20),
                        PrimaryButton(
                          label: 'تسجيل الدخول',
                          loading: _saving,
                          onPressed: _submit,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'بياناتك محفوظة محليًا على جهازك فقط',
                  textAlign: TextAlign.center,
                  style: AuroraText.faint(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      hintText: 'مثال: ليان',
      hintStyle: AuroraText.faint(context),
      filled: true,
      fillColor: Aurora.surfaceHi,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Aurora.rTile),
        borderSide: BorderSide(color: Aurora.hairline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Aurora.rTile),
        borderSide: BorderSide(color: Aurora.hairline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Aurora.rTile),
        borderSide: BorderSide(color: Aurora.brand, width: 1.4),
      ),
    );
  }
}
