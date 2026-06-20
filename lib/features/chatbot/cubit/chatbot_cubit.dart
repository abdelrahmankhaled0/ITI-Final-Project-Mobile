// import 'dart:convert';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:record/record.dart';
// import 'package:http/http.dart' as http;
// import 'package:taborq/features/chatbot/data/chat_message_model.dart';
// import 'package:path_provider/path_provider.dart';
//
// abstract class ChatBotState {}
// class ChatBotInitialState extends ChatBotState {}
// class ChatBotLoadingState extends ChatBotState {}
// class ChatBotRecordingState extends ChatBotState {}
// class ChatBotSuccessState extends ChatBotState {}
// class ChatBotErrorState extends ChatBotState {
//   final String error;
//   ChatBotErrorState({required this.error});
// }
//
// class ChatBotCubit extends Cubit<ChatBotState> {
//   ChatBotCubit() : super(ChatBotInitialState());
//
//   final AudioRecorder _audioRecorder = AudioRecorder();
//   final ImagePicker _picker = ImagePicker();
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//
//   // 🌟 جعلنا القائمة static عشان الشات يفضل محفوظ ومتعملوش Reset لما نخرج من السكرين
//   static List<ChatMessageModel> persistedMessages = [
//     ChatMessageModel(
//       message: "Welcome to Taborq! How can I assist you with your bookings today?",
//       isUser: false,
//       time: DateTime.now(),
//       type: MessageType.text,
//     ),
//   ];
//
//   List<ChatMessageModel> get messages => persistedMessages;
//
//   String? _currentVoicePath;
//
//   Future<void> sendTextMessage(String text) async {
//     if (text.trim().isEmpty) return;
//     persistedMessages.add(ChatMessageModel(message: text, isUser: true, time: DateTime.now(), type: MessageType.text));
//     emit(ChatBotSuccessState());
//     await _sendToBackend(bodyFields: {'message': text});
//   }
//
//   Future<void> sendImage(ImageSource source) async {
//     final XFile? image = await _picker.pickImage(source: source);
//     if (image != null) {
//       persistedMessages.add(ChatMessageModel(mediaPath: image.path, isUser: true, time: DateTime.now(), type: MessageType.image));
//       emit(ChatBotSuccessState());
//       await _sendToBackend(filePath: image.path, fileType: 'image', bodyFields: {'message': 'User sent an image'});
//     }
//   }
//
//   Future<void> startRecording() async {
//     if (await _audioRecorder.hasPermission()) {
//       emit(ChatBotRecordingState());
//
//       // 🌟 التصليح: جلب مسار آمن ومسموح للتطبيق بالتخزين فيه
//       final directory = await getTemporaryDirectory();
//       final filePath = '${directory.path}/voice_msg_${DateTime.now().millisecondsSinceEpoch}.m4a';
//
//       await _audioRecorder.start(const RecordConfig(), path: filePath);
//     }
//   }
//
//   Future<void> stopRecording() async {
//     final path = await _audioRecorder.stop();
//     if (path != null) {
//       _currentVoicePath = path;
//       persistedMessages.add(ChatMessageModel(mediaPath: _currentVoicePath, isUser: true, time: DateTime.now(), type: MessageType.voice));
//       emit(ChatBotSuccessState());
//       await _sendToBackend(filePath: _currentVoicePath, fileType: 'voice');
//     }
//   }
//
//   Future<void> _sendToBackend({String? filePath, String? fileType, Map<String, String>? bodyFields}) async {
//     emit(ChatBotLoadingState());
//     try {
//       var request = http.MultipartRequest('POST', Uri.parse('http://10.0.2.2:5000/api/chat'));
//
//       if (bodyFields != null) request.fields.addAll(bodyFields);
//
//       final User? currentUser = _auth.currentUser;
//       if (currentUser != null) {
//         request.fields['userId'] = currentUser.uid;
//         request.fields['userName'] = currentUser.displayName ?? 'Taborq User';
//       }
//
//       if (filePath != null && fileType != null) {
//         request.files.add(await http.MultipartFile.fromPath(fileType, filePath));
//       }
//
//       var streamedResponse = await request.send();
//       var response = await http.Response.fromStream(streamedResponse);
//
//       if (response.statusCode == 200) {
//         var data = jsonDecode(response.body);
//
//         if (data['is_booking_proposal'] == true) {
//           persistedMessages.add(ChatMessageModel(
//             isUser: false,
//             time: DateTime.now(),
//             type: MessageType.confirmation,
//             bookingData: data['booking_details'],
//           ));
//         } else {
//           // 🌟 هنا بنستقبل اقتراحات الخدمات لو الـ AI بعتها
//           persistedMessages.add(ChatMessageModel(
//             message: data['reply'],
//             isUser: false,
//             time: DateTime.now(),
//             type: MessageType.text,
//             suggestedServices: data['suggested_services'],
//           ));
//         }
//         emit(ChatBotSuccessState());
//       } else {
//         throw Exception("Server Error");
//       }
//     } catch (e) {
//       emit(ChatBotErrorState(error: e.toString()));
//       persistedMessages.add(ChatMessageModel(
//         message: "Sorry, I am having trouble connecting to the assistant. Please try again.",
//         isUser: false,
//         time: DateTime.now(),
//         type: MessageType.text,
//       ));
//       emit(ChatBotSuccessState());
//     }
//   }
//
//   Future<void> confirmBooking(Map<String, dynamic> bookingData) async {
//     emit(ChatBotLoadingState());
//     try {
//       final User? currentUser = _auth.currentUser;
//       if (currentUser == null) throw Exception("User unauthenticated!");
//
//       final docRef = _firestore.collection('tickets').doc();
//
//       // 🌟 الحفظ الفعلي في الـ Firestore مع التوقيت والبيانات الحقيقية بالكامل
//       await docRef.set({
//         'ticketId': docRef.id,
//         'userId': currentUser.uid,
//         'businessId': bookingData['businessId'] ?? '',
//         'serviceId': bookingData['serviceId'] ?? '',
//         'serviceName': bookingData['serviceName'] ?? '',
//         'ticketNumber': bookingData['ticketNumber'] ?? 1,
//         'bookingTime': Timestamp.fromDate(DateTime.parse(bookingData['bookingTime'])),
//         'status': 'pending',
//         'name': currentUser.displayName ?? 'Taborq Patient',
//         'phone': currentUser.phoneNumber ?? '',
//         'bussinessName': bookingData['bussinessName'] ?? '',
//         'imageURI': bookingData['imageURI'] ?? '',
//       });
//
//       persistedMessages.add(ChatMessageModel(
//           message: "🎉 Your appointment at (${bookingData['bussinessName']}) has been successfully confirmed!",
//           isUser: false,
//           time: DateTime.now(),
//           type: MessageType.text
//       ));
//       emit(ChatBotSuccessState());
//     } catch (e) {
//       emit(ChatBotErrorState(error: e.toString()));
//     }
//   }
// }


// import 'dart:convert';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:record/record.dart';
// import 'package:http/http.dart' as http;
// import 'package:taborq/features/chatbot/data/chat_message_model.dart';
// import 'package:path_provider/path_provider.dart';
//
// abstract class ChatBotState {}
// class ChatBotInitialState extends ChatBotState {}
// class ChatBotLoadingState extends ChatBotState {}
// class ChatBotRecordingState extends ChatBotState {}
// class ChatBotSuccessState extends ChatBotState {}
// class ChatBotErrorState extends ChatBotState {
//   final String error;
//   ChatBotErrorState({required this.error});
// }
//
// class ChatBotCubit extends Cubit<ChatBotState> {
//   ChatBotCubit() : super(ChatBotInitialState());
//
//   final AudioRecorder _audioRecorder = AudioRecorder();
//   final ImagePicker _picker = ImagePicker();
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//
//   // 🌟 جعلنا القائمة static عشان الشات يفضل محفوظ ومتعملوش Reset لما نخرج من السكرين
//   static List<ChatMessageModel> persistedMessages = [
//     ChatMessageModel(
//       message: "Welcome to Taborq! How can I assist you with your bookings today?",
//       isUser: false,
//       time: DateTime.now(),
//       type: MessageType.text,
//     ),
//   ];
//
//   List<ChatMessageModel> get messages => persistedMessages;
//
//   String? _currentVoicePath;
//
//   // 🌟 Builds the conversation history payload sent to the backend on every
//   // request, so the AI actually remembers prior turns instead of treating
//   // each message as a brand-new conversation (which was causing it to
//   // re-greet/re-introduce itself constantly).
//   //
//   // We intentionally skip index 0 — that's just the static local welcome
//   // bubble shown on screen, never something the AI actually said via the
//   // API — so the backend can correctly tell "this is truly the first
//   // message" apart from "this is a continuing conversation".
//   List<Map<String, String>> _buildHistoryPayload() {
//     final List<Map<String, String>> history = [];
//
//     for (int i = 1; i < persistedMessages.length; i++) {
//       final msg = persistedMessages[i];
//
//       // Booking confirmation cards aren't plain text turns from the model,
//       // so we skip them here rather than guessing at their content.
//       if (msg.type == MessageType.confirmation) continue;
//
//       String text;
//       switch (msg.type) {
//         case MessageType.image:
//           text = msg.isUser ? "[User sent an image]" : (msg.message ?? "");
//           break;
//         case MessageType.voice:
//           text = msg.isUser ? "[User sent a voice note]" : (msg.message ?? "");
//           break;
//         default:
//           text = msg.message ?? "";
//       }
//
//       if (text.trim().isEmpty) continue;
//
//       history.add({
//         'role': msg.isUser ? 'user' : 'model',
//         'text': text,
//       });
//     }
//
//     return history;
//   }
//
//   Future<void> sendTextMessage(String text) async {
//     if (text.trim().isEmpty) return;
//     final history = _buildHistoryPayload();
//     persistedMessages.add(ChatMessageModel(message: text, isUser: true, time: DateTime.now(), type: MessageType.text));
//     emit(ChatBotSuccessState());
//     await _sendToBackend(bodyFields: {'message': text}, history: history);
//   }
//
//   Future<void> sendImage(ImageSource source) async {
//     final XFile? image = await _picker.pickImage(source: source);
//     if (image != null) {
//       final history = _buildHistoryPayload();
//       persistedMessages.add(ChatMessageModel(mediaPath: image.path, isUser: true, time: DateTime.now(), type: MessageType.image));
//       emit(ChatBotSuccessState());
//       await _sendToBackend(filePath: image.path, fileType: 'image', bodyFields: {'message': 'User sent an image'}, history: history);
//     }
//   }
//
//   Future<void> startRecording() async {
//     if (await _audioRecorder.hasPermission()) {
//       emit(ChatBotRecordingState());
//
//       // 🌟 التصليح: جلب مسار آمن ومسموح للتطبيق بالتخزين فيه
//       final directory = await getTemporaryDirectory();
//       final filePath = '${directory.path}/voice_msg_${DateTime.now().millisecondsSinceEpoch}.m4a';
//
//       await _audioRecorder.start(const RecordConfig(), path: filePath);
//     }
//   }
//
//   Future<void> stopRecording() async {
//     final path = await _audioRecorder.stop();
//     if (path != null) {
//       final history = _buildHistoryPayload();
//       _currentVoicePath = path;
//       persistedMessages.add(ChatMessageModel(mediaPath: _currentVoicePath, isUser: true, time: DateTime.now(), type: MessageType.voice));
//       emit(ChatBotSuccessState());
//       await _sendToBackend(filePath: _currentVoicePath, fileType: 'voice', history: history);
//     }
//   }
//
//   Future<void> _sendToBackend({
//     String? filePath,
//     String? fileType,
//     Map<String, String>? bodyFields,
//     List<Map<String, String>>? history,
//   }) async {
//     emit(ChatBotLoadingState());
//     try {
//       var request = http.MultipartRequest('POST', Uri.parse('http://10.0.2.2:5000/api/chat'));
//
//       if (bodyFields != null) request.fields.addAll(bodyFields);
//
//       // 🌟 Send the conversation history alongside the request so the
//       // backend can build a real multi-turn prompt for Gemini.
//       request.fields['history'] = jsonEncode(history ?? []);
//
//       final User? currentUser = _auth.currentUser;
//       if (currentUser != null) {
//         request.fields['userId'] = currentUser.uid;
//         request.fields['userName'] = currentUser.displayName ?? 'Taborq User';
//       }
//
//       if (filePath != null && fileType != null) {
//         request.files.add(await http.MultipartFile.fromPath(fileType, filePath));
//       }
//
//       var streamedResponse = await request.send();
//       var response = await http.Response.fromStream(streamedResponse);
//
//       if (response.statusCode == 200) {
//         var data = jsonDecode(response.body);
//
//         if (data['is_booking_proposal'] == true) {
//           persistedMessages.add(ChatMessageModel(
//             isUser: false,
//             time: DateTime.now(),
//             type: MessageType.confirmation,
//             bookingData: data['booking_details'],
//           ));
//         } else {
//           // 🌟 هنا بنستقبل اقتراحات الخدمات لو الـ AI بعتها
//           persistedMessages.add(ChatMessageModel(
//             message: data['reply'],
//             isUser: false,
//             time: DateTime.now(),
//             type: MessageType.text,
//             suggestedServices: data['suggested_services'],
//           ));
//         }
//         emit(ChatBotSuccessState());
//       } else {
//         throw Exception("Server Error");
//       }
//     } catch (e) {
//       emit(ChatBotErrorState(error: e.toString()));
//       persistedMessages.add(ChatMessageModel(
//         message: "Sorry, I am having trouble connecting to the assistant. Please try again.",
//         isUser: false,
//         time: DateTime.now(),
//         type: MessageType.text,
//       ));
//       emit(ChatBotSuccessState());
//     }
//   }
//
//   Future<void> confirmBooking(Map<String, dynamic> bookingData) async {
//     emit(ChatBotLoadingState());
//     try {
//       final User? currentUser = _auth.currentUser;
//       if (currentUser == null) throw Exception("User unauthenticated!");
//
//       final docRef = _firestore.collection('tickets').doc();
//
//       // 🌟 الحفظ الفعلي في الـ Firestore مع التوقيت والبيانات الحقيقية بالكامل
//       await docRef.set({
//         'ticketId': docRef.id,
//         'userId': currentUser.uid,
//         'businessId': bookingData['businessId'] ?? '',
//         'serviceId': bookingData['serviceId'] ?? '',
//         'serviceName': bookingData['serviceName'] ?? '',
//         'ticketNumber': bookingData['ticketNumber'] ?? 1,
//         'bookingTime': Timestamp.fromDate(DateTime.parse(bookingData['bookingTime'])),
//         'status': 'pending',
//         'name': currentUser.displayName ?? 'Taborq Patient',
//         'phone': currentUser.phoneNumber ?? '',
//         'bussinessName': bookingData['bussinessName'] ?? '',
//         'imageURI': bookingData['imageURI'] ?? '',
//       });
//
//       persistedMessages.add(ChatMessageModel(
//           message: "🎉 Your appointment at (${bookingData['bussinessName']}) has been successfully confirmed!",
//           isUser: false,
//           time: DateTime.now(),
//           type: MessageType.text
//       ));
//       emit(ChatBotSuccessState());
//     } catch (e) {
//       emit(ChatBotErrorState(error: e.toString()));
//     }
//   }
// }



import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';
import 'package:http/http.dart' as http;
import 'package:taborq/features/chatbot/data/chat_message_model.dart';
import 'package:path_provider/path_provider.dart';

abstract class ChatBotState {}
class ChatBotInitialState extends ChatBotState {}
class ChatBotLoadingState extends ChatBotState {}
class ChatBotRecordingState extends ChatBotState {}
class ChatBotSuccessState extends ChatBotState {}
class ChatBotErrorState extends ChatBotState {
  final String error;
  ChatBotErrorState({required this.error});
}

class ChatBotCubit extends Cubit<ChatBotState> {
  ChatBotCubit() : super(ChatBotInitialState());

  final AudioRecorder _audioRecorder = AudioRecorder();
  final ImagePicker _picker = ImagePicker();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 🌟 جعلنا القائمة static عشان الشات يفضل محفوظ ومتعملوش Reset لما نخرج من السكرين
  static List<ChatMessageModel> persistedMessages = [
    ChatMessageModel(
      message: "Welcome to Taborq! How can I assist you with your bookings today?",
      isUser: false,
      time: DateTime.now(),
      type: MessageType.text,
    ),
  ];

  List<ChatMessageModel> get messages => persistedMessages;

  String? _currentVoicePath;

  // 🌟 Builds the conversation history payload sent to the backend on every
  // request, so the AI actually remembers prior turns instead of treating
  // each message as a brand-new conversation (which was causing it to
  // re-greet/re-introduce itself constantly).
  //
  // We intentionally skip index 0 — that's just the static local welcome
  // bubble shown on screen, never something the AI actually said via the
  // API — so the backend can correctly tell "this is truly the first
  // message" apart from "this is a continuing conversation".
  List<Map<String, String>> _buildHistoryPayload() {
    final List<Map<String, String>> history = [];

    for (int i = 1; i < persistedMessages.length; i++) {
      final msg = persistedMessages[i];

      // Booking confirmation cards aren't plain text turns from the model,
      // so we skip them here rather than guessing at their content.
      if (msg.type == MessageType.confirmation) continue;

      String text;
      switch (msg.type) {
        case MessageType.image:
          text = msg.isUser ? "[User sent an image]" : (msg.message ?? "");
          break;
        case MessageType.voice:
          text = msg.isUser ? "[User sent a voice note]" : (msg.message ?? "");
          break;
        default:
          text = msg.message ?? "";
      }

      if (text.trim().isEmpty) continue;

      history.add({
        'role': msg.isUser ? 'user' : 'model',
        'text': text,
      });
    }

    return history;
  }

  Future<void> sendTextMessage(String text) async {
    if (text.trim().isEmpty) return;
    final history = _buildHistoryPayload();
    persistedMessages.add(ChatMessageModel(message: text, isUser: true, time: DateTime.now(), type: MessageType.text));
    emit(ChatBotSuccessState());
    await _sendToBackend(bodyFields: {'message': text}, history: history);
  }

  Future<void> sendImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      final history = _buildHistoryPayload();
      persistedMessages.add(ChatMessageModel(mediaPath: image.path, isUser: true, time: DateTime.now(), type: MessageType.image));
      emit(ChatBotSuccessState());
      await _sendToBackend(filePath: image.path, fileType: 'image', bodyFields: {'message': 'User sent an image'}, history: history);
    }
  }

  Future<void> startRecording() async {
    if (await _audioRecorder.hasPermission()) {
      emit(ChatBotRecordingState());

      // 🌟 التصليح: جلب مسار آمن ومسموح للتطبيق بالتخزين فيه
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/voice_msg_${DateTime.now().millisecondsSinceEpoch}.m4a';

      await _audioRecorder.start(const RecordConfig(), path: filePath);
    }
  }

  Future<void> stopRecording() async {
    final path = await _audioRecorder.stop();
    if (path != null) {
      final history = _buildHistoryPayload();
      _currentVoicePath = path;
      persistedMessages.add(ChatMessageModel(mediaPath: _currentVoicePath, isUser: true, time: DateTime.now(), type: MessageType.voice));
      emit(ChatBotSuccessState());
      await _sendToBackend(filePath: _currentVoicePath, fileType: 'voice', history: history);
    }
  }

  Future<void> _sendToBackend({
    String? filePath,
    String? fileType,
    Map<String, String>? bodyFields,
    List<Map<String, String>>? history,
  }) async {
    emit(ChatBotLoadingState());
    try {
      var request = http.MultipartRequest('POST', Uri.parse('http://10.0.2.2:5000/api/chat'));

      if (bodyFields != null) request.fields.addAll(bodyFields);

      // 🌟 Send the conversation history alongside the request so the
      // backend can build a real multi-turn prompt for Gemini.
      request.fields['history'] = jsonEncode(history ?? []);

      final User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        request.fields['userId'] = currentUser.uid;
        request.fields['userName'] = currentUser.displayName ?? 'Taborq User';
      }

      if (filePath != null && fileType != null) {
        request.files.add(await http.MultipartFile.fromPath(fileType, filePath));
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        if (data['is_booking_proposal'] == true) {
          persistedMessages.add(ChatMessageModel(
            isUser: false,
            time: DateTime.now(),
            type: MessageType.confirmation,
            bookingData: data['booking_details'],
          ));
        } else {
          // 🌟 هنا بنستقبل اقتراحات الخدمات لو الـ AI بعتها
          persistedMessages.add(ChatMessageModel(
            message: data['reply'],
            isUser: false,
            time: DateTime.now(),
            type: MessageType.text,
            suggestedServices: data['suggested_services'],
          ));
        }
        emit(ChatBotSuccessState());
      } else {
        throw Exception("Server Error");
      }
    } catch (e) {
      emit(ChatBotErrorState(error: e.toString()));
      persistedMessages.add(ChatMessageModel(
        message: "Sorry, I am having trouble connecting to the assistant. Please try again.",
        isUser: false,
        time: DateTime.now(),
        type: MessageType.text,
      ));
      emit(ChatBotSuccessState());
    }
  }

  // 🌟 Lets the UI layer (which has access to BookingCubit/NotificationCubit)
  // post a plain assistant message into the chat thread after a real queue
  // booking succeeds, already-exists, or fails — without ChatBotCubit needing
  // to know anything about the booking system itself.
  void addAssistantMessage(String text) {
    persistedMessages.add(ChatMessageModel(
      message: text,
      isUser: false,
      time: DateTime.now(),
      type: MessageType.text,
    ));
    emit(ChatBotSuccessState());
  }
}