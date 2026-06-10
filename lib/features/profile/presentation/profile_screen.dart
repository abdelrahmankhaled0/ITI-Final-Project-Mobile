import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:taborq/core/routes/navigations.dart';
import 'package:taborq/core/routes/routes.dart';
import 'package:taborq/core/utils/app_colors.dart';
import 'package:taborq/core/utils/app_text_styles.dart';
import 'package:taborq/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:taborq/features/auth/presentation/cubit/auth_state.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        // 1. حالة التحميل: بنفتح Dialog يمنع اليوزر يضغط على أي حاجة لحد ما يخلص
        if (state is AuthLoadingState) {
          showDialog(
            context: context,
            barrierDismissible: false, // ميعرفش يقفله بإيده
            builder: (context) => const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.primaryColor,
                ),
              ),
            ),
          );
        }

        // 2. حالة النجاح
        if (state is AuthSuccessState) {
          Navigator.of(
            context,
            rootNavigator: true,
          ).pop(); // 🎯 قفل الـ Loading Dialog أولاً

          // التوجيه لصفحة التسجيل وتنظيف الديزاين القديم
          AppNavigations.pushReplacementTo(context, AppRoutes.register);

          Fluttertoast.showToast(
            msg: "Account Processed Successfully",
            backgroundColor: AppColors.primaryColor,
          );
        }

        // 3. حالة الخطأ
        if (state is AuthErrorState) {
          Navigator.of(
            context,
            rootNavigator: true,
          ).pop(); // 🎯 قفل الـ Loading Dialog أولاً عشان الشاشة متقفلش

          Fluttertoast.showToast(msg: state.error, backgroundColor: Colors.red);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.lightColor,
        appBar: AppBar(
          backgroundColor: AppColors.lightColor,
          elevation: 0,
          centerTitle: true,
          title: Text(
            "My Profile",
            style: AppTextStyles.textStyle20.copyWith(
              color: AppColors.neutralColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.settings_outlined,
                color: AppColors.neutralColor,
              ),
              onPressed: () {
                // TODO: Navigation to Settings
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // 1. قسم الصورة الشخصية والاسم (Header Card)
              _buildProfileHeader(),

              const SizedBox(height: 30),

              // 2. قسم الإحصائيات السريعة (Stats Counter)
              _buildStatsSection(),

              const SizedBox(height: 30),

              // 3. قائمة الخيارات الاحترافية (Options List)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "ACCOUNT SETTINGS",
                      style: AppTextStyles.textStyle10.copyWith(
                        color: AppColors.neutralColor4,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildProfileOption(
                      icon: Icons.person_outline_rounded,
                      title: "Personal Information",
                      subtitle: "Update your name, phone, and email",
                      onTap: () {},
                    ),
                    _buildProfileOption(
                      icon: Icons.history_rounded,
                      title: "Booking History",
                      subtitle: "Check your past queue tickets",
                      onTap: () {},
                    ),
                    _buildProfileOption(
                      icon: Icons.payment_rounded,
                      title: "Payment Methods",
                      subtitle: "Manage your linked cards & PayPal",
                      onTap: () {},
                    ),

                    const SizedBox(height: 24),
                    Text(
                      "SUPPORT & LEGAL",
                      style: AppTextStyles.textStyle10.copyWith(
                        color: AppColors.neutralColor4,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildProfileOption(
                      icon: Icons.help_outline_rounded,
                      title: "Help & Support",
                      subtitle: "FAQs and direct chat assistance",
                      onTap: () {},
                    ),
                    _buildProfileOption(
                      icon: Icons.privacy_tip_outlined,
                      title: "Privacy Policy",
                      subtitle: "Review our terms and data policy",
                      onTap: () {},
                    ),

                    const SizedBox(height: 32),

                    // 4. زر تسجيل الخروج (Logout)
                    _buildLogoutButton(context),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // الـ Header الخاص بصورة اليوزر والبيانات الأساسية
  Widget _buildProfileHeader() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primaryColor, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryColor.withOpacity(0.15),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const CircleAvatar(
                radius: 55,
                backgroundColor: AppColors.neutralColor10,
                child: Icon(
                  Icons.person,
                  size: 55,
                  color: AppColors.primaryColor,
                ),
              ),
            ),
            Container(
              height: 34,
              width: 34,
              decoration: const BoxDecoration(
                color: AppColors.primaryColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.camera_alt_outlined,
                color: Colors.white,
                size: 18,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          "Abdelrahman Khaled",
          style: AppTextStyles.textStyle20.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.neutralColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "Tanta, Egypt",
          style: AppTextStyles.textStyle12.copyWith(
            color: AppColors.neutralColor4,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // لوحة الإحصائيات (عدد الحجوزات النشطة، المنتهية، إلخ)
  Widget _buildStatsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.infoCardBg1,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem("02", "Active Queues"),
          Container(height: 30, width: 1, color: AppColors.neutralColor9),
          _buildStatItem("48", "Total Bookings"),
          Container(height: 30, width: 1, color: AppColors.neutralColor9),
          _buildStatItem("Top 1%", "User Rate"),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.textStyle18.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.neutralColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.textStyle10.copyWith(
            color: AppColors.neutralColor4,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // الـ Widget الموحد لبناء عناصر القائمة (List Tiles) بلمسة Premium
  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.neutralColor9),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.infoCardBg2,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: AppColors.primaryColor, size: 22),
        ),
        title: Text(
          title,
          style: AppTextStyles.textStyle14.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.neutralColor,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: AppTextStyles.textStyle12.copyWith(
            color: AppColors.neutralColor4,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          size: 14,
          color: AppColors.neutralColor4,
        ),
      ),
    );
  }

  // زر تسجيل الخروج
  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade50.withOpacity(0.8),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
            side: BorderSide(color: Colors.red.shade100),
          ),
        ),
        onPressed: () {
          // TODO: Implement Logout Logic
          context.read<AuthCubit>().deleteUserById();
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, color: Colors.red.shade700, size: 20),
            const SizedBox(width: 8),
            Text(
              "Log Out",
              style: AppTextStyles.textStyle16.copyWith(
                color: Colors.red.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
