import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:taborq/core/utils/app_colors.dart';
import 'package:taborq/core/utils/app_text_styles.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      cardColor: Colors.grey.shade50,

      textSelectionTheme: TextSelectionThemeData(
        selectionHandleColor: AppColors.primaryColor,
        selectionColor: AppColors.primaryColor.withValues(alpha: 0.3),
        cursorColor: AppColors.primaryColor,
      ),
      appBarTheme: AppBarThemeData(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.lightColor,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
      ),
      scaffoldBackgroundColor: AppColors.lightColor,

      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: AppColors.primaryColor,
      ),

      inputDecorationTheme: InputDecorationThemeData(
        filled: true,
        fillColor: AppColors.neutralColor10,
        errorStyle: const TextStyle(fontSize: 10),
        hintStyle: AppTextStyles.textStyle12.copyWith(
          color: AppColors.neutralColor4,
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        errorMaxLines: 4,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          // fixedSize: const Size(400, 50),
          backgroundColor: AppColors.primaryColor,
          foregroundColor: AppColors.lightColor,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(backgroundColor: AppColors.primaryColor),
      ),
      textTheme: TextTheme(
        headlineLarge: AppTextStyles.textStyle24.copyWith(
          color: const Color(0xFF1A1A1A),
          fontWeight: FontWeight.bold,
        ),
        titleLarge: AppTextStyles.textStyle18.copyWith(
          color: const Color(0xFF2D2D2D), // رمادي داكن شيك
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: AppTextStyles.textStyle16.copyWith(
          color: const Color(0xFF333333), // مريح جداً للقراءة والمدخلات
        ),
        // خط الشرح الفرعي أو التفاصيل الصغيرة جوه الكروت
        bodyMedium: AppTextStyles.textStyle14.copyWith(
          color: AppColors.neutralColor4,
        ),
        // خط النصوص اللي جوه الأزرار (Buttons)
        labelLarge: AppTextStyles.textStyle14.copyWith(
          color:
              AppColors.lightColor, // أبيض عشان يبان جوه الزرار الأزرق/الأخضر
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,

      brightness: Brightness.dark,
      cardColor: Colors.grey.shade900,
      appBarTheme: const AppBarTheme(
        backgroundColor:
            Colors.transparent, // شفاف بيدي مظهر مودرن جداً في الدارك
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness:
              Brightness.light, // أيقونات بيضاء لأن الخلفية غامقة
          statusBarBrightness: Brightness.dark,
        ),
      ),
      scaffoldBackgroundColor: AppColors.primaryColor1,
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: AppColors.lightColor,
      ),
      textSelectionTheme: TextSelectionThemeData(
        selectionColor: AppColors.primaryColor,
        selectionHandleColor: AppColors.primaryColor,
        cursorColor: AppColors.primaryColor,
      ),
      textTheme: TextTheme(
        // خط العناوين الكبيرة (مثلاً: "حجوزاتي"، "الرئيسية")
        headlineLarge: AppTextStyles.textStyle24.copyWith(
          color: AppColors.lightColor, // أبيض ناصع للعناوين عشان تظهر بقوة
          fontWeight: FontWeight.bold,
        ),
        // خط العناوين المتوسطة (اسم المحل، عنوان الكارت، اسم الخدمة)
        titleLarge: AppTextStyles.textStyle18.copyWith(
          color: const Color(0xFFE0E0E0), // رمادي فاتح جداً هادي ومش فاقع
          fontWeight: FontWeight.w600,
        ),
        // خط الـ TextFormField والمدخلات والكتابة الطويلة
        bodyLarge: AppTextStyles.textStyle16.copyWith(
          color: AppColors
              .lightColor, // أبيض صريح عشان اليوزر يشوف هو بيكتب إيه بوضوح
        ),
        // خط الشرح الفرعي أو التفاصيل الصغيرة جوه الكروت
        bodyMedium: AppTextStyles.textStyle14.copyWith(
          color: AppColors.neutralColor9, // رمادي فاتح هادي للتفاصيل الجانبية
        ),
        // خط النصوص اللي جوه الأزرار (Buttons)
        labelLarge: AppTextStyles.textStyle14.copyWith(
          color: AppColors
              .lightColor, // بيفضل أبيض لأن الزرار خلفيته غامقة في المودين
          fontWeight: FontWeight.w600,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey.shade800,
        errorStyle: const TextStyle(fontSize: 10),
        hintStyle: AppTextStyles.textStyle12.copyWith(
          color: AppColors.neutralColor9,
        ),
        suffixIconColor: AppColors.neutralColor9,
        prefixIconColor: AppColors.neutralColor9,

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        errorMaxLines: 4,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          // fixedSize: const Size(400, 50),
          backgroundColor: AppColors.primaryColor,
          foregroundColor: AppColors.lightColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(backgroundColor: AppColors.primaryColor),
      ),
    );
  }
}
