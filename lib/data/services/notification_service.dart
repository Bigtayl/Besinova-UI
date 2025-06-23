import 'package:flutter/material.dart';

class NotificationService {
  static final GlobalKey<ScaffoldMessengerState> _messengerKey = GlobalKey<ScaffoldMessengerState>();
  
  static GlobalKey<ScaffoldMessengerState> get messengerKey => _messengerKey;

  static Future<void> initialize() async {
    // No initialization needed
  }

  static Future<void> showWelcomeNotification() async {
    _messengerKey.currentState?.showSnackBar(
      SnackBar(
        content: const Text(
          'Besinova kullanıcıları arasına hoşgeldin!',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: const Color(0xFF52796F),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 8,
      ),
    );
  }

  static Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    _messengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              body,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF52796F),
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 8,
      ),
    );
  }

  static Future<void> cancelAllNotifications() async {
    _messengerKey.currentState?.hideCurrentSnackBar();
  }

  static Future<void> cancelNotification(int id) async {
    // Not applicable for SnackBar
  }

  static Future<void> requestPermission() async {
    // No permission needed for SnackBar
  }
} 