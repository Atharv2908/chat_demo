import 'package:chat_demo/routes/route_names.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/storage/prefs_service.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  User? get user => _auth.currentUser;

  // SIGN UP
  Future<void> signUp({
    required String name,
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      final auth = FirebaseAuth.instance;
      final firestore = FirebaseFirestore.instance;

      // 🔐 Create user in Firebase Auth
      UserCredential userCredential =
      await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;

      // Save user in Firestore (ONLY ON SIGNUP)
      await firestore.collection('users').doc(user!.uid).set({
        'name' : name,
        'uid': user.uid,
        'email': user.email,
        'createdAt': Timestamp.now(),
      });

      // Navigate after success
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Signup Successful")),
      );
      context.go(RouteNames.home);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  //  LOGIN
  Future<void> login({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      await PrefsService.updateLastActive();

      _showMessage(context, "Login Successful");
      context.go(RouteNames.home);

    } on FirebaseAuthException catch (e) {
      _showMessage(context, _handleAuthError(e));

    } catch (e) {
      _showMessage(context, "Something went wrong");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  //  LOGOUT
  Future<void> logout() async {

    await _auth.signOut();

    await PrefsService.clearSession();

  }

  //  ERROR HANDLER
  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'Email already in use';
      case 'invalid-email':
        return 'Invalid email';
      case 'weak-password':
        return 'Password too weak';
      case 'user-not-found':
        return 'User not found';
      case 'wrong-password':
        return 'Wrong password';
      default:
        return e.message ?? 'Auth error';
    }
  }

  // SNACKBAR
  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}