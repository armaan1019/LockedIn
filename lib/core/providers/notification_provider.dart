import 'package:flutter/material.dart';

class NotificationProvider extends ChangeNotifier {
  bool notificationsEnabled = true;

  void toggleNotifications(bool enabled) {
    notificationsEnabled = enabled;
    notifyListeners();
  }
}
