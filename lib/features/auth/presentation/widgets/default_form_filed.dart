import 'package:flutter/material.dart';
import 'package:taborq/core/utils/app_colors.dart';
import 'package:taborq/core/utils/app_text_styles.dart';

class DefaultFormFiled extends StatelessWidget {
  const DefaultFormFiled({
    super.key,
    this.controller,
    this.validator,
    this.prefixIcon,
    required this.hintText,
    this.keyboardType,
  });

  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final Widget? prefixIcon;
  final String hintText;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      cursorColor: AppColors.primaryColor,
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.neutralColor10,
        prefixIcon: prefixIcon,
        errorStyle: const TextStyle(fontSize: 10),
        hintText: hintText,
        hintStyle: AppTextStyles.textStyle12.copyWith(
          color: AppColors.neutralColor4,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}