// settings_screen.dart
// Uygulama ayarları ekranı: Modern ve tematik tasarım

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../presentation/presentation.dart';
import 'signin_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _budgetController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _activityLevelController =
      TextEditingController();
  final TextEditingController _goalController = TextEditingController();
  final TextEditingController _allergiesController = TextEditingController();
  final TextEditingController _preferencesController = TextEditingController();
  final TextEditingController _restrictionsController = TextEditingController();
  final TextEditingController _supplementsController = TextEditingController();
  final TextEditingController _medicationsController = TextEditingController();
  final TextEditingController _conditionsController = TextEditingController();
  final TextEditingController _familyHistoryController =
      TextEditingController();
  final TextEditingController _lifestyleController = TextEditingController();
  final TextEditingController _stressLevelController = TextEditingController();
  final TextEditingController _sleepQualityController = TextEditingController();
  final TextEditingController _waterIntakeController = TextEditingController();
  final TextEditingController _exerciseFrequencyController =
      TextEditingController();
  final TextEditingController _exerciseDurationController =
      TextEditingController();
  final TextEditingController _exerciseTypeController = TextEditingController();
  final TextEditingController _smokingController = TextEditingController();
  final TextEditingController _alcoholController = TextEditingController();
  final TextEditingController _caffeineController = TextEditingController();
  final TextEditingController _sugarController = TextEditingController();
  final TextEditingController _saltController = TextEditingController();
  final TextEditingController _fiberController = TextEditingController();
  final TextEditingController _proteinController = TextEditingController();
  final TextEditingController _carbsController = TextEditingController();
  final TextEditingController _fatController = TextEditingController();
  final TextEditingController _caloriesController = TextEditingController();
  final TextEditingController _vitaminAController = TextEditingController();
  final TextEditingController _vitaminBController = TextEditingController();
  final TextEditingController _vitaminCController = TextEditingController();
  final TextEditingController _vitaminDController = TextEditingController();
  final TextEditingController _vitaminEController = TextEditingController();
  final TextEditingController _vitaminKController = TextEditingController();
  final TextEditingController _calciumController = TextEditingController();
  final TextEditingController _ironController = TextEditingController();
  final TextEditingController _magnesiumController = TextEditingController();
  final TextEditingController _zincController = TextEditingController();
  final TextEditingController _seleniumController = TextEditingController();
  final TextEditingController _copperController = TextEditingController();
  final TextEditingController _manganeseController = TextEditingController();
  final TextEditingController _chromiumController = TextEditingController();
  final TextEditingController _molybdenumController = TextEditingController();
  final TextEditingController _iodineController = TextEditingController();
  final TextEditingController _fluorideController = TextEditingController();
  final TextEditingController _phosphorusController = TextEditingController();
  final TextEditingController _potassiumController = TextEditingController();
  final TextEditingController _sulfurController = TextEditingController();
  final TextEditingController _chlorideController = TextEditingController();
  final TextEditingController _bicarbonateController = TextEditingController();
  final TextEditingController _boronController = TextEditingController();
  final TextEditingController _vanadiumController = TextEditingController();
  final TextEditingController _nickelController = TextEditingController();
  final TextEditingController _siliconController = TextEditingController();
  final TextEditingController _arsenicController = TextEditingController();
  final TextEditingController _cadmiumController = TextEditingController();
  final TextEditingController _leadController = TextEditingController();
  final TextEditingController _mercuryController = TextEditingController();
  final TextEditingController _aluminumController = TextEditingController();
  final TextEditingController _bariumController = TextEditingController();
  final TextEditingController _berylliumController = TextEditingController();
  final TextEditingController _bismuthController = TextEditingController();
  final TextEditingController _cobaltController = TextEditingController();
  final TextEditingController _galliumController = TextEditingController();
  final TextEditingController _germaniumController = TextEditingController();
  final TextEditingController _goldController = TextEditingController();
  final TextEditingController _indiumController = TextEditingController();
  final TextEditingController _lithiumController = TextEditingController();
  final TextEditingController _niobiumController = TextEditingController();
  final TextEditingController _osmiumController = TextEditingController();
  final TextEditingController _palladiumController = TextEditingController();
  final TextEditingController _platinumController = TextEditingController();
  final TextEditingController _rheniumController = TextEditingController();
  final TextEditingController _rhodiumController = TextEditingController();
  final TextEditingController _rutheniumController = TextEditingController();
  final TextEditingController _scandiumController = TextEditingController();
  final TextEditingController _strontiumController = TextEditingController();
  final TextEditingController _tantalumController = TextEditingController();
  final TextEditingController _telluriumController = TextEditingController();
  final TextEditingController _thalliumController = TextEditingController();
  final TextEditingController _titaniumController = TextEditingController();
  final TextEditingController _tungstenController = TextEditingController();
  final TextEditingController _vanadium2Controller = TextEditingController();
  final TextEditingController _ytterbiumController = TextEditingController();
  final TextEditingController _yttriumController = TextEditingController();
  final TextEditingController _zirconiumController = TextEditingController();
  final TextEditingController _lanthanumController = TextEditingController();
  final TextEditingController _ceriumController = TextEditingController();
  final TextEditingController _praseodymiumController = TextEditingController();
  final TextEditingController _neodymiumController = TextEditingController();
  final TextEditingController _promethiumController = TextEditingController();
  final TextEditingController _samariumController = TextEditingController();
  final TextEditingController _europiumController = TextEditingController();
  final TextEditingController _gadoliniumController = TextEditingController();
  final TextEditingController _terbiumController = TextEditingController();
  final TextEditingController _dysprosiumController = TextEditingController();
  final TextEditingController _holmiumController = TextEditingController();
  final TextEditingController _erbiumController = TextEditingController();
  final TextEditingController _thuliumController = TextEditingController();
  final TextEditingController _lutetiumController = TextEditingController();
  final TextEditingController _actiniumController = TextEditingController();
  final TextEditingController _thoriumController = TextEditingController();
  final TextEditingController _protactiniumController = TextEditingController();
  final TextEditingController _uraniumController = TextEditingController();
  final TextEditingController _neptuniumController = TextEditingController();
  final TextEditingController _plutoniumController = TextEditingController();
  final TextEditingController _americiumController = TextEditingController();
  final TextEditingController _curiumController = TextEditingController();
  final TextEditingController _berkeliumController = TextEditingController();
  final TextEditingController _californiumController = TextEditingController();
  final TextEditingController _einsteiniumController = TextEditingController();
  final TextEditingController _fermiumController = TextEditingController();
  final TextEditingController _mendeleviumController = TextEditingController();
  final TextEditingController _nobeliumController = TextEditingController();
  final TextEditingController _lawrenciumController = TextEditingController();
  final TextEditingController _rutherfordiumController =
      TextEditingController();
  final TextEditingController _dubniumController = TextEditingController();
  final TextEditingController _seaborgiumController = TextEditingController();
  final TextEditingController _bohriumController = TextEditingController();
  final TextEditingController _hassiumController = TextEditingController();
  final TextEditingController _meitneriumController = TextEditingController();
  final TextEditingController _darmstadtiumController = TextEditingController();
  final TextEditingController _roentgeniumController = TextEditingController();
  final TextEditingController _coperniciumController = TextEditingController();
  final TextEditingController _nihoniumController = TextEditingController();
  final TextEditingController _fleroviumController = TextEditingController();
  final TextEditingController _moscoviumController = TextEditingController();
  final TextEditingController _livermoriumController = TextEditingController();
  final TextEditingController _tennessineController = TextEditingController();
  final TextEditingController _oganessonController = TextEditingController();
  bool _isDarkMode = false;
  bool _notificationsEnabled = true;
  String _selectedLanguage = 'Türkçe';

  // Tema renkleri
  static const Color midnightBlue = Color(0xFF2C3E50);
  static const Color settingsColor = Color(0xFFBD93F9);
  static const Color tropicalLime = Color(0xFFA3EBB1);

  @override
  void initState() {
    super.initState();
    _fixLegacyBudget();
  }

  Future<void> _fixLegacyBudget() async {
    final prefs = await SharedPreferences.getInstance();
    final double? oldBudget = prefs.getDouble('budget');
    if (oldBudget != null && oldBudget == 5000.0) {
      await prefs.setDouble('budget', 0.0);
      if (mounted) setState(() {});
    }
  }

  Future<void> _editProfile() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final TextEditingController nameController =
        TextEditingController(text: userProvider.name);
    final TextEditingController emailController =
        TextEditingController(text: userProvider.email);
    final TextEditingController ageController =
        TextEditingController(text: userProvider.age.toString());
    String selectedGender = userProvider.gender;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: midnightBlue,
        title: const Text(
          'Profili Düzenle',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('Ad Soyad', Icons.person),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: emailController,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('E-posta', Icons.email),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: ageController,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('Yaş', Icons.cake),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                  border:
                      Border.all(color: Colors.white.withValues(alpha: 0.18)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedGender,
                    isExpanded: true,
                    dropdownColor: midnightBlue,
                    style: const TextStyle(color: Colors.white),
                    items: ['Erkek', 'Kadın']
                        .map((e) => DropdownMenuItem(
                              value: e,
                              child: Text(e),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        selectedGender = value;
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: settingsColor,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('name', nameController.text);
              await prefs.setString('email', emailController.text);
              await prefs.setInt('age', int.tryParse(ageController.text) ?? 0);
              await prefs.setString('gender', selectedGender);
              if (context.mounted) {
                await userProvider.loadUserData();
                Navigator.pop(context);
              }
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SignInScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    debugResetBudget(); // DEBUG: her build'de bütçeyi sıfırla
    final userProvider = Provider.of<UserProvider>(context);

    // Tema renkleri
    final Color settingsLight = settingsColor.withValues(alpha: 0.15);
    final Color settingsDark = settingsColor.withValues(alpha: 0.8);

    return Scaffold(
      backgroundColor: midnightBlue,
      appBar: AppBar(
        backgroundColor: settingsColor.withValues(alpha: 0.95),
        elevation: 0,
        centerTitle: true,
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Colors.white, settingsColor],
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
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [settingsColor.withValues(alpha: 0.8), midnightBlue],
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
                    color: settingsLight,
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
                    color: settingsLight,
                  ),
                ),
              ),
              // Ana içerik
              AnimationLimiter(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profil Bilgileri Kartı
                      AnimationConfiguration.staggeredList(
                        position: 0,
                        duration: const Duration(milliseconds: 375),
                        child: SlideAnimation(
                          verticalOffset: 50.0,
                          child: FadeInAnimation(
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [settingsColor, settingsDark],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: settingsColor.withValues(alpha: 0.3),
                                    blurRadius: 15,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 30,
                                        backgroundColor:
                                            Colors.white.withValues(alpha: 0.2),
                                        child: const Icon(Icons.person,
                                            color: Colors.white, size: 30),
                                      ),
                                      const SizedBox(width: 15),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              userProvider.name,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 5),
                                            Text(
                                              userProvider.email,
                                              style: TextStyle(
                                                color: Colors.white
                                                    .withValues(alpha: 0.8),
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.edit,
                                            color: Colors.white),
                                        onPressed: _editProfile,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  _buildInfoRow('Yaş', '${userProvider.age}'),
                                  const SizedBox(height: 10),
                                  _buildInfoRow(
                                      'Cinsiyet', userProvider.gender),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Ayarlar Listesi
                      AnimationConfiguration.staggeredList(
                        position: 1,
                        duration: const Duration(milliseconds: 375),
                        child: SlideAnimation(
                          verticalOffset: 50.0,
                          child: FadeInAnimation(
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: settingsColor.withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                children: [
                                  _buildSettingItem(
                                    'Bildirimler',
                                    Icons.notifications_outlined,
                                    _notificationsEnabled,
                                    (value) {
                                      setState(() {
                                        _notificationsEnabled = value;
                                      });
                                    },
                                  ),
                                  const Divider(color: Colors.white24),
                                  _buildSettingItem(
                                    'Karanlık Mod',
                                    Icons.dark_mode_outlined,
                                    _isDarkMode,
                                    (value) {
                                      setState(() {
                                        _isDarkMode = value;
                                      });
                                    },
                                  ),
                                  const Divider(color: Colors.white24),
                                  _buildLanguageSelector(),
                                  const Divider(color: Colors.white24),
                                  _buildBudgetSetting(),
                                  const Divider(color: Colors.white24),
                                  _buildSettingItem(
                                    'Hakkında',
                                    Icons.info_outline,
                                    null,
                                    (value) {
                                      // Hakkında sayfası
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Çıkış Yap Butonu
                      AnimationConfiguration.staggeredList(
                        position: 2,
                        duration: const Duration(milliseconds: 375),
                        child: SlideAnimation(
                          verticalOffset: 50.0,
                          child: FadeInAnimation(
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Colors.red.withValues(alpha: 0.8),
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 15),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                onPressed: _logout,
                                child: const Text(
                                  'Çıkış Yap',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 16,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingItem(
    String title,
    IconData icon,
    bool? value,
    Function(dynamic) onChanged,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Colors.white70),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
      trailing: value != null
          ? Switch(
              value: value,
              onChanged: onChanged,
              activeColor: settingsColor,
            )
          : const Icon(Icons.chevron_right, color: Colors.white70),
      onTap: value == null ? () => onChanged(null) : null,
    );
  }

  Widget _buildLanguageSelector() {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.language_outlined, color: Colors.white70),
      title: const Text(
        'Dil',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
      trailing: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedLanguage,
          dropdownColor: midnightBlue,
          style: const TextStyle(color: Colors.white),
          items: ['Türkçe', 'English']
              .map((e) => DropdownMenuItem(
                    value: e,
                    child: Text(e),
                  ))
              .toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedLanguage = value;
              });
            }
          },
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      prefixIcon: Icon(icon, color: Colors.white70),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.08),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.18)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: settingsColor),
      ),
    );
  }

  Widget _buildBudgetSetting() {
    final userProvider = Provider.of<UserProvider>(context);
    final currentBudget = userProvider.budget;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.account_balance_wallet_outlined,
          color: Colors.white70),
      title: const Text(
        'Aylık Bütçe',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        currentBudget > 0
            ? 'Bütçeniz: ₺${currentBudget.toStringAsFixed(0)}'
            : 'Bütçe belirlenmedi',
        style: TextStyle(
          color: currentBudget > 0 ? settingsColor : Colors.white60,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.white70),
      onTap: () => _showBudgetDialog(),
    );
  }

  void _showBudgetDialog() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    double selectedBudget =
        userProvider.budget > 0 ? userProvider.budget : 5000.0;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: midnightBlue,
          title: const Text(
            'Aylık Bütçe Belirle',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Besin önerilerin bu bütçeye göre optimize edilecek',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              // Bütçe değeri gösterimi
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: settingsColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: settingsColor.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.account_balance_wallet,
                      color: settingsColor,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '₺${selectedBudget.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Slider
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '₺1.000',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '₺50.000',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: settingsColor,
                      inactiveTrackColor: Colors.white.withValues(alpha: 0.2),
                      thumbColor: settingsColor,
                      overlayColor: settingsColor.withValues(alpha: 0.2),
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 12,
                        elevation: 4,
                      ),
                      overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 20,
                      ),
                      trackHeight: 6,
                    ),
                    child: Slider(
                      value: selectedBudget,
                      min: 1000.0,
                      max: 50000.0,
                      divisions:
                          490, // 50000-1000 = 49000, 49000/100 = 490 divisions
                      onChanged: (value) {
                        setState(() {
                          selectedBudget = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Hızlı seçim butonları - Güncellenmiş fiyatlar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildQuickBudgetButton('₺5.000', 5000.0, selectedBudget,
                      (value) {
                    setState(() {
                      selectedBudget = value;
                    });
                  }),
                  _buildQuickBudgetButton('₺10.000', 10000.0, selectedBudget,
                      (value) {
                    setState(() {
                      selectedBudget = value;
                    });
                  }),
                  _buildQuickBudgetButton('₺20.000', 20000.0, selectedBudget,
                      (value) {
                    setState(() {
                      selectedBudget = value;
                    });
                  }),
                ],
              ),
              const SizedBox(height: 12),
              // İkinci satır hızlı seçim butonları
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildQuickBudgetButton('₺17.000', 17000.0, selectedBudget,
                      (value) {
                    setState(() {
                      selectedBudget = value;
                    });
                  }),
                  _buildQuickBudgetButton('₺25.000', 25000.0, selectedBudget,
                      (value) {
                    setState(() {
                      selectedBudget = value;
                    });
                  }),
                  _buildQuickBudgetButton('₺35.000', 35000.0, selectedBudget,
                      (value) {
                    setState(() {
                      selectedBudget = value;
                    });
                  }),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'İptal',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: settingsColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () async {
                await userProvider.setBudget(selectedBudget);
                if (mounted) setState(() {}); // Ekranı güncelle
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'Bütçe ₺${selectedBudget.toStringAsFixed(0)} olarak ayarlandı'),
                    backgroundColor: settingsColor,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
              },
              child: const Text('Kaydet'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickBudgetButton(String label, double value,
      double selectedValue, Function(double) onTap) {
    final isSelected = (selectedValue - value).abs() < 50; // 50 TL tolerans

    return GestureDetector(
      onTap: () => onTap(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color:
              isSelected ? settingsColor : Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? settingsColor
                : Colors.white.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Future<void> debugResetBudget() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('budget', 0.0);
    // print('Bütçe sıfırlandı!');
  }
}
