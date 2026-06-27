import 'package:flutter/material.dart';
import 'package:taborq/core/utils/app_colors.dart';
import 'package:taborq/core/utils/app_text_styles.dart';

// في ملف DefaultButton.dart
class DefaultButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const DefaultButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 65,
      decoration: BoxDecoration(
        // استخدام اللون الأساسي مع التدرج المطلوب
        gradient: LinearGradient(
          colors: [
            const Color(0xFF2F6F6D),
            const Color(0xFF2F6F6D).withOpacity(0.82),

          ],
        ),
        borderRadius: BorderRadius.circular(50),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent, // شفاف لنظهر الـ Gradient من الكونتير
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
        child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 16)),
      ),
    );
  }
}
