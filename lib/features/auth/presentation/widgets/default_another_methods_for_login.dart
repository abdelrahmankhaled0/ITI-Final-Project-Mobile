import 'package:flutter/material.dart';
import 'package:taborq/core/utils/app_colors.dart';
import 'package:taborq/core/utils/app_text_styles.dart';
import 'package:taborq/features/auth/presentation/cubit/auth_cubit.dart';

class DefaultAnthorMethodsForLogin extends StatelessWidget {
  const DefaultAnthorMethodsForLogin({super.key, required this.cubit});

  final AuthCubit cubit;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 10,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 1,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              fixedSize: Size(0, 50),
              backgroundColor: AppColors.neutralColor9,
              overlayColor: AppColors.lightColor,
            ),
            onPressed: () {
              cubit.signInWithGoogle();
            },
            child: Text(
              "Google",
              style: AppTextStyles.textStyle16.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor1,
              ),
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              fixedSize: Size(0, 50),
              backgroundColor: AppColors.neutralColor9,
              overlayColor: AppColors.primaryColor4,
            ),
            onPressed: () {},
            child: Text(
              "Apple",
              style: AppTextStyles.textStyle16.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor1,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
