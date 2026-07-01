import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:taborq/core/services/remote/notification_service.dart';
import 'package:taborq/features/notifications/presentation/cubit/notification_cubit.dart';
import '../../data/models/ticket_model.dart';
import 'booking_state.dart';

class BookingCubit extends Cubit<BookingState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final NotificationCubit _notificationCubit;
  StreamSubscription<User?>? _authStateSub;

  BookingCubit({required NotificationCubit notificationCubit})
    : _notificationCubit = notificationCubit,
      super(BookingInitial()) {
    // Start listening to auth changes; when a user logs in, init listeners.
    _authStateSub = _auth.authStateChanges().listen((user) {
      if (user != null) {
        initListenersForUserActiveTickets(_notificationCubit);
      }
    });
    // If already signed in, initialize immediately.
    if (_auth.currentUser != null) {
      debugPrint(
        'BookingCubit: user already signed in, initializing listeners',
      );
      initListenersForUserActiveTickets(_notificationCubit);
    }
  }

  Future<void> bookQueuePlace({
    required String businessId,
    required String serviceId,
    required String serviceName,
    required int avgServiceTime,
    required NotificationCubit notificationCubit,
  }) async {
    emit(BookingLoading());
    try {
      final String? userId = _auth.currentUser?.uid;

      if (userId == null) {
        emit(
          BookingFailure(
            errorMessage: "You must be logged in to book a place.",
          ),
        );
        return;
      }

      String userName = "عميل جديد";
      String userPhone = "";
      String businessName = ""; // ✅ تم إصلاح الإسبيلنج
      String imageUri = "";

      // 1️⃣ جلب بيانات البيزنس
      try {
        final snapshot = await _firestore
            .collection("businesses")
            .doc(businessId)
            .get();
        if (snapshot.exists) {
          final data = snapshot.data();
          if (data != null) {
            businessName = data['name'] ?? "";
            imageUri = data['imageUrl'] ?? "";
          }
        }
      } catch (e) {
        debugPrint("❌ Error fetching business data: ${e.toString()}");
      }

      // 2️⃣ جلب بيانات المستخدم
      try {
        final userDoc = await _firestore.collection('users').doc(userId).get();
        if (userDoc.exists && userDoc.data()?['name'] != null) {
          userName = userDoc.data()?['name'];
          userPhone = userDoc.data()?['phone'] ?? "";
        } else {
          userName = _auth.currentUser?.displayName ?? "عميل جديد";
        }
      } catch (e) {
        userName = _auth.currentUser?.displayName ?? "عميل جديد";
      }

      final String ticketDocId = "${userId}_$serviceId";

      final ticketRef = _firestore
          .collection('Queues')
          .doc(businessId)
          .collection('services')
          .doc(serviceId)
          .collection('tickets')
          .doc(ticketDocId);

      final serviceRef = _firestore
          .collection('Queues')
          .doc(businessId)
          .collection('services')
          .doc(serviceId);

      // 3️⃣ التشيك إذا كان محجوز مسبقاً
      final existingTicket = await ticketRef.get();
      if (existingTicket.exists &&
          existingTicket.data()?['status'] == 'pending') {
        int activeTicketNum = existingTicket.data()?['ticketNumber'];
        emit(
          BookingAlreadyBookedState(
            ticketCode: activeTicketNum,
            ticketId: ticketDocId,
            businessName: businessName,
            serviceName: serviceName,
            avgServiceTime: avgServiceTime,
            bookingTime: _toDateTime(existingTicket.data()?['bookingTime']),
          ),
        );
        return;
      }

      // 4️⃣ الـ Transaction لتحديث الـ Counter وحفظ التذكرة
      final bookingTimestamp = DateTime.now();
      int currentInService = 0;
      int finalTicketCode = await _firestore.runTransaction<int>((
        transaction,
      ) async {
        DocumentSnapshot serviceSnapshot = await transaction.get(serviceRef);

        int currentLastTicket = 0;
        if (serviceSnapshot.exists) {
          Map<String, dynamic> serviceData =
              serviceSnapshot.data() as Map<String, dynamic>;
          currentLastTicket = serviceData['lastGeneratedTicket'] ?? 0;
          currentInService = _toInt(
            serviceData['currentTicket'] ?? serviceData['currentlyInService'],
          );
        }

        int updatedTicket = currentLastTicket + 1;

        transaction.set(serviceRef, {
          'lastGeneratedTicket': updatedTicket,
        }, SetOptions(merge: true));

        final newTicket = TicketModel(
          name: userName,
          ticketId: ticketDocId,
          userId: userId,
          businessId: businessId,
          serviceId: serviceId,
          serviceName: serviceName,
          ticketNumber: updatedTicket,
          bookingTime: bookingTimestamp,
          status: 'pending',
          phone: userPhone,
          bussinessName: businessName, // ✅ متناسق مع المتغير المعدل
          imageURI: imageUri,
        );

        transaction.set(ticketRef, newTicket.toFirestore());
        return updatedTicket;
      });

      emit(
        BookingSuccess(
          ticketCode: finalTicketCode,
          isAlreadyBooked: false,
          businessName: businessName,
          serviceName: serviceName,
          avgServiceTime: avgServiceTime,
        ),
      );

      _triggerBookingCreatedNotification(
        notificationCubit: notificationCubit,
        businessName: businessName,
        serviceName: serviceName,
        ticketNumber: finalTicketCode,
        avgServiceTime: avgServiceTime,
        currentInService: currentInService,
        bookingTime: bookingTimestamp,
      );

      // Start listening for queue updates for the newly booked ticket
      startQueueListener(
        businessId: businessId,
        serviceId: serviceId,
        userTurnNumber: finalTicketCode,
        ticketId: ticketDocId,
        avgServiceTime: avgServiceTime,
        notificationCubit: notificationCubit,
        serviceName: serviceName,
        businessName: businessName,
        bookingTime: bookingTimestamp,
      );
    } catch (e) {
      emit(BookingFailure(errorMessage: "Booking failed: ${e.toString()}"));
    }
  }

  // استبدل أو ضيف دالة الـ Listener دي والـ Functions المساعدة اللي تحتها جوه الـ BookingCubit بتاعك:

  // Support multiple active ticket listeners (user may have tickets across services)
  final Map<String, StreamSubscription> _queueSubscriptions = {};
  final Map<String, StreamSubscription> _ticketStatusSubscriptions = {};
  final Map<String, bool> _isQueueListenerPrimed = {};
  final Map<String, bool> _movementNotifiedMap = {};
  final Map<String, bool> _yourTurnNotifiedMap = {};
  final Map<String, bool> _serviceCompletedNotifiedMap = {};
  final Map<String, int> _lastNotifiedActiveTurnMap = {};
  final Map<String, String?> _lastTicketStatusMap = {};

  String _queueListenerKey({
    required String businessId,
    required String serviceId,
    required int userTurnNumber,
  }) {
    return '${businessId}_${serviceId}_$userTurnNumber';
  }

  void _cancelAndCleanQueueListenerByKey(String key) {
    _queueSubscriptions[key]?.cancel();
    _ticketStatusSubscriptions[key]?.cancel();
    _queueSubscriptions.remove(key);
    _ticketStatusSubscriptions.remove(key);
    _isQueueListenerPrimed.remove(key);
    _movementNotifiedMap.remove(key);
    _yourTurnNotifiedMap.remove(key);
    _serviceCompletedNotifiedMap.remove(key);
    _lastNotifiedActiveTurnMap.remove(key);
    _lastTicketStatusMap.remove(key);
  }

  void cancelAndCleanQueueListener({
    required String businessId,
    required String serviceId,
    required int userTurnNumber,
  }) {
    final key = _queueListenerKey(
      businessId: businessId,
      serviceId: serviceId,
      userTurnNumber: userTurnNumber,
    );
    _cancelAndCleanQueueListenerByKey(key);
  }

  void _triggerBookingCreatedNotification({
    required NotificationCubit notificationCubit,
    required String businessName,
    required String serviceName,
    required int ticketNumber,
    required int avgServiceTime,
    required int currentInService,
    required DateTime bookingTime,
  }) {
    final peopleAhead = ticketNumber - currentInService - 1;
    final isDuringWorkingHours = _isDuringWorkingHours(bookingTime);
    final estimatedStartTime = _estimatedServiceStartTime(
      peopleAhead,
      avgServiceTime,
      bookingTime,
    );
    final formattedTime = DateFormat('h:mm a').format(estimatedStartTime);
    final waitDurationText = _formatDuration(
      Duration(minutes: peopleAhead * avgServiceTime),
    );

    final String title;
    final String body;

    if (ticketNumber <= 1 && peopleAhead <= 0 && !isDuringWorkingHours) {
      title = 'First in line • Opening soon';
      body =
          'Ticket Number: Q-$ticketNumber\nLive People Ahead: 0\nExpected Turn Time: $formattedTime\nPlease ensure your presence at the business location right at the start of opening hours, as you are the first in line.';
    } else if (ticketNumber <= 1 && peopleAhead <= 0 && isDuringWorkingHours) {
      title = "It's your turn right now! 🎉";
      body =
          'Ticket Number: Q-$ticketNumber\nLive People Ahead: 0\nExpected Turn Time: Right now\nIt\'s your turn right now! Please proceed to the service desk immediately.';
    } else {
      title = 'Booking confirmed for $serviceName';
      body =
          'Ticket Number: Q-$ticketNumber\nLive People Ahead: $peopleAhead\nExpected Turn Time: $formattedTime\nCurrent serving: Q-$currentInService. Your ticket is confirmed and you are expected around $formattedTime ($waitDurationText waiting time).';
    }

    NotificationService().showNotification(id: 100, title: title, body: body);

    notificationCubit.addNotification(
      title: title,
      body: body,
      serviceName: serviceName,
      businessName: businessName,
      isRead: false,
    );
  }

  bool _isDuringWorkingHours(DateTime time) {
    return time.hour >= 9 && time.hour < 17;
  }

  DateTime _getQueueBaseStartTime(DateTime bookingTime) {
    if (_isDuringWorkingHours(bookingTime)) {
      return bookingTime;
    }

    final openingToday = DateTime(
      bookingTime.year,
      bookingTime.month,
      bookingTime.day,
      9,
      0,
    );
    if (bookingTime.isBefore(openingToday)) {
      return openingToday;
    }

    final nextOpeningDay = DateTime(
      bookingTime.year,
      bookingTime.month,
      bookingTime.day,
    ).add(const Duration(days: 1));
    return DateTime(
      nextOpeningDay.year,
      nextOpeningDay.month,
      nextOpeningDay.day,
      9,
      0,
    );
  }

  DateTime _estimatedServiceStartTime(
    int ahead,
    int avgServiceTime,
    DateTime bookingTime,
  ) {
    final baseStartTime = _getQueueBaseStartTime(bookingTime);
    return baseStartTime.add(Duration(minutes: ahead * avgServiceTime));
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    if (hours > 0 && minutes > 0) return '$hours hr $minutes mins';
    if (hours > 0) return '$hours hr';
    return '$minutes mins';
  }

  void startQueueListener({
    required String businessId,
    required String serviceId,
    required int userTurnNumber,
    required String ticketId,
    required int avgServiceTime,
    required NotificationCubit notificationCubit,
    required String serviceName,
    required String businessName,
    DateTime? bookingTime,
  }) {
    final key = '${businessId}_${serviceId}_$userTurnNumber';

    // الحماية الأمنية الأولى: التأكد من إغلاق أي بقايا للاستماع القديم قبل فتح الجديد
    _cancelAndCleanQueueListenerByKey(key);

    // تهيئة الـ Maps للمستخدم الحالي
    _isQueueListenerPrimed[key] = false;
    _movementNotifiedMap[key] = false;
    _yourTurnNotifiedMap[key] = false;
    _serviceCompletedNotifiedMap[key] = false;
    _lastNotifiedActiveTurnMap[key] = -1;

    _listenForTicketStatusChanges(
      key: key,
      businessId: businessId,
      serviceId: serviceId,
      ticketId: ticketId,
      userTurnNumber: userTurnNumber,
      notificationCubit: notificationCubit,
      serviceName: serviceName,
      businessName: businessName,
    );

    final sub = _firestore
        .collection('Queues')
        .doc(businessId)
        .collection('services')
        .doc(serviceId)
        .snapshots()
        .listen((snapshot) {
          if (!snapshot.exists || snapshot.data() == null) return;
          if (snapshot.metadata.isFromCache) return;

          final raw = snapshot.data();
          final int currentlyInService = _toInt(
            raw?['currentTicket'] ?? raw?['currentlyInService'],
          );
          final int peopleAhead = userTurnNumber - currentlyInService;
          final int estimatedWaitingTime = peopleAhead * avgServiceTime;

          emit(
            BookingQueueUpdated(
              currentlyInService: currentlyInService,
              peopleAhead: peopleAhead,
              estimatedWaitingTime: estimatedWaitingTime,
            ),
          );

          final bool isWarmup = !(_isQueueListenerPrimed[key] ?? false);
          if (isWarmup) {
            _isQueueListenerPrimed[key] = true;
            _lastNotifiedActiveTurnMap[key] = currentlyInService;
            return;
          }

          final bool turnChanged =
              currentlyInService != (_lastNotifiedActiveTurnMap[key] ?? -1);
          if (!turnChanged) {
            return;
          }

          if (peopleAhead <= 0) {
            if (!(_yourTurnNotifiedMap[key] ?? false)) {
              _triggerYourTurnNotification(
                notificationCubit: notificationCubit,
                businessName: businessName,
                serviceName: serviceName,
                ticketNumber: userTurnNumber,
                bookingTime: bookingTime,
              );
              _yourTurnNotifiedMap[key] = true;
            }
          } else if (estimatedWaitingTime <= 60 && estimatedWaitingTime >= 30) {
            if (!(_movementNotifiedMap[key] ?? false)) {
              _triggerMovementAlertNotification(
                waitingTime: estimatedWaitingTime,
                notificationCubit: notificationCubit,
                businessName: businessName,
                serviceName: serviceName,
                ticketNumber: userTurnNumber,
                ahead: peopleAhead,
                avgServiceTime: avgServiceTime,
                bookingTime: bookingTime,
              );
              _movementNotifiedMap[key] = true;
            } else {
              _triggerQueueUpdateNotification(
                businessName: businessName,
                serviceName: serviceName,
                ticketNumber: userTurnNumber,
                currentActive: currentlyInService,
                ahead: peopleAhead,
                waitingTime: estimatedWaitingTime,
                notificationCubit: notificationCubit,
                avgServiceTime: avgServiceTime,
                bookingTime: bookingTime,
              );
            }
          } else {
            _triggerQueueUpdateNotification(
              businessName: businessName,
              serviceName: serviceName,
              ticketNumber: userTurnNumber,
              currentActive: currentlyInService,
              ahead: peopleAhead,
              waitingTime: estimatedWaitingTime,
              notificationCubit: notificationCubit,
              avgServiceTime: avgServiceTime,
              bookingTime: bookingTime,
            );
          }

          _lastNotifiedActiveTurnMap[key] = currentlyInService;
        });

    _queueSubscriptions[key] = sub;
  }

  // 👈 دالة مراقبة حالة التذكرة - تم تعديلها لتمنع تماماً إشعار الاكتمال عند بداية التشغيل الخاطئ
  void _listenForTicketStatusChanges({
    required String key,
    required String businessId,
    required String serviceId,
    required String ticketId,
    required int userTurnNumber,
    required NotificationCubit notificationCubit,
    required String serviceName,
    required String businessName,
  }) {
    final String? uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final sub = _firestore
        .collection('Queues')
        .doc(businessId)
        .collection('services')
        .doc(serviceId)
        .collection('tickets')
        .where('userId', isEqualTo: uid)
        .snapshots()
        .listen((snapshot) {
          for (var change in snapshot.docChanges) {
            if (change.type == DocumentChangeType.removed &&
                change.doc.id == ticketId) {
              _cancelAndCleanQueueListenerByKey(key);
              return;
            }

            final data = change.doc.data();
            if (data == null) continue;

            final currentStatus = (data['status'] ?? 'pending')
                .toString()
                .toLowerCase();
            final bool isInitial = !_lastTicketStatusMap.containsKey(key);

            if (isInitial) {
              // حفظ الحالة المبدئية فقط دون إطلاق أي إشعارات مزعجة
              _lastTicketStatusMap[key] = currentStatus;
              continue;
            }

            // ⚡ إشعار الاكتمال لا ينطلق إلا إذا تغيرت الحالة فعلياً وبشكل حقيقي إلى completed
            if (currentStatus == 'completed' &&
                _lastTicketStatusMap[key] != 'completed') {
              _triggerCompletedNotification(
                notificationCubit: notificationCubit,
                businessName: businessName,
                serviceName: serviceName,
                key: key,
              );
            }

            if (currentStatus == 'canceled' || currentStatus == 'deleted') {
              _cancelAndCleanQueueListenerByKey(key);
            }

            _lastTicketStatusMap[key] = currentStatus;
          }
        });

    _ticketStatusSubscriptions[key] = sub;
  }

  int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  DateTime _toDateTime(dynamic v) {
    if (v is Timestamp) return v.toDate();
    if (v is DateTime) return v;
    if (v is String) {
      final parsed = DateTime.tryParse(v);
      if (parsed != null) return parsed;
    }
    return DateTime.now();
  }

  void _triggerQueueUpdateNotification({
    required int ticketNumber,
    required int currentActive,
    required int ahead,
    required int waitingTime,
    required int avgServiceTime,
    required NotificationCubit notificationCubit,
    required String businessName,
    required String serviceName,
    DateTime? bookingTime,
  }) {
    final effectiveBookingTime = bookingTime ?? DateTime.now();
    final expectedTurnTime = _estimatedServiceStartTime(
      ahead,
      avgServiceTime,
      effectiveBookingTime,
    );
    final formattedTime = DateFormat('h:mm a').format(expectedTurnTime);
    final waitDurationText = _formatDuration(Duration(minutes: waitingTime));

    final String title = "Queue Update • Ticket Q-$ticketNumber";
    final String body =
        'Ticket Number: Q-$ticketNumber\nLive People Ahead: $ahead\nExpected Turn Time: $formattedTime\nCurrent serving: Q-$currentActive. Your estimated wait is $waitDurationText.';

    NotificationService().showNotification(id: 101, title: title, body: body);
    notificationCubit.addNotification(
      title: title,
      body: body,
      serviceName: serviceName,
      businessName: businessName,
      isRead: false,
    );
  }

  void _triggerMovementAlertNotification({
    required int waitingTime,
    required NotificationCubit notificationCubit,
    required String businessName,
    required String serviceName,
    required int ticketNumber,
    required int ahead,
    required int avgServiceTime,
    DateTime? bookingTime,
  }) {
    final effectiveBookingTime = bookingTime ?? DateTime.now();
    final expectedTurnTime = _estimatedServiceStartTime(
      ahead,
      avgServiceTime,
      effectiveBookingTime,
    );
    final formattedTime = DateFormat('h:mm a').format(expectedTurnTime);
    const String title = "Time to move! 🏃‍♂️";
    final String body =
        'Ticket Number: Q-$ticketNumber\nLive People Ahead: $ahead\nExpected Turn Time: $formattedTime\nOnly $waitingTime minutes left before your turn. Please start moving now to arrive on time.';

    NotificationService().showNotification(id: 102, title: title, body: body);
    notificationCubit.addNotification(
      title: title,
      body: body,
      serviceName: serviceName,
      businessName: businessName,
      isRead: false,
    );
  }

  void _triggerYourTurnNotification({
    required NotificationCubit notificationCubit,
    required String businessName,
    required String serviceName,
    required int ticketNumber,
    DateTime? bookingTime,
  }) {
    const String title = "It's your turn right now! 🎉";
    final String body =
        'Ticket Number: Q-$ticketNumber\nLive People Ahead: 0\nExpected Turn Time: Right now\nIt\'s your turn right now! Please proceed to the service desk immediately.';

    NotificationService().showNotification(id: 103, title: title, body: body);
    notificationCubit.addNotification(
      title: title,
      body: body,
      serviceName: serviceName,
      businessName: businessName,
      isRead: false,
    );
  }

  void _triggerCompletedNotification({
    required NotificationCubit notificationCubit,
    required String businessName,
    required String serviceName,
    String? key,
  }) {
    final alreadyNotified = key != null
        ? (_serviceCompletedNotifiedMap[key] ?? false)
        : false;

    if (!alreadyNotified) {
      String title = "Service Completed! 🎉";
      String body =
          "Thank you for using Taborq! Your service for $serviceName at $businessName has been completed successfully.";

      NotificationService().showNotification(id: 104, title: title, body: body);
      notificationCubit.addNotification(
        title: title,
        body: body,
        serviceName: serviceName,
        businessName: businessName,
        isRead: false, // إشعار اكتمال جديد غير مقروء ومميز
      );
      if (key != null) _serviceCompletedNotifiedMap[key] = true;
    }
  }

  // 👈 دالة بدء التشغيل عند فتح التطبيق: تم تعديلها لتبحث فقط عن التذاكر الفعالة والـ pending وتتجاهل المنتهية تماماً لتجنب استدعاء إشعار الاكتمال فوراً
  Future<void> initListenersForUserActiveTickets(
    NotificationCubit notificationCubit,
  ) async {
    final String? uid = _auth.currentUser?.uid;
    if (uid == null) return;

    try {
      final querySnapshot = await _firestore
          .collectionGroup('tickets')
          .where('userId', isEqualTo: uid)
          .where(
            'status',
            isEqualTo: 'pending',
          ) // 👈 تم التعديل هنا: نبحث عن الـ pending فقط
          .get();

      debugPrint(
        'initListenersForUserActiveTickets: found ${querySnapshot.docs.length} active pending tickets for user $uid',
      );

      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        final int ticketNumber = data['ticketNumber'] ?? 0;
        final String businessId = data['businessId'] ?? '';
        final String serviceId = data['serviceId'] ?? '';
        final String serviceName = data['serviceName'] ?? '';
        final String businessName =
            data['bussinessName'] ?? data['businessName'] ?? '';

        int avgServiceTime = 10;
        try {
          final serviceDoc = await _firestore
              .collection('Queues')
              .doc(businessId)
              .collection('services')
              .doc(serviceId)
              .get();
          if (serviceDoc.exists) {
            avgServiceTime =
                serviceDoc.data()?['avgServiceTime'] ?? avgServiceTime;
          }
        } catch (_) {}

        // تشغيل الـ Listener للتذاكر الـ Pending فقط لتحديث حركة الطابور الحية
        final String ticketId = doc.id;
        startQueueListener(
          businessId: businessId,
          serviceId: serviceId,
          userTurnNumber: ticketNumber,
          ticketId: ticketId,
          avgServiceTime: avgServiceTime,
          notificationCubit: notificationCubit,
          serviceName: serviceName,
          businessName: businessName,
          bookingTime: _toDateTime(data['bookingTime']),
        );
      }
    } catch (e) {
      debugPrint('Error initializing active ticket listeners: ${e.toString()}');
    }
  }

  @override
  Future<void> close() {
    for (final s in _queueSubscriptions.values) {
      s.cancel();
    }
    for (final s in _ticketStatusSubscriptions.values) {
      s.cancel();
    }
    return super.close();
  }
}
