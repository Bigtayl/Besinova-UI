// analytics_screen.dart
// Kullanıcının vücut analizlerini (BMI, BMR, TDEE) hesaplayan ve öneriler sunan ekran.
// Profil yönetimi, aktivite seviyesi, amaç seçimi ve sonuç kartları içerir.

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../../presentation/presentation.dart';
import '../../data/data.dart';
import '../../core/constants/app_constants.dart';
import 'settings_screen.dart';

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

  // Scroll kontrolü için controller
  final ScrollController _scrollController = ScrollController();

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
    'Sağlıklı olmak için',
    'Sporcu için besin önerisi',
  ];

  // Akordiyon yapısı için state değişkeni
  bool _showResults = false;
  bool _isCalculating = false;
  bool _isLoadingForm = false; // Form yüklenirken flag

  // Sonuçlar kartı için key
  final GlobalKey _resultsKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _loadProfiles();
    _loadUserDataFromProvider();

    // Input alanlarına listener ekle
    _heightController.addListener(_onInputChanged);
    _weightController.addListener(_onInputChanged);
    _ageController.addListener(_onInputChanged);
  }

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Input alanları değiştiğinde sonuçları kapat (sadece manuel değişikliklerde)
  void _onInputChanged() {
    if (_showResults && !_isLoadingForm) {
      setState(() {
        _showResults = false;
      });
    }
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

      final parsedAge = p['age'] != null && p['age'].toString().isNotEmpty
          ? int.tryParse(p['age'].toString())
          : userProvider.age;

      // Update UserProvider
      userProvider.updateUserField(
        name: p['name'] ?? '',
        height: p['height'] != null && p['height'].toString().isNotEmpty
            ? double.tryParse(p['height'].toString())
            : userProvider.height,
        weight: p['weight'] != null && p['weight'].toString().isNotEmpty
            ? double.tryParse(p['weight'].toString())
            : userProvider.weight,
        age: parsedAge,
        gender: p['gender'] ?? userProvider.gender,
        activityLevel: p['activityLevel'] ?? userProvider.activityLevel,
        goal: p['purpose'] ?? userProvider.goal,
      );

      // Save to SharedPreferences to persist the data
      _saveUserDataToStorage(
        name: p['name'] ?? '',
        height: p['height'] != null && p['height'].toString().isNotEmpty
            ? double.tryParse(p['height'].toString()) ?? userProvider.height
            : userProvider.height,
        weight: p['weight'] != null && p['weight'].toString().isNotEmpty
            ? double.tryParse(p['weight'].toString()) ?? userProvider.weight
            : userProvider.weight,
        age: parsedAge ?? userProvider.age,
        gender: p['gender'] ?? userProvider.gender,
        activityLevel: p['activityLevel'] ?? userProvider.activityLevel,
        goal: p['purpose'] ?? userProvider.goal,
      );
    }
  }

  /// Save user data to SharedPreferences
  Future<void> _saveUserDataToStorage({
    required String name,
    required double height,
    required double weight,
    required int age,
    required String gender,
    required String activityLevel,
    required String goal,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString(AppConstants.storageKeyName, name);
      await prefs.setDouble(AppConstants.storageKeyHeight, height);
      await prefs.setDouble(AppConstants.storageKeyWeight, weight);
      await prefs.setInt(AppConstants.storageKeyAge, age);
      await prefs.setString(AppConstants.storageKeyGender, gender);
      await prefs.setString(
          AppConstants.storageKeyActivityLevel, activityLevel);
      await prefs.setString(AppConstants.storageKeyGoal, goal);
    } catch (e) {
      // Handle error silently or log to a proper logging service
    }
  }

  /// Yeni profil ekler.
  void _addProfile(String name) {
    setState(() {
      _isLoadingForm = true;
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
      _showResults = false; // Yeni profil eklendiğinde sonuçları kapat
      _isLoadingForm = false;
    });
    _saveProfiles();
    _saveSelectedProfileIndex(_selectedIndex);
    _syncUserProviderWithProfile(_selectedIndex);
  }

  /// Seçili profili yükler ve ekrana yazar.
  void _selectProfile(int index) {
    setState(() {
      _isLoadingForm = true;
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
      _showResults = false; // Profil değiştiğinde sonuçları kapat
      _isLoadingForm = false;
    });
    _saveSelectedProfileIndex(index);
    _syncUserProviderWithProfile(index);

    // Eğer profil verileri varsa, makroları yeniden hesapla
    if (_profiles[index]['tdee'] != null) {
      double tdee = _profiles[index]['tdee'].toDouble();
      double weight = double.tryParse(_profiles[index]['weight']) ?? 70;
      String purpose = _profiles[index]['purpose'] ?? _purposeOptions[0];

      Map<String, double> macros = _calculateMacros(tdee, purpose, weight);

      setState(() {
        _profiles[index]['protein'] = macros['protein']!.round();
        _profiles[index]['carb'] = macros['carb']!.round();
        _profiles[index]['fat'] = macros['fat']!.round();
        _saveProfiles();
      });
    }
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
                  _isLoadingForm = true;
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
                  _showResults = false; // Profil silindiğinde sonuçları kapat
                  _isLoadingForm = false;
                });
                _saveProfiles();
                _saveSelectedProfileIndex(_selectedIndex);
                if (_selectedIndex >= 0) {
                  _syncUserProviderWithProfile(_selectedIndex);
                } else {
                  // Clear UserProvider if no profile left
                  final userProvider =
                      Provider.of<UserProvider>(context, listen: false);
                  userProvider.updateUserField(
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

  /// Kullanıcının hedefine göre makro besin değerlerini hesaplar
  Map<String, double> _calculateMacros(
      double tdee, String purpose, double weight) {
    double protein, carbs, fat;

    switch (purpose) {
      case 'Kilo vermek için':
        // Kilo verme için: Yüksek protein, orta yağ, düşük karbonhidrat
        protein = weight * 2.2; // kg başına 2.2g protein
        fat = tdee * 0.25 / 9; // Kalorinin %25'i yağdan (1g yağ = 9 kcal)
        carbs = (tdee - (protein * 4) - (fat * 9)) /
            4; // Kalan kaloriler karbonhidrattan (1g karbonhidrat = 4 kcal)
        break;

      case 'Kilo almak için':
        // Kilo alma için: Yüksek karbonhidrat, orta protein, düşük yağ
        protein = weight * 1.8; // kg başına 1.8g protein
        fat = tdee * 0.20 / 9; // Kalorinin %20'si yağdan
        carbs = (tdee - (protein * 4) - (fat * 9)) /
            4; // Kalan kaloriler karbonhidrattan
        break;

      case 'Kas yapmak için':
        // Kas yapma için: Yüksek protein, orta karbonhidrat, düşük yağ
        protein = weight * 2.5; // kg başına 2.5g protein
        fat = tdee * 0.20 / 9; // Kalorinin %20'si yağdan
        carbs = (tdee - (protein * 4) - (fat * 9)) /
            4; // Kalan kaloriler karbonhidrattan
        break;

      default: // 'Kilonu korumak için' veya diğer durumlar
        // Kilo koruma için: Dengeli makro dağılımı
        protein = weight * 2.0; // kg başına 2.0g protein
        fat = tdee * 0.25 / 9; // Kalorinin %25'i yağdan
        carbs = (tdee - (protein * 4) - (fat * 9)) /
            4; // Kalan kaloriler karbonhidrattan
        break;
    }

    // Minimum değerleri kontrol et
    protein = protein.clamp(
        weight * 1.0, weight * 3.0); // Minimum 1g/kg, maksimum 3g/kg
    fat = fat.clamp(
        weight * 0.8, weight * 2.0); // Minimum 0.8g/kg, maksimum 2g/kg
    carbs = carbs.clamp(
        50, tdee * 0.6 / 4); // Minimum 50g, maksimum kalorinin %60'ı

    return {
      'protein': protein,
      'carb': carbs,
      'fat': fat,
    };
  }

  /// Analiz sonuçlarını hesaplar ve state'i günceller.
  void _calculate() {
    setState(() => _isCalculating = true);

    final double? height = double.tryParse(_heightController.text);
    final double? weight = double.tryParse(_weightController.text);
    final int? age = int.tryParse(_ageController.text);

    if (height != null && weight != null && age != null) {
      final calculatedBmi = weight / ((height / 100) * (height / 100));
      final calculatedBmr = _gender == 'Erkek'
          ? (10 * weight) + (6.25 * height) - (5 * age) + 5
          : (10 * weight) + (6.25 * height) - (5 * age) - 161;
      final activityMultiplier = _activityMultipliers[_activityLevel] ?? 1.2;
      final calculatedTdee = calculatedBmr * activityMultiplier;
      final calculatedRecommendation = _getRecommendation(calculatedBmi);

      // Verileri hem state'te hem de UserProvider'da güncelle
      setState(() {
        _bmi = calculatedBmi;
        _bmr = calculatedBmr;
        _tdee = calculatedTdee;
        _recommendation = calculatedRecommendation;
        _showResults = true;
      });

      final userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.updateUserField(
        height: height,
        weight: weight,
        age: age,
        gender: _gender,
        activityLevel: _activityLevel,
        goal: _purpose,
      );

      // Profili SharedPreferences'ta da güncelle
      if (_selectedIndex != -1) {
        setState(() {
          _profiles[_selectedIndex]['height'] = height.toString();
          _profiles[_selectedIndex]['weight'] = weight.toString();
          _profiles[_selectedIndex]['age'] = age.toString();
          _profiles[_selectedIndex]['gender'] = _gender;
          _profiles[_selectedIndex]['activityLevel'] = _activityLevel;
          _profiles[_selectedIndex]['purpose'] = _purpose;
          _profiles[_selectedIndex]['bmi'] = _bmi;
          _profiles[_selectedIndex]['bmr'] = _bmr;
          _profiles[_selectedIndex]['tdee'] = _tdee;
        });
        _saveProfiles();
      }
    }

    // Scroll to results and finish calculation
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() => _isCalculating = false);
        if (_resultsKey.currentContext != null) {
          Scrollable.ensureVisible(
            _resultsKey.currentContext!,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      }
    });
  }

  /// Vücut kitle indeksine göre öneri döndürür.
  String _getRecommendation(double bmi) {
    if (bmi < 18.5) {
      return 'Kilo alman faydalı olabilir. Günlük kalori ihtiyacın: ${_tdee?.toStringAsFixed(0) ?? 'N/A'} kcal';
    } else if (bmi >= 18.5 && bmi <= 24.9) {
      return 'Kilonu koruyorsun, böyle devam! Günlük kalori ihtiyacın: ${_tdee?.toStringAsFixed(0) ?? 'N/A'} kcal';
    } else if (bmi >= 25 && bmi <= 29.9) {
      return 'Biraz kilo vermen önerilir. Günlük kalori ihtiyacın: ${_tdee?.toStringAsFixed(0) ?? 'N/A'} kcal';
    } else {
      return 'Sağlığın için kilo vermen önemli. Günlük kalori ihtiyacın: ${_tdee?.toStringAsFixed(0) ?? 'N/A'} kcal';
    }
  }

  /// BMI değerine göre renk döndürür (görsel gösterim için)
  Color _bmiColor() {
    if (_bmi == null) {
      return Colors.grey; // Null durumunda gri renk
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

  /// UserProvider'dan kullanıcı verilerini yükler ve form alanlarına doldurur
  void _loadUserDataFromProvider() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _isLoadingForm = true;
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      // Eğer form alanları boşsa ve UserProvider'da veri varsa, formu doldur
      if (_heightController.text.isEmpty && userProvider.height > 0) {
        _heightController.text = userProvider.height.toString();
      }
      if (_weightController.text.isEmpty && userProvider.weight > 0) {
        _weightController.text = userProvider.weight.toString();
      }
      if (_ageController.text.isEmpty && userProvider.age > 0) {
        _ageController.text = userProvider.age.toString();
      }
      if (_nameController.text.isEmpty && userProvider.name.isNotEmpty) {
        _nameController.text = userProvider.name;
      }

      // Dropdown değerlerini güncelle
      if (userProvider.gender.isNotEmpty &&
          _genderOptions.contains(userProvider.gender)) {
        _gender = userProvider.gender;
      }
      if (userProvider.activityLevel.isNotEmpty &&
          _activityMultipliers.containsKey(userProvider.activityLevel)) {
        _activityLevel = userProvider.activityLevel;
      }
      if (userProvider.goal.isNotEmpty &&
          _purposeOptions.contains(userProvider.goal)) {
        _purpose = userProvider.goal;
      }

      _isLoadingForm = false;
    });
  }

  double _parseDouble(dynamic value, double defaultValue) {
    if (value == null) return defaultValue;
    if (value is num) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value);
      return parsed ?? defaultValue;
    }
    return defaultValue;
  }

  @override
  Widget build(BuildContext context) {
    // Tema renkleri
    const Color midnightBlue = Color(0xFF2C3E50);
    const Color deepFern = Color(0xFF52796F);
    const Color analyticsColor = Color(0xFF50FA7B); // Ana sayfa buton rengi
    final Color analyticsLight = analyticsColor.withValues(alpha: 0.15);

    return Scaffold(
      backgroundColor: midnightBlue,
      appBar: AppBar(
        backgroundColor: deepFern.withValues(alpha: 0.95),
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
            colors: [deepFern.withValues(alpha: 0.8), midnightBlue],
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
                controller: _scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profil seçimi kartı
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: analyticsColor.withValues(alpha: 0.3),
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
                                    color:
                                        analyticsColor.withValues(alpha: 0.3),
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          analyticsColor.withValues(alpha: 0.2),
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
                                  color: Colors.white.withValues(alpha: 0.7),
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
                                          : const Color(0xFF222222),
                                      fontSize: 15,
                                      fontWeight: _selectedIndex == index
                                          ? FontWeight.bold
                                          : FontWeight.w600,
                                      letterSpacing: 0.1,
                                    ),
                                  ),
                                  selected: _selectedIndex == index,
                                  onSelected: (selected) {
                                    if (selected) {
                                      _selectProfile(index);
                                    }
                                  },
                                  backgroundColor: _selectedIndex == index
                                      ? Colors.white
                                      : const Color(0xFFECECEC),
                                  selectedColor: Colors.white,
                                  side: BorderSide(
                                    color: _selectedIndex == index
                                        ? deepFern
                                        : Colors.black.withOpacity(0.08),
                                    width: 1.2,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 9,
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
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
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
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(
                                      0xFF50FA7B,
                                    ).withValues(alpha: 0.3),
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFF50FA7B,
                                      ).withValues(alpha: 0.2),
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
                                      if (_showResults) {
                                        _showResults = false;
                                      }
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
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
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
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(
                                      0xFF50FA7B,
                                    ).withValues(alpha: 0.3),
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFF50FA7B,
                                      ).withValues(alpha: 0.2),
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
                                if (_showResults) {
                                  _showResults = false;
                                }
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
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
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
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(
                                      0xFF50FA7B,
                                    ).withValues(alpha: 0.3),
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFF50FA7B,
                                      ).withValues(alpha: 0.2),
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
                                if (_showResults) {
                                  _showResults = false;
                                }
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
                        onPressed: _isCalculating ? null : _calculate,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: analyticsColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: _isCalculating
                            ? const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    'Hesaplanıyor...',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              )
                            : const Text(
                                'Hesapla',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Sonuçlar kartı - Akordiyon yapısı
                    AnimatedCrossFade(
                      duration: const Duration(milliseconds: 500),
                      crossFadeState: _showResults
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      firstChild: const SizedBox.shrink(),
                      secondChild: Container(
                        key: _resultsKey,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
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
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: const Color(
                                        0xFF50FA7B,
                                      ).withValues(alpha: 0.3),
                                      width: 1,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(
                                          0xFF50FA7B,
                                        ).withValues(alpha: 0.2),
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
                                const Spacer(),
                                // Kapatma butonu
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _showResults = false;
                                    });
                                  },
                                  icon: const Icon(
                                    Icons.keyboard_arrow_up,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildResultCard(
                              title: 'Vücut Kitle İndeksi (BMI)',
                              value: _bmi?.toStringAsFixed(1) ?? 'N/A',
                              color: _bmiColor(),
                              icon: Icons.monitor_weight,
                            ),
                            const SizedBox(height: 12),
                            _buildResultCard(
                              title: 'Bazal Metabolizma Hızı (BMR)',
                              value: _bmr != null
                                  ? '${_bmr!.toStringAsFixed(0)} kcal'
                                  : 'N/A',
                              color: Colors.blue,
                              icon: Icons.local_fire_department,
                            ),
                            const SizedBox(height: 12),
                            _buildResultCard(
                              title: 'Günlük Kalori İhtiyacı (TDEE)',
                              value: _tdee != null
                                  ? '${_tdee!.toStringAsFixed(0)} kcal'
                                  : 'N/A',
                              color: Colors.orange,
                              icon: Icons.restaurant,
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.2),
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
                            const SizedBox(height: 20),
                            // Bütçe optimizasyonu kartı
                            _buildBudgetOptimizationCard(),
                          ],
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
        labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
        prefixIcon: Icon(icon, color: Colors.white.withValues(alpha: 0.7)),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
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
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
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
                    color: Colors.white.withValues(alpha: 0.7),
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
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
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
                    color: Colors.white.withValues(alpha: 0.7),
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

  Widget _buildBudgetOptimizationCard() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _getSelectedProfile(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final profile = snapshot.data!;
        final budget = _parseDouble(profile['budget'], 0.0);
        final suggestions = <String>[];
        final optimizedProducts = <Product>[];

        if (budget > 0) {
          // Bütçe önerileri
          if (budget < 1000) {
            suggestions
                .add('Düşük bütçe için mevsimlik sebzeleri tercih edin.');
          } else if (budget < 2000) {
            suggestions.add(
                'Protein kaynaklarını haftalık planlayarak alışveriş yapın.');
          } else {
            suggestions.add(
                'Çeşitli besin gruplarından dengeli alışveriş yapabilirsiniz.');
          }

          // Optimize edilmiş ürünler (örnek)
          optimizedProducts.addAll(OptimizationService.getProducts().take(5));
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF50FA7B).withValues(alpha: 0.3),
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
                      color: const Color(0xFF50FA7B).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF50FA7B).withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet,
                      color: Color(0xFF50FA7B),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Bütçe Optimizasyonu',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (budget > 0) ...[
                // Bütçe bilgisi
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Aylık Bütçe:',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '₺${budget.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Bütçe kullanım oranı
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Kullanım Oranı:',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '${((optimizedProducts.fold(0.0, (sum, p) => sum + p.price) / budget) * 100).toStringAsFixed(1)}%',
                      style: const TextStyle(
                        color: Color(0xFF50FA7B),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Öneriler
                if (suggestions.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF50FA7B).withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.lightbulb_outline,
                          color: Color(0xFF50FA7B),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            suggestions.first,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                // Optimize edilmiş ürün sayısı
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Önerilen Ürün:',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '${optimizedProducts.length} ürün',
                      style: const TextStyle(
                        color: Color(0xFF50FA7B),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ] else ...[
                // Bütçe belirlenmemiş durumu
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.white.withValues(alpha: 0.7),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Bütçe belirlenmedi. Ayarlar sayfasından bütçenizi belirleyerek besin önerilerinizi optimize edebilirsiniz.',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              // Bütçe ayarlama butonu
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    );
                  },
                  icon: const Icon(Icons.settings),
                  label: Text(budget > 0 ? 'Bütçeyi Düzenle' : 'Bütçe Belirle'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xFF50FA7B).withValues(alpha: 0.2),
                    foregroundColor: const Color(0xFF50FA7B),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: const Color(0xFF50FA7B).withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Optimize listemi gör butonu
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Navigate to shopping list screen
                    Navigator.pushNamed(context, '/shopping-list');
                  },
                  icon: const Icon(Icons.shopping_cart),
                  label: const Text('Optimize Listemi Gör'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B6B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<Map<String, dynamic>> _getSelectedProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final String? profilesString = prefs.getString('profiles');
    final int? selectedIndex = prefs.getInt('selectedProfileIndex');
    if (profilesString != null && selectedIndex != null) {
      final List<dynamic> decoded = json.decode(profilesString);
      if (selectedIndex >= 0 && selectedIndex < decoded.length) {
        final Map<String, dynamic> profile =
            Map<String, dynamic>.from(decoded[selectedIndex]);
        return profile;
      }
    }
    return {};
  }
}
