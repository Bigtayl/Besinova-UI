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
  final List<String> _avatarOptions = ['🏃‍♂️', '💪', '🦸‍♂️', '🦸‍♀️'];
  String _selectedAvatar = '🏃‍♂️'; // Default avatar
  Map<String, dynamic>? _profileData;

  @override
  void initState() {
    super.initState();
    // Veriler doğrudan UserProvider'dan (Consumer widget'ı ile) alınacağı için
    // SharedPreferences'tan manuel yüklemeye gerek kalmadı.
    // _loadProfileFromAnalytics(); // Bu fonksiyon kaldırıldı.
    // _loadSelectedAvatar(); // Bu da artık UserProvider'dan gelecek.
  }

  Future<void> _saveAvatarToProfile(String avatar) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_avatar', avatar);

    final String? profilesString = prefs.getString('profiles');
    final int? selectedIndex = prefs.getInt('selectedProfileIndex');
    if (profilesString != null && selectedIndex != null) {
      final List profiles = json.decode(profilesString);
      if (profiles.isNotEmpty &&
          selectedIndex >= 0 &&
          selectedIndex < profiles.length) {
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
    // Provider.of<UserProvider>(context, listen: false).loadUserData(); // Removed - causing setState during build
  }

  /// Avatar seçimi için dialog açar ve seçilen avatarı UserProvider'a kaydeder.
  void _chooseAvatar() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentAvatar = userProvider.avatar;

    String? chosen = await showDialog<String>(
      context: context,
      builder: (context) =>
          _AvatarSelectionDialog(currentAvatar: currentAvatar),
    );

    if (chosen != null && chosen != currentAvatar) {
      // Update the provider, which handles saving the new avatar.
      await userProvider.setAvatar(chosen);

      // Also update the separate 'profiles' list used by the analytics screen.
      await _saveAvatarToProfile(chosen);

      // To be absolutely sure the UI updates, force a rebuild of this screen.
      // This ensures the widget rebuilds and the Consumer fetches the new avatar.
      if (mounted) {
        setState(() {
          // This call forces a rebuild, ensuring the new avatar is displayed instantly.
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final user = userProvider.user;
        final userName = user?.name ?? 'Hoş geldin!';
        final userEmail = user?.email ?? '';
        final userHeight = user?.height.toString() ?? '';
        final userWeight = user?.weight.toString() ?? '';
        final userAge = user?.age.toString() ?? '';
        final userGender = user?.gender ?? '';
        final userActivityLevel = user?.activityLevel ?? '';
        final userGoal = user?.goal ?? '';
        final userLoginCount = user?.loginCount.toString() ?? '';
        final userLastLogin = user?.lastLogin ?? '';
        final userCompletedGoals = user?.completedGoals.toString() ?? '';
        final userAvatar =
            userProvider.avatar.isNotEmpty ? userProvider.avatar : '👤';

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
                              userName.toString().isNotEmpty
                                  ? userName.toString()
                                  : 'Hoş geldin!',
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
                            _buildInfoRow('Boy',
                                userHeight.isNotEmpty ? '$userHeight cm' : '-'),
                            _buildInfoRow('Kilo',
                                userWeight.isNotEmpty ? '$userWeight kg' : '-'),
                            _buildInfoRow(
                                'Yaş', userAge.isNotEmpty ? userAge : '-'),
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
                            _buildInfoRow(
                                'Aktivite Seviyesi', userActivityLevel),
                            _buildInfoRow('Hedef', userGoal),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // İstatistikler kartı (örnek veriler)
                        _buildInfoCard(
                          title: 'İstatistikler',
                          icon: Icons.analytics_outlined,
                          children: [
                            _buildInfoRow('Toplam Giriş', userLoginCount),
                            _buildInfoRow(
                                'Son Giriş',
                                userLastLogin.isNotEmpty
                                    ? _formatLastLogin(userLastLogin)
                                    : '-'),
                            _buildInfoRow(
                                'Tamamlanan Hedefler', userCompletedGoals),
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
                              backgroundColor:
                                  Colors.red.withValues(alpha: 0.2),
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
      },
    );
  }

  /// Local sign out fonksiyonu
  Future<void> _signOut() async {
    try {
      // Set session to inactive instead of clearing all data
      await StorageService.setSessionActive(false);

      // Clear user provider data
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.clearUserData();

      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const SignInScreen()),
          (route) => false, // Remove all previous routes
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
        border: Border.all(color: Colors.white.withOpacity(0.22), width: 1),
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
              color: value == '-'
                  ? Colors.white.withOpacity(0.5)
                  : const Color(0xFFFFB86C),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  String _formatLastLogin(String lastLogin) {
    try {
      final DateTime dateTime = DateTime.parse(lastLogin);
      final String formattedDate =
          '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
      final String formattedTime =
          '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
      return '$formattedDate $formattedTime';
    } catch (e) {
      return lastLogin;
    }
  }
}

// Avatar seçim dialog'u için StatefulWidget
class _AvatarSelectionDialog extends StatefulWidget {
  final String currentAvatar;

  const _AvatarSelectionDialog({required this.currentAvatar});

  @override
  State<_AvatarSelectionDialog> createState() => _AvatarSelectionDialogState();
}

class _AvatarSelectionDialogState extends State<_AvatarSelectionDialog> {
  late String selectedAvatar;
  // New, relevant avatar list
  final List<String> _avatarOptions = ['💪', '🏋️', '🏃‍♀️', '🥗', '🍎', '🥦'];

  @override
  void initState() {
    super.initState();
    selectedAvatar = widget.currentAvatar;
  }

  @override
  Widget build(BuildContext context) {
    const Color deepFern = Color(0xFF52796F);

    return AlertDialog(
      backgroundColor: const Color(0xFF2C3E50),
      title: const Text(
        'Avatar Seç',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      content: Wrap(
        alignment: WrapAlignment.center,
        spacing: 12,
        runSpacing: 12,
        children: _avatarOptions.map((avatar) {
          final isSelected = selectedAvatar == avatar;
          return GestureDetector(
            onTap: () {
              // Instantly pop with the selected avatar
              Navigator.of(context).pop(avatar);
            },
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: isSelected ? deepFern : Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? deepFern : Colors.white.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  avatar,
                  style: const TextStyle(
                    fontSize: 32,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
      // Removed actions for instant selection on tap
    );
  }
}
