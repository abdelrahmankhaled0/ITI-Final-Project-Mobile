import 'dart:async';

import 'package:flutter/material.dart';
import 'package:taborq/core/routes/navigations.dart';
import 'package:taborq/core/routes/routes.dart';
import 'package:taborq/core/utils/app_colors.dart';
import 'package:taborq/core/utils/app_images.dart';

class SplachScreen extends StatefulWidget {
  const SplachScreen({super.key});

  @override
  State<SplachScreen> createState() => _SplachScreenState();
}

class _SplachScreenState extends State<SplachScreen> {
  double scale = 0.0;
  double opacity = 0.0;
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        scale = 1.0;
        opacity = 1.0;
      });
    });

    Timer(Duration(seconds: 3), () {
      if (mounted) {
        AppNavigations.pushReplacementTo(context, AppRoutes.onboarding);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      body: Center(
        child: AnimatedScale(
          scale: scale,
          duration: Duration(seconds: 6),
          curve: Curves.elasticOut,
          child: AnimatedOpacity(
            opacity: opacity,
            duration: Duration(seconds: 3),
            child: Image(
              image: AssetImage(AppImages.icon),
              width: 200,
              height: 200,
            ),
          ),
        ),
      ),
    );
  }
}
