// main.dart
// Uygulamanın giriş noktası. Provider ile tema ve kullanıcı yönetimi sağlar.
// MaterialApp ile uygulamanın genel temasını ve rotalarını ayarlar.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/providers/user_provider.dart';
import 'presentation/providers/optimization_provider.dart';
import 'presentation/screens/splash_screen.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/auth_gate.dart';
import 'presentation/screens/signin_screen.dart';
import 'presentation/screens/signup_screen.dart';
import 'presentation/screens/optimization_test_screen.dart';
import 'presentation/screens/settings_screen.dart';
import 'presentation/screens/shopping_list_screen.dart';
import 'data/services/optimization_service.dart';
import 'data/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize optimization service with gender mapping fix
  await OptimizationService.initialize();

  runApp(const BesinovaApp());
}

/// Main application widget
class BesinovaApp extends StatelessWidget {
  const BesinovaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => OptimizationProvider()),
      ],
      child: const _BesinovaAppContent(),
    );
  }
}

/// Application content widget
class _BesinovaAppContent extends StatelessWidget {
  const _BesinovaAppContent();

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      scaffoldMessengerKey: NotificationService.messengerKey,
      home: const SplashScreen(),
      routes: {
        '/home': (context) => const HomeScreen(),
        '/auth': (context) => const AuthGate(),
        '/signin': (context) => const SignInScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/test': (context) => const OptimizationTestScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/shopping-list': (context) => const ShoppingListScreen(),
      },
    );
  }
}

// Basit çeviri fonksiyonu (ileride gerçek localization ile değiştirilebilir)
String t(String key) {
  // Placeholder for localization. In the future, use Intl or similar.
  return key;
}
