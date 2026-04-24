import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _verificationId;

  /// Send OTP
  Future<void> sendOtp({
    required String phone,
    required Function() onCodeSent,
    required Function(String error) onError,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phone,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: (e) {
        onError(e.message ?? "Verification failed");
      },
      codeSent: (verificationId, resendToken) {
        _verificationId = verificationId;
        onCodeSent();
      },
      codeAutoRetrievalTimeout: (verificationId) {
        _verificationId = verificationId;
      },
    );
  }

  /// Verify OTP
  Future<User?> verifyOtp({
    required String otp,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );

      final userCred = await _auth.signInWithCredential(credential);

      await _saveUserIfNew(userCred.user!);

      return userCred.user;
    } catch (e) {
      return null;
    }
  }

  /// Save user in Firestore
  Future<void> _saveUserIfNew(User user) async {
    final doc =
    _firestore.collection('users').doc(user.uid);

    final snapshot = await doc.get();

    if (!snapshot.exists) {
      await doc.set({
        'uid': user.uid,
        'phone': user.phoneNumber,
        'name': 'User',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }
}