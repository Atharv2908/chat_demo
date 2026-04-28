import 'package:chat_demo/core/constants/app_colors.dart';
import 'package:chat_demo/features/general/widgets/c_drawer.dart';
import 'package:chat_demo/routes/route_names.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/chat_widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatTime(Timestamp? ts) {
    if (ts == null) return '';
    final date = ts.toDate();
    final now = DateTime.now();
    if (date.day == now.day &&
        date.month == now.month &&
        date.year == now.year) {
      return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    }
    return '${date.day}/${date.month}';
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      drawer: CDrawer(),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      // ── AppBar ────────────────────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor:
        isDark ? AppColors.neutral800 : AppColors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 16,
        title: Row(
          children: [
            Builder(
              builder: (ctx) => GestureDetector(
                onTap: () => Scaffold.of(ctx).openDrawer(),
                child: CAvatar(
                  name: currentUser.displayName ??
                      currentUser.email ??
                      'U',
                  radius: 18,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Messages',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color:
                isDark ? AppColors.white : AppColors.neutral900,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => context.push(RouteNames.addUsers),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.blue500.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_add_alt_1_rounded,
                color: AppColors.blue500,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 4),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(
            height: 1,
            color: isDark
                ? AppColors.neutral700
                : AppColors.neutral100,
          ),
        ),
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 14),

          // ── Search bar ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
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
                hintText: 'Search conversations...',
                hintStyle: TextStyle(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.neutral400,
                  fontSize: 15,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: isDark
                      ? AppColors.neutral400
                      : AppColors.neutral500,
                  size: 22,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.close_rounded,
                      size: 18),
                  color: AppColors.neutral400,
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
                    : null,
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
                    color: AppColors.blue500,
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ── Section label ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Chats',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.neutral400
                        : AppColors.neutral500,
                    letterSpacing: 0.6,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 6),

          // ── Chat list ───────────────────────────────────────────────────
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chatRooms')
                  .where('participants',
                  arrayContains: currentUser.uid)
                  .orderBy('lastMessageTime', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.blue500,
                      strokeWidth: 2,
                    ),
                  );
                }

                var chats = snapshot.data!.docs;

                if (_searchQuery.isNotEmpty) {
                  chats = chats.where((doc) {
                    final data =
                    doc.data() as Map<String, dynamic>;
                    final names = Map<String, dynamic>.from(
                        data['participantNames'] ?? {});
                    final participants =
                    List<String>.from(data['participants']);
                    final otherId = participants.firstWhere(
                          (id) => id != currentUser.uid,
                      orElse: () => '',
                    );
                    final name = (names[otherId] ?? '').toString();
                    return name
                        .toLowerCase()
                        .contains(_searchQuery);
                  }).toList();
                }

                if (chats.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline_rounded,
                          size: 56,
                          color: isDark
                              ? AppColors.neutral700
                              : AppColors.neutral100,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isNotEmpty
                              ? 'No chats match "$_searchQuery"'
                              : 'No conversations yet',
                          style: TextStyle(
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                            fontSize: 15,
                          ),
                        ),
                        if (_searchQuery.isEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Tap + to start a new chat',
                            style: TextStyle(
                              color: isDark
                                  ? AppColors.neutral500
                                  : AppColors.neutral400,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  itemCount: chats.length,
                  itemBuilder: (context, index) {
                    final chat = chats[index].data()
                    as Map<String, dynamic>;
                    final participants =
                    List<String>.from(chat['participants']);
                    final otherId = participants.firstWhere(
                          (id) => id != currentUser.uid,
                      orElse: () => '',
                    );
                    final names = Map<String, dynamic>.from(
                        chat['participantNames'] ?? {});
                    final otherName =
                    (names[otherId] ?? 'User').toString();
                    final unread = (Map<String, dynamic>.from(
                        chat['unreadCounts'] ?? {}))[
                    currentUser.uid] ??
                        0;
                    final chatId = chats[index].id;

                    return ChatTile(
                      name: otherName,
                      lastMessage:
                      (chat['lastMessage'] ?? '').toString(),
                      time: _formatTime(
                          chat['lastMessageTime'] as Timestamp?),
                      unreadCount: unread is int ? unread : 0,
                      isOnline: false,
                      onTap: () => context.push(
                        RouteNames.chat
                            .replaceFirst(':chatId', chatId)
                            .replaceFirst(':receiverId', otherId)
                            .replaceFirst(
                            ':name',
                            Uri.encodeComponent(
                                otherName)),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),

      // ── FAB ──────────────────────────────────────────────────────────────
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(RouteNames.addUsers),
        backgroundColor: AppColors.blue500,
        elevation: 4,
        child: const Icon(Icons.edit_rounded,
            color: Colors.white, size: 22),
      ),
    );
  }
}