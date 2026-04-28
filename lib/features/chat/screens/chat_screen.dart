import 'package:chat_demo/core/constants/app_colors.dart';
import 'package:chat_demo/features/chat/providers/call_provider.dart';
import 'package:chat_demo/features/chat/services/chat_service.dart';
import 'package:chat_demo/routes/route_names.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/chat_provider.dart';
import '../widgets/chat_widgets.dart';

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
  final TextEditingController _controller = TextEditingController();
  final ChatService _service = ChatService();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _markAsRead();
    _markMessagesSeen();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _markAsRead() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance
        .collection('chatRooms')
        .doc(widget.chatId)
        .update({'unreadCounts.$uid': 0});
  }

  Future<void> _markMessagesSeen() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final snap = await FirebaseFirestore.instance
        .collection('chatRooms')
        .doc(widget.chatId)
        .collection('messages')
        .where('rid', isEqualTo: uid)
        .where('isSeen', isEqualTo: false)
        .get();
    for (final doc in snap.docs) {
      doc.reference.update({'isSeen': true});
    }
  }

  String _formatBubbleTime(Timestamp? ts) {
    if (ts == null) return '';
    final d = ts.toDate();
    return '${d.hour}:${d.minute.toString().padLeft(2, '0')}';
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    final uid = FirebaseAuth.instance.currentUser!.uid;
    Provider.of<ChatProvider>(context, listen: false).sendMessage(
      chatId: widget.chatId,
      senderId: uid,
      receiverId: widget.receiverId,
      text: text,
    );
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      // ── AppBar ────────────────────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor:
        isDark ? AppColors.neutral800 : AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          color: isDark ? AppColors.white : AppColors.neutral900,
          onPressed: () => context.pop(),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            Stack(
              children: [
                CAvatar(name: widget.name, radius: 20),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: OnlineDot(isOnline: true),
                ),
              ],
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.name,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.white
                        : AppColors.neutral900,
                  ),
                ),
                Text(
                  'Online',
                  style: TextStyle(
                    fontSize: 12,
                    color: const Color(0xFF4CAF50),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // Audio call
          IconButton(
            icon: Icon(
              Icons.call_rounded,
              color: isDark
                  ? AppColors.neutral300
                  : AppColors.neutral700,
              size: 22,
            ),
            onPressed: () {},
          ),
          // Video call
          IconButton(
            icon: Icon(
              Icons.videocam_rounded,
              color: isDark
                  ? AppColors.neutral300
                  : AppColors.neutral700,
              size: 24,
            ),
            onPressed: () async {
              final callId = await context
                  .read<CallProvider>()
                  .startOutgoingCall(
                receiverId: widget.receiverId,
                receiverName: widget.name,
              );
              if (mounted) {
                context.push(
                  RouteNames.call
                      .replaceFirst(':callId', callId)
                      .replaceFirst(':receiverId', widget.receiverId)
                      .replaceFirst(
                      ':name', Uri.encodeComponent(widget.name)),
                );
              }
            },
          ),
          IconButton(
            icon: Icon(
              Icons.more_vert_rounded,
              color: isDark
                  ? AppColors.neutral300
                  : AppColors.neutral700,
              size: 22,
            ),
            onPressed: () {},
          ),
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

      // ── Body ──────────────────────────────────────────────────────────────
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _service.getMessages(widget.chatId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.blue500,
                      strokeWidth: 2,
                    ),
                  );
                }

                final messages = snapshot.data!.docs;

                if (messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.waving_hand_rounded,
                          size: 48,
                          color: isDark
                              ? AppColors.neutral700
                              : AppColors.neutral100,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Say hi to ${widget.name}!',
                          style: TextStyle(
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index].data()
                    as Map<String, dynamic>;
                    final isMe = msg['sid'] == currentUser.uid;
                    final ts = msg['createdAt'] as Timestamp?;

                    return MessageBubble(
                      text: msg['msg'] ?? '',
                      isMe: isMe,
                      time: _formatBubbleTime(ts),
                      isSeen: msg['isSeen'] == true,
                    );
                  },
                );
              },
            ),
          ),

          // ── Input bar ───────────────────────────────────────────────────
          ChatInputBar(
            controller: _controller,
            onSend: _sendMessage,
          ),
        ],
      ),
    );
  }
}