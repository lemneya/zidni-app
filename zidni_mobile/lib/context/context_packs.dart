import 'package:flutter/material.dart';
import 'models/context_pack.dart';

/// Context Packs Registry
/// Gate LOC-1: Context Packs + Mode Selector
///
/// Const list of all available context packs.
/// These are offline-first, no remote config needed.

/// All available context packs
class ContextPacks {
  ContextPacks._();
  
  // ============================================
  // Pack 1: Guangzhou / Canton Fair
  // ============================================
  static const guangzhouCantonFair = ContextPack(
    id: 'guangzhou_cantonfair',
    titleAr: 'قوانغتشو / معرض كانتون',
    titleEn: 'Guangzhou / Canton Fair',
    defaultLangPair: LanguagePair.arZh,
    loudModeDefault: true, // Noisy trade fair environment
    quickPacks: [
      QuickPack.supplier,    // Most important for traders
      QuickPack.business,    // Negotiations
      QuickPack.taxi,        // Getting around
      QuickPack.hotel,       // Accommodation
      QuickPack.restaurant,  // Food
      QuickPack.numbers,     // Prices/quantities
      QuickPack.greetings,   // Basic courtesy
      QuickPack.shopping,    // Markets
    ],
    primaryShortcuts: [
      PrimaryShortcut.eyesScan,      // Scan products
      PrimaryShortcut.createDeal,    // Create deals
      PrimaryShortcut.findSupplier,  // Find suppliers
      PrimaryShortcut.history,       // View history
    ],
    icon: Icons.factory,
    themeColor: Color(0xFFE53935), // Red for China
    descriptionAr: 'للتجار في معرض كانتون وأسواق قوانغتشو',
    descriptionEn: 'For traders at Canton Fair and Guangzhou markets',
  );
  
  // ============================================
  // Pack 2: USA
  // ============================================
  static const usa = ContextPack(
    id: 'usa',
    titleAr: 'الولايات المتحدة',
    titleEn: 'United States',
    defaultLangPair: LanguagePair.arEn,
    loudModeDefault: false,
    quickPacks: [
      QuickPack.business,    // Business meetings
      QuickPack.airport,     // Travel
      QuickPack.hotel,       // Accommodation
      QuickPack.taxi,        // Transportation
      QuickPack.restaurant,  // Dining
      QuickPack.shopping,    // Shopping
      QuickPack.greetings,   // Social
      QuickPack.emergency,   // Safety
    ],
    primaryShortcuts: [
      PrimaryShortcut.translate,     // General translation
      PrimaryShortcut.quickPhrases,  // Quick phrases
      PrimaryShortcut.history,       // View history
      PrimaryShortcut.eyesScan,      // Scan documents
    ],
    icon: Icons.flight,
    themeColor: Color(0xFF1565C0), // Blue for USA
    descriptionAr: 'للسفر والأعمال في أمريكا',
    descriptionEn: 'For travel and business in America',
  );
  
  // ============================================
  // Pack 3: Egypt
  // ============================================
  static const egypt = ContextPack(
    id: 'egypt',
    titleAr: 'مصر',
    titleEn: 'Egypt',
    defaultLangPair: LanguagePair.arEn, // Many tourists speak English
    loudModeDefault: false,
    quickPacks: [
      QuickPack.greetings,   // Egyptian dialect
      QuickPack.taxi,        // Getting around Cairo
      QuickPack.shopping,    // Bazaars
      QuickPack.restaurant,  // Food
      QuickPack.hotel,       // Accommodation
      QuickPack.numbers,     // Bargaining
      QuickPack.emergency,   // Safety
      QuickPack.airport,     // Travel
    ],
    primaryShortcuts: [
      PrimaryShortcut.translate,     // General translation
      PrimaryShortcut.quickPhrases,  // Quick phrases
      PrimaryShortcut.history,       // View history
      PrimaryShortcut.eyesScan,      // Scan signs
    ],
    icon: Icons.mosque,
    themeColor: Color(0xFFFFB300), // Gold for Egypt
    descriptionAr: 'للسفر والتواصل في مصر',
    descriptionEn: 'For travel and communication in Egypt',
  );
  
  // ============================================
  // Pack 4: Travel Default (Fallback)
  // ============================================
  static const travelDefault = ContextPack(
    id: 'travel_default',
    titleAr: 'السفر العام',
    titleEn: 'General Travel',
    defaultLangPair: LanguagePair.arEn,
    loudModeDefault: false,
    quickPacks: [
      QuickPack.greetings,   // Basic courtesy
      QuickPack.taxi,        // Transportation
      QuickPack.hotel,       // Accommodation
      QuickPack.restaurant,  // Food
      QuickPack.airport,     // Travel
      QuickPack.shopping,    // Shopping
      QuickPack.emergency,   // Safety
      QuickPack.numbers,     // Basic numbers
    ],
    primaryShortcuts: [
      PrimaryShortcut.translate,     // General translation
      PrimaryShortcut.quickPhrases,  // Quick phrases
      PrimaryShortcut.history,       // View history
      PrimaryShortcut.eyesScan,      // Scan signs
    ],
    icon: Icons.public,
    themeColor: Color(0xFF43A047), // Green for general
    descriptionAr: 'للسفر العام حول العالم',
    descriptionEn: 'For general travel around the world',
  );
  
  // ============================================
  // Registry
  // ============================================
  
  /// All available packs
  static const List<ContextPack> all = [
    guangzhouCantonFair,
    usa,
    egypt,
    travelDefault,
  ];
  
  /// Get pack by ID
  static ContextPack? getById(String id) {
    try {
      return all.firstWhere((pack) => pack.id == id);
    } catch (_) {
      return null;
    }
  }
  
  /// Default pack (fallback)
  static const ContextPack defaultPack = travelDefault;
  
  /// Trade-focused packs (for Canton Fair traders)
  static const List<ContextPack> tradePacks = [
    guangzhouCantonFair,
  ];
  
  /// Travel-focused packs
  static const List<ContextPack> travelPacks = [
    usa,
    egypt,
    travelDefault,
  ];
}
