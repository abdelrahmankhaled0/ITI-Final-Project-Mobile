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
    await FirebaseFirestore.instance.collection("users").doc(user.uid).update({"name": newName});
    setState(() {}); // لتحديث الاسم في الـ UI فوراً
  }

  void showEditNameDialog() {
    final controller = TextEditingController(text: user?.displayName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor:Theme.of(context).scaffoldBackgroundColor,
        title: const Text("Edit Name"),
        content: TextField(controller: controller, decoration: const InputDecoration(hintText: "Enter new name")),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel" , style: TextStyle(color: Colors.red),)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryColor),
            onPressed: () async {
              await updateUserName(controller.text);
              Navigator.pop(context);
            },
            child: const Text("Save", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: Theme.of(context).cardColor,
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(40))),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Wrap(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Text("Profile Photo", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt_outlined, color: AppColors.primaryColor),
                  title: const Text('Take a photo'),
                  onTap: () { Navigator.pop(context); _pickAndUploadImage(ImageSource.camera); },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined, color: AppColors.primaryColor),
                  title: const Text('Choose from gallery'),
                  onTap: () { Navigator.pop(context); _pickAndUploadImage(ImageSource.gallery); },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickAndUploadImage(ImageSource source) async {
    if (user == null) return;
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source, imageQuality: 60);
    if (image == null) return;
    setState(() => _isUploading = true);
    try {
      final imgbbApiKey = dotenv.env['IMGBB_API_KEY'];
      var request = http.MultipartRequest('POST', Uri.parse('https://api.imgbb.com/1/upload?key=$imgbbApiKey'));
      request.files.add(await http.MultipartFile.fromPath('image', image.path));
      var response = await request.send();
      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var jsonResult = jsonDecode(responseData);
        String downloadUrl = jsonResult['data']['url'];
        await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({'imageUrl': downloadUrl}, SetOptions(merge: true));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bookingCubit = context.read<BookingViewCubit>();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        title: Text("Profile", style: theme.textTheme.headlineSmall),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(user?.uid).snapshots(),
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
            padding: const EdgeInsets.only(left: 16.0, top: 12, right: 16.0, bottom: 70),
            child: Column(
              children: [
                _buildProfileAvatar(imageUrl),
                const SizedBox(height: 16),
                // اسم المستخدم مع أيقونة التعديل
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(name, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    IconButton(icon: const Icon(Icons.edit, size: 20, color: AppColors.primaryColor), onPressed: showEditNameDialog),
                  ],
                ),
                Text(email, style: TextStyle(color: Colors.grey[500], fontSize: 14)),
                const SizedBox(height: 24),

                // Membership Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(24)),
                  child: _buildMembershipRow(),
                ),
                const SizedBox(height: 32),

                // Booking History
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Booking History", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    GestureDetector(onTap: () => context.go(AppRoutes.bookings), child: const Text("View All", style: TextStyle(color: AppColors.primaryColor, fontWeight: FontWeight.bold))),
                  ],
                ),
                const SizedBox(height: 16),
                BlocBuilder<BookingViewCubit, BookingViewStates>(
                  builder: (context, state) {
                    if (state is BookingViewLoadingState) return const CircularProgressIndicator( color: AppColors.primaryColor,);
                    if (bookingCubit.tickets.isEmpty) return const Text("No bookings yet");
                    return Column(
                      children: bookingCubit.tickets.take(2).map((ticket) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildHistoryCard(ticket: ticket, theme: theme),
                      )).toList(),
                    );
                  },
                ),
                const SizedBox(height: 32),

                // Settings
                Align(alignment: Alignment.centerLeft, child: Text("Settings", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold))),
                const SizedBox(height: 12),
                _buildSettingsList(theme),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileAvatar(String? imageUrl) {
    return Center(
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.primaryColor, width: 2)),
            child: CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.primaryColor.withOpacity(0.1),
              backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
              child: imageUrl == null ? const Icon(Icons.person, size: 50, color: AppColors.primaryColor) : null,
            ),
          ),
          Positioned(
            bottom: 4, right: 4,
            child: GestureDetector(
              onTap: () => _showImageSourceActionSheet(context),
              child: const CircleAvatar(radius: 16, backgroundColor: AppColors.primaryColor, child: Icon(Icons.camera_alt_outlined, size: 16, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMembershipRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Column(children: [
          const Icon(Icons.verified_user_outlined, color: AppColors.primaryColor, size: 20),
          const SizedBox(height: 4),
          const Text("MEMBERSHIP", style: TextStyle(fontSize: 10, color: Colors.grey)),
          const SizedBox(height: 4),
          const Text("Tabourq", style: TextStyle(fontWeight: FontWeight.bold))
        ]),
        Container(height: 40, width: 1, color: Colors.grey.withOpacity(0.2)),
        Column(children: [
          const Icon(Icons.calendar_today_outlined, color: AppColors.primaryColor, size: 20),
          const SizedBox(height: 4),
          const Text("JOINED", style: TextStyle(fontSize: 10, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(joinedDate, style: const TextStyle(fontWeight: FontWeight.bold))
        ]),
      ],
    );
  }

  Widget _buildHistoryCard({required dynamic ticket, required ThemeData theme}) {
    // نجلب حالة التذكرة ونجعلها بحروف صغيرة لضمان صحة المقارنة
    final String status = (ticket.status ?? '').toLowerCase();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(24)
      ),
      child: Row(
        children: [
          CircleAvatar(
              backgroundColor: AppColors.primaryColor.withOpacity(0.1),
              child: const Icon(Icons.calendar_month, color: AppColors.primaryColor)
          ),
          const SizedBox(width: 16),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(ticket.bussinessName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(ticket.serviceName, style: const TextStyle(fontSize: 12, color: Colors.grey))
                  ]
              )
          ),
          // عرض الـ Status بالألوان الديناميكية
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
              ticket.status,
              style: TextStyle(
                color: status == "completed"
                    ? Colors.green
                    : status == "pending"
                    ? Colors.orange
                    : Colors.red,
                fontSize: 10, // تم تعديل الحجم ليتناسب مع التصميم
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSettingsList(ThemeData theme) {
    bool isDark = theme.brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(24)),
      child: Column(
        children: [
          SwitchListTile(
            title: Text(isDark ? "Dark Mode" : "Light Mode", ),
            secondary: Icon(isDark ? Icons.dark_mode : Icons.light_mode, color: AppColors.primaryColor),
            activeColor: AppColors.primaryColor,
            value: isDark,
            onChanged: (val) => BlocProvider.of<ThemeCubit>(context).toggleTheme(val),
          ),

          // Divider(height: 1, color: Colors.grey.withOpacity(0.2), indent: 16, endIndent: 16),

          ListTile(leading: const Icon(Icons.lock_outline, color: AppColors.primaryColor), title: const Text("Privacy"), trailing: const Icon(Icons.arrow_forward_ios, size: 14)),

          // Divider(height: 1, color: Colors.grey.withOpacity(0.2), indent: 16, endIndent: 16),

          ListTile(leading: const Icon(Icons.logout, color: Colors.red), title: const Text("Log out", style: TextStyle(color: Colors.red)), onTap: () async {
            await logout();

            if (context.mounted) {
              context.go(AppRoutes.login);
            }}),
        ],
      ),
    );
  }
}