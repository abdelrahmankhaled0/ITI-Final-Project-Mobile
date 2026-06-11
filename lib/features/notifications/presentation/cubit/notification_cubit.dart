import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taborq/features/notifications/data/notification_model.dart';
import 'package:taborq/features/notifications/presentation/cubit/notification_state.dart'; // تأكد من اسم ملف الـ state عندك

class NotificationCubit extends Cubit<NotificationStates> {
  NotificationCubit() : super(NotificationInitialState());

  final List<NotificationModel> notificationsList = [];

  void fetchNotifications() {
    emit(NotificationLoadingState());
    emit(NotificationSuccessState(List.from(notificationsList)));
  }

  void addNotification({
    required String title,
    required String body,
    required String serviceName,
    required String businessName,
  }) {
    final newNotification = NotificationModel(
      title: title,
      body: body,
      serviceName: serviceName,
      businessName: businessName,
      dateTime: DateTime.now(),
    );

    notificationsList.add(newNotification);
    
    // الطباعة اللي هتأكد لك في الترمينال إن كله تمام
    print("🚀 Cubit: Notification Added! Total count: ${notificationsList.length}");

    emit(NotificationSuccessState(List.from(notificationsList)));
  }
}