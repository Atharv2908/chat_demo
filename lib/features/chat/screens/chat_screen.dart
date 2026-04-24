import 'package:chat_demo/core/constants/app_images.dart';
import 'package:chat_demo/features/chat/services/chat_service.dart';
import 'package:chat_demo/features/chat/widgets/fields.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/chat_provider.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String receiverId;
  final String name;

  const ChatScreen({
    super.key,
    required this.chatId,
    required this.receiverId,
    required this.name,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController controller = TextEditingController();
  final ChatService service = ChatService();

  @override
  void initState() {
    super.initState();
    markAsRead();
    markMessagesSeen();
  }

  Future<void> markAsRead() async {
    final currentUser = FirebaseAuth.instance.currentUser!;

    await FirebaseFirestore.instance
        .collection('chatRooms')
        .doc(widget.chatId)
        .update({
      'unreadCounts.${currentUser.uid}': 0,
    });
  }

  Future<void> markMessagesSeen() async {
    final currentUser = FirebaseAuth.instance.currentUser!;

    final snapshot = await FirebaseFirestore.instance
        .collection('chatRooms')
        .doc(widget.chatId)
        .collection('messages')
        .where('rid', isEqualTo: currentUser.uid)
        .where('isSeen', isEqualTo: false)
        .get();

    for (var doc in snapshot.docs) {
      doc.reference.update({'isSeen': true});
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser!;

    return Scaffold(
      appBar: AppBar(title: Text(widget.name)),

      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: service.getMessages(widget.chatId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg =
                    messages[index].data() as Map<String, dynamic>;

                    final isMe =
                        msg['sid'] == currentUser.uid;

                    return Align(
                      alignment: isMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,

                      child: Container(
                        margin: const EdgeInsets.all(8),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isMe
                              ? Colors.blue
                              : Colors.grey[300],
                          borderRadius:
                          BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(msg['msg']),

                            const SizedBox(width: 6),

                            if (isMe)
                              Icon(
                                msg['isSeen'] == true
                                    ? Icons.done_all
                                    : Icons.done,
                                size: 16,
                                color: msg['isSeen'] == true
                                    ? Colors.blue
                                    : Colors.grey,
                              ),
                          ],
                        )
                      ),
                    );
                  },
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: Fields(
                      controller: controller,
                    hintText: 'Message',
                  )
                ),

                IconButton(
                  icon: Image.asset(AppImages.send, scale: 0.95,),
                  onPressed: () {
                    final text = controller.text.trim();

                    if (text.isEmpty) return;

                    Provider.of<ChatProvider>(
                      context,
                      listen: false,
                    ).sendMessage(
                      chatId: widget.chatId,
                      senderId: currentUser.uid,
                      receiverId: widget.receiverId,
                      text: text,
                    );

                    controller.clear();
                  },
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// import 'package:chat_demo/features/chat/services/chat_service.dart';
// import 'package:chat_demo/routes/route_names.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:provider/provider.dart';
//
// import '../providers/chat_provider.dart';
//
// class ChatScreen extends StatefulWidget {
//   final String receiverId;
//   final String chatId;
//   final String name;
//
//   const ChatScreen({
//     super.key,
//     required this.receiverId,
//     required this.name,
//     required this.chatId,
//   });
//
//   @override
//   State<ChatScreen> createState() => _ChatScreenState();
// }
//
// class _ChatScreenState extends State<ChatScreen> {
//   final TextEditingController _messageController = TextEditingController();
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//
//   late final ChatService _chatService;
//
//   @override
//   void initState() {
//     super.initState();
//     _chatService = ChatService();
//
//     //mark unread as read when opening the chat
//     // context.read<ChatProvider>().markAsRead(widget.chatId);
//   }
//
//   @override
//   void dispose() {
//     _messageController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _handleSend(ChatProvider provider, String currentUid) async {
//     final currentUserDoc = await FirebaseFirestore.instance
//         .collection('users')
//         .doc(_auth.currentUser!.uid)
//         .get();
//
//     final senderName = currentUserDoc.data()?['name'] ?? 'User';
//
//     final text = _messageController.text.trim();
//
//     if (text.isEmpty) return;
//
//     try {
//       await provider.sendMessage(
//         chatId: widget.chatId,
//         senderId: senderName,
//         receiverId: widget.receiverId,
//         text: text,
//       );
//
//       _messageController.clear();
//     } catch (e) {
//       if (!mounted) return;
//
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Failed to send message: $e')));
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final currentUser = _auth.currentUser;
//     final provider = context.read<ChatProvider>();
//
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           onPressed: () => context.go(RouteNames.home),
//           icon: Icon(Icons.arrow_back_ios),
//         ),
//         title: Text(widget.name),
//       ),
//       body: Column(
//         children: [
//           /// 🔹 Messages List
//           Expanded(
//             child: StreamBuilder<QuerySnapshot>(
//               stream: _chatService.getMessages(widget.chatId),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(child: CircularProgressIndicator());
//                 }
//
//                 if (!snapshot.hasData) {
//                   return const Center(child: Text('No messages yet'));
//                 }
//
//                 final messages = snapshot.data!.docs;
//
//                 return ListView.builder(
//                   reverse: true,
//                   itemCount: messages.length,
//                   itemBuilder: (context, index) {
//                     final msg = messages[index].data() as Map<String, dynamic>;
//
//                     final isMe = msg['sid'] == currentUser!.uid;
//
//                     return Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 12,
//                         vertical: 6,
//                       ),
//                       alignment: isMe
//                           ? Alignment.centerRight
//                           : Alignment.centerLeft,
//                       child: Container(
//                         padding: const EdgeInsets.all(12),
//                         constraints: const BoxConstraints(maxWidth: 250),
//                         decoration: BoxDecoration(
//                           color: isMe ? Colors.blue : Colors.grey.shade300,
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: Text(
//                           msg['msg'] ?? '',
//                           style: TextStyle(
//                             color: isMe ? Colors.white : Colors.black,
//                           ),
//                         ),
//                       ),
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//
//           /// 🔹 Input Field
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _messageController,
//                     decoration: const InputDecoration(
//                       hintText: 'Type a message...',
//                       border: OutlineInputBorder(),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 IconButton(
//                   onPressed: provider.sending
//                       ? null
//                       : () => _handleSend(provider, currentUser!.uid),
//
//                   icon: provider.sending
//                       ? const SizedBox(
//                           width: 20,
//                           height: 20,
//                           child: CircularProgressIndicator(),
//                         )
//                       : const Icon(Icons.send),
//
//                   color: Colors.blue,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
