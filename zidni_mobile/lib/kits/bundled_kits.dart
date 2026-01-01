/// Bundled Kits Registry
/// Gate LOC-3: Offline Kits + Safe Optional Updates
///
/// These kits are bundled with the app and always available offline.
/// Remote updates can add new kits or update existing ones, but bundled
/// kits are never deleted.

import 'package:flutter/material.dart';
import 'models/offline_kit.dart';

/// All bundled kits (shipped with app)
class BundledKits {
  BundledKits._();
  
  // ============================================
  // Kit 1: Canton Fair Kit v1
  // ============================================
  static final cantonFairV1 = OfflineKit(
    id: 'kit_cantonfair_v1',
    version: 1,
    titleAr: 'حقيبة معرض كانتون',
    titleEn: 'Canton Fair Kit',
    descriptionAr: 'كل ما تحتاجه للتجارة في معرض كانتون وأسواق قوانغتشو',
    descriptionEn: 'Everything you need for trading at Canton Fair and Guangzhou markets',
    defaultPackId: 'guangzhou_cantonfair',
    phrasePacks: [
      PhrasePack.supplier,    // Most important for traders
      PhrasePack.business,    // Negotiations
      PhrasePack.numbers,     // Prices/quantities
      PhrasePack.taxi,        // Getting around
      PhrasePack.hotel,       // Accommodation
      PhrasePack.restaurant,  // Food
      PhrasePack.customs,     // Import/export
      PhrasePack.greetings,   // Basic courtesy
    ],
    updatedAt: DateTime(2026, 1, 1),
    isBundled: true,
    icon: Icons.factory,
    themeColor: const Color(0xFFE53935), // Red for China
  );
  
  // ============================================
  // Kit 2: Travel Basic Kit v1
  // ============================================
  static final travelBasicV1 = OfflineKit(
    id: 'kit_travel_basic_v1',
    version: 1,
    titleAr: 'حقيبة السفر الأساسية',
    titleEn: 'Travel Basic Kit',
    descriptionAr: 'عبارات أساسية للسفر والتنقل في أي مكان',
    descriptionEn: 'Essential phrases for traveling anywhere',
    defaultPackId: 'travel_default',
    phrasePacks: [
      PhrasePack.airport,     // Travel
      PhrasePack.hotel,       // Accommodation
      PhrasePack.taxi,        // Transportation
      PhrasePack.restaurant,  // Dining
      PhrasePack.shopping,    // Shopping
      PhrasePack.greetings,   // Social
      PhrasePack.emergency,   // Safety
      PhrasePack.medical,     // Health
    ],
    updatedAt: DateTime(2026, 1, 1),
    isBundled: true,
    icon: Icons.flight,
    themeColor: const Color(0xFF43A047), // Green for travel
  );
  
  // ============================================
  // All bundled kits
  // ============================================
  static final List<OfflineKit> all = [
    cantonFairV1,
    travelBasicV1,
  ];
  
  /// Get bundled kit by ID
  static OfflineKit? getById(String id) {
    try {
      return all.firstWhere((kit) => kit.id == id);
    } catch (_) {
      return null;
    }
  }
  
  /// Default kit (Canton Fair for traders)
  static OfflineKit get defaultKit => cantonFairV1;
}
