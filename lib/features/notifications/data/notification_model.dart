class NotificationModel {
  final String id;
  final String title;
  final String body;
  final DateTime dateTime;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.dateTime,
  });

  // لتحويل البيانات القادمة من الفايربيز أو الـ Local Storage
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      dateTime: json['dateTime'] != null
          ? DateTime.parse(json['dateTime'])
          : DateTime.now(),
    );
  }
}
