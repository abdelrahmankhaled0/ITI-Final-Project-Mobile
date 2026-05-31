import 'dart:async';

import 'package:flutter/material.dart';
import 'package:taborq/core/routes/navigations.dart';
import 'package:taborq/core/routes/routes.dart';
import 'package:taborq/core/utils/app_images.dart';

class SplachScreen extends StatefulWidget {
  const SplachScreen({super.key});

  @override
  State<SplachScreen> createState() => _SplachScreenState();
}

class _SplachScreenState extends State<SplachScreen> {
  @override
  void initState() {
    Timer(Duration(seconds: 2), () {
      AppNavigations.pushReplacementTo(context, AppRoutes.onboarding);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: AppColors.primaryColor,
      body: Center(
        child: Image(
          image: AssetImage(AppImages.logo),
          fit: BoxFit.fill,
          height: double.infinity,
        ),
      ),
    );
  }
}
