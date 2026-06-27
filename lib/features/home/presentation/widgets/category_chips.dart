import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taborq/core/utils/app_colors.dart';
import 'package:taborq/core/utils/app_text_styles.dart';
import 'package:taborq/features/home/presentation/cubit/home_cubit.dart';

class CategoryChips extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;

  const CategoryChips({
    super.key,
    required this.categories,
    required this.selectedCategory
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // 🌟 تعريف الثيم
    final isDark = theme.brightness == Brightness.dark;

    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final isSelected = categories[index] == selectedCategory;

          // 🌟 تحديد الألوان ديناميكياً
          final backgroundColor = isSelected
              ? AppColors.primaryColor
              : (isDark ? theme.cardColor : AppColors
              .lightgrey); // لون الدارك مود هو لون الكارد

          final textColor = isSelected
              ? Colors.white
              : (isDark ? Colors.white70 : AppColors.neutralColor3);

          return GestureDetector(
            onTap: () {
              context.read<HomeCubit>().filterByCategory(categories[index]);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                categories[index],
                style: AppTextStyles.textStyle14.copyWith(
                  color: textColor,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}