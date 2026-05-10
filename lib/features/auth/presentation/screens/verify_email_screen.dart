import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taborq/core/routes/navigations.dart';
import 'package:taborq/core/routes/routes.dart';
import 'package:taborq/core/utils/app_colors.dart';
import 'package:taborq/core/utils/app_text_styles.dart';
import 'package:taborq/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:taborq/features/auth/presentation/cubit/auth_state.dart';
import 'package:taborq/features/auth/presentation/widgets/default_button.dart';

class VerifyEmailScreen extends StatelessWidget {
  const VerifyEmailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = AuthCubit.get(context);
    final email = cubit.emailController.text.trim();

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthLoadingState) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const Center(child: CircularProgressIndicator()),
          );
        } else {
          Navigator.of(context, rootNavigator: true).pop();

          if (state is AuthVerifyEmailState) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Verification email sent')),
            );
          } else if (state is AuthSuccessState) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Email verified successfully!')),
            );
            AppNavigations.pushReplacementTo(context, AppRoutes.login);
          } else if (state is AuthErrorState) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.error)));
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Verify Your Email'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: AppColors.primaryColor1,
          automaticallyImplyLeading: true,
        ),
        body: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.lightColor,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryColor1.withOpacity(0.08),
                        blurRadius: 22,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primaryColor10,
                            ),
                            padding: const EdgeInsets.all(14),
                            child: Icon(
                              Icons.mark_email_read,
                              size: 28,
                              color: AppColors.primaryColor,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              'Verify Your Account',
                              style: AppTextStyles.headStyle.copyWith(
                                fontSize: 26,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      Text(
                        'A verification email has been sent to',
                        style: AppTextStyles.textStyle16.copyWith(
                          color: AppColors.primaryColor1,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        email.isEmpty ? 'your email address' : email,
                        style: AppTextStyles.textStyle16.copyWith(
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Please open your email and tap the verification link. After verifying, tap the button below to continue to login.',
                        style: AppTextStyles.textStyle14.copyWith(
                          color: AppColors.primaryColor1.withOpacity(0.8),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 18,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor10,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Need help?',
                              style: AppTextStyles.textStyle14.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryColor1,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '• Check your spam or junk folder.\n• Wait a few minutes for the email to arrive.\n• Tap RESEND if you did not receive it.',
                              style: AppTextStyles.textStyle12.copyWith(
                                color: AppColors.primaryColor1.withOpacity(
                                  0.75,
                                ),
                                height: 1.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      DefaultButton(
                        text: 'I have verified my email',
                        onPressed: () {
                          cubit.checkEmailVerification();
                        },
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () {
                            cubit.resendVerificationEmail();
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: AppColors.primaryColor10,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            'Resend verification email',
                            style: AppTextStyles.textStyle16.copyWith(
                              color: AppColors.primaryColor1,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    AppNavigations.pushReplacementTo(context, AppRoutes.login);
                  },
                  child: Text(
                    'Back to login',
                    style: AppTextStyles.textStyle14.copyWith(
                      color: AppColors.primaryColor,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
