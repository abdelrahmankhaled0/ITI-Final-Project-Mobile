import 'package:flutter/material.dart';
import 'package:taborq/core/utils/app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      textSelectionTheme: TextSelectionThemeData(
        selectionHandleColor: AppColors.primaryColor,
        selectionColor: AppColors.primaryColor,
        cursorColor: AppColors.primaryColor,
      ),
      dialogTheme: DialogThemeData(backgroundColor: AppColors.darkColor),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      textSelectionTheme: TextSelectionThemeData(
        selectionColor: AppColors.primaryColor,
        selectionHandleColor: AppColors.primaryColor,
        cursorColor: AppColors.primaryColor,
      ),
    );
  }
}
