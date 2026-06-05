import 'package:flutter/material.dart';
import 'package:taborq/core/utils/app_colors.dart';
import 'package:taborq/core/utils/app_text_styles.dart';

class PasswordDefaultFormFiled extends StatefulWidget {
  const PasswordDefaultFormFiled({super.key, this.controller, this.validator});

  final TextEditingController? controller;
  final String? Function(String?)? validator;

  @override
  State<PasswordDefaultFormFiled> createState() =>
      _PasswordDefaultFormFiledState();
}

class _PasswordDefaultFormFiledState extends State<PasswordDefaultFormFiled> {
  bool isPassword = true;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      validator: widget.validator,
      cursorColor: AppColors.primaryColor,
      keyboardType: TextInputType.visiblePassword,
      obscureText: isPassword,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.lock),
        errorMaxLines: 4,
        errorStyle: const TextStyle(fontSize: 10),
        hintText: "**********",
        hintStyle: AppTextStyles.textStyle12.copyWith(
          color: AppColors.neutralColor4,
        ),
        suffixIcon: IconButton(
          onPressed: () {
            setState(() {
              isPassword = !isPassword;
            });
          },
          icon: isPassword
              ? const Icon(Icons.visibility)
              : const Icon(Icons.visibility_off),
        ),
        filled: true,
        fillColor: AppColors.neutralColor10,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
