import 'package:chat_demo/core/constants/app_colors.dart';
import 'package:chat_demo/routes/route_names.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/chat_widgets.dart';

class AddUsers extends StatefulWidget {
  const AddUsers({super.key});

  @override
  State<AddUsers> createState() => _AddUsersState();
}

class _AddUsersState extends State<AddUsers> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor:
        isDark ? AppColors.neutral800 : AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          color: isDark ? AppColors.white : AppColors.neutral900,
          onPressed: () => context.pop(),
        ),
        title: Text(
          'New Chat',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.white : AppColors.neutral900,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(
            height: 1,
            color:
            isDark ? AppColors.neutral700 : AppColors.neutral100,
          ),
        ),
      ),
      body: Column(
        children: [
          // ── Search ─────────────────────────────────────────────────────
          Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: TextField(
              controller: _searchController,
              onChanged: (v) =>
                  setState(() => _searchQuery = v.toLowerCase()),
              style: TextStyle(
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
                fontSize: 15,
              ),
              decoration: InputDecoration(
                hintText: 'Search people...',
                hintStyle: TextStyle(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.neutral400,
                ),
                prefixIcon: const Icon(Icons.search_rounded,
                    color: AppColors.neutral400, size: 22),
                filled: true,
                fillColor: isDark
                    ? AppColors.darkInputBg
                    : AppColors.lightInputBg,
                contentPadding:
                const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                      color: AppColors.blue500, width: 1.5),
                ),
              ),
            ),
          ),

          // ── Section label ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'All Users',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.neutral400
                      : AppColors.neutral500,
                  letterSpacing: 0.6,
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // ── User list ──────────────────────────────────────────────────
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.blue500,
                      strokeWidth: 2,
                    ),
                  );
                }

                if (!snapshot.hasData ||
                    snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      'No users found',
                      style: TextStyle(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                  );
                }

                var users = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return data['uid'] != currentUser.uid;
                }).toList();

                if (_searchQuery.isNotEmpty) {
                  users = users.where((doc) {
                    final data =
                    doc.data() as Map<String, dynamic>;
                    final name =
                    (data['name'] ?? '').toString().toLowerCase();
                    return name.contains(_searchQuery);
                  }).toList();
                }

                if (users.isEmpty) {
                  return Center(
                    child: Text(
                      'No users match your search',
                      style: TextStyle(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final data = users[index].data()
                    as Map<String, dynamic>;
                    final name =
                    (data['name'] ?? 'Unknown').toString();
                    final email =
                    (data['email'] ?? '').toString();

                    return UserTile(
                      name: name,
                      subtitle: email.isNotEmpty ? email : 'User',
                      onTap: () async {
                        final ids = [currentUser.uid, data['uid']]
                          ..sort();
                        final chatId = ids.join('_');
                        final chatRef = FirebaseFirestore.instance
                            .collection('chatRooms')
                            .doc(chatId);

                        await chatRef.set({
                          'participants': [
                            currentUser.uid,
                            data['uid']
                          ],
                          'participantNames': {
                            currentUser.uid: currentUser
                                .displayName ??
                                currentUser.email?.split('@').first ??
                                'Me',
                            data['uid']: name,
                          },
                          'lastMessage': '',
                          'lastMessageTime':
                          FieldValue.serverTimestamp(),
                          'unreadCounts': {
                            currentUser.uid: 0,
                            data['uid']: 0
                          },
                        }, SetOptions(merge: true));

                        if (context.mounted) {
                          context.push(
                            RouteNames.chat
                                .replaceFirst(':chatId', chatId)
                                .replaceFirst(
                                ':receiverId', data['uid'])
                                .replaceFirst(
                                ':name',
                                Uri.encodeComponent(name)),
                          );
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}