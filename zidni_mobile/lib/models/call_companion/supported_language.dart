/// Supported Language Model for Call Companion Mode
/// Defines the languages available for translation

import 'package:flutter/material.dart';

/// Enum of supported languages for Call Companion
enum SupportedLanguage {
  arabic,
  chinese,
  english,
  turkish,
}

/// Extension methods for SupportedLanguage
extension SupportedLanguageExtension on SupportedLanguage {
  /// Language code for ML Kit and Whisper
  String get code {
    switch (this) {
      case SupportedLanguage.arabic:
        return 'ar';
      case SupportedLanguage.chinese:
        return 'zh';
      case SupportedLanguage.english:
        return 'en';
      case SupportedLanguage.turkish:
        return 'tr';
    }
  }

  /// BCP-47 locale code
  String get localeCode {
    switch (this) {
      case SupportedLanguage.arabic:
        return 'ar-SA';
      case SupportedLanguage.chinese:
        return 'zh-CN';
      case SupportedLanguage.english:
        return 'en-US';
      case SupportedLanguage.turkish:
        return 'tr-TR';
    }
  }

  /// Display name in Arabic
  String get nameAr {
    switch (this) {
      case SupportedLanguage.arabic:
        return 'العربية';
      case SupportedLanguage.chinese:
        return 'الصينية';
      case SupportedLanguage.english:
        return 'الإنجليزية';
      case SupportedLanguage.turkish:
        return 'التركية';
    }
  }

  /// Display name in native language
  String get nameNative {
    switch (this) {
      case SupportedLanguage.arabic:
        return 'العربية';
      case SupportedLanguage.chinese:
        return '中文';
      case SupportedLanguage.english:
        return 'English';
      case SupportedLanguage.turkish:
        return 'Türkçe';
    }
  }

  /// Flag emoji for the language
  String get flag {
    switch (this) {
      case SupportedLanguage.arabic:
        return '🇸🇦';
      case SupportedLanguage.chinese:
        return '🇨🇳';
      case SupportedLanguage.english:
        return '🇺🇸';
      case SupportedLanguage.turkish:
        return '🇹🇷';
    }
  }

  /// Text direction for the language
  TextDirection get textDirection {
    switch (this) {
      case SupportedLanguage.arabic:
        return TextDirection.rtl;
      case SupportedLanguage.chinese:
      case SupportedLanguage.english:
      case SupportedLanguage.turkish:
        return TextDirection.ltr;
    }
  }

  /// Color associated with the language (for UI)
  Color get color {
    switch (this) {
      case SupportedLanguage.arabic:
        return Colors.blue;
      case SupportedLanguage.chinese:
        return Colors.red;
      case SupportedLanguage.english:
        return Colors.indigo;
      case SupportedLanguage.turkish:
        return Colors.red.shade700;
    }
  }

  /// Whisper model language code
  String get whisperCode {
    switch (this) {
      case SupportedLanguage.arabic:
        return 'ar';
      case SupportedLanguage.chinese:
        return 'zh';
      case SupportedLanguage.english:
        return 'en';
      case SupportedLanguage.turkish:
        return 'tr';
    }
  }

  /// Whether this is a right-to-left language
  bool get isRtl => this == SupportedLanguage.arabic;

  /// Get language from code
  static SupportedLanguage fromCode(String code) {
    switch (code.toLowerCase()) {
      case 'ar':
        return SupportedLanguage.arabic;
      case 'zh':
        return SupportedLanguage.chinese;
      case 'en':
        return SupportedLanguage.english;
      case 'tr':
        return SupportedLanguage.turkish;
      default:
        return SupportedLanguage.english;
    }
  }
}

/// Model for a language pair (source → target)
class LanguagePair {
  /// Source language (what the other person speaks)
  final SupportedLanguage source;

  /// Target language (what you speak - always Arabic for now)
  final SupportedLanguage target;

  const LanguagePair({
    required this.source,
    required this.target,
  });

  /// Default pair: Chinese → Arabic
  static const defaultPair = LanguagePair(
    source: SupportedLanguage.chinese,
    target: SupportedLanguage.arabic,
  );

  /// Common pairs for Arab users
  static const chineseArabic = LanguagePair(
    source: SupportedLanguage.chinese,
    target: SupportedLanguage.arabic,
  );

  static const englishArabic = LanguagePair(
    source: SupportedLanguage.english,
    target: SupportedLanguage.arabic,
  );

  static const turkishArabic = LanguagePair(
    source: SupportedLanguage.turkish,
    target: SupportedLanguage.arabic,
  );

  /// All available pairs
  static const List<LanguagePair> allPairs = [
    chineseArabic,
    englishArabic,
    turkishArabic,
  ];

  /// Display string for the pair
  String get displayAr => '${source.nameAr} ↔ ${target.nameAr}';

  /// Display with flags
  String get displayWithFlags => '${source.flag} ${source.nameNative} ↔ ${target.flag} ${target.nameNative}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LanguagePair &&
          runtimeType == other.runtimeType &&
          source == other.source &&
          target == other.target;

  @override
  int get hashCode => source.hashCode ^ target.hashCode;
}
