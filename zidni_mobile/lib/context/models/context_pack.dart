import 'package:flutter/material.dart';

/// Context Pack Model
/// Gate LOC-1: Context Packs + Mode Selector
///
/// Represents a location/context-specific configuration pack
/// that personalizes the UI without building separate UIs.

/// Language pair for translation defaults
enum LanguagePair {
  /// Arabic ↔ Chinese (Mandarin)
  arZh,
  
  /// Arabic ↔ English
  arEn,
  
  /// Arabic ↔ French
  arFr,
  
  /// Arabic ↔ Spanish
  arEs,
}

extension LanguagePairExtension on LanguagePair {
  /// Get the source language code
  String get sourceCode {
    switch (this) {
      case LanguagePair.arZh:
      case LanguagePair.arEn:
      case LanguagePair.arFr:
      case LanguagePair.arEs:
        return 'ar';
    }
  }
  
  /// Get the target language code
  String get targetCode {
    switch (this) {
      case LanguagePair.arZh:
        return 'zh';
      case LanguagePair.arEn:
        return 'en';
      case LanguagePair.arFr:
        return 'fr';
      case LanguagePair.arEs:
        return 'es';
    }
  }
  
  /// Get Arabic display name
  String get arabicName {
    switch (this) {
      case LanguagePair.arZh:
        return 'عربي ↔ صيني';
      case LanguagePair.arEn:
        return 'عربي ↔ إنجليزي';
      case LanguagePair.arFr:
        return 'عربي ↔ فرنسي';
      case LanguagePair.arEs:
        return 'عربي ↔ إسباني';
    }
  }
  
  /// Get English display name
  String get englishName {
    switch (this) {
      case LanguagePair.arZh:
        return 'Arabic ↔ Chinese';
      case LanguagePair.arEn:
        return 'Arabic ↔ English';
      case LanguagePair.arFr:
        return 'Arabic ↔ French';
      case LanguagePair.arEs:
        return 'Arabic ↔ Spanish';
    }
  }
}

/// Quick phrase pack category
enum QuickPack {
  supplier,
  taxi,
  hotel,
  restaurant,
  shopping,
  airport,
  emergency,
  business,
  greetings,
  numbers,
}

extension QuickPackExtension on QuickPack {
  /// Get Arabic name
  String get arabicName {
    switch (this) {
      case QuickPack.supplier:
        return 'المورد';
      case QuickPack.taxi:
        return 'التاكسي';
      case QuickPack.hotel:
        return 'الفندق';
      case QuickPack.restaurant:
        return 'المطعم';
      case QuickPack.shopping:
        return 'التسوق';
      case QuickPack.airport:
        return 'المطار';
      case QuickPack.emergency:
        return 'الطوارئ';
      case QuickPack.business:
        return 'الأعمال';
      case QuickPack.greetings:
        return 'التحيات';
      case QuickPack.numbers:
        return 'الأرقام';
    }
  }
  
  /// Get English name
  String get englishName {
    switch (this) {
      case QuickPack.supplier:
        return 'Supplier';
      case QuickPack.taxi:
        return 'Taxi';
      case QuickPack.hotel:
        return 'Hotel';
      case QuickPack.restaurant:
        return 'Restaurant';
      case QuickPack.shopping:
        return 'Shopping';
      case QuickPack.airport:
        return 'Airport';
      case QuickPack.emergency:
        return 'Emergency';
      case QuickPack.business:
        return 'Business';
      case QuickPack.greetings:
        return 'Greetings';
      case QuickPack.numbers:
        return 'Numbers';
    }
  }
  
  /// Get icon for the pack
  IconData get icon {
    switch (this) {
      case QuickPack.supplier:
        return Icons.factory;
      case QuickPack.taxi:
        return Icons.local_taxi;
      case QuickPack.hotel:
        return Icons.hotel;
      case QuickPack.restaurant:
        return Icons.restaurant;
      case QuickPack.shopping:
        return Icons.shopping_bag;
      case QuickPack.airport:
        return Icons.flight;
      case QuickPack.emergency:
        return Icons.emergency;
      case QuickPack.business:
        return Icons.business_center;
      case QuickPack.greetings:
        return Icons.waving_hand;
      case QuickPack.numbers:
        return Icons.numbers;
    }
  }
}

/// Primary shortcut action
enum PrimaryShortcut {
  eyesScan,
  createDeal,
  history,
  quickPhrases,
  findSupplier,
  translate,
}

extension PrimaryShortcutExtension on PrimaryShortcut {
  /// Get Arabic name
  String get arabicName {
    switch (this) {
      case PrimaryShortcut.eyesScan:
        return 'مسح';
      case PrimaryShortcut.createDeal:
        return 'صفقة';
      case PrimaryShortcut.history:
        return 'السجل';
      case PrimaryShortcut.quickPhrases:
        return 'عبارات';
      case PrimaryShortcut.findSupplier:
        return 'مورد';
      case PrimaryShortcut.translate:
        return 'ترجمة';
    }
  }
  
  /// Get English name
  String get englishName {
    switch (this) {
      case PrimaryShortcut.eyesScan:
        return 'Scan';
      case PrimaryShortcut.createDeal:
        return 'Deal';
      case PrimaryShortcut.history:
        return 'History';
      case PrimaryShortcut.quickPhrases:
        return 'Phrases';
      case PrimaryShortcut.findSupplier:
        return 'Supplier';
      case PrimaryShortcut.translate:
        return 'Translate';
    }
  }
  
  /// Get icon
  IconData get icon {
    switch (this) {
      case PrimaryShortcut.eyesScan:
        return Icons.document_scanner;
      case PrimaryShortcut.createDeal:
        return Icons.handshake;
      case PrimaryShortcut.history:
        return Icons.history;
      case PrimaryShortcut.quickPhrases:
        return Icons.chat_bubble;
      case PrimaryShortcut.findSupplier:
        return Icons.search;
      case PrimaryShortcut.translate:
        return Icons.translate;
    }
  }
}

/// Context Pack - location/context-specific configuration
class ContextPack {
  /// Unique identifier
  final String id;
  
  /// Arabic title
  final String titleAr;
  
  /// English title
  final String titleEn;
  
  /// Default language pair for translation
  final LanguagePair defaultLangPair;
  
  /// Ordered list of quick phrase packs
  final List<QuickPack> quickPacks;
  
  /// Primary shortcuts to show
  final List<PrimaryShortcut> primaryShortcuts;
  
  /// Whether loud mode should be enabled by default
  final bool loudModeDefault;
  
  /// Icon for the pack
  final IconData icon;
  
  /// Color theme for the pack
  final Color themeColor;
  
  /// Description in Arabic
  final String descriptionAr;
  
  /// Description in English
  final String descriptionEn;
  
  const ContextPack({
    required this.id,
    required this.titleAr,
    required this.titleEn,
    required this.defaultLangPair,
    required this.quickPacks,
    required this.primaryShortcuts,
    this.loudModeDefault = false,
    required this.icon,
    required this.themeColor,
    required this.descriptionAr,
    required this.descriptionEn,
  });
  
  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titleAr': titleAr,
      'titleEn': titleEn,
      'defaultLangPair': defaultLangPair.name,
      'loudModeDefault': loudModeDefault,
    };
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ContextPack && other.id == id;
  }
  
  @override
  int get hashCode => id.hashCode;
}
