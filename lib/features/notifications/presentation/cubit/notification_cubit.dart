import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taborq/core/services/remote/notification_service.dart';
import 'package:taborq/features/notifications/data/notification_model.dart';
import 'package:taborq/features/notifications/presentation/cubit/notification_state.dart';

class NotificationCubit extends Cubit<NotificationStates> {
  NotificationCubit() : super(NotificationInitialState());

  StreamSubscription? _notificationsSubscription;

  List<NotificationModel> notifications = [];

  void getNotifications() {
    emit(NotificationLoadingState());

    _notificationsSubscription?.cancel();

    _notificationsSubscription =
        NotificationFirebaseService.getNotifications().listen(
      (snapshot) {
        notifications = snapshot.docs.map((doc) {
          return NotificationModel.fromJson(
            doc.id,
            doc.data(),
          );
        }).toList();

        emit(NotificationSuccessState(notifications));
      },
      onError: (error) {
        emit(NotificationErrorState(error.toString()));
      },
    );
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await NotificationFirebaseService.markAsRead(
        notificationId,
      );
    } catch (e) {
      emit(NotificationErrorState(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _notificationsSubscription?.cancel();
    return super.close();
  }
}