import 'package:chat_demo/features/chat/screens/add_users.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/screens/login_screen.dart';

import '../features/auth/screens/otp_screen.dart';
import '../features/auth/screens/phone_input_screen.dart';
import '../features/auth/screens/signup_screen.dart';
import '../features/chat/screens/chat_screen.dart';
import '../features/chat/screens/home_screen.dart';
import '../features/startup/splash_screen.dart';
import 'route_names.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',

    routes: [
      GoRoute(
        path: RouteNames.splash,
        builder: (context, state) => SplashScreen(),
      ),
      GoRoute(
        path: RouteNames.login,
        builder: (context, state) => LoginScreen(),
      ),
      GoRoute(
        path: RouteNames.signup,
        builder: (context, state) => SignupScreen(),
      ),
      GoRoute(
        path: RouteNames.phone,
        builder: (context, state) => PhoneInputScreen(),
      ),
      GoRoute(
        path: RouteNames.otp,
        builder: (context, state) => OtpScreen(),
      ),
      GoRoute(path: RouteNames.home, builder: (context, state) => HomeScreen()),
      GoRoute(path: RouteNames.addUsers, builder: (context, state) => AddUsers()),
      GoRoute(
        path: RouteNames.chat,
        builder: (BuildContext context, GoRouterState state) {
          final chatId = state.pathParameters['chatId']!;
          final receiverId = state.pathParameters['receiverId']!;
          final name = Uri.decodeComponent(state.pathParameters['name']!);

          return ChatScreen(chatId: chatId, receiverId: receiverId, name: name);
        },
      ),
    ],
  );
}
