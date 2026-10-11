import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Kolom isian dengan label tetap di atas, pesan galat (ikon + teks) di bawah,
/// dan varian kata sandi dengan tombol mata 56dp.
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.helper,
    this.errorText,
    this.focusNode,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.autofillHints,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
    this.isPassword = false,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final String? helper;
  final String? errorText;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool enabled;
  final bool isPassword;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _obscured = true;

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: AppText.body(
            size: 14,
            weight: FontWeight.w600,
            color: AppColors.foregroundPrimary,
            height: 1.3,
          ),
        ),
        const SizedBox(height: AppSpace.sm),
        TextField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          enabled: widget.enabled,
          obscureText: widget.isPassword && _obscured,
          enableSuggestions: !widget.isPassword,
          autocorrect: !widget.isPassword,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          textCapitalization: widget.textCapitalization,
          autofillHints: widget.autofillHints,
          onChanged: widget.onChanged,
          onSubmitted: widget.onSubmitted,
          style: AppText.body(
            size: 16,
            color: AppColors.foregroundPrimary,
            height: 1.3,
          ),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: AppText.body(
              size: 16,
              color: AppColors.foregroundTertiary,
              height: 1.3,
            ),
            error: hasError ? const SizedBox.shrink() : null,
            suffixIcon: widget.isPassword ? _eyeButton() : null,
            suffixIconConstraints: const BoxConstraints(
              minWidth: AppSize.touch,
              minHeight: AppSize.touch,
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: AppSpace.sm),
            child: Semantics(
              liveRegion: true,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 1),
                    child: Icon(
                      Icons.error_outline,
                      size: 20,
                      color: AppColors.danger,
                    ),
                  ),
                  const SizedBox(width: AppSpace.sm),
                  Expanded(
                    child: Text(
                      widget.errorText!,
                      style: AppText.body(
                        size: 13,
                        weight: FontWeight.w500,
                        color: AppColors.danger,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        else if (widget.helper != null)
          Padding(
            padding: const EdgeInsets.only(top: AppSpace.sm),
            child: Text(
              widget.helper!,
              style: AppText.body(size: 13, height: 1.3),
            ),
          ),
      ],
    );
  }

  Widget _eyeButton() {
    return Semantics(
      button: true,
      label: _obscured ? 'Tampilkan kata sandi' : 'Sembunyikan kata sandi',
      excludeSemantics: true,
      child: IconButton(
        onPressed: widget.enabled
            ? () => setState(() => _obscured = !_obscured)
            : null,
        constraints: const BoxConstraints.tightFor(
          width: AppSize.touch,
          height: AppSize.touch,
        ),
        icon: Icon(
          _obscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          size: 26,
          color: AppColors.foregroundSecondary,
        ),
      ),
    );
  }
}
