// splash_screen.dart
// Uygulama açılırken gösterilen animasyonlu yükleme (splash) ekranı.
// Lottie animasyonu ve zamanlayıcı ile AuthGate'e geçiş içerir.

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'dart:async';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';

/// Splash screen shown during app startup
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(AppConstants.splashDuration, () {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/auth');
      }
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: AppColors.splashGradient,
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Center(
            // Lottie animasyonu (JSON dosyası ile)
            child: Lottie.asset(
              'assets/ayca.json',
              width: AppSizes.splashAnimationSize,
              height: AppSizes.splashAnimationSize,
              fit: BoxFit.contain,
              repeat: true,
            ),
          ),
        ),
      );
}
