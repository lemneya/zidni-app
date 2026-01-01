import 'package:zidni_mobile/eyes/models/eyes_scan_result.dart';
import 'package:zidni_mobile/eyes/models/search_query.dart';
import 'package:zidni_mobile/eyes/models/deal_record.dart';
import 'package:zidni_mobile/context/models/context_pack.dart';
import 'package:zidni_mobile/context/context_packs.dart';
import 'package:zidni_mobile/kits/models/offline_kit.dart';
import 'package:zidni_mobile/kits/bundled_kits.dart';
import 'package:zidni_mobile/billing/models/entitlement.dart';
import 'package:zidni_mobile/os/models/unified_history_item.dart';

/// Fake data generators for tests.
/// Use these to create consistent test data across all tests.

class FakeData {
  // ============================================
  // EYES MODULE FAKES
  // ============================================

  /// Creates a fake Eyes scan result with Chinese product text.
  static EyesScanResult eyesScanChinese() {
    return EyesScanResult(
      id: 'fake-scan-001',
      rawText: 'Samsung Galaxy S24 Ultra\n型号: SM-S928B\n256GB\n韩国制造',
      detectedLanguage: 'zh',
      productNameGuess: 'Samsung Galaxy S24 Ultra',
      extractedFields: const {
        'brand': 'Samsung',
        'model': 'SM-S928B',
        'storage': '256GB',
        'origin': '韩国制造',
      },
      scannedAt: DateTime(2026, 1, 1, 10, 30),
    );
  }

  /// Creates a fake Eyes scan result with Arabic product text.
  static EyesScanResult eyesScanArabic() {
    return EyesScanResult(
      id: 'fake-scan-002',
      rawText: 'مصباح LED\nالقوة: 15 واط\nاللون: أبيض دافئ',
      detectedLanguage: 'ar',
      productNameGuess: 'مصباح LED',
      extractedFields: const {
        'power': '15 واط',
        'color': 'أبيض دافئ',
      },
      scannedAt: DateTime(2026, 1, 1, 11, 0),
    );
  }

  /// Creates a fake Eyes scan result with barcode only.
  static EyesScanResult eyesScanBarcode() {
    return EyesScanResult(
      id: 'fake-scan-003',
      rawText: '6901234567890',
      detectedLanguage: 'unknown',
      productNameGuess: null,
      extractedFields: const {
        'barcode': '6901234567890',
      },
      scannedAt: DateTime(2026, 1, 1, 11, 30),
    );
  }

  // ============================================
  // SEARCH QUERY FAKES
  // ============================================

  /// Creates a fake search query for Alibaba.
  static SearchQuery searchQueryAlibaba() {
    return SearchQuery(
      baseQuery: 'Samsung Galaxy S24 Ultra SM-S928B',
      platform: 'alibaba',
      contextChips: const ['Guangzhou', 'Factory'],
      createdAt: DateTime(2026, 1, 1, 10, 35),
      scanResultId: 'fake-scan-001',
    );
  }

  /// Creates a fake search query for 1688.
  static SearchQuery searchQuery1688() {
    return SearchQuery(
      baseQuery: 'LED灯泡 15W',
      platform: '1688',
      contextChips: const ['广州', '工厂', 'MOQ'],
      createdAt: DateTime(2026, 1, 1, 11, 5),
      scanResultId: 'fake-scan-002',
    );
  }

  // ============================================
  // DEAL RECORD FAKES
  // ============================================

  /// Creates a fake deal record.
  static DealRecord dealRecord() {
    return DealRecord(
      id: 'fake-deal-001',
      productName: 'Samsung Galaxy S24 Ultra',
      ocrRawText: 'Samsung Galaxy S24 Ultra\n型号: SM-S928B',
      extractedFields: const {
        'brand': 'Samsung',
        'model': 'SM-S928B',
      },
      searchQuery: 'Samsung Galaxy S24 Ultra SM-S928B',
      selectedPlatform: 'alibaba',
      contextChips: const ['Guangzhou', 'Factory'],
      createdAt: DateTime(2026, 1, 1, 10, 40),
    );
  }

  // ============================================
  // CONTEXT PACK FAKES
  // ============================================

  /// Returns the Guangzhou context pack.
  static ContextPack contextPackGuangzhou() {
    return ContextPacks.guangzhouCantonFair;
  }

  /// Returns the USA context pack.
  static ContextPack contextPackUSA() {
    return ContextPacks.usa;
  }

  /// Returns the Travel Default context pack.
  static ContextPack contextPackTravel() {
    return ContextPacks.travelDefault;
  }

  // ============================================
  // OFFLINE KIT FAKES
  // ============================================

  /// Returns the Canton Fair kit.
  static OfflineKit kitCantonFair() {
    return BundledKits.cantonFairV1;
  }

  /// Returns the Travel Basic kit.
  static OfflineKit kitTravelBasic() {
    return BundledKits.travelBasicV1;
  }

  // ============================================
  // ENTITLEMENT FAKES
  // ============================================

  /// Creates a free tier entitlement.
  static Entitlement entitlementFree() {
    return Entitlement(
      tier: SubscriptionTier.personalFree,
      updatedAt: DateTime(2026, 1, 1),
    );
  }

  /// Creates a business solo entitlement.
  static Entitlement entitlementBusiness() {
    return Entitlement(
      tier: SubscriptionTier.businessSolo,
      expiresAt: DateTime(2027, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );
  }

  // ============================================
  // UNIFIED HISTORY FAKES
  // ============================================

  /// Creates a list of mixed history items for testing.
  static List<UnifiedHistoryItem> mixedHistoryItems() {
    return [
      UnifiedHistoryItem(
        id: 'hist-001',
        type: HistoryItemType.eyesScan,
        title: 'Samsung Galaxy S24 Ultra',
        subtitle: 'مسح المنتج',
        createdAt: DateTime(2026, 1, 1, 10, 30),
        metadata: const {'scanId': 'fake-scan-001'},
      ),
      UnifiedHistoryItem(
        id: 'hist-002',
        type: HistoryItemType.eyesSearch,
        title: 'Samsung Galaxy S24 Ultra SM-S928B',
        subtitle: 'بحث على Alibaba',
        createdAt: DateTime(2026, 1, 1, 10, 35),
        metadata: const {'searchId': 'fake-search-001', 'platform': 'alibaba'},
      ),
      UnifiedHistoryItem(
        id: 'hist-003',
        type: HistoryItemType.deal,
        title: 'Samsung Galaxy S24 Ultra',
        subtitle: 'صفقة جديدة',
        createdAt: DateTime(2026, 1, 1, 10, 40),
        metadata: const {'dealId': 'fake-deal-001'},
      ),
      UnifiedHistoryItem(
        id: 'hist-004',
        type: HistoryItemType.translation,
        title: 'مرحبا، أريد شراء هذا المنتج',
        subtitle: 'ترجمة',
        createdAt: DateTime(2026, 1, 1, 9, 0),
        metadata: const {'captureId': 'fake-capture-001'},
      ),
    ];
  }
}
