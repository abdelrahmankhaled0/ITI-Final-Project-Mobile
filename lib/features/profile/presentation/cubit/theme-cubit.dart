import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// 🌟 لا تنسي استيراد ملف الـ CashHelper هنا حسب مساره الصحيح في مشروعك
import 'package:taborq/core/services/local/cash_helper.dart';

class ThemeCubit extends Cubit<ThemeMode> {

  // 🌟 1. تعديل الـ Constructor ليستقبل الثيم المحفوظ القادم من الـ main ويحدده كحالة ابتدائية
  ThemeCubit(String initialTheme)
      : super(initialTheme == 'dark' ? ThemeMode.dark : ThemeMode.light);

  // دالة تبديل الثيم بناءً على حالة الـ Switch
  void toggleTheme(bool isDark) {
    emit(isDark ? ThemeMode.dark : ThemeMode.light);

    // 🌟 2. حفظ المود الجديد في الكاش فوراً عند التغيير لكي يتذكره التطبيق المرة القادمة
    CashHelper.setData('theme_mode', isDark ? 'dark' : 'light');
  }
}
