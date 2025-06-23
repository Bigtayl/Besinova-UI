import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/user.dart';
import '../../data/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider for managing user state and data
class UserProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _cachedLastLogin;
  bool _hasSetBudget = false; // Track if user has explicitly set a budget

  /// Current user data
  User? get user => _user;

  /// Loading state
  bool get isLoading => _isLoading;

  /// Check if user has explicitly set a budget
  bool get hasSetBudget => _hasSetBudget;

  /// User getters with defaults
  String get name => _user?.name ?? '';
  String get email => _user?.email ?? '';
  double get height => _user?.height ?? 0.0;
  double get weight => _user?.weight ?? 0.0;
  int get age => _user?.age ?? 0;
  String get gender => _user?.gender ?? '';
  String get activityLevel => _user?.activityLevel ?? '';
  String get goal => _user?.goal ?? '';
  String get avatar => _user?.avatar ?? '';
  int get loginCount => _user?.loginCount ?? 0;
  String get lastLogin => _cachedLastLogin ?? DateTime.now().toString();
  int get completedGoals => _user?.completedGoals ?? 0;
  double get budget => _user?.budget ?? 0.0;
  int get notificationCount => _user?.notificationCount ?? 0;

  /// Initialize user data from storage
  Future<void> loadUserData() async {
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      await StorageService.init();

      // Check if user has actual data before loading
      final hasAccount = await StorageService.hasAccount();

      if (hasAccount) {
        User? loadedUser = await StorageService.loadUser();

        if (loadedUser != null) {
          // Load saved avatar from SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          final String? savedAvatar = prefs.getString('selected_avatar');
          if (savedAvatar != null && savedAvatar.isNotEmpty) {
            loadedUser = loadedUser.copyWith(avatar: savedAvatar);
          }

          _user = loadedUser;
          _cachedLastLogin = loadedUser.lastLogin;
          _hasSetBudget = loadedUser.budget != AppConstants.defaultBudget;
        } else {
          // User data is corrupted or incomplete, set user to null
          _user = null;
          _cachedLastLogin = null;
          _hasSetBudget = false;
        }
      } else {
        // No user data found, set user to null
        _user = null;
        _cachedLastLogin = null;
        _hasSetBudget = false;
      }

      _isLoading = false;
    } catch (e) {
      // Error occurred, set user to null
      _user = null;
      _cachedLastLogin = null;
      _hasSetBudget = false;
      _isLoading = false;
    }

    notifyListeners();
  }

  User _createDefaultUser() => User(
        name: AppConstants.defaultName,
        email: AppConstants.defaultEmail,
        height: AppConstants.defaultHeight,
        weight: AppConstants.defaultWeight,
        age: AppConstants.defaultAge,
        gender: AppConstants.defaultGender,
        activityLevel: AppConstants.defaultActivityLevel,
        goal: AppConstants.defaultGoal,
        avatar: AppConstants.defaultAvatar,
        loginCount: AppConstants.defaultLoginCount,
        lastLogin: DateTime.now().toString(),
        completedGoals: 0,
        budget: AppConstants.defaultBudget,
        notificationCount: AppConstants.defaultNotificationCount,
      );

  /// Update user data
  Future<void> updateUser(User updatedUser) async {
    // Check if users are identical to avoid unnecessary updates
    if (_user == updatedUser) {
      return;
    }

    _user = updatedUser;
    _cachedLastLogin = updatedUser.lastLogin;
    _hasSetBudget = updatedUser.budget != AppConstants.defaultBudget;

    // Save to storage
    await StorageService.saveUser(updatedUser);
  }

  /// Update specific user field
  Future<void> updateUserField({
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
    // Ensure user exists
    if (_user == null) {
      await loadUserData();

      if (_user == null) {
        // Create new user with provided data or defaults
        _user = User(
          name: name ?? AppConstants.defaultName,
          email: email ?? AppConstants.defaultEmail,
          height: height ?? AppConstants.defaultHeight,
          weight: weight ?? AppConstants.defaultWeight,
          age: age ?? AppConstants.defaultAge,
          gender: gender ?? AppConstants.defaultGender,
          activityLevel: activityLevel ?? AppConstants.defaultActivityLevel,
          goal: goal ?? AppConstants.defaultGoal,
          avatar: avatar ?? AppConstants.defaultAvatar,
          loginCount: loginCount ?? AppConstants.defaultLoginCount,
          lastLogin: lastLogin ?? DateTime.now().toString(),
          completedGoals: completedGoals ?? 0,
          budget: budget ?? AppConstants.defaultBudget,
          notificationCount:
              notificationCount ?? AppConstants.defaultNotificationCount,
        );
      }
    }

    User updatedUser = _user!.copyWith(
      name: name ?? _user!.name,
      email: email ?? _user!.email,
      height: height ?? _user!.height,
      weight: weight ?? _user!.weight,
      age: age ?? _user!.age,
      gender: gender ?? _user!.gender,
      activityLevel: activityLevel ?? _user!.activityLevel,
      goal: goal ?? _user!.goal,
      avatar: avatar ?? _user!.avatar,
      loginCount: loginCount ?? _user!.loginCount,
      lastLogin: lastLogin ?? _user!.lastLogin,
      completedGoals: completedGoals ?? _user!.completedGoals,
      budget: budget ?? _user!.budget,
      notificationCount: notificationCount ?? _user!.notificationCount,
    );

    await updateUser(updatedUser);
  }

  /// Update avatar
  Future<void> setAvatar(String newAvatar) async {
    // Save to SharedPreferences first
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_avatar', newAvatar);

    // Update user data
    await updateUserField(avatar: newAvatar);

    // Force notify listeners
    notifyListeners();
  }

  /// Update name
  Future<void> setName(String newName) => updateUserField(name: newName);

  /// Update budget
  Future<void> setBudget(double newBudget) async {
    _hasSetBudget = true;
    await updateUserField(budget: newBudget);
  }

  /// Increment login count
  Future<void> incrementLoginCount() =>
      updateUserField(loginCount: loginCount + 1);

  /// Update last login time
  Future<void> updateLastLogin(String dateTime) =>
      updateUserField(lastLogin: dateTime);

  /// Increment completed goals
  Future<void> incrementCompletedGoals() =>
      updateUserField(completedGoals: completedGoals + 1);

  /// Clear all user data from the provider's state
  Future<void> clearUserData() async {
    // This only clears the in-memory state.
    // Persistent storage changes (like session status) are handled where this method is called.
    _user = null;
    _cachedLastLogin = null;
    _hasSetBudget = false;
    notifyListeners();
  }
}
