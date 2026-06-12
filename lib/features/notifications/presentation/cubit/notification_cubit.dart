import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taborq/core/services/remote/notification_service.dart';
import 'package:taborq/features/notifications/data/notification_model.dart';
import 'package:taborq/features/notifications/presentation/cubit/notification_state.dart'; // تأكد من اسم ملف الـ state عندك

class NotificationCubit extends Cubit<NotificationStates> {
  NotificationCubit() : super(NotificationInitialState());

  final List<NotificationModel> notificationsList = [];
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
  _notificationsSubscription;

  void fetchNotifications() {
    emit(NotificationLoadingState());
    _notificationsSubscription?.cancel();

    if (NotificationFirebaseService.userId == null) {
      emit(NotificationSuccessState([]));
      return;
    }

    _notificationsSubscription = NotificationFirebaseService.getNotifications()
        .listen(
          (snapshot) {
            final loadedNotifications = snapshot.docs
                .map((doc) => NotificationModel.fromJson(doc.data()))
                .toList();

            notificationsList
              ..clear()
              ..addAll(loadedNotifications);

            emit(NotificationSuccessState(List.from(notificationsList)));
          },
          onError: (error) {
            emit(NotificationErrorState(error.toString()));
          },
        );
  }

  Future<void> addNotification({
    required String title,
    required String body,
    required String serviceName,
    required String businessName,
  }) async {
    final newNotification = NotificationModel(
      title: title,
      body: body,
      serviceName: serviceName,
      businessName: businessName,
      dateTime: DateTime.now(),
    );

    notificationsList.add(newNotification);
    print(
      "🚀 Cubit: Notification Added! Total count: ${notificationsList.length}",
    );

    emit(NotificationSuccessState(List.from(notificationsList)));
    await NotificationFirebaseService.saveNotification(newNotification);
  }
}
