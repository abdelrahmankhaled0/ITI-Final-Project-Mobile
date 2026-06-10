import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;

  final String title;
  final String body;

  final String businessName;
  final String serviceName;

  final int userTicketNumber;
  final int currentActiveNumber;
  final int peopleAhead;
  final int estimatedWaitingTime;

  final DateTime createdAt;
  final bool isRead;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.businessName,
    required this.serviceName,
    required this.userTicketNumber,
    required this.currentActiveNumber,
    required this.peopleAhead,
    required this.estimatedWaitingTime,
    required this.createdAt,
    required this.isRead,
  });

  factory NotificationModel.fromJson(String id, Map<String, dynamic> json) {
    return NotificationModel(
      id: id,

      title: json["title"] ?? "",
      body: json["body"] ?? "",

      businessName: json["businessName"] ?? "",
      serviceName: json["serviceName"] ?? "",

      userTicketNumber: json["userTicketNumber"] ?? 0,
      currentActiveNumber: json["currentActiveNumber"] ?? 0,
      peopleAhead: json["peopleAhead"] ?? 0,
      estimatedWaitingTime: json["estimatedWaitingTime"] ?? 0,

      createdAt: json["createdAt"] != null
          ? (json["createdAt"] as Timestamp).toDate()
          : DateTime.now(),

      isRead: json["isRead"] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "title": title,
      "body": body,

      "businessName": businessName,
      "serviceName": serviceName,

      "userTicketNumber": userTicketNumber,
      "currentActiveNumber": currentActiveNumber,
      "peopleAhead": peopleAhead,
      "estimatedWaitingTime": estimatedWaitingTime,

      "createdAt": Timestamp.fromDate(createdAt),
      "isRead": isRead,
    };
  }
}
