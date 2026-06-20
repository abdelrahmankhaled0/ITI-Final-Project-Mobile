class ClinicModel {
  final String id;
  final String name;
  final String address;
  final double rating;
  final int waitTime;
  final String imageUrl;
  final String category;
  final String lat;
  final String lng;

  ClinicModel({
    required this.id,
    required this.name,
    required this.address,
    required this.rating,
    required this.waitTime,
    required this.imageUrl,
    required this.category,
    required this.lat,
    required this.lng,
  });

  factory ClinicModel.fromFirestore(
    Map<String, dynamic> data,
    String documentId,
  ) {
    return ClinicModel(
      id: documentId,
      name: data['name'] ?? '',
      address: data['address'] ?? '',
      rating: (data['rating'] ?? 0).toDouble(),
      waitTime: data['avgServiceTime'] ?? 0,
      imageUrl: data['imageUrl'] ?? '',
      category: data['category'] ?? 'General',
      lat: (data['latitude'] ?? '0').toString(),
      lng: (data['longitude'] ?? '0').toString(),
    );
  }
}
