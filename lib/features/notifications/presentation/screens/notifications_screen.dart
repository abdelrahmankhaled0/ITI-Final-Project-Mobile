import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:taborq/core/utils/app_colors.dart';
import 'package:taborq/core/utils/app_text_styles.dart';
import 'package:taborq/features/home/widgets/bottom_nav.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightColor,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: Text('Notifications', style: AppTextStyles.textStyle18.copyWith(color: AppColors.lightColor)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.lightColor),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: const Center(
        child: Text("No new notifications yet!"),
      ),
    );
  }
}