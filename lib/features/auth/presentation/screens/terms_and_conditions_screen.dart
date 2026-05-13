import 'package:flutter/material.dart';
import 'package:taborq/core/routes/navigations.dart';
import 'package:taborq/core/utils/app_colors.dart';
import 'package:taborq/core/utils/app_text_styles.dart';
import 'package:taborq/features/auth/presentation/cubit/auth_cubit.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightColor,
      appBar: AppBar(
        title: const Text('Terms & Conditions'),
        elevation: 0,
        backgroundColor: AppColors.primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.lightColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryColor1.withAlpha(
                        (0.1 * 255).round(),
                      ),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Terms & Conditions',
                        style: AppTextStyles.headStyle.copyWith(fontSize: 24),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Before you create your account, please read and agree to the terms below. Your privacy and data security are our top priorities.',
                        style: AppTextStyles.textStyle14.copyWith(
                          color: AppColors.primaryColor1.withAlpha(
                            (0.9 * 255).round(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        '1. Account Use',
                        style: AppTextStyles.textStyle16.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'You agree to use the app for legitimate purposes only. Please keep your login details secure and do not share them with others.',
                        style: AppTextStyles.textStyle14,
                      ),
                      const SizedBox(height: 18),
                      Text(
                        '2. Privacy',
                        style: AppTextStyles.textStyle16.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'We collect your account information to personalize your experience. We do not sell your data to third parties.',
                        style: AppTextStyles.textStyle14,
                      ),
                      const SizedBox(height: 18),
                      Text(
                        '3. Email Verification',
                        style: AppTextStyles.textStyle16.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'You must verify your email address before your account is fully activated. This helps protect you from unauthorized access.',
                        style: AppTextStyles.textStyle14,
                      ),
                      const SizedBox(height: 18),
                      Text(
                        '4. Password Reset',
                        style: AppTextStyles.textStyle16.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'If you forget your password, we will send a reset link to your email. Follow the instructions to safely update your password.',
                        style: AppTextStyles.textStyle14,
                      ),
                      const SizedBox(height: 18),
                      Text(
                        '5. Contact',
                        style: AppTextStyles.textStyle16.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'If you have questions, contact support through the app or the email address provided in the help section.',
                        style: AppTextStyles.textStyle14,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () {
                  AuthCubit.get(context).setTermsAccepted(true);
                  AppNavigations.pop(context);
                },
                child: Text(
                  'Agree and Continue',
                  style: AppTextStyles.textStyle16.copyWith(
                    color: AppColors.lightColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
