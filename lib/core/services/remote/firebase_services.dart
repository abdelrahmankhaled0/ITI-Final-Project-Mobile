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

    // 🎯 استخدام Transaction لتعديل الـ Counter وحذف التذكرة معاً بأمان
    return await firestore.runTransaction((transaction) async {
      // 1. جلب بيانات السيرفس الحالية
      DocumentSnapshot serviceSnapshot = await transaction.get(serviceRef);

      if (serviceSnapshot.exists) {
        Map<String, dynamic> serviceData =
            serviceSnapshot.data() as Map<String, dynamic>;
        int currentLastTicket = serviceData['lastGeneratedTicket'] ?? 0;

        // 2. تقليل الـ Counter بمقدار 1 بشرط ميكونش أصلاً صفر
        if (currentLastTicket > 0) {
          transaction.update(serviceRef, {
            'lastGeneratedTicket': currentLastTicket - 1,
          });
        }
      }

      // 3. حذف وثيقة التذكرة نهائياً
      transaction.delete(ticketRef);
    });
  }
}
