import 'package:cloud_firestore/cloud_firestore.dart';

class TicketModel {
  final String ticketId;
  final String userId;
  final String businessId;
  final String serviceId;
  final String
  serviceName; // الكاتيجوري أو اسم الخدمة (مثل: قسم الصدر / دكتور معين)
  final int ticketNumber;
  final DateTime bookingTime;
  final String status;
  final String name;
  final String phone; // pending, serving, completed, cancelled

  TicketModel({
    required this.ticketId,
    required this.userId,
    required this.businessId,
    required this.serviceId,
    required this.serviceName,
    required this.ticketNumber,
    required this.bookingTime,
    required this.status,
    required this.name,
    required this.phone,
  });

  // تحويل الموديل لـ Map عشان نرفعه للفايربيز
  Map<String, dynamic> toFirestore() {
    return {
      'ticketId': ticketId,
      'userId': userId,
      'businessId': businessId,
      'serviceId': serviceId,
      'serviceName': serviceName,
      'ticketNumber': ticketNumber,
      'bookingTime': Timestamp.fromDate(bookingTime),
      'status': status,
      'name': name,
      'phone': phone,
    };
  }

  // تحويل الـ Map الراجع من الفايربيز لموديل نقدر نستخدمه في الابليكيشن
  factory TicketModel.fromFirestore(Map<String, dynamic> data) {
    return TicketModel(
      ticketId: data['ticketId'] ?? '',
      userId: data['userId'] ?? '',
      businessId: data['businessId'] ?? '',
      serviceId: data['serviceId'] ?? '',
      serviceName: data['serviceName'] ?? '',
      ticketNumber: (data['ticketNumber'] as num?)?.toInt() ?? 0,
      bookingTime: (data['bookingTime'] as Timestamp).toDate(),
      status: data['status'] ?? 'pending',
      name: data["name"] ?? "",
      phone: data["phone"],
    );
  }
}
