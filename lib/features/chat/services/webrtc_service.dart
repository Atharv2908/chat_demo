import 'package:flutter_webrtc/flutter_webrtc.dart';

class WebRTCService {
  RTCPeerConnection? pc;
  MediaStream? localStream;

  final RTCVideoRenderer localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer remoteRenderer = RTCVideoRenderer();

  /// Called whenever a local ICE candidate is generated
  /// CallProvider wires this up to send candidates to Firestore
  Function(RTCIceCandidate)? onLocalIceCandidate;

  Future<void> init() async {
    await localRenderer.initialize();
    await remoteRenderer.initialize();

    pc = await createPeerConnection({
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
        {'urls': 'stun:stun1.l.google.com:19302'},
      ],
      'sdpSemantics': 'unified-plan',
    });

    localStream = await navigator.mediaDevices.getUserMedia({
      'video': {'facingMode': 'user'},
      'audio': true,
    });

    localRenderer.srcObject = localStream;

    // Add all tracks to the peer connection
    for (var track in localStream!.getTracks()) {
      await pc!.addTrack(track, localStream!);
    }

    // When remote stream arrives, attach to renderer
    pc!.onTrack = (event) {
      if (event.streams.isNotEmpty) {
        remoteRenderer.srcObject = event.streams[0];
      }
    };

    // Fire ICE candidates upward to CallProvider
    pc!.onIceCandidate = (candidate) {
      if (candidate.candidate != null) {
        onLocalIceCandidate?.call(candidate);
      }
    };

    pc!.onConnectionState = (state) {
      // Optional: log or handle connection state changes
    };
  }

  Future<Map<String, dynamic>> createOffer() async {
    final offer = await pc!.createOffer({
      'offerToReceiveVideo': true,
      'offerToReceiveAudio': true,
    });
    await pc!.setLocalDescription(offer);
    return {'sdp': offer.sdp, 'type': offer.type};
  }

  Future<Map<String, dynamic>> createAnswer(
      Map<String, dynamic> offer) async {
    await pc!.setRemoteDescription(
      RTCSessionDescription(offer['sdp'], offer['type']),
    );
    final answer = await pc!.createAnswer();
    await pc!.setLocalDescription(answer);
    return {'sdp': answer.sdp, 'type': answer.type};
  }

  Future<void> setRemoteAnswer(Map<String, dynamic> answer) async {
    await pc!.setRemoteDescription(
      RTCSessionDescription(answer['sdp'], answer['type']),
    );
  }

  Future<void> addIceCandidate(RTCIceCandidate candidate) async {
    try {
      await pc!.addCandidate(candidate);
    } catch (_) {}
  }

  void setMicEnabled(bool enabled) {
    localStream?.getAudioTracks().forEach((t) => t.enabled = enabled);
  }

  void setCameraEnabled(bool enabled) {
    localStream?.getVideoTracks().forEach((t) => t.enabled = enabled);
  }

  Future<void> dispose() async {
    localRenderer.dispose();
    remoteRenderer.dispose();
    await localStream?.dispose();
    await pc?.close();
    pc = null;
    localStream = null;
  }
}
