import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String serviceName;
  final String businessName;
  final DateTime dateTime;
  final bool isRead;

  NotificationModel({
    this.id = '',
    required this.title,
    required this.body,
    required this.serviceName,
    required this.businessName,
    required this.dateTime,
    this.isRead = false,
  });

  factory NotificationModel.fromJson(
    Map<String, dynamic> json, {
    String id = '',
  }) {
    DateTime parsedDate;
    if (json['dateTime'] is Timestamp) {
      parsedDate = (json['dateTime'] as Timestamp).toDate();
    } else if (json['dateTime'] is String) {
      parsedDate = DateTime.tryParse(json['dateTime']) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    return NotificationModel(
      id: id,
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      serviceName: json['serviceName'] ?? '',
      businessName: json['businessName'] ?? '',
      dateTime: parsedDate,
      isRead: json['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'body': body,
      'serviceName': serviceName,
      'businessName': businessName,
      'dateTime': Timestamp.fromDate(dateTime),
      'isRead': isRead,
    };
  }
}
