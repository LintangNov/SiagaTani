import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:siaga_tani/controllers/auth_controller.dart';
import 'package:siaga_tani/view/register_screen.dart';

import '../core/theme/app_theme.dart';
import '../core/utils/validators.dart';
import '../widgets/common/app_button.dart';
import '../widgets/common/app_text_field.dart';
import '../widgets/common/error_banner.dart';
import '../widgets/common/google_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthController _auth = Get.find<AuthController>();

  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _emailFocus = FocusNode();
  final _passFocus = FocusNode();

  String? _emailError;
  String? _passError;
  AuthFailure? _failure;

  @override
  void initState() {
    super.initState();
    _emailFocus.addListener(() {
      if (!_emailFocus.hasFocus) _validateEmail();
    });
    _passFocus.addListener(() {
      if (!_passFocus.hasFocus) _validatePassword();
    });
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _emailFocus.dispose();
    _passFocus.dispose();
    super.dispose();
  }

  void _validateEmail() {
    if (_emailCtrl.text.isEmpty && _emailError == null) return;
    setState(() => _emailError = Validators.email(_emailCtrl.text));
  }

  void _validatePassword() {
    if (_passCtrl.text.isEmpty && _passError == null) return;
    setState(() => _passError = Validators.passwordRequired(_passCtrl.text));
  }

  Future<void> _submit() async {
    final emailError = Validators.email(_emailCtrl.text);
    final passError = Validators.passwordRequired(_passCtrl.text);
    setState(() {
      _emailError = emailError;
      _passError = passError;
      _failure = null;
    });

    if (emailError != null) {
      _emailFocus.requestFocus();
      return;
    }
    if (passError != null) {
      _passFocus.requestFocus();
      return;
    }

    FocusScope.of(context).unfocus();
    final failure = await _auth.login(
      _emailCtrl.text.trim(),
      _passCtrl.text.trim(),
    );
    if (mounted && failure != null) setState(() => _failure = failure);
  }

  Future<void> _googleSignIn() async {
    setState(() => _failure = null);
    final failure = await _auth.googleSignIn();
    if (mounted && failure != null) setState(() => _failure = failure);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpace.screen,
                  AppSpace.xxxl,
                  AppSpace.screen,
                  AppSpace.xxl,
                ),
                child: Obx(() => _buildContent(_auth.isLoading.value)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(bool loading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Text('Masuk Akun', style: AppText.heading()),
        ),
        const SizedBox(height: AppSpace.sm),
        Text(
          'Selamat datang kembali,\nPejuang Pangan!',
          style: AppText.body(),
        ),
        const SizedBox(height: AppSpace.xl),
        AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                hint: 'Masukkan kata sandi',
                controller: _passCtrl,
                focusNode: _passFocus,
                enabled: !loading,
                isPassword: true,
                errorText: _passError,
                keyboardType: TextInputType.visiblePassword,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.password],
                onChanged: (_) {
                  if (_passError != null || _failure != null) {
                    setState(() {
                      _passError = null;
                      _failure = null;
                    });
                  }
                },
                onSubmitted: (_) {
                  TextInput.finishAutofillContext();
                  _submit();
                },
              ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: loading ? null : () {},
            child: const Text('Lupa Kata Sandi?'),
          ),
        ),
        if (_failure != null) ...[
          ErrorBanner(
            message: _failure!.message,
            onDismiss: () => setState(() => _failure = null),
          ),
          const SizedBox(height: AppSpace.lg),
        ],
        AppButton(label: 'Masuk', loading: loading, onPressed: _submit),
        const SizedBox(height: AppSpace.xl),
        Row(
          children: [
            const Expanded(
              child: Divider(color: AppColors.borderStrong, thickness: 1),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpace.lg),
              child: Text(
                'atau',
                style: AppText.body(
                  size: 14,
                  color: AppColors.foregroundTertiary,
                ),
              ),
            ),
            const Expanded(
              child: Divider(color: AppColors.borderStrong, thickness: 1),
            ),
          ],
        ),
        const SizedBox(height: AppSpace.xl),
        GoogleButton(onPressed: loading ? null : _googleSignIn),
        const Spacer(),
        const SizedBox(height: AppSpace.xl),
        Center(
          child: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text('Belum punya akun? ', style: AppText.body(size: 14)),
              TextButton(
                onPressed: loading
                    ? null
                    : () => Get.to(() => const RegisterScreen()),
                child: Text(
                  'Daftar Sekarang',
                  style: AppText.body(
                    size: 14,
                    weight: FontWeight.w700,
                    color: AppColors.accentPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
