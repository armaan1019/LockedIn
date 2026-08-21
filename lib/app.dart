import 'package:flutter/material.dart';
import 'navigation/app_shell.dart';
import 'features/social/pages/login_page.dart';
import 'core/services/session_manager.dart';
import 'package:provider/provider.dart';
import 'core/providers/theme_provider.dart';
import 'core/theme/app_theme.dart';
import 'navigation/splash_screen.dart';
import 'core/pages/email_verification_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SessionManager>(
      builder: (context, session, _) {
        return MaterialApp(
          key: ValueKey('${session.isLoggedIn}-${session.emailVerified}'),
          debugShowCheckedModeBanner: false,
          title: 'Workout App',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: context.watch<ThemeProvider>().themeMode,
          home: !session.initialized
              ? const SplashScreen()
              : session.emailVerificationRequired
                  ? const EmailVerificationPage()
                  : session.isLoggedIn
                      ? const AppShell()
                      : const LoginPage(),
        );
      },
    );
  }
}
