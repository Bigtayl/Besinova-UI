// profile_screen.dart
// Kullanıcının profil ekranı. Avatar seçimi, kişisel bilgiler, istatistikler ve çıkış işlemi içerir.
// Kullanıcı avatarı UserProvider ile global olarak yönetilir.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../user_provider.dart';

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

  @override
  void initState() {
    super.initState();
    // Uygulama açıldığında UserProvider'dan avatarı çek
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        setState(() {
          _selectedAvatar = userProvider.avatar;
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (context.mounted) {
      Provider.of<UserProvider>(context, listen: false).loadUserData();
    }
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
      if (context.mounted) {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        userProvider.setAvatar(chosen);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final userName = userProvider.name;
    final userEmail = userProvider.email;
    final userHeight = userProvider.height;
    final userWeight = userProvider.weight;
    final userAge = userProvider.age;
    final userGender = userProvider.gender;
    final userActivityLevel = userProvider.activityLevel;
    final userGoal = userProvider.goal;
    final userLoginCount = userProvider.loginCount;
    final userLastLogin = userProvider.lastLogin;
    final userCompletedGoals = userProvider.completedGoals;

    return Scaffold(
      backgroundColor: const Color(0xFF2C3E50),
      appBar: AppBar(
        backgroundColor: const Color(0xFF52796F).withValues(alpha: 0.95),
        elevation: 0,
        title: const Text(
          'Profilim',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
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
                            backgroundColor: Colors.white.withValues(alpha: 0.15),
                            child: Text(
                              Provider.of<UserProvider>(context).avatar,
                              style: const TextStyle(fontSize: 48),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Kullanıcı adı
                        Text(
                          userName.isNotEmpty ? userName : 'Hoş geldin!',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Kullanıcı email
                        Text(
                          userEmail,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 16,
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
                            'Boy',
                            userHeight > 0
                                ? '${userHeight.toStringAsFixed(1)} cm'
                                : '-'),
                        _buildInfoRow(
                            'Kilo',
                            userWeight > 0
                                ? '${userWeight.toStringAsFixed(1)} kg'
                                : '-'),
                        _buildInfoRow(
                            'Yaş', userAge > 0 ? userAge.toString() : '-'),
                        _buildInfoRow('Cinsiyet',
                            userGender.isNotEmpty ? userGender : '-'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Aktivite ve hedef kartı
                    _buildInfoCard(
                      title: 'Aktivite ve Hedef',
                      icon: Icons.fitness_center,
                      children: [
                        _buildInfoRow('Aktivite Seviyesi', userActivityLevel),
                        _buildInfoRow('Hedef', userGoal),
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
                            userLastLogin.isNotEmpty ? userLastLogin : '-'),
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
                        onPressed: () {
                          // TODO: Çıkış işlemi
                        },
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
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
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

  /// Bilgi kartı oluşturan yardımcı fonksiyon (ör: vücut ölçüleri, istatistikler)
  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
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
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 16,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
