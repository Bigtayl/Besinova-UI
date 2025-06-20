// splash_screen.dart
// Uygulama açılırken gösterilen animasyonlu yükleme (splash) ekranı.
// Lottie animasyonu ve zamanlayıcı ile ana sayfaya geçiş içerir.

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'dart:async';

/// SplashScreen: Açılışta animasyon gösterir ve 4 saniye sonra ana sayfaya yönlendirir.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // 4 saniye sonra direkt HomeScreen'e geçiş (sign in sürecini atla)
    Timer(const Duration(seconds: 4), () {
      Navigator.of(context).pushReplacementNamed('/auth');
    });
  }

  @override
  Widget build(BuildContext context) {
    // Tema renkleri
    const Color tropicalLime = Color(0xFFA3EBB1);
    const Color deepFern = Color(0xFF52796F);
    const Color midnightBlue = Color(0xFF2C3E50);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [tropicalLime, deepFern, midnightBlue],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          // Lottie animasyonu (JSON dosyası ile)
          child: Lottie.asset(
            'assets/ayca.json',
            width: 180,
            height: 180,
            fit: BoxFit.contain,
            repeat: true,
          ),
        ),
      ),
    );
  }
}
