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
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final isSelected = categories[index] == selectedCategory;
          return GestureDetector(
            onTap: () {
              context.read<HomeCubit>().filterByCategory(categories[index]);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryColor : AppColors.lightgrey,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? AppColors.primaryColor : AppColors.lightgrey,
                  width: 1.5,
                ),
              ),
              child: Text(
                categories[index],
                style: AppTextStyles.textStyle14.copyWith(
                  color: isSelected ? AppColors.lightColor : AppColors.neutralColor3,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
