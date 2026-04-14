import 'package:flutter/material.dart';
import 'package:flutter_gap/flutter_gap.dart';
import 'package:taborq/core/utils/app_colors.dart';
import 'package:taborq/core/utils/app_text_styles.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightColor,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: EdgeInsets.all(40),
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 100),
        decoration: BoxDecoration(
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05))],
          borderRadius: BorderRadius.circular(24),
        ),
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
            Text("Email address"),
            Gap(5),
            TextFormField(
              cursorColor: AppColors.primaryColor,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.neutralColor9,
                prefixIcon: Icon(Icons.email),
                hint: Text(
                  style: AppTextStyles.textStyle12.copyWith(
                    color: AppColors.neutralColor4,
                  ),
                  "name@gmail.com",
                ),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
