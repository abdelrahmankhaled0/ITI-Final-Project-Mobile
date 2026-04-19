import 'package:flutter/material.dart';
import 'package:flutter_gap/flutter_gap.dart';
import 'package:taborq/core/routes/navigations.dart';
import 'package:taborq/core/routes/routes.dart';
import 'package:taborq/core/utils/app_colors.dart';
import 'package:taborq/core/utils/app_text_styles.dart';
import 'package:taborq/features/auth/presentation/widgets/default_button.dart';
import 'package:taborq/features/auth/presentation/widgets/default_form_filed.dart';
import 'package:taborq/features/auth/presentation/widgets/default_swap_between_login_and_register.dart';

class ForgetPasswordScreen extends StatelessWidget {
  const ForgetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              children: [
                Text("Forgot Password?", style: AppTextStyles.headStyle),
                Gap(10),
                Text(
                  textAlign: TextAlign.center,
                  "No worries, it happens to the best of us.Enter your email below and we'll sendyou a sanctuary for your credentials.",
                  style: AppTextStyles.textStyle16.copyWith(
                    color: AppColors.primaryColor1,
                  ),
                ),
                Gap(20),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20),
                  // margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  decoration: BoxDecoration(
                    color: AppColors.lightColor,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Email Adress",
                        style: AppTextStyles.textStyle12.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor1,
                        ),
                      ),
                      Gap(5),
                      DefaultFormFiled(hintText: "name@gmail.com"),
                      Gap(40),
                      DefaultButton(text: "Send Reset Link"),
                    ],
                  ),
                ),
                Gap(40),
                DefaultSwapBetweenLoginAndRegister(
                  text: "Remembered your password?",
                  actionText: "Sign In",
                  onPressed: () {
                    AppNavigations.pushTo(context, AppRoutes.login);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
