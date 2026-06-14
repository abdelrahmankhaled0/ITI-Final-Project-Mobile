import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:taborq/core/utils/app_colors.dart';
import 'package:taborq/core/utils/app_text_styles.dart';
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
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        title: Text(
          'Notifications',
          style: AppTextStyles.textStyle18.copyWith(
            color: AppColors.lightColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Icon(Icons.notifications),
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final item = notifications[index];
                return _buildNotificationCard(item);
              },
            );
          }

          return _buildEmptyState();
        },
      ),
    );
  }

  Widget _buildNotificationCard(dynamic item) {
    final bool isSuccess =
        item.title.contains('Successfully') ||
        item.title.contains('turn') ||
        item.title.contains('Completed');
    final Color iconBgColor = isSuccess
        ? const Color(0xE3E8FFF3)
        : AppColors.primaryColor.withOpacity(0.1);
    final Color iconColor = isSuccess
        ? Colors.green.shade700
        : AppColors.primaryColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: AppTextStyles.textStyle14.copyWith(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Cairo',
                      color: AppColors.darkColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.body,
                    style: AppTextStyles.textStyle12.copyWith(
                      fontFamily: 'Cairo',
                      color: Colors.grey.shade600,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if ((item.serviceName ?? '').isNotEmpty ||
                      (item.businessName ?? '').isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if ((item.serviceName ?? '').isNotEmpty)
                          Text(
                            'Service: ${item.serviceName}',
                            style: AppTextStyles.textStyle12.copyWith(
                              color: Colors.grey.shade500,
                            ),
                          ),
                        if ((item.businessName ?? '').isNotEmpty)
                          Text(
                            'Business: ${item.businessName}',
                            style: AppTextStyles.textStyle12.copyWith(
                              color: Colors.grey.shade500,
                            ),
                          ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  Align(
                    alignment: Alignment.bottomRight,
                    key: const Key('time_align'),
                    child: Text(
                      item.dateTime is String
                          ? item.dateTime
                          : DateFormat(
                              'EEE, MMM d • hh:mm a',
                            ).format(item.dateTime),
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade400,
                        fontWeight: FontWeight.w500,
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
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
              fontFamily: 'Cairo',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Active queue updates will appear here.',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12,
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }
}
