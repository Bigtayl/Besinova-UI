// theme_provider.dart
// Uygulamanın tema (dark/light mode) yönetimini sağlayan Provider sınıfı.
// Kullanıcı tema değiştirince tüm uygulama otomatik güncellenir.

import 'package:flutter/material.dart';

/// Tema yönetimi sağlayan Provider. Kullanıcı dark/light mode arasında geçiş yapabilir.
class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light; // Varsayılan tema: açık

  ThemeMode get themeMode => _themeMode;

  /// Şu an dark mode mu?
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  /// Temayı değiştirir ve dinleyicilere bildirir.
  void toggleTheme(bool isOn) {
    _themeMode = isOn ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}
