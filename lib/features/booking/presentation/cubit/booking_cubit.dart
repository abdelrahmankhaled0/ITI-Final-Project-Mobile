import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
            'A-${updatedTicket.toString().padLeft(3, '0')}';

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
          ticketNumber: formattedTicketCode, // 🚀 مبعوثة كـ String منسق تماماً
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
}
