import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:taborq/core/utils/app_colors.dart';
import 'package:taborq/features/notifications/data/notification_model.dart';
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
    context.read<NotificationCubit>().fetchNotifications();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<NotificationCubit>().markAllAsRead();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        title: const Text('Notifications'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
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
              padding: const EdgeInsets.only(
                left: 16,
                top: 12,
                right: 16,
                bottom: 80,
              ),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                return _buildNotificationCard(notifications[index], context);
              },
            );
          }

          return _buildEmptyState();
        },
      ),
    );
  }

  Widget _buildNotificationCard(
    NotificationModel item,
    BuildContext context,
  ) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final isUnread = !item.isRead;

    final isSuccess = item.title.contains('Successfully') ||
        item.title.contains('turn') ||
        item.title.contains('Completed');

    final iconBgColor = isSuccess
        ? const Color(0xE3E8FFF3)
        : AppColors.primaryColor.withOpacity(0.1);
    final iconColor = isSuccess ? Colors.green.shade700 : AppColors.primaryColor;
    final unreadAccent = AppColors.primaryColor;
    final cardColor = isUnread
        ? (isLight
              ? unreadAccent.withOpacity(0.08)
              : unreadAccent.withOpacity(0.14))
        : theme.cardColor;

    return InkWell(
      borderRadius: BorderRadius.circular(28),
      onTap: () => context.read<NotificationCubit>().markAsRead(item.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 18),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: isUnread
                ? unreadAccent.withOpacity(0.35)
                : Colors.transparent,
          ),
          boxShadow: isLight
              ? [
                  BoxShadow(
                    color: isUnread
                        ? unreadAccent.withOpacity(0.18)
                        : AppColors.darkColor.withAlpha(30),
                    blurRadius: isUnread ? 16 : 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isUnread)
                Container(
                  width: 10,
                  height: 10,
                  margin: const EdgeInsets.only(top: 16, right: 10),
                  decoration: BoxDecoration(
                    color: unreadAccent,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: unreadAccent.withOpacity(0.55),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
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
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight:
                            isUnread ? FontWeight.w800 : FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (item.serviceName.isNotEmpty ||
                        item.businessName.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            if (item.serviceName.isNotEmpty)
                              _buildBadge(
                                'Service: ${item.serviceName}',
                                isLight,
                              ),
                            if (item.businessName.isNotEmpty)
                              _buildBadge(
                                'Business: ${item.businessName}',
                                isLight,
                              ),
                          ],
                        ),
                      ),
                    Text(
                      item.body,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isLight
                            ? Colors.grey.shade700
                            : Colors.grey.shade400,
                        height: 1.4,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Text(
                        DateFormat('EEE, MMM d - hh:mm a').format(
                          item.dateTime,
                        ),
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
      ),
    );
  }

  Widget _buildBadge(String text, bool isLight) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isLight ? Colors.grey.shade100 : const Color(0xFF232E37),
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
