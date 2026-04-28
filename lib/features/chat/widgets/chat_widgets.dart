import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
// C A V A T A R  — consistent avatar across all screens
// ─────────────────────────────────────────────────────────────────────────────

class CAvatar extends StatelessWidget {
  final String name;
  final double radius;
  final Color? bgColor;
  final String? imageUrl;

  const CAvatar({
    super.key,
    required this.name,
    this.radius = 24,
    this.bgColor,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final letter = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return CircleAvatar(
      radius: radius,
      backgroundColor: bgColor ?? AppColors.blue500.withOpacity(0.18),
      backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
      child: imageUrl == null
          ? Text(
        letter,
        style: TextStyle(
          fontSize: radius * 0.8,
          fontWeight: FontWeight.w700,
          color: AppColors.blue500,
        ),
      )
          : null,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// O N L I N E   D O T  — small status indicator
// ─────────────────────────────────────────────────────────────────────────────

class OnlineDot extends StatelessWidget {
  final bool isOnline;
  const OnlineDot({super.key, this.isOnline = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 11,
      height: 11,
      decoration: BoxDecoration(
        color: isOnline ? const Color(0xFF4CAF50) : AppColors.neutral400,
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).scaffoldBackgroundColor,
          width: 2,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// C H A T   T I L E  — used in HomeScreen list
// ─────────────────────────────────────────────────────────────────────────────

class ChatTile extends StatelessWidget {
  final String name;
  final String lastMessage;
  final String time;
  final int unreadCount;
  final VoidCallback onTap;
  final bool isOnline;

  const ChatTile({
    super.key,
    required this.name,
    required this.lastMessage,
    required this.time,
    required this.onTap,
    this.unreadCount = 0,
    this.isOnline = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary =
    isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary =
    isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            // Avatar with online dot
            Stack(
              children: [
                CAvatar(name: name, radius: 26),
                if (isOnline)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: OnlineDot(isOnline: isOnline),
                  ),
              ],
            ),
            const SizedBox(width: 14),
            // Name + message
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: textPrimary,
                          ),
                        ),
                      ),
                      Text(
                        time,
                        style: TextStyle(
                          fontSize: 12,
                          color: unreadCount > 0
                              ? AppColors.blue500
                              : textSecondary,
                          fontWeight: unreadCount > 0
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          lastMessage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            color: textSecondary,
                            fontWeight: unreadCount > 0
                                ? FontWeight.w500
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                      if (unreadCount > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.all(5),
                          constraints: const BoxConstraints(minWidth: 20),
                          decoration: const BoxDecoration(
                            color: AppColors.blue500,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            unreadCount > 99 ? '99+' : unreadCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// M E S S A G E   B U B B L E  — used in ChatScreen
// ─────────────────────────────────────────────────────────────────────────────

class MessageBubble extends StatelessWidget {
  final String text;
  final bool isMe;
  final String time;
  final bool isSeen;

  const MessageBubble({
    super.key,
    required this.text,
    required this.isMe,
    required this.time,
    this.isSeen = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          left: isMe ? 60 : 16,
          right: isMe ? 16 : 60,
          top: 3,
          bottom: 3,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isMe
              ? AppColors.blue500
              : isDark
              ? AppColors.neutral800
              : AppColors.neutral50,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isMe ? 18 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 18),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment:
          isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: TextStyle(
                color: isMe
                    ? Colors.white
                    : isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
                fontSize: 14.5,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 10,
                    color: isMe
                        ? Colors.white.withOpacity(0.7)
                        : AppColors.neutral400,
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    isSeen ? Icons.done_all : Icons.done,
                    size: 13,
                    color: isSeen
                        ? Colors.white
                        : Colors.white.withOpacity(0.6),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// C H A T   I N P U T  — message input bar
// ─────────────────────────────────────────────────────────────────────────────

class ChatInputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final String hintText;

  const ChatInputBar({
    super.key,
    required this.controller,
    required this.onSend,
    this.hintText = 'Type a message...',
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.neutral800 : AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Attachment icon
            _IconBtn(
              icon: Icons.attach_file_rounded,
              onTap: () {},
              color: isDark ? AppColors.neutral400 : AppColors.neutral500,
            ),
            const SizedBox(width: 8),
            // Text field
            Expanded(
              child: TextField(
                controller: controller,
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                style: TextStyle(
                  fontSize: 15,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: TextStyle(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.neutral400,
                    fontSize: 15,
                  ),
                  filled: true,
                  fillColor: isDark
                      ? AppColors.darkInputBg
                      : AppColors.lightInputBg,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Send button
            GestureDetector(
              onTap: onSend,
              child: Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.gradientBlueStart,
                      AppColors.gradientBlueEnd,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  const _IconBtn({required this.icon, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(icon, color: color ?? AppColors.neutral400, size: 22),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// C A L L   C O N T R O L   B U T T O N  — used in call screens
// ─────────────────────────────────────────────────────────────────────────────

class CallControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isActive;
  final Color? activeColor;
  final Color? inactiveColor;
  final double size;

  const CallControlButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = true,
    this.activeColor,
    this.inactiveColor,
    this.size = 56,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isActive
        ? (activeColor ?? Colors.white.withOpacity(0.18))
        : (inactiveColor ?? Colors.white.withOpacity(0.08));

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: bg,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.12),
              ),
            ),
            child: Icon(icon, color: Colors.white, size: size * 0.42),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// C   A P P B A R  — consistent styled app bar
// ─────────────────────────────────────────────────────────────────────────────

class CAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBack;
  final Color? backgroundColor;

  const CAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.showBack = true,
    this.backgroundColor,
  });

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = backgroundColor ??
        (isDark ? AppColors.neutral800 : AppColors.white);

    return AppBar(
      backgroundColor: bg,
      elevation: 0,
      centerTitle: false,
      automaticallyImplyLeading: false,
      leading: showBack
          ? (leading ??
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            color: isDark ? AppColors.white : AppColors.neutral900,
            onPressed: () => Navigator.of(context).pop(),
          ))
          : leading,
      title: Text(
        title,
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: isDark ? AppColors.white : AppColors.neutral900,
        ),
      ),
      actions: actions,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Divider(
          height: 1,
          thickness: 1,
          color: isDark ? AppColors.neutral700 : AppColors.neutral100,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// U S E R   T I L E  — used in AddUsers screen
// ─────────────────────────────────────────────────────────────────────────────

class UserTile extends StatelessWidget {
  final String name;
  final String subtitle;
  final VoidCallback onTap;

  const UserTile({
    super.key,
    required this.name,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary =
    isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary =
    isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            CAvatar(name: name, radius: 24),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 13, color: textSecondary),
                  ),
                ],
              ),
            ),
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.blue500.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Message',
                style: TextStyle(
                  color: AppColors.blue500,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}