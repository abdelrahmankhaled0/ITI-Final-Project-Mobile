import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:taborq/features/notifications/data/notification_model.dart';

// دالة الخلفية: يجب أن تكون Top-Level أو Static لتشتغل والفون مقفول
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // هنا الـ OS بيستقبل الرسالة من السيرفر مباشرة ويعرضها تلقائياً لو تحتوي على notification object
}

class NotificationFirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static String? get userId => FirebaseAuth.instance.currentUser?.uid;

  static Stream<QuerySnapshot<Map<String, dynamic>>> getNotifications() {
    final uid = userId;
    if (uid == null) {
      return Stream<QuerySnapshot<Map<String, dynamic>>>.empty();
    }

    return _firestore
        .collection("users")
        .doc(uid)
        .collection("notifications")
        .orderBy("dateTime", descending: true)
        .snapshots();
  }

  static Future<void> saveNotification(NotificationModel notification) async {
    final uid = userId;
    if (uid == null) return;

    await _firestore
        .collection("users")
        .doc(uid)
        .collection("notifications")
        .add(notification.toJson());
  }

  static Future<void> markAsRead(String notificationId) async {
    await _firestore
        .collection("users")
        .doc(userId)
        .collection("notifications")
        .doc(notificationId)
        .update({"isRead": true});
  }
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initNotification() async {
    // 1. طلب صلاحيات الإشعارات من المستخدم
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    await messaging.requestPermission(alert: true, badge: true, sound: true);

    // 2. إعدادات الإشعارات المحلية داخل التطبيق (Foreground)
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _localNotificationsPlugin.initialize(
      settings: initializationSettings,
    );

    // 3. تعيين الـ Background Handler الخاص بـ FCM
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 4. معالجة الإشعارات والتطبيق مفتوح في الـ Foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        showNotification(
          id: message.hashCode,
          title: message.notification!.title ?? '',
          body: message.notification!.body ?? '',
        );
      }
    });
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'taborq_queue_channel',
          'Queue Updates',
          channelDescription: 'Notifications for queue position and updates',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
        );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await _localNotificationsPlugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: platformChannelSpecifics,
    );
  }
}
