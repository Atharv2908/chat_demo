import 'package:flutter/material.dart';
import '../services/chat_service.dart';

class ChatProvider extends ChangeNotifier {
  final ChatService _service = ChatService();

  bool sending = false;

  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String receiverId,
    required String text,
  }) async {
    sending = true;
    notifyListeners();

    try {
      await _service.sendMessage(
        chatId: chatId,
        senderId: senderId,
        receiverId: receiverId,
        text: text,
      );
    } finally {
      sending = false;
      notifyListeners();
    }
  }
}

// import 'package:cloud_firestore/cloud_firestore.dart';
//
// import 'package:flutter/material.dart';
// import '../services/chat_service.dart';
//
// class ChatProvider extends ChangeNotifier {
//
//   final ChatService _service =
//   ChatService();
//
//   bool sending = false;
//
//
//
//   Future<void> sendMessage({
//     required String chatId,
//     required String senderId,
//     required String receiverId,
//     required String text,
//   }) async {
//
//     sending = true;
//     notifyListeners();
//
//     try {
//       await _service.sendMessage(
//         chatId: chatId,
//         senderId: senderId,
//         receiverId: receiverId,
//         text: text,
//       );
//     } finally {
//       sending = false;
//       notifyListeners();
//     }
//
//   }
//
// }