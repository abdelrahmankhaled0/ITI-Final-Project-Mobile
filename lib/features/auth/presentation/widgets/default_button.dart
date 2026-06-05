import 'package:flutter/material.dart';
import 'package:taborq/core/utils/app_colors.dart';
import 'package:taborq/core/utils/app_text_styles.dart';

class DefaultButton extends StatelessWidget {
  const DefaultButton({super.key, required this.text, this.onPressed});

  final String text;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          fixedSize: const Size(400, 50),
          backgroundColor: AppColors.primaryColor,
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: AppTextStyles.textStyle16.copyWith(
            color: AppColors.lightColor,
          ),
        ),
      ),
    );
  }
}