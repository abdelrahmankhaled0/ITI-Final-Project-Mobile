import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseServices {
  static Query<Map<String, dynamic>> ticketsCollection = FirebaseFirestore
      .instance
      .collectionGroup("tickets");

  static CollectionReference<Map<String, dynamic>> usersCollection =
      FirebaseFirestore.instance.collection("users");

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

  static deleteUserById(String userId) {
    return usersCollection.doc(userId).delete();
  }

  static Future<void> deleteQueueById({
    required String ticketId,
    required String queuesId,
    required String servicesId,
  }) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    final serviceRef = firestore
        .collection("Queues")
        .doc(queuesId)
        .collection("services")
        .doc(servicesId);

    final ticketRef = serviceRef.collection("tickets").doc(ticketId);

    // Removing decrement of `lastGeneratedTicket` entirely per recent change.
    // We keep the delete atomic in a transaction but do not modify the service counter.
    return await firestore.runTransaction((transaction) async {
      // Ensure ticket exists then delete it within transaction for atomicity.
      DocumentSnapshot ticketSnapshot = await transaction.get(ticketRef);
      if (ticketSnapshot.exists) {
        transaction.delete(ticketRef);
      }
    });
  }
}
