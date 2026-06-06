import 'package:flutter/material.dart';
import 'package:taborq/core/utils/app_colors.dart';
import 'package:taborq/core/utils/app_text_styles.dart';

class SearchBarWidget extends StatelessWidget {
  final ValueChanged<String>? onChanged;
  const SearchBarWidget({super.key , this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.neutralColor10,
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: 'Search clinics, specialists...',
          hintStyle: AppTextStyles.textStyle14.copyWith(
            color: AppColors.neutralColor5,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: AppColors.neutralColor5,
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}