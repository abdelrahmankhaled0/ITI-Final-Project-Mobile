import 'package:taborq/features/notifications/data/notification_model.dart';

abstract class NotificationStates {}

class NotificationInitialState extends NotificationStates {}

class NotificationLoadingState extends NotificationStates {}

class NotificationSuccessState extends NotificationStates {
  final List<NotificationModel> notifications;
  NotificationSuccessState(this.notifications);
}

class NotificationErrorState extends NotificationStates {
  final String errorMessage;
  NotificationErrorState(this.errorMessage);
}
