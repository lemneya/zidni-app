import '../../models/app_mode.dart';

/// Pure function service for mapping country codes to suggested app modes.
/// 
/// This service contains the business logic for determining which mode
/// should be suggested based on the user's detected country.
class ModeRules {
  ModeRules._();

  /// MENA region country codes (Middle East and North Africa)
  static const Set<String> menaCountryCodes = {
    'DZ', // Algeria
    'BH', // Bahrain
    'EG', // Egypt
    'IQ', // Iraq
    'JO', // Jordan
    'KW', // Kuwait
    'LB', // Lebanon
    'LY', // Libya
    'MR', // Mauritania
    'MA', // Morocco
    'OM', // Oman
    'PS', // Palestine
    'QA', // Qatar
    'SA', // Saudi Arabia
    'SD', // Sudan
    'SY', // Syria
    'TN', // Tunisia
    'AE', // United Arab Emirates
    'YE', // Yemen
  };

  /// China country code
  static const String chinaCountryCode = 'CN';

  /// USA country code
  static const String usaCountryCode = 'US';

  /// Get suggested mode based on country code.
  /// 
  /// Rules:
  /// - US → Immigration Mode
  /// - CN → Canton Fair Mode
  /// - MENA countries → Home Mode
  /// - All others → Travel Mode
  static AppMode getSuggestedMode(String countryCode) {
    final normalizedCode = countryCode.toUpperCase().trim();

    if (normalizedCode == usaCountryCode) {
      return AppMode.immigration;
    }

    if (normalizedCode == chinaCountryCode) {
      return AppMode.cantonFair;
    }

    if (menaCountryCodes.contains(normalizedCode)) {
      return AppMode.home;
    }

    return AppMode.travel;
  }

  /// Check if a country code is in the MENA region
  static bool isMenaCountry(String countryCode) {
    return menaCountryCodes.contains(countryCode.toUpperCase().trim());
  }

  /// Check if a country code is China
  static bool isChina(String countryCode) {
    return countryCode.toUpperCase().trim() == chinaCountryCode;
  }

  /// Check if a country code is USA
  static bool isUsa(String countryCode) {
    return countryCode.toUpperCase().trim() == usaCountryCode;
  }

  /// Get the reason for mode suggestion (for UI display)
  static String getSuggestionReason(String countryCode, {bool arabic = true}) {
    final mode = getSuggestedMode(countryCode);
    
    if (arabic) {
      switch (mode) {
        case AppMode.immigration:
          return 'اكتشفنا أنك في الولايات المتحدة. هل تريد التبديل إلى وضع الهجرة؟';
        case AppMode.cantonFair:
          return 'اكتشفنا أنك في الصين. هل تريد التبديل إلى وضع معرض كانتون؟';
        case AppMode.home:
          return 'اكتشفنا أنك في منطقتك. هل تريد التبديل إلى الوضع المحلي؟';
        case AppMode.travel:
          return 'هل تريد استخدام وضع السفر؟';
      }
    } else {
      switch (mode) {
        case AppMode.immigration:
          return 'We detected you\'re in the USA. Switch to Immigration Mode?';
        case AppMode.cantonFair:
          return 'We detected you\'re in China. Switch to Canton Fair Mode?';
        case AppMode.home:
          return 'We detected you\'re in your home region. Switch to Home Mode?';
        case AppMode.travel:
          return 'Would you like to use Travel Mode?';
      }
    }
  }
}
