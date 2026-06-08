import 'package:flutter/material.dart';

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

      keyboardType: TextInputType.visiblePassword,
      obscureText: isPassword,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.lock),

        hintText: "**********",

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
      ),
    );
  }
}
