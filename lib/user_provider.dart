// user_provider.dart
// Kullanıcıya ait verilerin (isim, email, boy, kilo, yaş, avatar vb.) yönetimini sağlar.
// Veriler local storage (SharedPreferences) ile saklanır ve uygulama genelinde Provider ile erişilir.

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Kullanıcı verilerini ve ayarlarını yöneten Provider sınıfı.
class UserProvider with ChangeNotifier {
  // Kullanıcı bilgileri
  String _name = '';
  String _email = '';
  double _height = 0;
  double _weight = 0;
  int _age = 0;
  String _gender = '';
  String _activityLevel = '';
  String _goal = '';
  String _avatar = '🍏'; // Varsayılan avatar
  int _loginCount = 0;
  String _lastLogin = '';
  int _completedGoals = 0;
  double _budget = 0.0; // Bütçe alanı eklendi
  int _notificationCount = 3; // Bildirim sayısı eklendi

  // Getter'lar
  String get name => _name;
  String get email => _email;
  double get height => _height;
  double get weight => _weight;
  int get age => _age;
  String get gender => _gender;
  String get activityLevel => _activityLevel;
  String get goal => _goal;
  String get avatar => _avatar;
  int get loginCount => _loginCount;
  String get lastLogin => _lastLogin;
  int get completedGoals => _completedGoals;
  double get budget => _budget; // Bütçe getter'ı eklendi
  int get notificationCount =>
      _notificationCount; // Bildirim sayısı getter'ı eklendi

  /// Avatarı günceller ve kaydeder.
  void setAvatar(String newAvatar) {
    _avatar = newAvatar;
    saveUserData(avatar: newAvatar);
    notifyListeners();
  }

  /// İsmi günceller ve kaydeder.
  void setName(String newName) {
    _name = newName;
    saveUserData(name: newName);
    notifyListeners();
  }

  /// İstatistikleri güncelleyen fonksiyonlar
  void incrementLoginCount() async {
    _loginCount++;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('loginCount', _loginCount);
    notifyListeners();
  }

  void updateLastLogin(String dateTime) async {
    _lastLogin = dateTime;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lastLogin', dateTime);
    notifyListeners();
  }

  void incrementCompletedGoals() async {
    _completedGoals++;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('completedGoals', _completedGoals);
    notifyListeners();
  }

  /// Bütçeyi günceller ve kaydeder.
  void setBudget(double newBudget) {
    _budget = newBudget;
    saveUserData(budget: newBudget);
    notifyListeners();
  }

  /// Local storage'dan kullanıcı verilerini yükler.
  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    _name = prefs.getString('name') ?? 'Kullanıcı'; // Varsayılan isim
    _email = prefs.getString('email') ??
        'kullanici@besinova.com'; // Varsayılan email
    _height = prefs.getDouble('height') ?? 170.0; // Varsayılan boy
    _weight = prefs.getDouble('weight') ?? 70.0; // Varsayılan kilo
    _age = prefs.getInt('age') ?? 25; // Varsayılan yaş
    _gender = prefs.getString('gender') ?? 'Erkek'; // Varsayılan cinsiyet
    _activityLevel = prefs.getString('activityLevel') ??
        'Orta'; // Varsayılan aktivite seviyesi
    _goal = prefs.getString('goal') ?? 'Sağlıklı Yaşam'; // Varsayılan hedef
    _avatar = prefs.getString('avatar') ?? '🍏';
    _loginCount = prefs.getInt('loginCount') ?? 1; // Varsayılan giriş sayısı
    _lastLogin = prefs.getString('lastLogin') ?? DateTime.now().toString();
    _completedGoals = prefs.getInt('completedGoals') ?? 0;
    _budget = prefs.getDouble('budget') ?? 5000.0; // Varsayılan bütçe
    _notificationCount =
        prefs.getInt('notificationCount') ?? 3; // Varsayılan bildirim sayısı
    notifyListeners();
  }

  /// Kullanıcı verilerini local storage'a kaydeder.
  Future<void> saveUserData({
    String? name,
    String? email,
    double? height,
    double? weight,
    int? age,
    String? gender,
    String? activityLevel,
    String? goal,
    String? avatar,
    int? loginCount,
    String? lastLogin,
    int? completedGoals,
    double? budget,
    int? notificationCount,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    if (name != null) {
      _name = name;
      await prefs.setString('name', name);
    }
    if (email != null) {
      _email = email;
      await prefs.setString('email', email);
    }
    if (height != null) {
      _height = height;
      await prefs.setDouble('height', height);
    }
    if (weight != null) {
      _weight = weight;
      await prefs.setDouble('weight', weight);
    }
    if (age != null) {
      _age = age;
      await prefs.setInt('age', age);
    }
    if (gender != null) {
      _gender = gender;
      await prefs.setString('gender', gender);
    }
    if (activityLevel != null) {
      _activityLevel = activityLevel;
      await prefs.setString('activityLevel', activityLevel);
    }
    if (goal != null) {
      _goal = goal;
      await prefs.setString('goal', goal);
    }
    if (avatar != null) {
      _avatar = avatar;
      await prefs.setString('avatar', avatar);
    }
    if (loginCount != null) {
      _loginCount = loginCount;
      await prefs.setInt('loginCount', loginCount);
    }
    if (lastLogin != null) {
      _lastLogin = lastLogin;
      await prefs.setString('lastLogin', lastLogin);
    }
    if (completedGoals != null) {
      _completedGoals = completedGoals;
      await prefs.setInt('completedGoals', completedGoals);
    }
    if (budget != null) {
      _budget = budget;
      await prefs.setDouble('budget', budget);
    }
    if (notificationCount != null) {
      _notificationCount = notificationCount;
      await prefs.setInt('notificationCount', notificationCount);
    }
    notifyListeners();
  }
}
