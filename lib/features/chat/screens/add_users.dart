import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../routes/route_names.dart';
import '../../../widgets/texts.dart';

class AddUsers extends StatelessWidget {
  const AddUsers({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.blue500,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(Icons.arrow_back_ios, color: AppColors.white),
        ),
        title: HeadingText('Add Friends', color: AppColors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No users found"));
          }

          final users = snapshot.data!.docs;

          // Exclude current user
          final filteredUsers = users.where((user) {
            final data = user.data() as Map<String, dynamic>;
            return data['uid'] != currentUser?.uid;
          }).toList();

          if (filteredUsers.isEmpty) {
            return const Center(child: Text("No other users available"));
          }

          return ListView.builder(
            itemCount: filteredUsers.length,
            itemBuilder: (context, index) {
              final userData = filteredUsers[index];
              final data = userData.data() as Map<String, dynamic>;

              return ListTile(
                title: Text(data['name'] ?? 'Unknown User'),
                leading: const CircleAvatar(
                  child: Icon(Icons.person, color: AppColors.gradientBlueEnd),
                  backgroundColor: AppColors.profileBg,
                ),
                onTap: () async {
                  final ids = [currentUser!.uid, data['uid']]..sort();

                  final chatId = ids.join('_');

                  final chatRef = FirebaseFirestore.instance
                      .collection('chatRooms')
                      .doc(chatId);

                  await chatRef.set({
                    'participants': [currentUser.uid, data['uid']],

                    'participantNames': {
                      currentUser.uid: currentUser.uid, // replace
                      data['uid']: data['name'],
                    },

                    'lastMessage': '',

                    'lastMessageTime': FieldValue.serverTimestamp(),

                    'unreadCounts': {currentUser.uid: 0, data['uid']: 0},
                  }, SetOptions(merge: true));

                  context.push(
                    '${RouteNames.chat}'
                        .replaceFirst(':chatId', chatId)
                        .replaceFirst(':receiverId', data['uid'])
                        .replaceFirst(
                          ':name',
                          Uri.encodeComponent(data['name']),
                        ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
