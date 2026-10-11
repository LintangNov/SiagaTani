import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:siaga_tani/controllers/auth_controller.dart';

import '../core/theme/app_theme.dart';
import '../core/utils/validators.dart';
import '../widgets/common/app_back_button.dart';
import '../widgets/common/app_button.dart';
import '../widgets/common/app_text_field.dart';
import '../widgets/common/error_banner.dart';
import '../widgets/common/password_strength.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthController _auth = Get.find<AuthController>();

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passFocus = FocusNode();

  String? _nameError;
  String? _emailError;
  String? _passError;
  AuthFailure? _failure;

  @override
  void initState() {
    super.initState();
    _nameFocus.addListener(() {
      if (!_nameFocus.hasFocus) _validate(name: true);
    });
    _emailFocus.addListener(() {
      if (!_emailFocus.hasFocus) _validate(email: true);
    });
    _passFocus.addListener(() {
      if (!_passFocus.hasFocus) _validate(pass: true);
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _passFocus.dispose();
    super.dispose();
  }

  void _validate({bool name = false, bool email = false, bool pass = false}) {
    setState(() {
      if (name && (_nameCtrl.text.isNotEmpty || _nameError != null)) {
        _nameError = Validators.name(_nameCtrl.text);
      }
      if (email && (_emailCtrl.text.isNotEmpty || _emailError != null)) {
        _emailError = Validators.email(_emailCtrl.text);
      }
      if (pass && (_passCtrl.text.isNotEmpty || _passError != null)) {
        _passError = Validators.newPassword(_passCtrl.text);
      }
    });
  }

  Future<void> _submit() async {
    final nameError = Validators.name(_nameCtrl.text);
    final emailError = Validators.email(_emailCtrl.text);
    final passError = Validators.newPassword(_passCtrl.text);
    setState(() {
      _nameError = nameError;
      _emailError = emailError;
      _passError = passError;
      _failure = null;
    });

    if (nameError != null) {
      _nameFocus.requestFocus();
      return;
    }
    if (emailError != null) {
      _emailFocus.requestFocus();
      return;
    }
    if (passError != null) {
      _passFocus.requestFocus();
      return;
    }

    FocusScope.of(context).unfocus();
    final failure = await _auth.register(
      _nameCtrl.text.trim(),
      _emailCtrl.text.trim(),
      _passCtrl.text.trim(),
    );
    if (mounted && failure != null) setState(() => _failure = failure);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Obx(() {
          final loading = _auth.isLoading.value;
          return Column(
            children: [
              Expanded(child: _buildForm(loading)),
              _buildBottomBar(loading),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildForm(bool loading) {
    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(
        AppSpace.screen,
        AppSpace.xl,
        AppSpace.screen,
        AppSpace.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: AppBackButton(onPressed: loading ? null : () => Get.back()),
          ),
          const SizedBox(height: AppSpace.xl),
          Semantics(
            header: true,
            child: Text('Buat Akun Baru', style: AppText.heading()),
          ),
          const SizedBox(height: AppSpace.sm),
          Text(
            'Cukup tiga isian. Setelah itu Anda bisa langsung memakai aplikasi.',
            style: AppText.body(),
          ),
          const SizedBox(height: AppSpace.xl),
          AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppTextField(
                  label: 'Nama Panggilan',
                  hint: 'Contoh: Budi',
                  helper: 'Nama ini dipakai untuk menyapa Anda.',
                  controller: _nameCtrl,
                  focusNode: _nameFocus,
                  enabled: !loading,
                  errorText: _nameError,
                  keyboardType: TextInputType.name,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.nickname],
                  onChanged: (_) {
                    if (_nameError != null) setState(() => _nameError = null);
                  },
                  onSubmitted: (_) => _emailFocus.requestFocus(),
                ),
                const SizedBox(height: AppSpace.xl),
                AppTextField(
                  label: 'Email',
                  hint: 'contoh@email.com',
                  controller: _emailCtrl,
                  focusNode: _emailFocus,
                  enabled: !loading,
                  errorText: _emailError,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                  onChanged: (_) {
                    if (_emailError != null || _failure != null) {
                      setState(() {
                        _emailError = null;
                        _failure = null;
                      });
                    }
                  },
                  onSubmitted: (_) => _passFocus.requestFocus(),
                ),
                const SizedBox(height: AppSpace.xl),
                AppTextField(
                  label: 'Kata Sandi',
                  hint: 'Minimal 6 karakter',
                  helper:
                      'Gunakan minimal 6 karakter. Kombinasi huruf dan angka lebih aman.',
                  controller: _passCtrl,
                  focusNode: _passFocus,
                  enabled: !loading,
                  isPassword: true,
                  errorText: _passError,
                  keyboardType: TextInputType.visiblePassword,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.newPassword],
                  onChanged: (_) => setState(() => _passError = null),
                  onSubmitted: (_) {
                    TextInput.finishAutofillContext();
                    _submit();
                  },
                ),
                PasswordStrength(password: _passCtrl.text),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(bool loading) {
    final keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        AppSpace.screen,
        AppSpace.md,
        AppSpace.screen,
        AppSpace.sm,
      ),
      decoration: const BoxDecoration(color: AppColors.surfacePrimary),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_failure != null) ...[
            ErrorBanner(
              message: _failure!.message,
              onDismiss: () => setState(() => _failure = null),
              actionLabel: _failure!.emailAlreadyInUse ? 'Masuk' : null,
              onAction: _failure!.emailAlreadyInUse ? () => Get.back() : null,
            ),
            const SizedBox(height: AppSpace.md),
          ],
          AppButton(label: 'Daftar', loading: loading, onPressed: _submit),
          if (!keyboardOpen)
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text('Sudah punya akun? ', style: AppText.body(size: 14)),
                TextButton(
                  onPressed: loading ? null : () => Get.back(),
                  child: Text(
                    'Masuk',
                    style: AppText.body(
                      size: 14,
                      weight: FontWeight.w700,
                      color: AppColors.accentPrimary,
                    ),
                  ),
                ),
              ],
            )
          else
            const SizedBox(height: AppSpace.sm),
        ],
      ),
    );
  }
}
