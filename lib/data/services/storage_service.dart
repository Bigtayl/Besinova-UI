import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../models/user.dart';

/// Service for handling local data storage using SharedPreferences
class StorageService {
  static SharedPreferences? _prefs;
  static bool _isInitialized = false;
  static const String _sessionActiveKey = 'session_active';

  /// Initialize the storage service
  static Future<void> init() async {
    if (_isInitialized) return;
    _prefs = await SharedPreferences.getInstance();
    _isInitialized = true;
  }

  /// Get SharedPreferences instance
  static SharedPreferences get prefs {
    if (_prefs == null) {
      throw StateError('StorageService not initialized. Call init() first.');
    }
    return _prefs!;
  }

  /// Save user data to local storage
  static Future<void> saveUser(User user) async {
    final batch = <Future<bool>>[
      prefs.setString(AppConstants.storageKeyName, user.name),
      prefs.setString(AppConstants.storageKeyEmail, user.email),
      prefs.setDouble(AppConstants.storageKeyHeight, user.height),
      prefs.setDouble(AppConstants.storageKeyWeight, user.weight),
      prefs.setInt(AppConstants.storageKeyAge, user.age),
      prefs.setString(AppConstants.storageKeyGender, user.gender),
      prefs.setString(AppConstants.storageKeyActivityLevel, user.activityLevel),
      prefs.setString(AppConstants.storageKeyGoal, user.goal),
      prefs.setString(AppConstants.storageKeyAvatar, user.avatar),
      prefs.setInt(AppConstants.storageKeyLoginCount, user.loginCount),
      prefs.setString(AppConstants.storageKeyLastLogin, user.lastLogin),
      prefs.setInt(AppConstants.storageKeyCompletedGoals, user.completedGoals),
      prefs.setDouble(AppConstants.storageKeyBudget, user.budget),
      prefs.setInt(
          AppConstants.storageKeyNotificationCount, user.notificationCount),
    ];

    await Future.wait(batch);
  }

  /// Load user data from local storage
  static Future<User?> loadUser() async {
    // Check if user has actual data first
    final email = prefs.getString(AppConstants.storageKeyEmail);
    final name = prefs.getString(AppConstants.storageKeyName);

    // If no email or name, return null (no user data)
    if (email == null || name == null || email.isEmpty || name.isEmpty) {
      return null;
    }

    final loadedBudget = prefs.getDouble(AppConstants.storageKeyBudget) ??
        AppConstants.defaultBudget;
    final loadedAge =
        prefs.getInt(AppConstants.storageKeyAge) ?? AppConstants.defaultAge;
    final loadedGender = prefs.getString(AppConstants.storageKeyGender) ??
        AppConstants.defaultGender;

    final user = User(
      name: name,
      email: email,
      height: prefs.getDouble(AppConstants.storageKeyHeight) ??
          AppConstants.defaultHeight,
      weight: prefs.getDouble(AppConstants.storageKeyWeight) ??
          AppConstants.defaultWeight,
      age: loadedAge,
      gender: loadedGender,
      activityLevel: prefs.getString(AppConstants.storageKeyActivityLevel) ??
          AppConstants.defaultActivityLevel,
      goal: prefs.getString(AppConstants.storageKeyGoal) ??
          AppConstants.defaultGoal,
      avatar: prefs.getString(AppConstants.storageKeyAvatar) ??
          AppConstants.defaultAvatar,
      loginCount: prefs.getInt(AppConstants.storageKeyLoginCount) ??
          AppConstants.defaultLoginCount,
      lastLogin: prefs.getString(AppConstants.storageKeyLastLogin) ??
          DateTime.now().toString(),
      completedGoals: prefs.getInt(AppConstants.storageKeyCompletedGoals) ?? 0,
      budget: loadedBudget,
      notificationCount:
          prefs.getInt(AppConstants.storageKeyNotificationCount) ??
              AppConstants.defaultNotificationCount,
    );

    return user;
  }

  /// Check if user has an account
  static Future<bool> hasAccount() async {
    final email = prefs.getString('user_email');
    final password = prefs.getString('user_password');

    // User has account if they have valid credentials
    final hasValidCredentials = email != null &&
        password != null &&
        email.isNotEmpty &&
        password.isNotEmpty;

    return hasValidCredentials;
  }

  /// Save specific user field
  static Future<void> saveUserField(String key, dynamic value) async {
    switch (value.runtimeType) {
      case String:
        await prefs.setString(key, value as String);
        break;
      case int:
        await prefs.setInt(key, value as int);
        break;
      case double:
        await prefs.setDouble(key, value as double);
        break;
      case bool:
        await prefs.setBool(key, value as bool);
        break;
      default:
        throw ArgumentError('Unsupported type: ${value.runtimeType}');
    }
  }

  /// Get specific user field
  static T? getUserField<T>(String key) => prefs.get(key) as T?;

  /// Set the user's session status
  static Future<void> setSessionActive(bool isActive) async {
    await prefs.setBool(_sessionActiveKey, isActive);
  }

  /// Check if the user's session is active
  static Future<bool> isSessionActive() async {
    final bool sessionFlag = prefs.getBool(_sessionActiveKey) ?? false;

    // If the session flag isn't explicitly true, the session is not active.
    if (!sessionFlag) {
      return false;
    }

    // For a session to be truly valid, user credentials must also exist.
    // This prevents inconsistent states where a session is active but credentials are gone.
    final email = prefs.getString('user_email');
    final password = prefs.getString('user_password');

    final bool hasCredentials = email != null &&
        email.isNotEmpty &&
        password != null &&
        password.isNotEmpty;

    return hasCredentials;
  }

  /// Clear all stored data except credentials and session status
  static Future<void> clearSensitiveData() async {
    final email = prefs.getString('user_email');
    final password = prefs.getString('user_password');
    final name = prefs.getString('user_name');

    await prefs.clear();

    if (email != null) {
      await prefs.setString('user_email', email);
    }
    if (password != null) {
      await prefs.setString('user_password', password);
    }
    if (name != null) {
      await prefs.setString('user_name', name);
    }
    await setSessionActive(false); // Ensure session is marked as inactive
  }

  /// Clear all stored data
  static Future<void> clearAll() async => await prefs.clear();

  /// Remove specific key
  static Future<void> removeKey(String key) async => await prefs.remove(key);
}
