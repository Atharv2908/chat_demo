import 'package:flutter_webrtc/flutter_webrtc.dart';

class WebRTCService {
  RTCPeerConnection? peerConnection;
  MediaStream? localStream;

  final Map<String, dynamic> config = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
    ]
  };

  Future<void> init() async {
    peerConnection = await createPeerConnection(config);

    localStream = await navigator.mediaDevices.getUserMedia({
      'video': true,
      'audio': true,
    });

    for (var track in localStream!.getTracks()) {
      peerConnection!.addTrack(track, localStream!);
    }
  }
}