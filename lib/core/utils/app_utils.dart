import 'package:flutter/material.dart';
import 'dart:async';

/// Utility functions for the application
class AppUtils {
  static final RegExp _emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  static const Duration _defaultSnackBarDuration = Duration(seconds: 3);

  /// Show a snackbar with the given message
  static void showSnackBar(BuildContext context, String message,
      {Duration? duration}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration ?? _defaultSnackBarDuration,
      ),
    );
  }

  /// Show a loading dialog
  static void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  /// Hide the current dialog
  static void hideDialog(BuildContext context) => Navigator.of(context).pop();

  /// Format currency
  static String formatCurrency(double amount) =>
      '₺${amount.toStringAsFixed(2)}';

  /// Format date
  static String formatDate(DateTime date) =>
      '${date.day}/${date.month}/${date.year}';

  /// Validate email format
  static bool isValidEmail(String email) => _emailRegex.hasMatch(email);

  /// Validate password strength
  static bool isValidPassword(String password) => password.length >= 6;

  /// Get initials from name
  static String getInitials(String name) {
    final words = name.trim().split(' ');
    if (words.isEmpty) return '';
    if (words.length == 1) return words[0][0].toUpperCase();
    return '${words[0][0]}${words[1][0]}'.toUpperCase();
  }

  /// Debounce function for search
  static Function debounce(Function func, Duration wait) {
    Timer? timer;
    return (List<dynamic> args) {
      timer?.cancel();
      timer = Timer(wait, () => func(args));
    };
  }
}
