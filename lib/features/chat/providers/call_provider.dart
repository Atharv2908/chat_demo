import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../../../routes/app_routes.dart';
import '../services/call_service.dart';
import '../services/webrtc_service.dart';

class IncomingCallData {
  final String callId;
  final String callerId;
  final String callerName;
  final Map<String, dynamic> offer;

  IncomingCallData({
    required this.callId,
    required this.callerId,
    required this.callerName,
    required this.offer,
  });
}

class CallProvider extends ChangeNotifier {
  final CallService _callService = CallService();

  WebRTCService? _webrtc;
  WebRTCService? get webrtc => _webrtc;

  IncomingCallData? _incomingCall;
  IncomingCallData? get incomingCall => _incomingCall;

  String? _activeCallId;
  String? get activeCallId => _activeCallId;

  bool _isMuted = false;
  bool get isMuted => _isMuted;

  bool _isVideoOn = true;
  bool get isVideoOn => _isVideoOn;

  bool _isSpeakerOn = false;
  bool get isSpeakerOn => _isSpeakerOn;

  StreamSubscription? _callSubscription;
  StreamSubscription? _incomingCallSubscription;
  StreamSubscription? _iceCandidateSubscription;

  final Set<String> _handledCallIds = {};

  // ─── Start listening for incoming calls ───────────────────────────────────
  void startListeningIncomingCalls(String userId) {
    _incomingCallSubscription?.cancel();
    debugPrint('[CallProvider] Listening for calls for $userId');

    _incomingCallSubscription = FirebaseFirestore.instance
        .collection('calls')
        .where('receiverId', isEqualTo: userId)
        .where('status', isEqualTo: 'ringing')
        .snapshots()
        .listen((snapshot) {
      for (final change in snapshot.docChanges) {
        if (change.type != DocumentChangeType.added &&
            change.type != DocumentChangeType.modified) continue;

        final data = change.doc.data();
        if (data == null) continue;

        final callId = change.doc.id;
        final status = data['status'] as String? ?? '';

        if (status != 'ringing') continue;
        if (_handledCallIds.contains(callId)) continue;

        // ✅ Guarantee callerName is never null or empty
        final rawName = data['callerName'];
        final callerName = (rawName != null &&
            rawName.toString().trim().isNotEmpty)
            ? rawName.toString().trim()
            : 'Unknown';

        debugPrint('[CallProvider] Incoming call: $callId from "$callerName"');
        _handledCallIds.add(callId);

        _incomingCall = IncomingCallData(
          callId: callId,
          callerId: data['callerId'] ?? '',
          callerName: callerName,
          offer: Map<String, dynamic>.from(data['offer'] ?? {}),
        );

        _navigateToIncomingCall(_incomingCall!);
      }
    }, onError: (e) {
      debugPrint('[CallProvider] Listener error: $e');
    });
  }

  void _navigateToIncomingCall(IncomingCallData incoming) {
    // ✅ Use query parameters instead of path parameters for the name —
    //    this avoids GoRouter route-matching failures on empty/special strings
    final uri = Uri(
      path: '/incoming-call',
      queryParameters: {
        'callId': incoming.callId,
        'callerId': incoming.callerId,
        'callerName': incoming.callerName,
      },
    );
    debugPrint('[CallProvider] Navigating to: $uri');
    AppRouter.router.push(uri.toString());
  }

  void clearIncomingCall() {
    _incomingCall = null;
    notifyListeners();
  }

  // ─── CALLER: create offer + write call doc ────────────────────────────────
  Future<String> startOutgoingCall({
    required String receiverId,
    required String receiverName,
  }) async {
    final currentUser = FirebaseAuth.instance.currentUser!;

    // ✅ Safe callerName — never empty
    final callerName = (currentUser.displayName?.trim().isNotEmpty == true)
        ? currentUser.displayName!.trim()
        : (currentUser.email?.split('@').first ?? 'User');

    _webrtc = WebRTCService();
    await _webrtc!.init();

    final offer = await _webrtc!.createOffer();

    final callId = await _callService.createCall(
      callerId: currentUser.uid,
      callerName: callerName,
      receiverId: receiverId,
      receiverName: receiverName,
      offer: offer,
    );

    _activeCallId = callId;

    _webrtc!.onLocalIceCandidate = (candidate) {
      _callService.sendIceCandidate(
        callId: callId,
        candidate: candidate.toMap(),
        isCallerCandidate: true,
      );
    };

    notifyListeners();
    _listenCallUpdates(callId, isCaller: true);
    return callId;
  }

  // ─── RECEIVER: accept + answer ────────────────────────────────────────────
  Future<void> acceptCall(IncomingCallData incoming) async {
    _webrtc = WebRTCService();
    await _webrtc!.init();

    _webrtc!.onLocalIceCandidate = (candidate) {
      _callService.sendIceCandidate(
        callId: incoming.callId,
        candidate: candidate.toMap(),
        isCallerCandidate: false,
      );
    };

    final answer = await _webrtc!.createAnswer(incoming.offer);
    await _callService.sendAnswer(incoming.callId, answer);

    _activeCallId = incoming.callId;
    clearIncomingCall();
    notifyListeners();

    _listenCallUpdates(incoming.callId, isCaller: false);
  }

  // ─── RECEIVER: decline ────────────────────────────────────────────────────
  Future<void> declineCall(String callId) async {
    _handledCallIds.remove(callId);
    await _callService.endCall(callId);
    clearIncomingCall();
  }

  // ─── Listen for answer + ICE candidates ──────────────────────────────────
  void _listenCallUpdates(String callId, {required bool isCaller}) {
    _callSubscription?.cancel();
    _iceCandidateSubscription?.cancel();

    _callSubscription =
        _callService.listenCall(callId).listen((doc) async {
          if (!doc.exists) return;
          final data = doc.data() as Map<String, dynamic>;

          if (isCaller &&
              data['answer'] != null &&
              _webrtc?.pc?.signalingState !=
                  RTCSignalingState.RTCSignalingStateStable) {
            await _webrtc!
                .setRemoteAnswer(Map<String, dynamic>.from(data['answer']));
          }

          if (data['status'] == 'ended') {
            await _cleanupCall();
            notifyListeners();
          }
        });

    final candidateCollection =
    isCaller ? 'receiverCandidates' : 'callerCandidates';

    _iceCandidateSubscription = FirebaseFirestore.instance
        .collection('calls')
        .doc(callId)
        .collection(candidateCollection)
        .snapshots()
        .listen((snapshot) {
      for (final change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final d = change.doc.data()!;
          _webrtc?.addIceCandidate(RTCIceCandidate(
            d['candidate'],
            d['sdpMid'],
            d['sdpMLineIndex'],
          ));
        }
      }
    });
  }

  // ─── Controls ─────────────────────────────────────────────────────────────
  void toggleMute() {
    _isMuted = !_isMuted;
    _webrtc?.setMicEnabled(!_isMuted);
    notifyListeners();
  }

  void toggleVideo() {
    _isVideoOn = !_isVideoOn;
    _webrtc?.setCameraEnabled(_isVideoOn);
    notifyListeners();
  }

  void toggleSpeaker() {
    _isSpeakerOn = !_isSpeakerOn;
    notifyListeners();
  }

  // ─── End call ─────────────────────────────────────────────────────────────
  Future<void> endCall() async {
    if (_activeCallId != null) {
      await _callService.endCall(_activeCallId!);
    }
    await _cleanupCall();
    notifyListeners();
  }

  Future<void> _cleanupCall() async {
    _callSubscription?.cancel();
    _iceCandidateSubscription?.cancel();
    _callSubscription = null;
    _iceCandidateSubscription = null;
    await _webrtc?.dispose();
    _webrtc = null;
    _activeCallId = null;
    _isMuted = false;
    _isVideoOn = true;
    _isSpeakerOn = false;
  }

  @override
  void dispose() {
    _incomingCallSubscription?.cancel();
    _cleanupCall();
    super.dispose();
  }
}