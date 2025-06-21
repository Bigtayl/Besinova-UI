/// Service for handling application localization
class LocalizationService {
  static const String _defaultLanguage = 'tr';
  static String _currentLanguage = _defaultLanguage;

  /// Current language code
  static String get currentLanguage => _currentLanguage;

  /// Set current language
  static void setLanguage(String languageCode) =>
      _currentLanguage = languageCode;

  /// Translate text (placeholder for future implementation)
  /// In the future, this should use proper localization packages like intl
  static String t(String key) => key;

  /// Get localized text with parameters
  static String tWithParams(String key, Map<String, String> params) {
    String text = t(key);

    for (final entry in params.entries) {
      text = text.replaceAll('{${entry.key}}', entry.value);
    }

    return text;
  }

  /// Check if current language is Turkish
  static bool get isTurkish => _currentLanguage == 'tr';

  /// Check if current language is English
  static bool get isEnglish => _currentLanguage == 'en';
}
