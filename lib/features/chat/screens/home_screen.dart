import 'package:chat_demo/core/constants/app_colors.dart';
import 'package:chat_demo/features/general/widgets/c_drawer.dart';
import 'package:chat_demo/routes/route_names.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser!;

    return Scaffold(
      drawer: CDrawer(),
      appBar: AppBar(title: const Text('Chats')),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chatRooms')
            .where('participants', arrayContains: currentUser.uid)
            .orderBy('lastMessageTime', descending: true)
            .snapshots(),

        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final chats = snapshot.data!.docs;

          if (chats.isEmpty) {
            return const Center(child: Text("No chats found"));
          }

          String formatTime(Timestamp? ts) {
            if (ts == null) return '';

            final date = ts.toDate();
            final now = DateTime.now();

            if (date.day == now.day &&
                date.month == now.month &&
                date.year == now.year) {
              return "${date.hour}:${date.minute.toString().padLeft(2, '0')}";
            }

            return "${date.day}/${date.month}";
          }

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat =
              chats[index].data() as Map<String, dynamic>;

              final participants =
              List<String>.from(chat['participants']);

              final otherUserId =
              participants.firstWhere(
                    (id) => id != currentUser.uid,
              );

              final names =
              Map<String, dynamic>.from(
                chat['participantNames'] ?? {},
              );

              final otherName =
                  names[otherUserId] ?? 'User';

              final unreadCounts =
              Map<String, dynamic>.from(
                chat['unreadCounts'] ?? {},
              );

              final unread =
                  unreadCounts[currentUser.uid] ?? 0;

              final chatId = chats[index].id;

              return InkWell(
                onTap: () {
                  context.push(
                    '${RouteNames.chat}'
                        .replaceFirst(':chatId', chatId)
                        .replaceFirst(':receiverId', otherUserId)
                        .replaceFirst(
                      ':name',
                      Uri.encodeComponent(otherName),
                    ),
                  );
                },

                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.blue500,
                        child: Text(
                          otherName[0].toUpperCase(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  otherName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  formatTime(
                                      chat['lastMessageTime']),
                                ),
                              ],
                            ),

                            const SizedBox(height: 4),

                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    chat['lastMessage'] ?? '',
                                    maxLines: 1,
                                    overflow:
                                    TextOverflow.ellipsis,
                                  ),
                                ),
                                if (unread > 0)
                                  Container(
                                    margin:
                                    const EdgeInsets.only(left: 8),
                                    padding:
                                    const EdgeInsets.all(6),
                                    decoration:
                                    const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.blue,
                                    ),
                                    child: Text(
                                      unread.toString(),
                                      style: const TextStyle(
                                          color: Colors.white),
                                    ),
                                  )
                              ],
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push(RouteNames.addUsers);
        },
        child: const Icon(Icons.person_add),
      ),
    );
  }
}

// import 'package:chat_demo/core/constants/app_colors.dart';
// import 'package:chat_demo/features/general/widgets/c_drawer.dart';
// import 'package:chat_demo/routes/route_names.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
//
// class HomeScreen extends StatelessWidget {
//   const HomeScreen({super.key});
//
//   // Stream<QuerySnapshot> getUsersStream() {
//   //   return FirebaseFirestore.instance.collection('users').snapshots();
//   // }
//
//   @override
//   Widget build(BuildContext context) {
//     final currentUser = FirebaseAuth.instance.currentUser;
//
//     return Scaffold(
//       drawer: CDrawer(),
//       appBar: AppBar(
//         title: Text('Chats'),
//         actions: [IconButton(onPressed: () {}, icon: Icon(Icons.person))],
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: FirebaseFirestore.instance
//             .collection('chatRooms')
//             .where('participants', arrayContains: currentUser!.uid)
//             .orderBy('lastMessageTime', descending: true)
//             .snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//
//           if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//             return const Center(child: Text("No chats found"));
//           }
//
//           final chats = snapshot.data!.docs;
//
//           String formatTime(Timestamp? ts) {
//             if (ts == null) return '';
//
//             final date = ts.toDate();
//             final now = DateTime.now();
//
//             final isToday =
//                 date.year == now.year &&
//                 date.month == now.month &&
//                 date.day == now.day;
//
//             if (isToday) {
//               return "${date.hour}:${date.minute.toString().padLeft(2, '0')}";
//             }
//
//             return "${date.day}/${date.month}";
//           }
//
//           return ListView.builder(
//             itemCount: chats.length,
//             itemBuilder: (context, index) {
//               final chat = chats[index].data() as Map<String, dynamic>;
//
//               final participants = List<String>.from(chat['participants']);
//
//               final otherUserId = participants.firstWhere(
//                 (id) => id != currentUser.uid,
//               );
//
//               final names = Map<String, dynamic>.from(
//                 chat['participantNames'] ?? {},
//               );
//
//               String otherName = names[otherUserId] ?? '';
//
//               if (otherName.isEmpty || otherName == otherUserId) {
//                 otherName = 'User'; // temporary fallback
//               }
//
//               final unreadCounts = Map<String, dynamic>.from(
//                 chat['unreadCounts'] ?? {},
//               );
//
//               final unread = unreadCounts[currentUser.uid] ?? 0;
//
//               final chatId = chats[index].id;
//
//               return Material(
//                 color: Colors.transparent,
//                 child: InkWell(
//                   onTap: () {
//                     print("name ----- ${Uri.encodeComponent(otherName)}");
//                     context.push(
//                       '${RouteNames.chat}'
//                           .replaceFirst(':chatId', chatId)
//                           .replaceFirst(':receiverId', otherUserId)
//                           .replaceFirst(':name', Uri.encodeComponent(otherName)),
//                     );
//                   },
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 12,
//                       vertical: 8,
//                     ),
//                     child: Row(
//                       children: [
//                         Icon(Icons.person, color: AppColors.blue500),
//
//                         const SizedBox(width: 12),
//
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Row(
//                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Text(
//                                     otherName,
//                                     style: const TextStyle(
//                                       fontSize: 18,
//                                       fontWeight: FontWeight.w600,
//                                     ),
//                                   ),
//                                   Text(formatTime(chat['lastMessageTime'])),
//                                 ],
//                               ),
//
//                               const SizedBox(height: 6),
//
//                               Row(
//                                 children: [
//                                   Expanded(
//                                     child: Text(
//                                       chat['lastMessage'] ?? '',
//                                       maxLines: 1,
//                                       overflow: TextOverflow.ellipsis,
//                                     ),
//                                   ),
//
//                                   if (unread > 0)
//                                     Container(
//                                       margin: const EdgeInsets.only(left: 8),
//                                       padding: const EdgeInsets.all(8),
//                                       decoration: const BoxDecoration(
//                                         shape: BoxShape.circle,
//                                         color: Colors.blue, // add color for visibility
//                                       ),
//                                       child: Text(
//                                         unread.toString(),
//                                         style: const TextStyle(color: Colors.white),
//                                       ),
//                                     ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           context.push(RouteNames.addUsers);
//         },
//         child: Icon(Icons.person_add),
//       ),
//     );
//   }
// }
