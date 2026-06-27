import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:taborq/core/utils/app_colors.dart';
import 'package:taborq/features/notifications/presentation/cubit/notification_cubit.dart';
import 'package:taborq/features/notifications/presentation/cubit/notification_state.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    // 🚀 مناداة الفيتش مرة واحدة فقط عند فتح الشاشة
    context.read<NotificationCubit>().fetchNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        title: const Text('Notifications'), // 🌟 رجع زي ما كان بالظبط
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(Icons.notifications), // 🌟 رجع زي ما كان بالظبط
          ),
        ],
      ),
      body: BlocBuilder<NotificationCubit, NotificationStates>(
        builder: (context, state) {
          if (state is NotificationLoadingState) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            );
          }

          if (state is NotificationSuccessState) {
            final notifications = state.notifications;

            if (notifications.isEmpty) {
              return _buildEmptyState();
            }

            return ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(left: 16.0, top: 12 , right: 16.0 , bottom: 80),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final item = notifications[index];
                return _buildNotificationCard(item, context);
              },
            );
          }

          return _buildEmptyState();
        },
      ),
    );
  }

  Widget _buildNotificationCard(dynamic item, BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;

    // الحفاظ على لوجيك الألوان الخاص بكِ
    final bool isSuccess = item.title.contains('Successfully') ||
        item.title.contains('turn') ||
        item.title.contains('Completed');

    final Color iconBgColor = isSuccess
        ? const Color(0xE3E8FFF3)
        : AppColors.primaryColor.withOpacity(0.1);

    final Color iconColor = isSuccess
        ? Colors.green.shade700
        : AppColors.primaryColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: theme.cardColor, // يأخذ لون الكارت من الثيم تلقائياً
        borderRadius: BorderRadius.circular(48),
        boxShadow: isLight
            ? [
          BoxShadow(
            color: AppColors.darkColor.withAlpha(30), // شادو ناعم جداً للعين
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ]
            : null, // مفيش شادو في الدارك مود ليكون مريح للعين
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🌟 الأيقونة
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                item.title.contains('move')
                    ? Icons.directions_run
                    : Icons.notifications_active,
                color: iconColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            // 🌟 تفاصيل الإشعار
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // العنوان
                  Text(
                    item.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // 🌟 اسم الخدمة واسم المكان (تم تنسيقهم كـ Tags مريحة للعين)
                  if ((item.serviceName ?? '').isNotEmpty || (item.businessName ?? '').isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Wrap(
                        spacing: 8, // المسافة الأفقية بين التاجز
                        runSpacing: 6, // المسافة الرأسية لو نزلوا سطر جديد
                        children: [
                          if ((item.serviceName ?? '').isNotEmpty)
                            _buildBadge('Service: ${item.serviceName}', isLight),
                          if ((item.businessName ?? '').isNotEmpty)
                            _buildBadge('Business: ${item.businessName}', isLight),
                        ],
                      ),
                    ),

                  // الرسالة الأساسية
                  Text(
                    item.body,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isLight ? Colors.grey.shade700 : Colors.grey.shade400,
                      height: 1.4, // تباعد الأسطر المريح للقراءة
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // الوقت والتاريخ
                  Align(
                    alignment: Alignment.bottomRight,
                    key: const Key('time_align'),
                    child: Text(
                      item.dateTime is String
                          ? item.dateTime
                          : DateFormat('EEE, MMM d • hh:mm a').format(item.dateTime),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🌟 ويدجت صغيرة بتعمل تصميم الـ Badge (التاج) عشان تفصل بيانات الخدمة عن نص الرسالة
  Widget _buildBadge(String text, bool isLight) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isLight ? Colors.grey.shade100 : const Color(0xFF232E37), // لون رمادي خفيف جداً
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isLight ? Colors.grey.shade600 : Colors.grey.shade400,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_none_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No notifications yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Active queue updates will appear here.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }
}