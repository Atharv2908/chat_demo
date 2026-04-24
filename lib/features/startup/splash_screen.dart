import 'package:chat_demo/core/constants/app_images.dart';
import 'package:chat_demo/features/auth/services/session_service.dart';
import 'package:chat_demo/routes/route_names.dart';
import 'package:chat_demo/widgets/texts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async{

    await Future.delayed(const Duration(seconds: 2)); // Simulate loading time
    final route = await SessionService.resolveStartRoute();

    if(!mounted) return;
    context.go(route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(AppImages.logo),
          ],
        ),
      ),
    );
  }
}
