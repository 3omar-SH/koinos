import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:Koinos/core/theme/app_colors.dart';

class TextFieldWidget extends StatelessWidget {
  
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool isPassword;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;

  final ValueNotifier<bool> _isObscured;

  TextFieldWidget({
    super.key,
    required this.controller,
    required this.hint,
    required this.icon,
    this.isPassword = false,
    this.validator,
    this.keyboardType = TextInputType.text,
  }) : _isObscured = ValueNotifier<bool>(isPassword);


  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(40),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: ValueListenableBuilder<bool>(
          valueListenable: _isObscured,
          builder: (context, isObscuredValue, child) {
            return TextFormField(
              controller: controller,
              obscureText: isObscuredValue,
              style: const TextStyle(color: AppColors.textDarkMode, fontSize: 18),
              validator: validator,
              cursorColor: AppColors.textDarkMode,
              cursorHeight: 24,
              cursorWidth: 1,
              textInputAction: TextInputAction.next,
              keyboardType: keyboardType,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 16),
                prefixIcon: Icon(icon, color: AppColors.textMuted, size: 24),
                suffixIcon: isPassword
                    ? IconButton(
                        icon: Icon(
                          isObscuredValue ? Icons.visibility_off : Icons.visibility,
                          color: AppColors.textMuted,
                          size: 24,
                        ),
                        onPressed: () {
                          _isObscured.value = !_isObscured.value;
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.glassBackgroundDark,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(40),
                  borderSide: BorderSide(
                    color: AppColors.glassBorderLight,
                    width: 1.5,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(40),
                  borderSide: BorderSide(
                    color: AppColors.glassBorderLight,
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(40),
                  borderSide: BorderSide(
                    color: AppColors.glassBorder,
                    width: 1.5,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(40),
                  borderSide: const BorderSide(
                    color: AppColors.error,
                    width: 1.5,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(40),
                  borderSide: const BorderSide(
                    color: AppColors.error,
                    width: 1.5,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}