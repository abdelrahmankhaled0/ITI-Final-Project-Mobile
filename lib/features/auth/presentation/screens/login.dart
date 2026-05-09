import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gap/flutter_gap.dart';
import 'package:taborq/core/routes/navigations.dart';
import 'package:taborq/core/routes/routes.dart';
import 'package:taborq/core/utils/app_colors.dart';
import 'package:taborq/core/utils/app_regex.dart';
import 'package:taborq/core/utils/app_text_styles.dart';
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
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthLoadingState) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            ),
          );
        } else if (state is AuthSuccessState) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("success login"),
              backgroundColor: AppColors.primaryColor,
            ),
          );
          AppNavigations.pushReplacementTo(context, AppRoutes.home);
        } else if (state is AuthErrorState) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error), backgroundColor: Colors.red),
          );
        }
      },

      child: Scaffold(
        // backgroundColor: AppColors.lightColor,
        body: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Container(
            width: double.infinity,
            // height: double.infinity,
            padding: EdgeInsets.all(20),
            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 100),
            decoration: BoxDecoration(
              boxShadow: [BoxShadow(color: AppColors.lightColor)],
              borderRadius: BorderRadius.circular(24),
            ),
            child: Form(
              key: cubit.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(style: AppTextStyles.headStyle, "Welcome back"),
                  Gap(10),
                  Text(
                    style: AppTextStyles.textStyle16.copyWith(
                      color: AppColors.neutralColor6,
                    ),

                    "Please enter your details to continue.",
                  ),
                  Gap(50),
                  Text(
                    "Email address",
                    style: AppTextStyles.textStyle12.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor1,
                    ),
                  ),
                  Gap(10),
                  DefaultFormFiled(
                    controller: cubit.emailController,
                    hintText: "name@gmail.com",
                    prefixIcon: Icon(Icons.email),
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
                  Gap(20),
                  Text(
                    "Password",
                    style: AppTextStyles.textStyle12.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor1,
                    ),
                  ),
                  Gap(10),
                  PasswordDefaultFormFiled(
                    controller: cubit.passwordController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please Enter Password";
                      }
                      if (!AppRegex.isPasswordValid(value)) {
                        return "Password must be at least 8 characters long.\nIt must contain at least\none uppercase letter.\nlowercase letter.\nnumber.\nspecial character ! @ # \$ % &)";
                      }
                      return null;
                    },
                  ),
                  DefaultForgetPasswordRow(),
                  Gap(20),
                  DefaultButton(
                    text: "Login",
                    onPressed: () {
                      if (cubit.formKey.currentState!.validate()) {
                        cubit.login();
                      }
                    },
                  ),
                  Gap(50),
                  Row(
                    children: [
                      Expanded(child: Divider()),
                      Gap(5),
                      Text(
                        "Or continue with",
                        style: AppTextStyles.textStyle12.copyWith(
                          color: AppColors.primaryColor1,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Gap(5),
                      Expanded(child: Divider()),
                    ],
                  ),
                  Gap(30),
                  DefaultAnthorMethodsForLogin(),
                  Gap(20),
                  DefaultSwapBetweenLoginAndRegister(
                    text: "Don't have an account?",
                    actionText: "Create one now",

                    onPressed: () {
                      cubit.clearControllers();
                      AppNavigations.pushTo(context, AppRoutes.register);
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
