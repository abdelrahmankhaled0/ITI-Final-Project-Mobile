class ServiceModel {
  final String id;
  final String serviceName;
  final String about;
  final int avgServiceTime;
  final int currentTicket;
  final int lastGeneratedTicket;
  final String imageUrl;
  final bool isActive;
  final List<String> subServiceNames;

  ServiceModel({
    required this.id,
    required this.serviceName,
    required this.about,
    required this.avgServiceTime,
    required this.currentTicket,
    required this.lastGeneratedTicket,
    required this.imageUrl,
    required this.isActive,
    required this.subServiceNames,
  });

  factory ServiceModel.fromFirestore(Map<String, dynamic> data, String id) {
    return ServiceModel(
      id: id,
      serviceName: data['serviceName'] ?? '',
      about: data['about'] ?? '',
      avgServiceTime: (data['avgServiceTime'] as num?)?.toInt() ?? 0,
      currentTicket: (data['currentTicket'] as num?)?.toInt() ?? 0,
      lastGeneratedTicket: (data['lastGeneratedTicket'] as num?)?.toInt() ?? 0,
      imageUrl: data['imageUrl'] ?? '',
      isActive: data['isActive'] ?? false,
      subServiceNames: List<String>.from(data['subServiceNames'] ?? []),
    );
  }
}