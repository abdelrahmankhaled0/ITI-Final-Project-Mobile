class ClinicModel {
  final String name;
  final String distance;
  final double rating;
  final int waitTimeMinutes;
  final String imagePath;
  final String type;
  final bool isHighDemand;
  final bool canCheckInNow;

  ClinicModel({
    required this.name,
    required this.distance,
    required this.rating,
    required this.waitTimeMinutes,
    required this.imagePath,
    required this.type,
    this.isHighDemand = false,
    this.canCheckInNow = false,
  });
}