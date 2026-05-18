import 'package:flutter/material.dart';
import 'navigation/app_shell.dart';
import 'features/social/pages/login_page.dart';
import 'core/services/session_manager.dart';
import 'package:provider/provider.dart';
import 'core/providers/theme_provider.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SessionManager>(
      builder: (context, session, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Workout App',
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: context.watch<ThemeProvider>().themeMode,
          home: session.isLoggedIn ? const AppShell() : const LoginPage(),
        );
      },
    );
  }
}
