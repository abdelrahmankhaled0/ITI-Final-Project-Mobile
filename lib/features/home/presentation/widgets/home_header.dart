import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:taborq/core/utils/app_colors.dart';
import 'package:taborq/core/utils/app_text_styles.dart';

class HomeHeader extends StatelessWidget {
  final String userName;
  final String? profileImage;

  const HomeHeader({super.key, required this.userName, this.profileImage});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
      color: Colors.transparent,
      child: Row(
        children: [
          InkWell(
             onTap: (){context.go('/profile');},
            child: CircleAvatar(
              radius: 25,
              backgroundColor: AppColors.primaryColor5,
              backgroundImage: profileImage != null
                  ? NetworkImage(profileImage!)
                  : null,
              child: profileImage == null
                  ? const Icon(Icons.person, color: AppColors.lightColor)
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'WELCOME BACK,',
                  style: AppTextStyles.textStyle16.copyWith(
                    color: AppColors.lightColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  "${userName.toUpperCase()}  👋",
                  style: AppTextStyles.textStyle18.copyWith(
                    color: AppColors.lightColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  'BOOK YOUR TURN, SKIP THE WAIT',
                  style: AppTextStyles.textStyle10.copyWith(
                    color: AppColors.lightColor,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          _buildNotificationIcon(context),
        ],
      ),
    );
  }

  Widget _buildNotificationIcon(BuildContext context) {
    return InkWell(
      onTap: () {
        // BottomNav.changeIndex(context, 2);
        context.go('/notifications');
      },
      borderRadius: BorderRadius.circular(50),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.lightColor.withOpacity(0.15),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.notifications_none_rounded,
          color: AppColors.lightColor,
          size: 24,
        ),
      ),
    );
  }
}
