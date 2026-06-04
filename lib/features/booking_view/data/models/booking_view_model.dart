import 'package:cloud_firestore/cloud_firestore.dart';

class BookingViewModel {
  final String uri;
  final DateTime date;
  final String ticketNumber;
  final String bussinessName;
  final String serviceName;
  final String status;

  BookingViewModel({
    required this.uri,
    required this.date,
    required this.ticketNumber,
    required this.bussinessName,
    required this.serviceName,
    required this.status,
  });

  factory BookingViewModel.fromJson(Map<String, dynamic> data) {
    return BookingViewModel(
      uri: data["imageURI"] ?? "",
      date: data["bookingTime"] != null
          ? (data["bookingTime"] as Timestamp).toDate()
          : DateTime.now(),
      ticketNumber: data["ticketNumber"]?.toString() ?? "",
      bussinessName: data["bussinessName"] ?? "",
      serviceName: data["serviceName"] ?? "",
      status: data["status"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "imageURI": uri,
      "bookingTime": date,
      "ticketNumber": ticketNumber,
      "bussinessName": bussinessName,

      "serviceName": serviceName,
      "status": status,
    };
  }
}

// import 'package:cloud_firestore/cloud_firestore.dart';

// class BookingViewModel {
//   final String ticketId;
//   final String userId;
//   final String businessId;
//   final String serviceId;
//   final String serviceName;
//   final String status;
//   final String ticketNumber;
//   final DateTime bookingTime;

//   BookingViewModel({
//     required this.ticketId,
//     required this.userId,
//     required this.businessId,
//     required this.serviceId,
//     required this.serviceName,
//     required this.status,
//     required this.ticketNumber,
//     required this.bookingTime,
//   });

//   factory BookingViewModel.fromJson(Map<String, dynamic> json) {
//     return BookingViewModel(
//       ticketId: json["ticketId"] ?? "",
//       userId: json["userId"] ?? "",
//       businessId: json["businessId"] ?? "",
//       serviceId: json["serviceId"] ?? "",
//       serviceName: json["serviceName"] ?? "",
//       status: json["status"] ?? "",
//       ticketNumber: json["ticketNumber"].toString(),
//       bookingTime:
//           (json["bookingTime"] as Timestamp?)?.toDate() ?? DateTime.now(),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       "ticketId": ticketId,
//       "userId": userId,
//       "businessId": businessId,
//       "serviceId": serviceId,
//       "serviceName": serviceName,
//       "status": status,
//       "ticketNumber": ticketNumber,
//       "bookingTime": bookingTime,
//     };
//   }
// }
