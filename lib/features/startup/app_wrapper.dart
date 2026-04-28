import 'dart:async';

import 'package:chat_demo/features/chat/providers/call_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppWrapper extends StatefulWidget {
  final Widget child;
  const AppWrapper({super.key, required this.child});

  @override
  State<AppWrapper> createState() => _AppWrapperState();
}

class _AppWrapperState extends State<AppWrapper> {
  StreamSubscription? _authSubscription;

  @override
  void initState() {
    super.initState();
    // authStateChanges fires immediately with current user (or null),
    // then again on every login / logout — so we always catch the right moment
    _authSubscription =
        FirebaseAuth.instance.authStateChanges().listen((user) {
          if (user != null && mounted) {
            debugPrint('[AppWrapper] Auth ready — starting call listener for ${user.uid}');
            context.read<CallProvider>().startListeningIncomingCalls(user.uid);
          }
        });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}