// settings_screen.dart
// Uygulamanın ayarlar ekranı. Tema seçimi, isim girişi, aylık bütçe gibi kullanıcı ayarlarını yönetir.
// Bütçe ayarı için slider, isim için textfield ve tema için switch kullanılır.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart';
import '../user_provider.dart';

/// Ayarlar ekranı: Tema seçimi, isim girişi, aylık bütçe ayarı ve hata mesajı içerir.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final nameController = TextEditingController(); // İsim girişi için controller
  double _budget = 17002; // Aylık bütçe (varsayılan: asgari ücret)
  String? _errorText; // Hata mesajı

  @override
  void initState() {
    super.initState();
    // İleride burada local storage'dan ayarları yükleyebilirsin
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  /// Hata mesajı gösterir ve 3 saniye sonra otomatik gizler.
  void _showError(String message) {
    setState(() {
      _errorText = message;
    });

    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        _errorText = null;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    // Tema renkleri
    const Color tropicalLime = Color(0xFFA3EBB1);
    const Color deepFern = Color(0xFF52796F);
    const Color midnightBlue = Color(0xFF2C3E50);
    const Color whiteSmoke = Color(0xFFF5F5F5);
    const Color oliveShadow = Color(0xFF6B705C);

    return Scaffold(
      backgroundColor: midnightBlue,
      appBar: AppBar(
        backgroundColor: deepFern.withOpacity(0.95),
        elevation: 0,
        centerTitle: true,
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [tropicalLime, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: const Text(
            'Ayarlar',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 28,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [tropicalLime, deepFern, midnightBlue],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.15),
                borderRadius: BorderRadius.circular(36),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.10),
                    blurRadius: 20,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tema (karanlık mod) seçimi
                  SwitchListTile(
                    title: const Text(
                      "Karanlık Mod",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    secondary: const Icon(Icons.dark_mode, color: deepFern),
                    value: themeProvider.isDarkMode,
                    onChanged: (value) => themeProvider.toggleTheme(value),
                    activeColor: deepFern,
                  ),
                  const SizedBox(height: 24),
                  // İsim girişi
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'İsmin',
                      labelStyle: const TextStyle(color: Colors.white),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.black.withOpacity(0.10),
                    ),
                    style: const TextStyle(color: Colors.white),
                    onChanged: (value) {
                      userProvider.setName(value);
                    },
                  ),
                  const SizedBox(height: 16),
                  // Aylık bütçe ayarı
                  _buildBudgetSetting(),
                  if (_errorText != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        _errorText!,
                        style: const TextStyle(color: Colors.red, fontSize: 14),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Aylık bütçe ayarı için slider ve göstergeyi içeren widget.
  Widget _buildBudgetSetting() {
    final double safeBudget = _budget.clamp(17002, 100000);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.20),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.25), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_outlined,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Aylık Bütçe',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '₺${safeBudget.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: const Text(
                  'Asgari Ücret',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Bütçe slider'ı
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: const Color(0xFF50FA7B),
              inactiveTrackColor: Colors.black.withOpacity(0.25),
              thumbColor: const Color(0xFF50FA7B),
              overlayColor: const Color(0xFF50FA7B).withOpacity(0.2),
              valueIndicatorColor: const Color(0xFF50FA7B),
              valueIndicatorTextStyle: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            child: Slider(
              value: safeBudget,
              min: 17002,
              max: 100000,
              divisions: 830,
              label: '₺${safeBudget.toStringAsFixed(0)}',
              onChanged: (value) {
                setState(() {
                  _budget = value;
                });
                _saveSettings();
              },
            ),
          ),
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '₺17.002',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
              Text(
                '₺100.000',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Ayarları kaydetmek için fonksiyon (şu an boş, ileride geliştirilebilir)
  void _saveSettings() {
    // Implementation of _saveSettings method
  }
}
