import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gap/flutter_gap.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:taborq/core/routes/navigations.dart';
import 'package:taborq/core/routes/routes.dart';
import 'package:taborq/core/utils/app_colors.dart';
import 'package:taborq/core/utils/app_regex.dart';
import 'package:taborq/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:taborq/features/auth/presentation/cubit/auth_state.dart';
import 'package:taborq/features/auth/presentation/widgets/default_another_methods_for_login.dart';
import 'package:taborq/features/auth/presentation/widgets/default_button.dart';
import 'package:taborq/features/auth/presentation/widgets/default_forget_password_row.dart';
import 'package:taborq/features/auth/presentation/widgets/default_form_filed.dart';
import 'package:taborq/features/auth/presentation/widgets/default_swap_between_login_and_register.dart';
import 'package:taborq/features/auth/presentation/widgets/password_default_form_filed.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var cubit = AuthCubit.get(context);

    // متغير محلي لمتابعة سياق الـ Loading Dialog المفتوح
    BuildContext? dialogContext;

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        // 1. حالة التحميل (Loading): نفتح الدايلوج ونحفظ الـ Context بتاعه
        if (state is AuthLoadingState) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (dContext) {
              dialogContext = dContext;
              return Center(child: CircularProgressIndicator());
            },
          );
        } else {
          // 2. قفل دايلوج التحميل فوراً بشكل آمن لو رجعنا لأي حالة تانية
          if (dialogContext != null) {
            Navigator.pop(dialogContext!);
            dialogContext = null; // تصفير المتغير للحماية
          }

          // 3. حالة النجاح (Success Login)
          if (state is AuthSuccessState) {
            Fluttertoast.showToast(
              msg: "Logged in successfully!",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.green, // التوست الأخضر الجميل عند النجاح
              textColor: Colors.white,
              fontSize: 14.0,
            );
            // الانتقال لصفحة الهوم بنجاح
            AppNavigations.pushReplacementTo(context, AppRoutes.home);
          }
          // 4. حالة الخطأ (Error)
          else if (state is AuthErrorState) {
            Fluttertoast.showToast(
              msg: "Email or Password is uncorrect",
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.redAccent, // توست أحمر عند حدوث خطأ
              textColor: Colors.white,
              fontSize: 14.0,
            );
          }
        }
      },
      child: Scaffold(
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 100),
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
            child: Form(
              key: cubit.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome back",
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const Gap(10),
                  Text(
                    "Please enter your details to continue.",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const Gap(50),
                  Text(
                    "Email address",
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const Gap(10),
                  DefaultFormFiled(
                    controller: cubit.emailController,
                    hintText: "name@gmail.com",
                    prefixIcon: const Icon(Icons.email),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please Enter Your Email";
                      }
                      if (!AppRegex.isEmailValid(value)) {
                        return "Invalid Email Address";
                      }
                      return null;
                    },
                  ),
                  const Gap(20),
                  Text(
                    "Password",
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const Gap(10),
                  PasswordDefaultFormFiled(
                    controller: cubit.passwordController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please Enter Password";
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
                  const DefaultForgetPasswordRow(),
                  const Gap(20),
                  DefaultButton(
                    text: "Login",
                    onPressed: () {
                      if (cubit.formKey.currentState!.validate()) {
                        cubit.login(
                          email: cubit.emailController.text.trim(),
                          password: cubit.passwordController.text,
                        );
                      }
                    },
                  ),
                  const Gap(50),
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      const Gap(5),
                      Text(
                        "Or continue with",
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const Gap(5),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  const Gap(30),
                  DefaultAnthorMethodsForLogin(cubit: cubit),
                  const Gap(20),
                  DefaultSwapBetweenLoginAndRegister(
                    text: "Don't have an account?",
                    actionText: "Create one now",
                    onPressed: () {
                      cubit.clearControllers();
                      AppNavigations.pushReplacementTo(
                        context,
                        AppRoutes.register,
                      );
                    },
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
