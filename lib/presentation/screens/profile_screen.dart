// profile_screen.dart
// Kullanıcının profil ekranı. Avatar seçimi, kişisel bilgiler, istatistikler ve çıkış işlemi içerir.
// Kullanıcı avatarı UserProvider ile global olarak yönetilir.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/services/storage_service.dart';
import '../../presentation/providers/user_provider.dart';
import 'signin_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Profil ekranı: Kullanıcı avatarı, adı, emaili, vücut ölçüleri, istatistikler ve çıkış butonu içerir.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Kullanıcıya sunulan hazır avatarlar (emoji)
  final List<String> _avatars = [
    '🍏',
    '🥑',
    '🍉',
    '🍔',
    '👩‍💻',
    '🧑‍🍳',
    '🏃‍♂️',
    '🏋️‍♀️',
    '🦸‍♂️',
    '🦸‍♀️'
  ];
  String _selectedAvatar = '🍏'; // Ekranda geçici olarak tutulan avatar
  Map<String, dynamic>? _profileData;

  @override
  void initState() {
    super.initState();
    _loadProfileFromAnalytics();
  }

  Future<void> _loadProfileFromAnalytics() async {
    final prefs = await SharedPreferences.getInstance();
    final String? profilesString = prefs.getString('profiles');
    final int? selectedIndex = prefs.getInt('selectedProfileIndex');
    if (profilesString != null && selectedIndex != null) {
      final List profiles = json.decode(profilesString);
      if (profiles.isNotEmpty && selectedIndex >= 0 && selectedIndex < profiles.length) {
        setState(() {
          _profileData = Map<String, dynamic>.from(profiles[selectedIndex]);
        });
      }
    }
  }

  Future<void> _saveAvatarToProfile(String avatar) async {
    final prefs = await SharedPreferences.getInstance();
    final String? profilesString = prefs.getString('profiles');
    final int? selectedIndex = prefs.getInt('selectedProfileIndex');
    if (profilesString != null && selectedIndex != null) {
      final List profiles = json.decode(profilesString);
      if (profiles.isNotEmpty && selectedIndex >= 0 && selectedIndex < profiles.length) {
        profiles[selectedIndex]['avatar'] = avatar;
        await prefs.setString('profiles', json.encode(profiles));
        setState(() {
          _profileData = Map<String, dynamic>.from(profiles[selectedIndex]);
        });
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Provider.of<UserProvider>(context, listen: false).loadUserData();
  }

  /// Avatar seçimi için dialog açar ve seçilen avatarı UserProvider'a kaydeder.
  void _chooseAvatar() async {
    String? chosen = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Avatar Seç'),
        content: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _avatars.map((avatar) {
            return GestureDetector(
              onTap: () => Navigator.of(context).pop(avatar),
              child: CircleAvatar(
                radius: 28,
                backgroundColor: avatar == _selectedAvatar
                    ? Colors.green[200]
                    : Colors.grey[200],
                child: Text(
                  avatar,
                  style: const TextStyle(fontSize: 32),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
    if (chosen != null && chosen != _selectedAvatar) {
      setState(() {
        _selectedAvatar = chosen;
      });
      await _saveAvatarToProfile(chosen);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = _profileData;
    final userName = profile?['name'] ?? 'Hoş geldin!';
    final userEmail = profile?['email'] ?? '';
    final userHeight = profile?['height'] ?? '';
    final userWeight = profile?['weight'] ?? '';
    final userAge = profile?['age'] ?? '';
    final userGender = profile?['gender'] ?? '';
    final userActivityLevel = profile?['activityLevel'] ?? '';
    final userGoal = profile?['purpose'] ?? '';
    final userLoginCount = profile?['loginCount'] ?? '';
    final userLastLogin = profile?['lastLogin'] ?? '';
    final userCompletedGoals = profile?['completedGoals'] ?? '';
    final userAvatar = profile?['avatar'] ?? _selectedAvatar;

    return Scaffold(
      backgroundColor: const Color(0xFF2C3E50),
      appBar: AppBar(
        backgroundColor: const Color(0xFF52796F).withValues(alpha: 0.95),
        elevation: 0,
        title: const Text(
          'Profil',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF52796F).withValues(alpha: 0.8),
              const Color(0xFF2C3E50),
            ],
            stops: const [0.0, 0.6],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Dekoratif arka plan daireleri
              Positioned(
                right: -50,
                top: -50,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFA3EBB1).withValues(alpha: 0.1),
                  ),
                ),
              ),
              Positioned(
                left: -30,
                bottom: -30,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF52796F).withValues(alpha: 0.1),
                  ),
                ),
              ),
              // Ana içerik
              SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Avatar ve isim
                    Column(
                      children: [
                        // Avatar seçimi (tıklayınca değiştir)
                        GestureDetector(
                          onTap: _chooseAvatar,
                          child: CircleAvatar(
                            radius: 48,
                            backgroundColor:
                                Colors.white.withValues(alpha: 0.15),
                            child: Text(
                              userAvatar,
                              style: const TextStyle(fontSize: 48),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Kullanıcı adı
                        Text(
                          userName.toString().isNotEmpty ? userName.toString() : 'Hoş geldin!',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Kullanıcı email
                        Text(
                          userEmail.toString(),
                          style: const TextStyle(
                            color: Color(0xFFFFB86C),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Avatarı değiştir butonu
                        TextButton(
                          onPressed: _chooseAvatar,
                          child: const Text('Avatarı Değiştir'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Vücut ölçüleri kartı
                    _buildInfoCard(
                      title: 'Vücut Ölçüleri',
                      icon: Icons.monitor_weight_outlined,
                      children: [
                        _buildInfoRow(
                            'Boy', userHeight.toString().isNotEmpty ? '${userHeight.toString()} cm' : '-'),
                        _buildInfoRow(
                            'Kilo', userWeight.toString().isNotEmpty ? '${userWeight.toString()} kg' : '-'),
                        _buildInfoRow(
                            'Yaş', userAge.toString().isNotEmpty ? userAge.toString() : '-'),
                        _buildInfoRow('Cinsiyet', userGender.toString().isNotEmpty ? userGender.toString() : '-'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Aktivite ve hedef kartı
                    _buildInfoCard(
                      title: 'Aktivite ve Hedef',
                      icon: Icons.fitness_center,
                      children: [
                        _buildInfoRow('Aktivite Seviyesi', userActivityLevel.toString()),
                        _buildInfoRow('Hedef', userGoal.toString()),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // İstatistikler kartı (örnek veriler)
                    _buildInfoCard(
                      title: 'İstatistikler',
                      icon: Icons.analytics_outlined,
                      children: [
                        _buildInfoRow(
                            'Toplam Giriş', userLoginCount.toString()),
                        _buildInfoRow('Son Giriş',
                            userLastLogin.toString().isNotEmpty ? userLastLogin.toString() : '-'),
                        _buildInfoRow('Tamamlanan Hedefler',
                            userCompletedGoals.toString()),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Çıkış butonu
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: ElevatedButton(
                        onPressed: _signOut,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.withValues(alpha: 0.2),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: Colors.red.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                        ),
                        child: const Text(
                          'Çıkış Yap',
                          style: TextStyle(
                            color: Color(0xFFFFB86C),
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Local sign out fonksiyonu
  Future<void> _signOut() async {
    try {
      // Clear user data from storage
      await StorageService.clearAll();

      // Clear user provider data
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.clearUserData();

      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const SignInScreen()),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Çıkış yapılırken bir hata oluştu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Bilgi kartı oluşturan yardımcı fonksiyon (ör: vücut ölçüleri, istatistikler)
  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.13),
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: Colors.white.withOpacity(0.22), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: const Color(0xFFFFB86C), size: 24),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFFFFB86C),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  /// Bilgi satırı oluşturan yardımcı fonksiyon (ör: 'Boy: 170 cm')
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: value == '-' ? Colors.white.withOpacity(0.5) : const Color(0xFFFFB86C),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
