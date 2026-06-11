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
    return NotificationModel(
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      serviceName: json['serviceName'] ?? '',
      businessName: json['businessName'] ?? '',
      dateTime: json['dateTime'] != null
          ? DateTime.parse(json['dateTime'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'body': body,
      'serviceName': serviceName,
      'businessName': businessName,
      'dateTime': dateTime.toIso8601String(),
    };
  }
}
