import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:taborq/core/routes/routes.dart';
import 'package:taborq/core/utils/app_colors.dart';
import 'package:taborq/core/utils/app_text_styles.dart';
import 'package:taborq/features/booking_view/presentation/cubit/booking_view_cubit.dart';
import 'package:taborq/features/booking_view/presentation/cubit/booking_view_states.dart';
import 'package:taborq/features/profile/presentation/cubit/theme-cubit.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  bool _isUploading = false;

  String get joinedDate {
    if (user?.metadata.creationTime != null) {
      return DateFormat.yMMMMd().format(user!.metadata.creationTime!);
    }
    return "Unknown";
  }

  Future<void> logout() async {
    await GoogleSignIn().signOut();
    await FirebaseAuth.instance.signOut();
  }

  Future<void> updateUserName(String newName) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    await user.updateDisplayName(newName);

    await FirebaseFirestore.instance.collection("users").doc(user.uid).update({
      "name": newName,
    });
  }

  void showEditNameDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.lightColor,
        title: const Text("Edit Name"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "Enter new name"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
            ),
            onPressed: () async {
              await updateUserName(controller.text);
              Navigator.pop(context);
            },
            child: const Text(
              "Save",
              style: TextStyle(color: AppColors.lightColor),
            ),
          ),
        ],
      ),
    );
  }

  // 1. عرض خيارات اختيار الصورة (كاميرا أو استوديو)
  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.lightColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Wrap(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Text(
                    "Profile Photo",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.primaryColor9,
                    child: Icon(
                      Icons.camera_alt_outlined,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  title: Text('Take a photo', style: AppTextStyles.textStyle16),
                  onTap: () {
                    Navigator.pop(context);
                    _pickAndUploadImage(ImageSource.camera); // فتح الكاميرا
                  },
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.primaryColor9,
                    child: Icon(
                      Icons.photo_library_outlined,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  title: Text(
                    'Choose from gallery',
                    style: AppTextStyles.textStyle16,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _pickAndUploadImage(ImageSource.gallery); // فتح الاستوديو
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 2. دالة اختيار الصورة ورفعها إلى ImgBB
  Future<void> _pickAndUploadImage(ImageSource source) async {
    if (user == null) return;

    final ImagePicker picker = ImagePicker();
    // تقليل جودة الصورة لتسريع الرفع وتوفير الباقة
    final XFile? image = await picker.pickImage(
      source: source,
      imageQuality: 60,
    );

    if (image == null) return;

    setState(() => _isUploading = true);

    try {
      // 🔴 ضعي مفتاح الـ API الخاص بك من موقع ImgBB هنا
      final imgbbApiKey = dotenv.env['IMGBB_API_KEY'];

      // تجهيز الـ Request لرفع الصورة كـ Multipart File
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://api.imgbb.com/1/upload?key=$imgbbApiKey'),
      );

      request.files.add(await http.MultipartFile.fromPath('image', image.path));

      // إرسال الطلب واستقبال الرد
      var response = await request.send();

      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var jsonResult = jsonDecode(responseData);

        // استخراج الرابط المباشر للصورة من الـ JSON
        String downloadUrl = jsonResult['data']['url'];

        // تحديث رابط الصورة في Firestore ليسمّع في شاشة الـ Home لحظياً
        await FirebaseFirestore.instance.collection('users').doc(user!.uid).set(
          {'imageUrl': downloadUrl},
          SetOptions(merge: true),
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile picture updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception(
          "Failed to upload image. Status code: ${response.statusCode}",
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingCubit = context.read<BookingViewCubit>();
    return Scaffold(
      // backgroundColor: AppColors.lightColor,
      appBar: AppBar(
        // foregroundColor: AppColors.lightColor,
        // backgroundColor: AppColors.lightColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Profile",
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        actions: [IconButton(icon: const Icon(Icons.search), onPressed: () {})],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          String name = user?.displayName ?? "User";
          String email = user?.email ?? "No Email";
          String? imageUrl;

          if (snapshot.hasData && snapshot.data!.exists) {
            var data = snapshot.data!.data() as Map<String, dynamic>;
            name = data['name'] ?? name;
            imageUrl = data['imageUrl'];
          }

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // صورة البروفايل
                _buildProfileAvatar(imageUrl),
                const SizedBox(height: 16),

                // بيانات المستخدم
                // Text(name, style: AppTextStyles.textStyle24.copyWith(fontWeight: FontWeight.bold)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.textStyle24.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: showEditNameDialog,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                const SizedBox(height: 24),

                // العضوية
                _buildMembershipRow(),
                const SizedBox(height: 32),

                _buildSectionHeader(
                  "Booking History",
                  onViewAll: () {
                    context.go(AppRoutes.bookings);
                  },
                ),
                const SizedBox(height: 16),

                // الحجوزات السابقة
                BlocBuilder<BookingViewCubit, BookingViewStates>(
                  builder: (context, state) {
                    if (state is BookingViewLoadingState) {
                      return const CircularProgressIndicator(
                        color: AppColors.primaryColor,
                      );
                    }

                    if (bookingCubit.tickets.isEmpty) {
                      return const Text("No bookings yet");
                    }

                    final bookings = bookingCubit.tickets.take(2).toList();

                    return Column(
                      children: bookings.map((ticket) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildHistoryCard(
                            title: ticket.bussinessName,
                            subtitle: ticket.serviceName,
                            date: DateFormat('dd MMM').format(ticket.date),
                            icon: Icons.calendar_month,
                            status: ticket.status,
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
                const SizedBox(height: 32),

                // الإعدادات
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Settings",
                    style: AppTextStyles.textStyle18.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _buildSettingsList(),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  // ودجت صورة البروفايل
  Widget _buildProfileAvatar(String? imageUrl) {
    return Center(
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: AppColors.primaryColor,
              shape: BoxShape.circle,
            ),
            child: CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.primaryColor9,
              backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
              child: _isUploading
                  ? const CircularProgressIndicator(color: AppColors.lightColor)
                  : (imageUrl == null
                        ? const Icon(
                            Icons.person,
                            size: 50,
                            color: AppColors.primaryColor,
                          )
                        : null),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 4,
            child: GestureDetector(
              // 🔴 فتح قائمة الخيارات بدلاً من الاستوديو مباشرة
              onTap: _isUploading
                  ? null
                  : () => _showImageSourceActionSheet(context),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.lightColor, width: 2),
                ),
                child: const Icon(
                  Icons.camera_alt_outlined,
                  color: AppColors.lightColor,
                  size: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // شريط العضوية وتاريخ الانضمام
  Widget _buildMembershipRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Column(
          children: [
            const Icon(
              Icons.verified_user_outlined,
              color: AppColors.primaryColor,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              "MEMBERSHIP",
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.grey[500],
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Tabouraq",
              textAlign: TextAlign.center,
              style: AppTextStyles.textStyle14.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Container(height: 40, width: 1, color: AppColors.neutralColor9),
        Column(
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              color: AppColors.primaryColor,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              "JOINED",
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.grey[500],
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              joinedDate,
              style: AppTextStyles.textStyle16.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, {required VoidCallback onViewAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: AppTextStyles.textStyle18.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        GestureDetector(
          onTap: onViewAll,
          child: const Text(
            "View All",
            style: TextStyle(
              color: AppColors.primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryCard({
    required String title,
    required String subtitle,
    required String date,
    required IconData icon,
    required String status,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.neutralColor10.withOpacity(0.5),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primaryColor9,
            child: Icon(icon, color: AppColors.primaryColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.textStyle14.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                date,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: status == "completed"
                      ? Colors.green.withAlpha(40)
                      : status == "pending"
                      ? Colors.orange.withAlpha(40)
                      : Colors.red.withAlpha(40),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: status == "completed"
                        ? Colors.green
                        : status == "pending"
                        ? Colors.orange
                        : Colors.red,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // قائمة الإعدادات (Settings)
  Widget _buildSettingsList() {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const CircleAvatar(
            backgroundColor: AppColors.neutralColor10,
            child: Icon(Icons.dark_mode_outlined, color: AppColors.darkColor),
          ),
          title: Text(
            "Theme: Dark/Light Mode",
            style: AppTextStyles.textStyle14.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            "Adjust visual appearance",
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          trailing: Switch(
            value: Theme.of(context).brightness == Brightness.dark,
            activeColor: AppColors.primaryColor,
            onChanged: (val) {
              BlocProvider.of<ThemeCubit>(context).toggleTheme(val);
            },
          ),
        ),
        const Divider(height: 24, color: AppColors.neutralColor9),
        _buildSettingsTile(title: "Privacy", icon: Icons.lock_outline),
        const Divider(height: 24, color: AppColors.neutralColor9),
        _buildSettingsTile(
          title: "Terms of Service",
          icon: Icons.description_outlined,
        ),
        const Divider(height: 24, color: AppColors.neutralColor9),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            backgroundColor: Colors.red.withOpacity(0.1),
            child: const Icon(Icons.logout, color: Colors.red),
          ),
          title: Text(
            "Log out",
            style: AppTextStyles.textStyle14.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            size: 14,
            color: Colors.red,
          ),
          onTap: () async {
            await logout();

            if (context.mounted) {
              context.go(AppRoutes.login);
            }
          },
        ),
      ],
    );
  }

  Widget _buildSettingsTile({required String title, required IconData icon}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: AppColors.neutralColor10,
        child: Icon(icon, color: AppColors.darkColor),
      ),
      title: Text(
        title,
        style: AppTextStyles.textStyle14.copyWith(fontWeight: FontWeight.bold),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 14,
        color: AppColors.neutralColor5,
      ),
      onTap: () {},
    );
  }
}
