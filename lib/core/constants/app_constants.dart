class AppConstants {
  static const String appName = 'Besinova';
  static const String appVersion = '1.0.0';

  static const String baseApiUrl = 'http://10.0.2.2:5019/api';
  static const String productEndpoint = '$baseApiUrl/product';

  static const String storageKeyName = 'name';
  static const String storageKeyEmail = 'email';
  static const String storageKeyPassword = 'password';
  static const String storageKeyHeight = 'height';
  static const String storageKeyWeight = 'weight';
  static const String storageKeyAge = 'age';
  static const String storageKeyGender = 'gender';
  static const String storageKeyActivityLevel = 'activityLevel';
  static const String storageKeyGoal = 'goal';
  static const String storageKeyAvatar = 'avatar';
  static const String storageKeyLoginCount = 'loginCount';
  static const String storageKeyLastLogin = 'lastLogin';
  static const String storageKeyCompletedGoals = 'completedGoals';
  static const String storageKeyBudget = 'budget';
  static const String storageKeyNotificationCount = 'notificationCount';

  static const String defaultName = 'Kullanıcı';
  static const String defaultEmail = 'kullanici@besinova.com';
  static const double defaultHeight = 170.0;
  static const double defaultWeight = 70.0;
  static const int defaultAge = 25;
  static const String defaultGender = 'Erkek';
  static const String defaultActivityLevel = 'Orta';
  static const String defaultGoal = 'Sağlıklı Yaşam';
  static const String defaultAvatar = 'User';
  static const int defaultLoginCount = 1;
  static const double defaultBudget = 0.0;
  static const int defaultNotificationCount = 3;

  static const Duration splashDuration = Duration(seconds: 4);
  static const Duration animationDuration = Duration(milliseconds: 300);

  static const double proteinBudgetPercentage = 0.3;
  static const double carbsBudgetPercentage = 0.25;
  static const double fatBudgetPercentage = 0.15;
  static const double vegetablesFruitsBudgetPercentage = 0.2;
  static const double otherBudgetPercentage = 0.1;

  static const double preferenceBonusMultiplier = 1.5;
  static const double marketBonusMultiplier = 1.2;
  static const double priceNormalizationFactor = 10000.0;
}
