import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../services/auth_service.dart';
import '../services/session_manager.dart';

class EmailVerificationPage extends StatefulWidget {
  const EmailVerificationPage({super.key});

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  bool _isBusy = false;

  Timer? _resendCooldownTimer;
  int _resendCooldown = 0;

  @override
  void dispose() {
    _resendCooldownTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkVerification() async {
    if (_isBusy) return;

    setState(() {
      _isBusy = true;
    });

    try {
      final verified = await context
          .read<SessionManager>()
          .refreshEmailVerification();

      if (!mounted) return;

      if (!verified) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Your email is not verified yet.')),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to check verification status.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isBusy = false;
        });
      }
    }
  }

  Future<void> _resendVerificationEmail() async {
    if (_isBusy) return;

    setState(() {
      _isBusy = true;
    });

    try {
      await AuthService.instance.resendVerificationEmail();

      setState(() {
        _resendCooldown = 30;
      });

      _resendCooldownTimer?.cancel();
      _resendCooldownTimer = Timer.periodic(const Duration(seconds: 1), (
        timer,
      ) {
        if (!mounted) {
          timer.cancel();
          return;
        }

        if (_resendCooldown <= 1) {
          timer.cancel();
          setState(() {
            _resendCooldown = 0;
          });
        } else {
          setState(() {
            _resendCooldown--;
          });
        }
      });

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Verification email sent.')));
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to send verification email.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isBusy = false;
        });
      }
    }
  }

  Future<void> _logout() async {
    if (_isBusy) return;

    setState(() {
      _isBusy = true;
    });

    try {
      await context.read<SessionManager>().logout();
    } finally {
      if (mounted) {
        setState(() {
          _isBusy = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Your Email'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.mark_email_unread_outlined,
                  size: 80,
                  color: theme.colorScheme.primary,
                ),

                const SizedBox(height: 24),

                Text(
                  'Check Your Email',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                const Text(
                  'We sent you a verification link. '
                  'Please verify your email address before continuing to Locked In. '
                  'Check your spam/junk folders if the email seems to be missing.',
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _isBusy ? null : _checkVerification,
                    child: _isBusy
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text("I've Verified My Email"),
                  ),
                ),

                const SizedBox(height: 12),

                OutlinedButton(
                  onPressed: _isBusy || _resendCooldown > 0
                      ? null
                      : _resendVerificationEmail,
                  child: _isBusy
                      ? const Text('Sending...')
                      : const Text('Resend Verification Email'),
                ),

                const SizedBox(height: 24),

                OutlinedButton(
                  onPressed: _isBusy ? null : _logout,
                  child: _isBusy
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Log Out'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
