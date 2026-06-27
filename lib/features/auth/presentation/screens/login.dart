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
    final theme = Theme.of(context);

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
              return  Center(child: CircularProgressIndicator(color: AppColors.primaryColor,));
            },
          );
        } else {
          // 2. قفل دايلوج التحميل فوراً
          if (dialogContext != null) {
            Navigator.pop(dialogContext!);
            dialogContext = null;
          }

          // 3. حالة النجاح
          if (state is AuthSuccessState) {
            Fluttertoast.showToast(
              msg: "Logged in successfully!",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.green,
              textColor: Colors.white,
              fontSize: 14.0,
            );
            AppNavigations.pushReplacementTo(context, AppRoutes.home);
          }
          // 4. حالة الخطأ
          else if (state is AuthErrorState) {
            Fluttertoast.showToast(
              msg: "Email or Password is uncorrect",
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
        resizeToAvoidBottomInset: false,
        backgroundColor: theme.primaryColor, // اللون الأساسي للثيم
        body: Stack(
          children: [
            // الجزء العلوي الملون
            Container(
              padding: const EdgeInsets.only(top: 80, left: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Welcome back",
                      style: theme.textTheme.headlineLarge?.copyWith(color: Colors.white)),
                  const Gap(10),
                  Text("Log in to continue...",
                      style: theme.textTheme.titleMedium?.copyWith(color: Colors.white70)),
                ],
              ),
            ),

            // الكارت الأبيض (النموذج)
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.76,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(48),
                    topRight: Radius.circular(48),
                  ),
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Form(
                    key: cubit.formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Gap(50),
                        Text("Email", style: theme.textTheme.bodyMedium),
                        const Gap(10),
                        DefaultFormFiled(
                          controller: cubit.emailController,
                          hintText: "name@gmail.com",
                          prefixIcon: const Icon(Icons.email),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) return "Please Enter Your Email";
                            if (!AppRegex.isEmailValid(value)) return "Invalid Email Address";
                            return null;
                          },
                        ),
                        const Gap(20),
                        Text("Password", style: theme.textTheme.bodyMedium),
                        const Gap(10),
                        PasswordDefaultFormFiled(
                          controller: cubit.passwordController,
                          validator: (value) {
                            if (value == null || value.isEmpty) return "Please Enter Password";
                            if (!AppRegex.isPasswordValid(value)) return "Invalid Password Format";
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
                            Padding(padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: Text("Or continue with", style: theme.textTheme.bodySmall)),
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
                            AppNavigations.pushReplacementTo(context, AppRoutes.register);
                          },
                        ),
                      ],
                    ),
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