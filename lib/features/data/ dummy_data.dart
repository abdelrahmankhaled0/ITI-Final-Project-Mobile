import 'package:taborq/features/models/clinic_model.dart';

class DummyData {
  static const String hospitalName = 'City Central Hospital';
  static const int hospitalQueue = 12;
  static const int hospitalWaitMinutes = 14;
  static const double hospitalQueueProgress = 0.45;

  static final List<ClinicModel> nearbyClinics = [
    ClinicModel(
      name: 'Elite Dental Care',
      distance: '0.8 miles away',
      rating: 4.9,
      waitTimeMinutes: 5,
      imagePath: 'assets/images/clince.png',
      type: 'Dental',
      canCheckInNow: true,
    ),
    ClinicModel(
      name: 'General Wellness Center',
      distance: '2.4 miles away',
      rating: 4.7,
      waitTimeMinutes: 45,
      imagePath: 'assets/images/hospital.png',
      type: 'General',
      isHighDemand: true,
    ),
    ClinicModel(
      name: 'Northside Pediatrics',
      distance: '3.1 miles away',
      rating: 4.8,
      waitTimeMinutes: 12,
      imagePath: 'assets/images/northside.png',
      type: 'General',
    ),
  ];
}