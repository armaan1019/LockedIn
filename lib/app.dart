import 'package:flutter/material.dart';
import 'navigation/app_shell.dart';
import 'features/social/login_page.dart';
import 'features/social/services/session_manager.dart';
import 'package:provider/provider.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SessionManager>(
      builder: (context, session, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Workout App',
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          ),
          home: session.isLoggedIn ? const AppShell() : const LoginPage(),
        );
      },
    );
  }
}
