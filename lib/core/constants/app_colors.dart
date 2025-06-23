import 'package:flutter/material.dart';

class AppColors {
  static const Color tropicalLime = Color(0xFFA3EBB1);
  static const Color deepFern = Color(0xFF52796F);
  static const Color midnightBlue = Color(0xFF2C3E50);
  static const Color whiteSmoke = Color(0xFFF5F5F5);
  static const Color oliveShadow = Color(0xFF6B705C);

  static const List<Color> splashGradient = [
    tropicalLime,
    deepFern,
    midnightBlue,
  ];

  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  static const Color primaryText = midnightBlue;
  static const Color secondaryText = oliveShadow;
  static const Color lightText = whiteSmoke;

  static const Color primaryBackground = whiteSmoke;
  static const Color secondaryBackground = Colors.white;
  static const Color darkBackground = midnightBlue;

  static const Color cardBackground = whiteSmoke;
  static const Color darkCardBackground = Color(0xCC2C3E50);

  static const Color inputBackground = Colors.white;
  static const Color darkInputBackground = Color(0xCC2C3E50);
}
