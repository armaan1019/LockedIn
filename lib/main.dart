import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'features/social/services/session_manager.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => SessionManager(), 
      child: const MyApp()),
  );
}
