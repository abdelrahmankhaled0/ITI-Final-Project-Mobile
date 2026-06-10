import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gap/flutter_gap.dart';
import 'package:taborq/core/routes/navigations.dart';
import 'package:taborq/core/routes/routes.dart';
import 'package:taborq/core/utils/app_colors.dart';
import 'package:taborq/core/utils/app_regex.dart';
import 'package:taborq/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:taborq/features/auth/presentation/cubit/auth_state.dart';
import 'package:taborq/features/auth/presentation/widgets/default_button.dart';
import 'package:taborq/features/auth/presentation/widgets/default_form_filed.dart';
import 'package:taborq/features/auth/presentation/widgets/default_swap_between_login_and_register.dart';

class ForgetPasswordScreen extends StatelessWidget {
  const ForgetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = AuthCubit.get(context);

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

          if (state is AuthPasswordResetEmailSentState) {
            cubit.emailController.clear();
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                return AlertDialog(
                  title: const Text('Reset Link Sent'),
                  content: const Text(
                    'A password reset link has been sent to your email. Open the link to set a new password. If you do not see the email, please check your spam folder.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        AppNavigations.pushReplacementTo(
                          context,
                          AppRoutes.login,
                        );
                      },
                      child: const Text('Back to Login'),
                    ),
                  ],
                );
              },
            );
          } else if (state is AuthErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error), backgroundColor: Colors.red),
            );
          }
        }
      },
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Form(
                key: cubit.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      height: MediaQuery.heightOf(context) * 0.7,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.darkColor.withAlpha(40),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Forgot Password?",
                            style: Theme.of(context).textTheme.headlineLarge,
                          ),
                          Gap(10),
                          Text(
                            "Enter the email address linked to your account. We will send a secure password reset link to your email.",
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Spacer(flex: 1),
                          Text(
                            "Email Address",
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Gap(5),
                          DefaultFormFiled(
                            controller: cubit.emailController,
                            hintText: "name@gmail.com",
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              if (!AppRegex.isEmailValid(value)) {
                                return 'Invalid email address';
                              }
                              return null;
                            },
                          ),
                          Gap(20),
                          DefaultButton(
                            text: "Send Reset Link",
                            onPressed: () {
                              if (cubit.formKey.currentState!.validate()) {
                                cubit.sendPasswordResetEmail(
                                  cubit.emailController.text.trim(),
                                );
                              }
                            },
                          ),
                          Spacer(flex: 1),
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
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
