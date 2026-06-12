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
            businessName: businessName,
            serviceName: serviceName,
            avgServiceTime: avgServiceTime,
          ),
        );
        return;
      }

      // 4️⃣ الـ Transaction لتحديث الـ Counter وحفظ التذكرة
      int finalTicketCode = await _firestore.runTransaction<int>((
        transaction,
      ) async {
        DocumentSnapshot serviceSnapshot = await transaction.get(serviceRef);

        int currentLastTicket = 0;
        if (serviceSnapshot.exists) {
          Map<String, dynamic> serviceData =
              serviceSnapshot.data() as Map<String, dynamic>;
          currentLastTicket = serviceData['lastGeneratedTicket'] ?? 0;
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
          bookingTime: DateTime.now(),
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
      );
    } catch (e) {
      emit(BookingFailure(errorMessage: "Booking failed: ${e.toString()}"));
    }
  }

  // استبدل أو ضيف دالة الـ Listener دي والـ Functions المساعدة اللي تحتها جوه الـ BookingCubit بتاعك:

  // Support multiple active ticket listeners (user may have tickets across services)
  final Map<String, StreamSubscription> _queueSubscriptions = {};
  final Map<String, bool> _movementNotifiedMap = {};
  final Map<String, bool> _completedNotifiedMap = {};
  final Map<String, int> _lastNotifiedActiveTurnMap = {};

  void _triggerBookingCreatedNotification({
    required NotificationCubit notificationCubit,
    required String businessName,
    required String serviceName,
    required int ticketNumber,
    required int avgServiceTime,
  }) {
    final estimatedStartTime = _estimatedServiceStartTime(
      ticketNumber,
      avgServiceTime,
    );
    final formattedTime = DateFormat('h:mm a').format(estimatedStartTime);

    final String title = 'Booking confirmed for $serviceName';
    final String body =
        'Your ticket Q-$ticketNumber at $businessName is confirmed. Estimated service start from 9:00 AM is $formattedTime.';

    NotificationService().showNotification(id: 100, title: title, body: body);
    notificationCubit.addNotification(
      title: title,
      body: body,
      serviceName: serviceName,
      businessName: businessName,
    );
  }

  DateTime _estimatedServiceStartTime(int ticketNumber, int avgServiceTime) {
    final now = DateTime.now();
    final workStart = DateTime(now.year, now.month, now.day, 9);
    return workStart.add(
      Duration(minutes: (ticketNumber - 1) * avgServiceTime),
    );
  }

  void startQueueListener({
    required String businessId,
    required String serviceId,
    required int userTurnNumber,
    required int avgServiceTime,
    required NotificationCubit notificationCubit,
    required String serviceName,
    required String businessName,
  }) {
    final key = '${businessId}_$serviceId';
    _movementNotifiedMap[key] = false;
    _completedNotifiedMap[key] = false;
    _lastNotifiedActiveTurnMap[key] = -1;
    // cancel existing subscription for this service if any
    _queueSubscriptions[key]?.cancel();

    debugPrint(
      "🎯 startQueueListener Started for Ticket Q-$userTurnNumber (key=$key)",
    );

    final sub = _firestore
        .collection('Queues')
        .doc(businessId)
        .collection('services')
        .doc(serviceId)
        .snapshots()
        .listen((snapshot) {
          debugPrint("⚡ Stream triggered! Snapshot exists: ${snapshot.exists}");

          if (snapshot.exists && snapshot.data() != null) {
            final raw = snapshot.data();
            debugPrint('Service snapshot data for $key: $raw');
            int currentlyInService = _toInt(raw?['currentlyInService']);
            int peopleAhead = userTurnNumber - currentlyInService;
            int estimatedWaitingTime = peopleAhead * avgServiceTime;

            if (peopleAhead < 0) {
              _triggerCompletedNotification(
                notificationCubit: notificationCubit,
                businessName: businessName,
                serviceName: serviceName,
                key: key,
              );
              emit(BookingQueueCompleted());
              _queueSubscriptions[key]?.cancel();
              return;
            }

            emit(
              BookingQueueUpdated(
                currentlyInService: currentlyInService,
                peopleAhead: peopleAhead,
                estimatedWaitingTime: estimatedWaitingTime,
              ),
            );

            if (currentlyInService != (_lastNotifiedActiveTurnMap[key] ?? -1)) {
              debugPrint(
                "🔔 Triggering notification for Ticket Q-$userTurnNumber (key=$key)",
              );
              _triggerQueueUpdateNotification(
                businessName: businessName,
                serviceName: serviceName,
                ticketNumber: userTurnNumber,
                currentActive: currentlyInService,
                ahead: peopleAhead,
                waitingTime: estimatedWaitingTime,
                notificationCubit: notificationCubit,
                avgServiceTime: avgServiceTime,
              );
              _lastNotifiedActiveTurnMap[key] = currentlyInService;
            }

            if (estimatedWaitingTime <= 60 &&
                estimatedWaitingTime > 30 &&
                !_movementNotifiedMap[key]!) {
              _triggerMovementAlertNotification(
                waitingTime: estimatedWaitingTime,
                notificationCubit: notificationCubit,
                businessName: businessName,
                serviceName: serviceName,
              );
              _movementNotifiedMap[key] = true;
            }

            if (peopleAhead == 0 && !_completedNotifiedMap[key]!) {
              _triggerYourTurnNotification(
                notificationCubit: notificationCubit,
                businessName: businessName,
                serviceName: serviceName,
              );
              _completedNotifiedMap[key] = true;
            }
          }
        });

    _queueSubscriptions[key] = sub;
    _lastNotifiedActiveTurnMap[key] = _lastNotifiedActiveTurnMap[key] ?? -1;
  }

  int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
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
  }) {
    final estimatedStartTime = _estimatedServiceStartTime(
      ticketNumber,
      avgServiceTime,
    );
    final formattedTime = DateFormat('h:mm a').format(estimatedStartTime);

    String title = "Queue Update - Ticket Q-$ticketNumber";
    String body =
        "Current turn: $currentActive. There are $ahead people ahead of you for $serviceName at $businessName. Estimated start time from 9:00 AM is $formattedTime.";

    NotificationService().showNotification(id: 101, title: title, body: body);
    notificationCubit.addNotification(
      title: title,
      body: body,
      serviceName: serviceName,
      businessName: businessName,
    );
  }

  void _triggerMovementAlertNotification({
    required int waitingTime,
    required NotificationCubit notificationCubit,
    required String businessName,
    required String serviceName,
  }) {
    String title = "Time to move! 🏃‍♂️";
    String body =
        "Only $waitingTime minutes left for $serviceName at $businessName. Please start moving now to arrive on time!";

    NotificationService().showNotification(id: 102, title: title, body: body);
    notificationCubit.addNotification(
      title: title,
      body: body,
      serviceName: serviceName,
      businessName: businessName,
    );
  }

  void _triggerYourTurnNotification({
    required NotificationCubit notificationCubit,
    required String businessName,
    required String serviceName,
  }) {
    String title = "It's your turn! 🎉";
    String body =
        "Please proceed immediately to $serviceName at $businessName, you are being called now.";

    NotificationService().showNotification(id: 103, title: title, body: body);
    notificationCubit.addNotification(
      title: title,
      body: body,
      serviceName: serviceName,
      businessName: businessName,
    );
  }

  void _triggerCompletedNotification({
    required NotificationCubit notificationCubit,
    required String businessName,
    required String serviceName,
    String? key,
  }) {
    final alreadyNotified = key != null
        ? (_completedNotifiedMap[key] ?? false)
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
      );
      if (key != null) _completedNotifiedMap[key] = true;
    }
  }

  @override
  Future<void> close() {
    for (final s in _queueSubscriptions.values) {
      s.cancel();
    }
    _authStateSub?.cancel();
    return super.close();
  }

  /// Query user's active pending tickets and start queue listeners for them so
  /// notifications are delivered even if the user didn't manually open the
  /// related service screen or press "Book Now" in this session.
  Future<void> initListenersForUserActiveTickets(
    NotificationCubit notificationCubit,
  ) async {
    final String? uid = _auth.currentUser?.uid;
    if (uid == null) return;

    try {
      final querySnapshot = await _firestore
          .collectionGroup('tickets')
          .where('userId', isEqualTo: uid)
          .where('status', isEqualTo: 'pending')
          .get();

      debugPrint(
        'initListenersForUserActiveTickets: found ${querySnapshot.docs.length} active tickets for user $uid',
      );

      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        final int ticketNumber = data['ticketNumber'] ?? 0;
        final String businessId = data['businessId'] ?? '';
        final String serviceId = data['serviceId'] ?? '';
        final String serviceName = data['serviceName'] ?? '';
        final String businessName =
            data['bussinessName'] ?? data['businessName'] ?? '';

        debugPrint(
          'initListenersForUserActiveTickets: ticket Q-$ticketNumber for service $serviceId at business $businessId (serviceName=$serviceName)',
        );

        // try to read avgServiceTime from the service doc
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

        // Start listener for this active ticket
        startQueueListener(
          businessId: businessId,
          serviceId: serviceId,
          userTurnNumber: ticketNumber,
          avgServiceTime: avgServiceTime,
          notificationCubit: notificationCubit,
          serviceName: serviceName,
          businessName: businessName,
        );
      }
    } catch (e) {
      debugPrint('Error initializing active ticket listeners: ${e.toString()}');
    }
  }
}
