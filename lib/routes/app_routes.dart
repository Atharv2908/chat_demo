import 'package:chat_demo/features/chat/screens/add_users.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/otp_screen.dart';
import '../features/auth/screens/phone_input_screen.dart';
import '../features/auth/screens/signup_screen.dart';
import '../features/chat/screens/call_screen.dart';
import '../features/chat/screens/chat_screen.dart';
import '../features/chat/screens/home_screen.dart';
import '../features/chat/screens/incoming_call_screen.dart';
import '../features/general/settings.dart';
import '../features/startup/splash_screen.dart';
import 'route_names.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: RouteNames.splash,
    routes: [
      GoRoute(
        path: RouteNames.splash,
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: RouteNames.login,
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: RouteNames.signup,
        builder: (_, __) => const SignupScreen(),
      ),
      GoRoute(
        path: RouteNames.phone,
        builder: (_, __) => const PhoneInputScreen(),
      ),
      GoRoute(
        path: RouteNames.otp,
        builder: (_, __) => const OtpScreen(),
      ),
      GoRoute(
        path: RouteNames.home,
        builder: (_, __) => const HomeScreen(),
      ),
      GoRoute(
        path: RouteNames.addUsers,
        builder: (_, __) => const AddUsers(),
      ),
      GoRoute(
        path: RouteNames.chat,
        builder: (_, state) => ChatScreen(
          chatId: state.pathParameters['chatId']!,
          receiverId: state.pathParameters['receiverId']!,
          name: Uri.decodeComponent(state.pathParameters['name']!),
        ),
      ),

      // ── INCOMING CALL ────────────────────────────────────────────────────
      // Uses query params — avoids path-matching crash on empty/special names
      GoRoute(
        path: RouteNames.incomingCall,   // '/incoming-call'
        builder: (_, state) {
          final callId     = state.uri.queryParameters['callId'] ?? '';
          final callerId   = state.uri.queryParameters['callerId'] ?? '';
          final callerName = state.uri.queryParameters['callerName'] ?? 'Unknown';
          return IncomingCallScreen(
            callId: callId,
            callerId: callerId,
            callerName: callerName,
          );
        },
      ),

      // ── ACTIVE CALL ──────────────────────────────────────────────────────
      GoRoute(
        path: RouteNames.call,           // '/call/:callId/:receiverId/:name'
        builder: (_, state) => CallScreen(
          callId: state.pathParameters['callId']!,
          receiverId: state.pathParameters['receiverId']!,
          receiverName: Uri.decodeComponent(state.pathParameters['name']!),
        ),
      ),
      
      GoRoute(path: RouteNames.settings, builder: (_, __) => const SettingsScreen())
    ],
  );
}