import 'package:flutter/material.dart';

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

      decoration: InputDecoration(prefixIcon: prefixIcon, hintText: hintText),
    );
  }
}
