enum MessageType { text, image, voice, confirmation }

class ChatMessageModel {
  final String? message;
  final String? mediaPath;
  final bool isUser;
  final DateTime time;
  final MessageType type;
  final Map<String, dynamic>? bookingData;
  final List<dynamic>? suggestedServices; // 🌟 أضفنا حقل اقتراحات الخدمات هنا

  ChatMessageModel({
    this.message,
    this.mediaPath,
    required this.isUser,
    required this.time,
    required this.type,
    this.bookingData,
    this.suggestedServices,
  });
}