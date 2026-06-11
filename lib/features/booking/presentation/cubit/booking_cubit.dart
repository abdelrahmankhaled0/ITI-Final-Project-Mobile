import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:taborq/core/services/remote/notification_service.dart';
import 'package:taborq/features/notifications/presentation/cubit/notification_cubit.dart';
import '../../data/models/ticket_model.dart';
import 'booking_state.dart';

class BookingCubit extends Cubit<BookingState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  BookingCubit() : super(BookingInitial());

  Future<void> bookQueuePlace({
    required String businessId,
    required String serviceId,
    required String serviceName,
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
          BookingSuccess(ticketCode: activeTicketNum, isAlreadyBooked: true),
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

      emit(BookingSuccess(ticketCode: finalTicketCode, isAlreadyBooked: false));
    } catch (e) {
      emit(BookingFailure(errorMessage: "Booking failed: ${e.toString()}"));
    }
  }

  // استبدل أو ضيف دالة الـ Listener دي والـ Functions المساعدة اللي تحتها جوه الـ BookingCubit بتاعك:

  StreamSubscription? _queueSubscription;
  bool _isMovementNotified = false;
  bool _isCompletedNotified = false;
  int _lastNotifiedActiveTurn = -1;

  void startQueueListener({
    required String businessId,
    required String serviceId,
    required int userTurnNumber,
    required int avgServiceTime,
    required NotificationCubit notificationCubit,
    required String serviceName,
    required String businessName,
  }) {
    _isMovementNotified = false;
    _isCompletedNotified = false;
    _lastNotifiedActiveTurn = -1;
    _queueSubscription?.cancel();

    print("🎯 startQueueListener Started for Ticket Q-$userTurnNumber");

    _queueSubscription = _firestore
        .collection('Queues')
        .doc(businessId)
        .collection('services')
        .doc(serviceId)
        .snapshots()
        .listen((snapshot) {
          print("⚡ Stream triggered! Snapshot exists: ${snapshot.exists}");

          if (snapshot.exists && snapshot.data() != null) {
            int currentlyInService =
                snapshot.data()?['currentlyInService'] ?? 0;
            int peopleAhead = userTurnNumber - currentlyInService;
            int estimatedWaitingTime = peopleAhead * avgServiceTime;

            if (peopleAhead < 0) {
              _triggerCompletedNotification(
                notificationCubit: notificationCubit,
                businessName: businessName,
                serviceName: serviceName,
              );
              emit(BookingQueueCompleted());
              _queueSubscription?.cancel();
              return;
            }

            emit(
              BookingQueueUpdated(
                currentlyInService: currentlyInService,
                peopleAhead: peopleAhead,
                estimatedWaitingTime: estimatedWaitingTime,
              ),
            );

            if (currentlyInService != _lastNotifiedActiveTurn) {
              print("🔔 Triggering notification for Ticket Q-$userTurnNumber");
              _triggerQueueUpdateNotification(
                businessName: businessName,
                serviceName: serviceName,
                ticketNumber: userTurnNumber,
                currentActive: currentlyInService,
                ahead: peopleAhead,
                waitingTime: estimatedWaitingTime,
                notificationCubit: notificationCubit,
              );
              _lastNotifiedActiveTurn = currentlyInService;
            }

            if (estimatedWaitingTime <= 60 &&
                estimatedWaitingTime > 30 &&
                !_isMovementNotified) {
              _triggerMovementAlertNotification(
                waitingTime: estimatedWaitingTime,
                notificationCubit: notificationCubit,
                businessName: businessName,
                serviceName: serviceName,
              );
              _isMovementNotified = true;
            }

            if (peopleAhead == 0 && !_isCompletedNotified) {
              _triggerYourTurnNotification(
                notificationCubit: notificationCubit,
                businessName: businessName,
                serviceName: serviceName,
              );
            }
          }
        });
  }

  void _triggerQueueUpdateNotification({
    required int ticketNumber,
    required int currentActive,
    required int ahead,
    required int waitingTime,
    required NotificationCubit notificationCubit,
    required String businessName,
    required String serviceName,
  }) {
    String title = "Queue Update - Ticket Q-$ticketNumber";
    String body =
        "Current turn: $currentActive. There are $ahead people ahead of you for $serviceName at $businessName. Waiting time: $waitingTime mins.";

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
  }) {
    if (!_isCompletedNotified) {
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
      _isCompletedNotified = true;
    }
  }

  @override
  Future<void> close() {
    _queueSubscription?.cancel();
    return super.close();
  }
}
