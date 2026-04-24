import 'package:cloud_firestore/cloud_firestore.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// STREAM MESSAGES
  Stream<QuerySnapshot> getMessages(String chatId) {
    return _firestore
        .collection('chatRooms')
        .doc(chatId)
        .collection('messages')
        .orderBy('time', descending: true)
        .snapshots();
  }

  /// SEND MESSAGE
  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String receiverId,
    required String text,
  }) async {
    final chatRef = _firestore.collection('chatRooms').doc(chatId);

    /// 🔥 Fetch user names
    final senderDoc =
    await _firestore.collection('users').doc(senderId).get();

    final receiverDoc =
    await _firestore.collection('users').doc(receiverId).get();

    final senderName = senderDoc.data()?['name'] ?? 'User';
    final receiverName = receiverDoc.data()?['name'] ?? 'User';

    /// 🔥 Add message
    await chatRef.collection('messages').add({
      'msg': text,
      'sid': senderId,
      'rid': receiverId,
      'time': FieldValue.serverTimestamp(),
      'isSeen': false,
    });

    /// 🔥 Update chat room
    await chatRef.set({
      'participants': [senderId, receiverId],

      'participantNames': {
        senderId: senderName,
        receiverId: receiverName,
      },

      'lastMessage': text,
      'lastMessageTime': FieldValue.serverTimestamp(),

      'unreadCounts': {
        senderId: 0,
        receiverId: FieldValue.increment(1),
      }
    }, SetOptions(merge: true));
  }
}

// import 'package:cloud_firestore/cloud_firestore.dart';
//
// class ChatService {
//
//   final FirebaseFirestore _firestore =
//       FirebaseFirestore.instance;
//
//   Stream<QuerySnapshot> getMessages(String chatId) {
//
//     return _firestore
//         .collection('chatRooms')
//         .doc(chatId)
//         .collection('messages')
//         .orderBy('time', descending: true)
//         .snapshots();
//   }
//
//   Future<void> sendMessage({
//     required String chatId,
//     required String senderId,
//     required String receiverId,
//     required String text,
//   }) async {
//
//     final chatRef =
//     _firestore.collection('chatRooms').doc(chatId);
//
//     /// 🔥 STEP 1: Fetch user data
//     final senderDoc =
//     await _firestore.collection('users').doc(senderId).get();
//
//     final receiverDoc =
//     await _firestore.collection('users').doc(receiverId).get();
//
//     /// 🔥 STEP 2: Extract names safely
//     final senderName = senderDoc.data()?['name'] ?? 'User';
//     final receiverName = receiverDoc.data()?['name'] ?? 'User';
//
//     await chatRef.collection('messages').add({
//       'msg': text,
//       'sid': senderId,
//       'rid': receiverId,
//       'time': FieldValue.serverTimestamp(),
//     });
//
//     await chatRef.set({
//       'participants': [senderId, receiverId],
//       'participantNames': {
//         senderId: senderName,
//         receiverId: receiverName,
//       },
//       'lastMessage': text,
//       'lastMessageTime':
//       FieldValue.serverTimestamp(),
//
//       'unreadCounts.$receiverId':
//       FieldValue.increment(1),
//
//     }, SetOptions(merge:true));
//   }
//
// }