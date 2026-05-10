class ClinicModel {
  final String id;
  final String name;
  final String address;
  final double rating;
  final int waitTime;
  final String image;

  ClinicModel({
    required this.id,
    required this.name,
    required this.address,
    required this.rating,
    required this.waitTime,
    required this.image,
  });

  // وظيفة لتحويل البيانات من Firebase (Map) إلى Model
  factory ClinicModel.fromFirestore(Map<String, dynamic> data, String documentId) {
    return ClinicModel(
      id: documentId,
      name: data['name'] ?? '',
      address: data['address'] ?? '',
      rating: (data['rating'] ?? 0).toDouble(),
      waitTime: data['waitTime'] ?? 0,
      image: data['image'] ?? '',
    );
  }
}