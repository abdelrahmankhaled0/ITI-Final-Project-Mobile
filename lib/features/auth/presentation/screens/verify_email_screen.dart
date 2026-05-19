import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
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

    // متغير محلي لمتابعة سياق (Context) الـ Dialog المفتوح فقط
    BuildContext? dialogContext;

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        // 1. أول ما يبدأ تحميل.. نفتح الدايلوج ونخزن الـ Context بتاعه
        if (state is AuthLoadingState) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (dContext) {
              dialogContext = dContext; // حفظنا سياق الدايلوج هنا
              return const Center(child: CircularProgressIndicator());
            },
          );
        } else {
          // 2. لو خرجنا من الـ Loading لأي حالة ثانية (خطأ أو نجاح) نقفل الدايلوج فوراً بشكل آمن
          if (dialogContext != null) {
            Navigator.pop(dialogContext!);
            dialogContext = null; // تصفير المتغير للحماية
          }

          // 3. لو تم إعادة إرسال إيميل التفعيل
          if (state is AuthVerifyEmailState) {
            Fluttertoast.showToast(
              msg: "Verification email sent",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: AppColors.primaryColor,
              textColor: Colors.white,
              fontSize: 14.0,
            );
          }
          // 4. لو اتأكد إنك عملت فيريفاي فعلاً (النجاح التام)
          else if (state is AuthSuccessState) {
            Fluttertoast.showToast(
              msg: "Email verified successfully!",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.green, // التوست الأخضر الجميل
              textColor: Colors.white,
              fontSize: 14.0,
            );
            // يروح لصفحة اللوجين فوراً
            AppNavigations.pushReplacementTo(context, AppRoutes.login);
          }
          // 5. لو داس وهو لسه مفعّلش (حالة الخطأ)
          else if (state is AuthErrorState) {
            // هيفضل ثابت في مكانه في السكرين ويظهر التوست الأحمر بالإيرور
            Fluttertoast.showToast(
              msg: state.error,
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.redAccent,
              textColor: Colors.white,
              fontSize: 14.0,
            );
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
