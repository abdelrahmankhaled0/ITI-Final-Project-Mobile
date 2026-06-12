import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String title;
  final String body;
  final String serviceName;
  final String businessName;
  final DateTime dateTime;

  NotificationModel({
    required this.title,
    required this.body,
    required this.serviceName,
    required this.businessName,
    required this.dateTime,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    DateTime parsedDate;
    if (json['dateTime'] is Timestamp) {
      parsedDate = (json['dateTime'] as Timestamp).toDate();
    } else if (json['dateTime'] is String) {
      parsedDate = DateTime.tryParse(json['dateTime']) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    return NotificationModel(
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      serviceName: json['serviceName'] ?? '',
      businessName: json['businessName'] ?? '',
      dateTime: parsedDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'body': body,
      'serviceName': serviceName,
      'businessName': businessName,
      'dateTime': Timestamp.fromDate(dateTime),
    };
  }
}
