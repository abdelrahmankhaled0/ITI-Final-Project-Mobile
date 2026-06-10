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
      String businesseName = "";
      String imageUri = "";

      // 1️⃣ جلب بيانات البيزنس (تم تصليح اسم الكولكشن لـ businesses)
      try {
        final snapshot = await _firestore
            .collection("businesses")
            .doc(businessId)
            .get();

        if (snapshot.exists) {
          final data = snapshot.data();
          if (data != null) {
            businesseName = data['name'] ?? "";
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

      debugPrint("================ BINDING DATA ================");
      debugPrint("UserID: $userId");
      debugPrint("BusinessID: $businessId");
      debugPrint("ServiceID: $serviceId");

      debugPrint("==============================================");

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
        // جلب رقم التذكرة الحالي كـ String أو تحويله لأمان الـ UI
        String activeTicketNum =
            existingTicket.data()?['ticketNumber']?.toString() ?? "A-000";

        emit(
          BookingSuccess(ticketCode: activeTicketNum, isAlreadyBooked: true),
        );
        return;
      }

      // 4️⃣ الـ Transaction لتحديث الـ Counter وحفظ التذكرة (تم تعديل الـ Return لـ String)
      String finalTicketCode = await _firestore.runTransaction<String>((
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

        // توليد الكود المنسق بشكل بروفيشنال (مثال: A-014)
        String formattedTicketCode =
            'Q-${updatedTicket.toString().padLeft(3, '0')}';

        // تحديث الـ Counter بالأرقام النظيفة (int) في السيرفر عشان الـ Transaction اللي بعده
        transaction.set(serviceRef, {
          'lastGeneratedTicket': updatedTicket,
        }, SetOptions(merge: true));

        // إنشاء موديل التذكرة بالكود الـ String المنسق
        final newTicket = TicketModel(
          name: userName,
          ticketId: ticketDocId,
          userId: userId,
          businessId: businessId,
          serviceId: serviceId,
          serviceName: serviceName,
          ticketNumber: updatedTicket, // 🚀 مبعوثة كـ String منسق تماماً
          bookingTime: DateTime.now(),
          status: 'pending',
          phone: userPhone,
          bussinessName: businesseName,
          imageURI: imageUri,
        );

        // حفظ التذكرة في الفايربيز جوه الـ Transaction
        transaction.set(ticketRef, newTicket.toFirestore());

        // نرجع الكود المنسق عشان الـ Cubit يستقبله بره
        return formattedTicketCode;
      });

      debugPrint(
        "✅ Ticket successfully saved in Firestore with Code: $finalTicketCode",
      );

      // 5️⃣ إرسال حالة النجاح للـ UI بالكود المنسق الجديد
      emit(BookingSuccess(ticketCode: finalTicketCode, isAlreadyBooked: false));
    } catch (e) {
      debugPrint("❌ Firestore Booking Error: ${e.toString()}");
      emit(BookingFailure(errorMessage: "Booking failed: ${e.toString()}"));
    }
  }

  // 🚀 ضيف الدالة دي جوه الكيوبت المسؤول عن شاشة الحجز أو الطابور (وليس كيو بت الإشعارات)
  // 🚀 النسخة المتطابقة 100% مع بنية الفايرستور بتاعتك
  void startQueueListener({
    required String businessId, // محتاجينه للمسار
    required String serviceId, // محتاجينه للمسار
    required int userTurnNumber,
    required NotificationCubit notificationCubit,
  }) {
    FirebaseFirestore.instance
        .collection('Queues') // 🎯 Q كابيتال زي الفايرستور
        .doc(businessId)
        .collection('services')
        .doc(
          serviceId,
        ) // 🎯 هنا المكان الصح اللي جواه الـ currentTurn والـ counter
        .snapshots()
        .listen((snapshot) {
          if (snapshot.exists) {
            // 🎯 تعديل اسم الفيلد لـ currentTurn ليطابق السيرفر
            int currentServing = snapshot.data()?['currentTurn'] ?? 0;

            // الحسبة السحرية
            int peopleAhead = userTurnNumber - currentServing;

            // 1. حالة: لو فاضل 3 أشخاص أو أقل ودور اليوزر لسه مجاش
            if (peopleAhead > 0 && peopleAhead <= 3) {
              String title = "Your turn is approaching! 🏃‍♂️";
              String body =
                  "Current turn: $currentServing. Your number: $userTurnNumber. There are $peopleAhead people ahead of you.";

              NotificationService().showNotification(
                id: 1,
                title: title,
                body: body,
              );

              notificationCubit.addNotification(title: title, body: body);
            }
            // 2. حالة: جه دور اليوزر بالظبط
            else if (peopleAhead == 0) {
              String title = "It's your turn! 🎉";
              String body = "Please proceed immediately, you are being called.";

              NotificationService().showNotification(
                id: 2,
                title: title,
                body: body,
              );
              notificationCubit.addNotification(title: title, body: body);
            }
          }
        });
  }
}
