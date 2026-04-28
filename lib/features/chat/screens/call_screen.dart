import 'dart:async';

import 'package:chat_demo/core/constants/app_colors.dart';
import 'package:chat_demo/features/chat/providers/call_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../widgets/chat_widgets.dart';

class CallScreen extends StatefulWidget {
  final String callId;
  final String receiverId;
  final String receiverName;

  const CallScreen({
    super.key,
    required this.callId,
    required this.receiverId,
    required this.receiverName,
  });

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  StreamSubscription? _endedSub;
  bool _localExpanded = false; // swap local/remote view

  @override
  void initState() {
    super.initState();
    _watchForCallEnd();
  }

  void _watchForCallEnd() {
    _endedSub =
        Stream.periodic(const Duration(milliseconds: 600)).listen((_) {
          if (!mounted) return;
          if (context.read<CallProvider>().activeCallId == null) {
            _endedSub?.cancel();
            if (mounted) context.pop();
          }
        });
  }

  @override
  void dispose() {
    _endedSub?.cancel();
    super.dispose();
  }

  String _callDuration = '00:00';
  Timer? _timer;
  int _seconds = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Start timer when remote stream arrives
    final webrtc = context.read<CallProvider>().webrtc;
    if (webrtc?.remoteRenderer.srcObject != null && _timer == null) {
      _startTimer();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      _seconds++;
      final m = (_seconds ~/ 60).toString().padLeft(2, '0');
      final s = (_seconds % 60).toString().padLeft(2, '0');
      setState(() => _callDuration = '$m:$s');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CallProvider>(
      builder: (context, callProvider, _) {
        final webrtc = callProvider.webrtc;
        final hasRemote = webrtc?.remoteRenderer.srcObject != null;

        // Start timer once remote stream is available
        if (hasRemote && _timer == null) _startTimer();

        return Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            fit: StackFit.expand,
            children: [

              // ── BACKGROUND: remote video or gradient ──────────────────
              if (webrtc != null && hasRemote)
                RTCVideoView(
                  webrtc.remoteRenderer,
                  objectFit:
                  RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                )
              else
                _GradientBackground(name: widget.receiverName),

              // ── DARK OVERLAY (always) ─────────────────────────────────
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.55),
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black.withOpacity(0.75),
                    ],
                    stops: const [0, 0.25, 0.65, 1],
                  ),
                ),
              ),

              // ── TOP: caller info ───────────────────────────────────────
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    child: Column(
                      children: [
                        if (!hasRemote) ...[
                          const SizedBox(height: 30),
                          CAvatar(
                            name: widget.receiverName,
                            radius: 46,
                            bgColor: Colors.white.withOpacity(0.22),
                          ),
                          const SizedBox(height: 14),
                        ],
                        Text(
                          widget.receiverName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            shadows: [
                              Shadow(
                                  color: Colors.black45, blurRadius: 8)
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          hasRemote ? _callDuration : 'Calling...',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── LOCAL PiP ─────────────────────────────────────────────
              if (webrtc != null)
                Positioned(
                  right: 16,
                  top: 160,
                  child: GestureDetector(
                    onTap: () =>
                        setState(() => _localExpanded = !_localExpanded),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: _localExpanded ? 120 : 90,
                      height: _localExpanded ? 170 : 130,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: Colors.white30, width: 1.5),
                        boxShadow: const [
                          BoxShadow(
                              color: Colors.black54, blurRadius: 12)
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(13),
                        child: callProvider.isVideoOn
                            ? RTCVideoView(
                          webrtc.localRenderer,
                          mirror: true,
                          objectFit: RTCVideoViewObjectFit
                              .RTCVideoViewObjectFitCover,
                        )
                            : Container(
                          color: Colors.black87,
                          child: const Center(
                            child: Icon(Icons.videocam_off,
                                color: Colors.white54, size: 28),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

              // ── CONTROLS ─────────────────────────────────────────────
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
                    child: Column(
                      children: [
                        // Row 1: mute / video / speaker / flip
                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceEvenly,
                          children: [
                            CallControlButton(
                              icon: callProvider.isMuted
                                  ? Icons.mic_off_rounded
                                  : Icons.mic_rounded,
                              label: callProvider.isMuted
                                  ? 'Unmute'
                                  : 'Mute',
                              isActive: !callProvider.isMuted,
                              onTap: () => callProvider.toggleMute(),
                            ),
                            CallControlButton(
                              icon: callProvider.isVideoOn
                                  ? Icons.videocam_rounded
                                  : Icons.videocam_off_rounded,
                              label: callProvider.isVideoOn
                                  ? 'Video'
                                  : 'No Video',
                              isActive: callProvider.isVideoOn,
                              onTap: () => callProvider.toggleVideo(),
                            ),
                            CallControlButton(
                              icon: callProvider.isSpeakerOn
                                  ? Icons.volume_up_rounded
                                  : Icons.volume_down_rounded,
                              label: 'Speaker',
                              isActive: callProvider.isSpeakerOn,
                              onTap: () =>
                                  callProvider.toggleSpeaker(),
                            ),
                            CallControlButton(
                              icon: Icons.flip_camera_ios_rounded,
                              label: 'Flip',
                              onTap: () {},
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // End call button
                        GestureDetector(
                          onTap: () async {
                            _timer?.cancel();
                            await callProvider.endCall();
                            if (mounted) context.pop();
                          },
                          child: Container(
                            width: 68,
                            height: 68,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE53935),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFE53935)
                                      .withOpacity(0.45),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.call_end_rounded,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Gradient placeholder when no remote video yet ─────────────────────────────
class _GradientBackground extends StatelessWidget {
  final String name;
  const _GradientBackground({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF1A237E),
            Color(0xFF1565C0),
            Color(0xFF0288D1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.15),
                border:
                Border.all(color: Colors.white30, width: 2),
              ),
              child: Center(
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: const TextStyle(
                    fontSize: 48,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}