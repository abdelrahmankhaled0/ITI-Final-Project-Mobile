import 'package:flutter/material.dart';
import 'package:taborq/core/utils/app_colors.dart';

class SearchBarWidget extends StatelessWidget {
  final ValueChanged<String>? onChanged;
  const SearchBarWidget({super.key, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.neutralColor10,
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextFormField(
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: 'Search clinics, specialists...',
          hintStyle: Theme.of(context).textTheme.bodyLarge,
          prefixIcon: Icon(Icons.search, size: 20),
          // border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}
