import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gap/flutter_gap.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
        } else {
          // إغلاق ديايلوج التحميل لأي حالة أخرى غير التحميل
          if (ModalRoute.of(context)?.isCurrent == false &&
              state is! AuthTermsState) {
            Navigator.of(context, rootNavigator: true).pop();
          }

          if (state is AuthVerifyEmailState) {
            Fluttertoast.showToast(
              msg: "Verification email sent. Please check your inbox.",
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: AppColors.primaryColor,
              textColor: Colors.white,
            );
            AppNavigations.pushTo(context, AppRoutes.verifyEmail, extra: cubit);
          } else if (state is AuthSuccessState) {
            Fluttertoast.showToast(
              msg: "Successfully signed in",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.green,
              textColor: Colors.white,
            );
            AppNavigations.pushReplacementTo(context, AppRoutes.login);
          } else if (state is AuthErrorState) {
            Fluttertoast.showToast(
              msg: "state.error",
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.redAccent,
              textColor: Colors.white,
            );
          }
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
            physics: const BouncingScrollPhysics(),
            child: Form(
              key: cubit.formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Create Account", style: AppTextStyles.headStyle),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 20,
                    ),
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
                        const Gap(10),
                        DefaultFormFiled(
                          controller: cubit.nameController,
                          hintText: "Full Name",
                          keyboardType: TextInputType.text,
                          prefixIcon: const Icon(Icons.person),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please Enter Your Name";
                            }
                            if (!AppRegex.isUsernameValid(value)) {
                              return 'Please enter your first and last name in English';
                            }
                            return null;
                          },
                        ),
                        const Gap(20),
                        Text(
                          "Email address",
                          style: AppTextStyles.textStyle12.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryColor1,
                          ),
                        ),
                        const Gap(10),
                        DefaultFormFiled(
                          controller: cubit.emailController,
                          hintText: "name@gmail.com",
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: const Icon(Icons.email),
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
                          "Phone Number",
                          style: AppTextStyles.textStyle12.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryColor1,
                          ),
                        ),
                        const Gap(10),
                        DefaultFormFiled(
                          controller: cubit.phoneController,
                          hintText: "(+20)1220632344",
                          keyboardType: TextInputType.phone,
                          prefixIcon: const Icon(Icons.phone),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please Enter your Phone Number";
                            }
                            if (!AppRegex.isEgyptianPhoneValid(value)) {
                              return "Invalid Egyptian Number";
                            }
                            return null;
                          },
                        ),
                        const Gap(20),
                        Text(
                          "Password",
                          style: AppTextStyles.textStyle12.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryColor1,
                          ),
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
                        const Gap(20),
                        Text(
                          "Confirm Password",
                          style: AppTextStyles.textStyle12.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryColor1,
                          ),
                        ),
                        const Gap(10),
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
                        const Gap(10),
                        BlocBuilder<AuthCubit, AuthState>(
                          buildWhen: (previous, current) =>
                              current is AuthTermsState,
                          builder: (context, state) {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Checkbox(
                                  activeColor: AppColors.primaryColor,
                                  value: cubit.termsAccepted,
                                  onChanged: (value) {
                                    cubit.setTermsAccepted(value ?? false);
                                  },
                                ),
                                Expanded(
                                  child: Wrap(
                                    children: [
                                      Text(
                                        "I agree to the ",
                                        style: AppTextStyles.textStyle12
                                            .copyWith(
                                              color: AppColors.primaryColor1,
                                            ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          AppNavigations.pushTo(
                                            context,
                                            AppRoutes.terms,
                                            extra: cubit,
                                          );
                                        },
                                        child: Text(
                                          "Terms and Conditions",
                                          style: AppTextStyles.textStyle12
                                              .copyWith(
                                                color: AppColors.primaryColor,
                                                fontWeight: FontWeight.bold,
                                                decoration:
                                                    TextDecoration.underline,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        const Gap(30),
                        DefaultButton(
                          text: "Sign Up",
                          onPressed: () {
                            if (!cubit.termsAccepted) {
                              Fluttertoast.showToast(
                                msg:
                                    "Please accept the Terms and Conditions first",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                backgroundColor: Colors.orange,
                                textColor: Colors.white,
                              );
                              return;
                            }
                            if (cubit.formKey.currentState!.validate()) {
                              cubit.register();
                            }
                          },
                        ),
                        const Gap(50),
                        Row(
                          children: [
                            const Expanded(child: Divider()),
                            const Gap(5),
                            Text(
                              "Or join with",
                              style: AppTextStyles.textStyle12.copyWith(
                                color: AppColors.primaryColor1,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Gap(5),
                            const Expanded(child: Divider()),
                          ],
                        ),
                        const Gap(30),
                        DefaultAnthorMethodsForLogin(cubit: cubit),
                        const Gap(10),
                        DefaultSwapBetweenLoginAndRegister(
                          text: "Already have an account? ",
                          actionText: "Log In",
                          onPressed: () {
                            cubit.clearControllers();
                            AppNavigations.pushReplacementTo(
                              context,
                              AppRoutes.login,
                            );
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
