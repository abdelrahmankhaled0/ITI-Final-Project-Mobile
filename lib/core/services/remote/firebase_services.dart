import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseServices {
  static Query<Map<String, dynamic>> ticketsCollection = FirebaseFirestore
      .instance
      .collectionGroup("tickets");

  static Future<QuerySnapshot<Map<String, dynamic>>>
  getTicketsByUserId() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      throw Exception("User not logged in");
    }

    return await ticketsCollection
        .where("userId", isEqualTo: userId)
        .orderBy("bookingTime", descending: true)
        .get();
  }

  static Future<void> deleteQueueById({
    required String ticketId,
    required String queuesId,
    required String servicesId,
  }) {
    return FirebaseFirestore.instance
        .collection("Queues")
        .doc(queuesId)
        .collection("services")
        .doc(servicesId)
        .collection("tickets")
        .doc(ticketId)
        .delete();
  }
}
