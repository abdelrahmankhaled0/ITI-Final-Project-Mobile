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

      final String ticketDocId = "${userId}_$serviceId";

      debugPrint("================ BINDING DATA ================");
      debugPrint("UserID: $userId");
      debugPrint("BusinessID: $businessId");
      debugPrint("ServiceID: $serviceId");
      debugPrint("==============================================");

      // التعديل هنا: غيّرنا 'businesses' لـ 'Queues'
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

      // 1. التشيك إذا كان محجوز مسبقاً
      final existingTicket = await ticketRef.get();
      if (existingTicket.exists &&
          existingTicket.data()?['status'] == 'pending') {
        int activeTicketNum = existingTicket.data()?['ticketNumber'] ?? 0;
        emit(
          BookingSuccess(ticketNumber: activeTicketNum, isAlreadyBooked: true),
        );
        return;
      }

      // 2. الـ Transaction لتحديث الـ Counter وحفظ التذكرة
      int nextTicketNumber = await _firestore.runTransaction<int>((
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

        // تحديث أو إنشاء الـ Counter في الخدمة
        transaction.set(serviceRef, {
          'lastGeneratedTicket': updatedTicket,
        }, SetOptions(merge: true));

        // إنشاء التذكرة
        final newTicket = TicketModel(
          ticketId: ticketDocId,
          userId: userId,
          businessId: businessId,
          serviceId: serviceId,
          serviceName: serviceName,
          ticketNumber: updatedTicket,
          bookingTime: DateTime.now(),
          status: 'pending',
        );

        // حفظ التذكرة في الفايربيز
        transaction.set(ticketRef, newTicket.toFirestore());

        return updatedTicket;
      });

      debugPrint(
        "✅ Ticket successfully saved in Firestore with Number: $nextTicketNumber",
      );
      emit(
        BookingSuccess(ticketNumber: nextTicketNumber, isAlreadyBooked: false),
      );
    } catch (e) {
      debugPrint("❌ Firestore Booking Error: ${e.toString()}");
      emit(BookingFailure(errorMessage: "Booking failed: ${e.toString()}"));
    }
  }
}
