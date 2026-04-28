import 'package:chat_demo/features/chat/providers/call_provider.dart';
import 'package:chat_demo/firebase_options.dart';
import 'package:chat_demo/routes/app_routes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/theme_provider.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/chat/providers/chat_provider.dart';
import 'features/startup/app_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => CallProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      // ✅ Use the same global router instance that CallProvider references
      routerConfig: AppRouter.router,
      builder: (context, child) {
        // AppWrapper sits INSIDE MaterialApp.router so GoRouter IS available,
        // but we no longer call GoRouter from AppWrapper anyway —
        // navigation is done directly via AppRouter.router in CallProvider
        return AppWrapper(child: child!);
      },
    );
  }
}