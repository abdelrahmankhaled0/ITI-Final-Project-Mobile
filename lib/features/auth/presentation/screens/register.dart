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
import 'package:taborq/features/auth/presentation/widgets/default_form_filed.dart';
import 'package:taborq/features/auth/presentation/widgets/default_swap_between_login_and_register.dart';
import 'package:taborq/features/auth/presentation/widgets/password_default_form_filed.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

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
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Sucessfully Sign In")));
          AppNavigations.pushReplacementTo(context, AppRoutes.login);
        } else if (state is AuthErrorState) {
          Navigator.pop(context);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.error)));
        }
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        body: Center(
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Form(
              key: cubit.formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Create Account", style: AppTextStyles.headStyle),

                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20),
                    margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    decoration: BoxDecoration(
                      color: AppColors.lightColor,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Full Name",
                          style: AppTextStyles.textStyle12.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryColor1,
                          ),
                        ),
                        Gap(10),
                        DefaultFormFiled(
                          controller: cubit.nameController,
                          hintText: "Full Name",
                          keyboardType: TextInputType.text,
                          prefixIcon: Icon(Icons.person),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please Enter Your Name";
                            }
                            if (!AppRegex.isUsernameValid(value)) {
                              return "Please Enter a Valid Name";
                            }
                            return null;
                          },
                        ),
                        Gap(20),
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
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: Icon(Icons.email),
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
                          "Phone Number",
                          style: AppTextStyles.textStyle12.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryColor1,
                          ),
                        ),
                        Gap(10),
                        DefaultFormFiled(
                          controller: cubit.phoneController,
                          hintText: "(+20)1220632344",
                          keyboardType: TextInputType.phone,
                          prefixIcon: Icon(Icons.phone),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please Enter your Phone Number";
                            }
                            if (!AppRegex.isEgyptianPhoneValid(value)) {
                              return "Invalid Egyption Number";
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
                              return "Password must be at least 8 characters long.\nIt must contain at least one uppercase letter.\nIt must contain at least one lowercase letter.\nIt must contain at least one number.\nIt must contain at least one special character ! @ # \$ % &)";
                            }
                            return null;
                          },
                        ),
                        Gap(20),
                        Text(
                          "Confirm Password",
                          style: AppTextStyles.textStyle12.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryColor1,
                          ),
                        ),
                        Gap(10),
                        PasswordDefaultFormFiled(
                          controller: cubit.confirmPasswordController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please Enter Password";
                            }
                            if (value != cubit.passwordController.text) {
                              return "Password Not Match";
                            }
                            return null;
                          },
                        ),
                        Gap(50),
                        DefaultButton(
                          text: "Sign Up",
                          onPressed: () {
                            if (cubit.formKey.currentState!.validate()) {
                              cubit.register();
                            }
                          },
                        ),
                        Gap(50),
                        Row(
                          children: [
                            Expanded(child: Divider()),
                            Gap(5),
                            Text(
                              "Or join with",
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
                        Gap(10),
                        DefaultSwapBetweenLoginAndRegister(
                          text: "Already have an account?",
                          actionText: "Log In",

                          onPressed: () {
                            cubit.clearControllers();
                            AppNavigations.pushTo(context, AppRoutes.login);
                          },
                          // bgColor: AppColors.primaryColor1,
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
