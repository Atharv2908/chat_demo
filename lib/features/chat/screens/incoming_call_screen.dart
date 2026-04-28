import 'package:chat_demo/core/constants/app_colors.dart';
import 'package:chat_demo/features/chat/providers/call_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class IncomingCallScreen extends StatefulWidget {
  final String callId;
  final String callerId;
  final String callerName;

  const IncomingCallScreen({
    super.key,
    required this.callId,
    required this.callerId,
    required this.callerName,
  });

  @override
  State<IncomingCallScreen> createState() => _IncomingCallScreenState();
}

class _IncomingCallScreenState extends State<IncomingCallScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;
  bool _isAccepting = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.18).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0D1B4B),
              Color(0xFF1565C0),
              Color(0xFF0288D1),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 32),

              // ── Incoming call label ──────────────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 18, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.videocam_rounded,
                        color: Colors.white70, size: 16),
                    const SizedBox(width: 6),
                    const Text(
                      'Incoming video call',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // ── Pulsing avatar ───────────────────────────────────────────
              ScaleTransition(
                scale: _pulseAnim,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer ring
                    Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.08),
                      ),
                    ),
                    // Middle ring
                    Container(
                      width: 132,
                      height: 132,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.12),
                      ),
                    ),
                    // Avatar
                    Container(
                      width: 108,
                      height: 108,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.22),
                        border: Border.all(
                            color: Colors.white38, width: 2.5),
                      ),
                      child: Center(
                        child: Text(
                          widget.callerName.isNotEmpty
                              ? widget.callerName[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            fontSize: 46,
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ── Name ────────────────────────────────────────────────────
              Text(
                widget.callerName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'is calling you...',
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),

              const Spacer(),

              // ── Action buttons ───────────────────────────────────────────
              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 48),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Decline
                    _ActionButton(
                      icon: Icons.call_end_rounded,
                      label: 'Decline',
                      color: const Color(0xFFE53935),
                      onTap: _isAccepting
                          ? null
                          : () async {
                        await context
                            .read<CallProvider>()
                            .declineCall(widget.callId);
                        if (mounted) context.pop();
                      },
                    ),

                    // Accept
                    _ActionButton(
                      icon: _isAccepting
                          ? Icons.hourglass_bottom_rounded
                          : Icons.videocam_rounded,
                      label: _isAccepting ? 'Joining...' : 'Accept',
                      color: const Color(0xFF43A047),
                      onTap: _isAccepting
                          ? null
                          : () async {
                        setState(() => _isAccepting = true);
                        final provider =
                        context.read<CallProvider>();
                        final incoming = provider.incomingCall;
                        if (incoming == null) {
                          if (mounted) context.pop();
                          return;
                        }
                        await provider.acceptCall(incoming);
                        if (mounted) {
                          context.pushReplacement(
                            '/call/${widget.callId}/${widget.callerId}/${Uri.encodeComponent(widget.callerName)}',
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: onTap == null ? color.withOpacity(0.4) : color,
              shape: BoxShape.circle,
              boxShadow: onTap != null
                  ? [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ]
                  : null,
            ),
            child: Icon(icon, color: Colors.white, size: 30),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}