import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taborq/core/routes/navigations.dart';
import 'package:taborq/core/routes/routes.dart';
import 'package:taborq/core/utils/app_colors.dart';
import 'package:taborq/core/utils/app_regex.dart';
import 'package:taborq/core/utils/app_text_styles.dart';
import 'package:taborq/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:taborq/features/auth/presentation/cubit/auth_state.dart';
import 'package:taborq/features/auth/presentation/widgets/default_button.dart';
import 'package:taborq/features/auth/presentation/widgets/password_default_form_filed.dart';

class ChangePasswordScreen extends StatefulWidget {
  final String? actionCode;

  const ChangePasswordScreen({super.key, this.actionCode});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = AuthCubit.get(context);

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthLoadingState) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            ),
          );
        } else {
          Navigator.of(context, rootNavigator: true).pop();

          if (state is AuthPasswordResetSuccessState) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Password changed successfully.')),
            );
            AppNavigations.pushReplacementTo(context, AppRoutes.login);
          } else if (state is AuthErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error), backgroundColor: Colors.red),
            );
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Change Password'), elevation: 0),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Form(
              key: cubit.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Set a new password', style: AppTextStyles.headStyle),
                  const SizedBox(height: 12),
                  Text(
                    'Enter a strong password and confirm it below.',
                    style: AppTextStyles.textStyle16.copyWith(
                      color: AppColors.primaryColor1,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.lightColor,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'New Password',
                          style: AppTextStyles.textStyle12.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryColor1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        PasswordDefaultFormFiled(
                          controller: passwordController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a new password';
                            }
                            if (!AppRegex.isPasswordValid(value)) {
                              return "Password Must contain at least:\n"
                                  "• 8 characters\n"
                                  "• Uppercase & Lowercase letters\n"
                                  "• Number & Special character (!@#\$%)";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Confirm Password',
                          style: AppTextStyles.textStyle12.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryColor1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        PasswordDefaultFormFiled(
                          controller: confirmPasswordController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please confirm your password';
                            }
                            if (value != passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 30),
                        DefaultButton(
                          text: 'Change Password',
                          onPressed: () {
                            if (cubit.formKey.currentState!.validate()) {
                              // سحب الكود من الـ widget (اللي استلمناه من GoRouter)
                              final actionCode =
                                  widget.actionCode?.trim() ?? '';

                              if (actionCode.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Invalid password reset code. Please use the link in your email.',
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }

                              // تنفيذ عملية التغيير
                              cubit.confirmPasswordReset(
                                codeOrLink: actionCode,
                                newPassword: passwordController.text.trim(),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
