import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taborq/features/notifications/data/notification_model.dart';
import 'package:taborq/features/notifications/presentation/cubit/notification_state.dart';

class NotificationCubit extends Cubit<NotificationStates> {
  NotificationCubit() : super(NotificationInitialState()) {
    addNotification(
      title: "Queue Update! 🏃‍♂️",
      body: "Current turn is 2. Your number is 5. There are 3 people ahead.",
    );
  }

  // ليستة محليّة لتخزين الإشعارات وعرضها في السكرين
  final List<NotificationModel> _notificationsList = [];

  // دالة تُستدعى لما يجي إشعار جديد عشان تضيفه في الـ UI فوراً
  void addNotification({required String title, required String body}) {
    // ❌ شيلنا الـ emit(NotificationLoadingState()) من هنا عشان نمنع الـ Flickering جوه الـ UI

    final newNotification = NotificationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      body: body,
      dateTime: DateTime.now(),
    );

    // بنضيف الإشعار الجديد في أول القائمة عشان يظهر فوق (Latest First)
    _notificationsList.insert(0, newNotification);

    // بنبعت الـ State الجديدة بالليستة المحدثة فوراً 🚀
    emit(NotificationSuccessState(List.from(_notificationsList)));
  }

  // الدالة دي اللي بتستدعى أول ما صفحة الإشعارات تفتح (جوه الـ initState أو الـ OnOpen)
  void fetchNotifications() {
    emit(NotificationLoadingState()); // الـ Loading هنا صح ومنطقي جداً

    // حالياً بنرجع الليستة الحالية اللي متخزن فيها الإشعارات اللي لقطناها
    // مستقبلاً: هنا المكان اللي هتجيب منه الإشعارات المحفوظة في الـ Local Storage أو Firestore
    emit(NotificationSuccessState(List.from(_notificationsList)));
  }
}
