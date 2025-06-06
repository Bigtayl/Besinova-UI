// analytics_screen.dart
// Kullanıcının vücut analizlerini (BMI, BMR, TDEE) hesaplayan ve öneriler sunan ekran.
// Profil yönetimi, aktivite seviyesi, amaç seçimi ve sonuç kartları içerir.

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../user_provider.dart';

/// Analiz ekranı: Kullanıcı profilleri, vücut ölçüleri, aktivite seviyesi, amaç ve sonuçlar.
class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  // Kullanıcıdan alınan bilgiler için controller'lar
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  String _gender = 'Erkek';
  final List<String> _genderOptions = ['Erkek', 'Kadın'];

  // Aktivite seviyesi ve çarpanları
  String _activityLevel = 'Hareketsiz';
  final Map<String, double> _activityMultipliers = {
    'Hareketsiz': 1.2, // Hareketsiz yaşam (oturarak çalışma)
    'Az Aktif': 1.375, // Haftada 1-3 gün hafif egzersiz
    'Orta Aktif': 1.55, // Haftada 3-5 gün orta şiddette egzersiz
    'Çok Aktif': 1.725, // Haftada 6-7 gün yoğun egzersiz
    'Ekstra Aktif': 1.9, // Günlük yoğun egzersiz veya fiziksel iş
  };

  List<Map<String, dynamic>> _profiles = []; // Kayıtlı profiller
  int _selectedIndex = -1; // Seçili profil indexi
  double? _bmi; // Vücut kitle indeksi
  double? _bmr; // Bazal metabolizma hızı
  double? _tdee; // Günlük toplam enerji harcaması
  String _recommendation = ''; // Kullanıcıya öneri

  String _purpose = 'Kilo vermek için';
  final List<String> _purposeOptions = [
    'Kilo vermek için',
    'Kilo almak için',
    'Sadece alışveriş önerisi için',
    'Sporcu için besin önerisi',
  ];

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  /// SharedPreferences ile profilleri yükler.
  Future<void> _loadProfiles() async {
    final prefs = await SharedPreferences.getInstance();
    final String? profilesString = prefs.getString('profiles');
    final int? lastIndex = prefs.getInt('selectedProfileIndex');
    if (profilesString != null) {
      setState(() {
        _profiles =
            List<Map<String, dynamic>>.from(json.decode(profilesString));
        if (lastIndex != null &&
            lastIndex >= 0 &&
            lastIndex < _profiles.length) {
          _selectedIndex = lastIndex;
          _syncUserProviderWithProfile(_selectedIndex);
        }
      });
    }
  }

  /// Profilleri SharedPreferences ile kaydeder.
  Future<void> _saveProfiles() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profiles', json.encode(_profiles));
  }

  void _syncUserProviderWithProfile(int index) {
    if (index >= 0 && index < _profiles.length) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final p = _profiles[index];
      userProvider.saveUserData(
        name: p['name'] ?? '',
        height: p['height'] != null && p['height'].toString().isNotEmpty
            ? double.tryParse(p['height'].toString())
            : userProvider.height,
        weight: p['weight'] != null && p['weight'].toString().isNotEmpty
            ? double.tryParse(p['weight'].toString())
            : userProvider.weight,
        age: p['age'] != null && p['age'].toString().isNotEmpty
            ? int.tryParse(p['age'].toString())
            : userProvider.age,
        gender: p['gender'] ?? userProvider.gender,
        activityLevel: p['activityLevel'] ?? userProvider.activityLevel,
        goal: p['purpose'] ?? userProvider.goal,
      );
    }
  }

  /// Yeni profil ekler.
  void _addProfile(String name) {
    setState(() {
      _profiles.add({
        'name': name,
        'height': '',
        'weight': '',
        'age': '',
        'gender': _gender,
        'activityLevel': _activityLevel,
        'purpose': _purpose,
      });
      _selectedIndex = _profiles.length - 1;
      _heightController.text = '';
      _weightController.text = '';
      _ageController.text = '';
      _bmi = null;
      _bmr = null;
      _tdee = null;
      _recommendation = '';
    });
    _saveProfiles();
    _saveSelectedProfileIndex(_selectedIndex);
    _syncUserProviderWithProfile(_selectedIndex);
  }

  /// Seçili profili yükler ve ekrana yazar.
  void _selectProfile(int index) {
    setState(() {
      _selectedIndex = index;
      _heightController.text = _profiles[index]['height'];
      _weightController.text = _profiles[index]['weight'];
      _ageController.text = _profiles[index]['age'] ?? '';
      _gender = _profiles[index]['gender'] ?? _genderOptions[0];
      _activityLevel = _profiles[index]['activityLevel'] ?? 'Hareketsiz';
      _purpose = _profiles[index]['purpose'] ?? _purposeOptions[0];
      _bmi = null;
      _bmr = null;
      _tdee = null;
      _recommendation = '';
    });
    _saveSelectedProfileIndex(index);
    _syncUserProviderWithProfile(index);
  }

  /// Profil silme işlemi (onaylı)
  void _deleteProfile() {
    if (_selectedIndex >= 0) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Profili Sil'),
          content: Text(
            '${_profiles[_selectedIndex]['name']} profilini silmek istiyor musun?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _profiles.removeAt(_selectedIndex);
                  if (_profiles.isEmpty) {
                    _selectedIndex = -1;
                  } else {
                    _selectedIndex = 0;
                  }
                  _heightController.clear();
                  _weightController.clear();
                  _ageController.text = '';
                  _bmi = null;
                  _bmr = null;
                  _tdee = null;
                  _recommendation = '';
                });
                _saveProfiles();
                _saveSelectedProfileIndex(_selectedIndex);
                if (_selectedIndex >= 0) {
                  _syncUserProviderWithProfile(_selectedIndex);
                } else {
                  // Clear UserProvider if no profile left
                  final userProvider =
                      Provider.of<UserProvider>(context, listen: false);
                  userProvider.saveUserData(
                      name: '',
                      height: 0,
                      weight: 0,
                      age: 0,
                      gender: '',
                      activityLevel: '',
                      goal: '');
                }
                Navigator.pop(context);
              },
              child: const Text('Sil'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _saveSelectedProfileIndex(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selectedProfileIndex', index);
  }

  /// BMI, BMR ve TDEE hesaplar ve öneri üretir.
  void _calculateBMI() {
    final double? height = double.tryParse(_heightController.text);
    final double? weight = double.tryParse(_weightController.text);
    final double? age = double.tryParse(_ageController.text);

    if (height != null &&
        weight != null &&
        age != null &&
        height > 0 &&
        age > 0) {
      final double heightInMeters = height / 100;
      final double bmi = weight / (heightInMeters * heightInMeters);

      // BMR hesaplama (Mifflin-St Jeor)
      double bmr;
      if (_gender == 'Erkek') {
        bmr = (10 * weight) + (6.25 * height) - (5 * age) + 5;
      } else {
        bmr = (10 * weight) + (6.25 * height) - (5 * age) - 161;
      }

      // TDEE hesaplama (aktivite çarpanı)
      double tdee = bmr * _activityMultipliers[_activityLevel]!;

      setState(() {
        _bmi = bmi;
        _bmr = bmr;
        _tdee = tdee;
        if (_selectedIndex >= 0) {
          _profiles[_selectedIndex]['height'] = _heightController.text;
          _profiles[_selectedIndex]['weight'] = _weightController.text;
          _profiles[_selectedIndex]['age'] = _ageController.text;
          _profiles[_selectedIndex]['gender'] = _gender;
          _profiles[_selectedIndex]['activityLevel'] = _activityLevel;
          _profiles[_selectedIndex]['purpose'] = _purpose;
          _profiles[_selectedIndex]['tdee'] = tdee;
          _profiles[_selectedIndex]['protein'] = 120;
          _profiles[_selectedIndex]['carb'] = 250;
          _profiles[_selectedIndex]['fat'] = 45;
          _saveProfiles();

          // UserProvider'ı güncelle
          _syncUserProviderWithProfile(_selectedIndex);
        }

        // Kullanıcıya öneri üret
        if (bmi < 18.5) {
          _recommendation =
              'Kilo alman faydalı olabilir. Günlük kalori ihtiyacın: ${tdee.toStringAsFixed(0)} kcal';
        } else if (bmi >= 18.5 && bmi <= 24.9) {
          _recommendation =
              'Kilonu koruyorsun, böyle devam! Günlük kalori ihtiyacın: ${tdee.toStringAsFixed(0)} kcal';
        } else if (bmi >= 25 && bmi <= 29.9) {
          _recommendation =
              'Biraz kilo vermen önerilir. Günlük kalori ihtiyacın: ${tdee.toStringAsFixed(0)} kcal';
        } else {
          _recommendation =
              'Sağlığın için kilo vermen önemli. Günlük kalori ihtiyacın: ${tdee.toStringAsFixed(0)} kcal';
        }
      });
    } else {
      setState(() {
        _bmi = null;
        _bmr = null;
        _tdee = null;
        _recommendation = 'Lütfen geçerli bir boy, kilo ve yaş girin.';
      });
    }
  }

  /// BMI değerine göre renk döndürür (görsel gösterim için)
  Color _bmiColor() {
    if (_bmi == null) {
      return Colors.black;
    } else if (_bmi! < 18.5) {
      return Colors.lightBlue;
    } else if (_bmi! >= 18.5 && _bmi! <= 24.9) {
      return Colors.green;
    } else if (_bmi! >= 25 && _bmi! <= 29.9) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tema renkleri
    const Color midnightBlue = Color(0xFF2C3E50);
    const Color deepFern = Color(0xFF52796F);
    const Color analyticsColor = Color(0xFF50FA7B); // Ana sayfa buton rengi
    final Color analyticsLight = analyticsColor.withOpacity(0.15);
    final Color analyticsDark = analyticsColor.withOpacity(0.8);

    return Scaffold(
      backgroundColor: midnightBlue,
      appBar: AppBar(
        backgroundColor: analyticsColor.withOpacity(0.95),
        elevation: 0,
        centerTitle: true,
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Colors.white, analyticsColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: const Text(
            'Analizlerim',
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
            colors: [analyticsColor.withOpacity(0.8), midnightBlue],
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
                    color: analyticsLight,
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
                    color: analyticsLight,
                  ),
                ),
              ),
              // Ana içerik: profil seçimi, ölçüler, aktivite, amaç, sonuçlar
              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profil seçimi kartı
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: analyticsColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: analyticsLight,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: analyticsColor.withOpacity(0.3),
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: analyticsColor.withOpacity(0.2),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.person_outline,
                                  color: analyticsColor,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Profil Seçimi',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Spacer(),
                              // Profil Ekle butonu
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline,
                                    color: Colors.white, size: 28),
                                tooltip: 'Profil Ekle',
                                onPressed: () async {
                                  String? newName = await showDialog<String>(
                                    context: context,
                                    builder: (context) {
                                      final TextEditingController
                                          nameController =
                                          TextEditingController();
                                      return AlertDialog(
                                        title:
                                            const Text('Yeni Profil Oluştur'),
                                        content: TextField(
                                          controller: nameController,
                                          decoration: const InputDecoration(
                                            labelText: 'Profil Adı',
                                            hintText: 'Örn: Kendi Adın',
                                          ),
                                          autofocus: true,
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: const Text('İptal'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              if (nameController.text
                                                  .trim()
                                                  .isNotEmpty) {
                                                Navigator.pop(context,
                                                    nameController.text.trim());
                                              }
                                            },
                                            child: const Text('Oluştur'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                  if (newName != null && newName.isNotEmpty) {
                                    _addProfile(newName);
                                  }
                                },
                              ),
                              // Profil Sil butonu (sadece bir profil seçiliyse ve profil varsa)
                              if (_selectedIndex >= 0 && _profiles.isNotEmpty)
                                IconButton(
                                  icon: const Icon(Icons.delete_outline,
                                      color: Colors.redAccent, size: 26),
                                  tooltip: 'Profili Sil',
                                  onPressed: _deleteProfile,
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (_profiles.isEmpty)
                            Center(
                              child: Text(
                                'Henüz profil oluşturulmamış',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 14,
                                ),
                              ),
                            )
                          else
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: List.generate(
                                _profiles.length,
                                (index) => ChoiceChip(
                                  label: Text(
                                    _profiles[index]['name'],
                                    style: TextStyle(
                                      color: _selectedIndex == index
                                          ? deepFern
                                          : Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                  selected: _selectedIndex == index,
                                  onSelected: (selected) {
                                    if (selected) {
                                      _selectProfile(index);
                                    }
                                  },
                                  backgroundColor: Colors.white.withOpacity(
                                    0.1,
                                  ),
                                  selectedColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Vücut ölçüleri kartı
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
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
                                  border: Border.all(
                                    color: const Color(
                                      0xFF50FA7B,
                                    ).withOpacity(0.3),
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFF50FA7B,
                                      ).withOpacity(0.2),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.monitor_weight_outlined,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Vücut Ölçüleri',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildInputField(
                                  controller: _heightController,
                                  label: 'Boy (cm)',
                                  icon: Icons.height,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildInputField(
                                  controller: _weightController,
                                  label: 'Kilo (kg)',
                                  icon: Icons.monitor_weight,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildInputField(
                                  controller: _ageController,
                                  label: 'Yaş',
                                  icon: Icons.cake,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildDropdownField(
                                  value: _gender,
                                  items: _genderOptions,
                                  label: 'Cinsiyet',
                                  icon: Icons.person,
                                  onChanged: (value) {
                                    setState(() {
                                      _gender = value!;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Aktivite seviyesi kartı
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
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
                                  border: Border.all(
                                    color: const Color(
                                      0xFF50FA7B,
                                    ).withOpacity(0.3),
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFF50FA7B,
                                      ).withOpacity(0.2),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.fitness_center,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Aktivite Seviyesi',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildDropdownField(
                            value: _activityLevel,
                            items: _activityMultipliers.keys.toList(),
                            label: 'Günlük Aktivite',
                            icon: Icons.directions_run,
                            onChanged: (value) {
                              setState(() {
                                _activityLevel = value!;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Amaç kartı
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
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
                                  border: Border.all(
                                    color: const Color(
                                      0xFF50FA7B,
                                    ).withOpacity(0.3),
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFF50FA7B,
                                      ).withOpacity(0.2),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.flag,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Hedef',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildDropdownField(
                            value: _purpose,
                            items: _purposeOptions,
                            label: 'Beslenme Amacı',
                            icon: Icons.track_changes,
                            onChanged: (value) {
                              setState(() {
                                _purpose = value!;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Hesapla butonu
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _calculateBMI,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: analyticsColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Hesapla',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Sonuçlar kartı
                    if (_bmi != null)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1,
                          ),
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
                                    border: Border.all(
                                      color: const Color(
                                        0xFF50FA7B,
                                      ).withOpacity(0.3),
                                      width: 1,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(
                                          0xFF50FA7B,
                                        ).withOpacity(0.2),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.analytics,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Sonuçlar',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildResultCard(
                              title: 'Vücut Kitle İndeksi (BMI)',
                              value: _bmi!.toStringAsFixed(1),
                              color: _bmiColor(),
                              icon: Icons.monitor_weight,
                            ),
                            const SizedBox(height: 12),
                            _buildResultCard(
                              title: 'Bazal Metabolizma Hızı (BMR)',
                              value: '${_bmr!.toStringAsFixed(0)} kcal',
                              color: Colors.blue,
                              icon: Icons.local_fire_department,
                            ),
                            const SizedBox(height: 12),
                            _buildResultCard(
                              title: 'Günlük Kalori İhtiyacı (TDEE)',
                              value: '${_tdee!.toStringAsFixed(0)} kcal',
                              color: Colors.orange,
                              icon: Icons.restaurant,
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.lightbulb_outline,
                                    color: Colors.amber,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _recommendation,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
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

  /// Sayısal giriş alanı oluşturan yardımcı fonksiyon.
  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
        prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.7)),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white),
        ),
      ),
    );
  }

  /// Dropdown (açılır liste) alanı oluşturan yardımcı fonksiyon.
  Widget _buildDropdownField({
    required String value,
    required List<String> items,
    required String label,
    required IconData icon,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: const Color(0xFF2C3E50),
          style: const TextStyle(color: Colors.white),
          icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Row(
                children: [
                  Icon(
                    icon,
                    color: Colors.white.withOpacity(0.7),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(item),
                ],
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  /// Sonuç kartı oluşturan yardımcı fonksiyon (ör: BMI, BMR, TDEE)
  Widget _buildResultCard({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
