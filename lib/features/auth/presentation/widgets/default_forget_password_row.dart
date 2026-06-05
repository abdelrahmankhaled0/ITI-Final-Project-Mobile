import 'package:flutter/material.dart';
import 'package:taborq/core/routes/navigations.dart';
import 'package:taborq/core/routes/routes.dart';
import 'package:taborq/core/utils/app_colors.dart';
import 'package:taborq/core/utils/app_text_styles.dart';

class DefaultForgetPasswordRow extends StatelessWidget {
  const DefaultForgetPasswordRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Spacer(),
        TextButton(
          style: TextButton.styleFrom(padding: EdgeInsets.zero),
          onPressed: () {
            AppNavigations.pushTo(context, AppRoutes.forgetPassword);
          },
          child: Text(
            "Forget Password?",
            style: AppTextStyles.textStyle12.copyWith(
              color: AppColors.neutralColor2,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
