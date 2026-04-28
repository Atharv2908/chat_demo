import 'package:cloud_firestore/cloud_firestore.dart';

class CallService {
  final _firestore = FirebaseFirestore.instance;

  /// Create a call document and return its ID
  Future<String> createCall({
    required String callerId,
    required String callerName,
    required String receiverId,
    required String receiverName,
    required Map<String, dynamic> offer,
  }) async {
    final doc = _firestore.collection('calls').doc();

    await doc.set({
      'callerId': callerId,
      'callerName': callerName,
      'receiverId': receiverId,
      'receiverName': receiverName,
      'offer': offer,
      'status': 'ringing',
      'createdAt': FieldValue.serverTimestamp(),
    });

    return doc.id;
  }

  /// Receiver sends back the answer SDP
  Future<void> sendAnswer(String callId, Map<String, dynamic> answer) async {
    await _firestore.collection('calls').doc(callId).update({
      'answer': answer,
      'status': 'accepted',
    });
  }

  /// Send an ICE candidate to the correct sub-collection
  /// isCallerCandidate = true  → caller is sending their candidate (goes to callerCandidates)
  /// isCallerCandidate = false → receiver is sending their candidate (goes to receiverCandidates)
  Future<void> sendIceCandidate({
    required String callId,
    required Map<String, dynamic> candidate,
    required bool isCallerCandidate,
  }) async {
    final collection =
    isCallerCandidate ? 'callerCandidates' : 'receiverCandidates';

    await _firestore
        .collection('calls')
        .doc(callId)
        .collection(collection)
        .add(candidate);
  }

  /// Stream the call document for status updates
  Stream<DocumentSnapshot> listenCall(String callId) {
    return _firestore.collection('calls').doc(callId).snapshots();
  }

  /// Mark call as ended
  Future<void> endCall(String callId) async {
    await _firestore.collection('calls').doc(callId).update({
      'status': 'ended',
    });
  }
}
