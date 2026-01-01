import 'package:zidni_mobile/billing/models/entitlement.dart';
import 'package:zidni_mobile/billing/services/entitlement_service.dart';
import 'package:zidni_mobile/usage/models/usage_record.dart';
import 'package:zidni_mobile/usage/services/usage_meter_service.dart';

/// Feature Gate Service
/// Gate BILL-1: Entitlements + Usage Meter + Paywall
///
/// Centralized feature flag system for gating features by tier
/// 
/// Strategy: "Free to 1M"
/// - Offline/local actions are UNLIMITED for free users (scans, searches, followups)
/// - Only PAID-COST actions are hard-limited (cloud boost, export PDF)
/// - Soft upgrade prompts based on behavior, not blocking

/// Available features that can be gated
enum Feature {
  /// Cloud boost for translation (LIMITED for free - costs money)
  cloudBoost,
  
  /// Export to PDF (OFF for free - costs money)
  exportPdf,
  
  /// Team mode with shared folders (OFF for now)
  teamMode,
  
  /// Verification/authentication features (OFF for now)
  verification,
  
  /// Unlimited follow-up kits (UNLIMITED for free - offline)
  unlimitedFollowups,
  
  /// Unlimited Eyes scans (UNLIMITED for free - offline)
  unlimitedScans,
  
  /// Unlimited searches (UNLIMITED for free - offline)
  unlimitedSearches,
}

extension FeatureExtension on Feature {
  /// Get Arabic name for the feature
  String get arabicName {
    switch (this) {
      case Feature.cloudBoost:
        return 'تعزيز السحابة';
      case Feature.exportPdf:
        return 'تصدير PDF';
      case Feature.teamMode:
        return 'وضع الفريق';
      case Feature.verification:
        return 'التحقق';
      case Feature.unlimitedFollowups:
        return 'متابعات غير محدودة';
      case Feature.unlimitedScans:
        return 'مسح غير محدود';
      case Feature.unlimitedSearches:
        return 'بحث غير محدود';
    }
  }
  
  /// Get English name for the feature
  String get englishName {
    switch (this) {
      case Feature.cloudBoost:
        return 'Cloud Boost';
      case Feature.exportPdf:
        return 'Export PDF';
      case Feature.teamMode:
        return 'Team Mode';
      case Feature.verification:
        return 'Verification';
      case Feature.unlimitedFollowups:
        return 'Unlimited Follow-ups';
      case Feature.unlimitedScans:
        return 'Unlimited Scans';
      case Feature.unlimitedSearches:
        return 'Unlimited Searches';
    }
  }
  
  /// Whether this feature has a real cost (requires hard limit)
  bool get hasCost {
    switch (this) {
      case Feature.cloudBoost:
        return true; // API calls cost money
      case Feature.exportPdf:
        return true; // PDF generation costs money
      case Feature.teamMode:
        return true; // Sync costs money
      case Feature.verification:
        return true; // Verification costs money
      case Feature.unlimitedFollowups:
        return false; // Offline, no cost
      case Feature.unlimitedScans:
        return false; // Offline, no cost
      case Feature.unlimitedSearches:
        return false; // Opens external browser, no cost
    }
  }
}

/// Result of a feature gate check
class FeatureGateResult {
  /// Whether the feature is allowed
  final bool allowed;
  
  /// Reason if not allowed
  final String? reason;
  
  /// Arabic reason if not allowed
  final String? arabicReason;
  
  /// Whether to show upgrade prompt
  final bool showUpgradePrompt;
  
  /// Remaining uses if limited
  final int? remainingUses;
  
  /// Whether this is a soft prompt (allowed but suggesting upgrade)
  final bool isSoftPrompt;
  
  const FeatureGateResult({
    required this.allowed,
    this.reason,
    this.arabicReason,
    this.showUpgradePrompt = false,
    this.remainingUses,
    this.isSoftPrompt = false,
  });
  
  /// Feature is allowed
  static const FeatureGateResult allow = FeatureGateResult(allowed: true);
  
  /// Feature is denied with upgrade prompt
  factory FeatureGateResult.deny({
    required String reason,
    required String arabicReason,
    bool showUpgradePrompt = true,
    int? remainingUses,
  }) {
    return FeatureGateResult(
      allowed: false,
      reason: reason,
      arabicReason: arabicReason,
      showUpgradePrompt: showUpgradePrompt,
      remainingUses: remainingUses,
    );
  }
  
  /// Feature is allowed but with soft upgrade suggestion
  factory FeatureGateResult.allowWithSoftPrompt({
    required String reason,
    required String arabicReason,
  }) {
    return FeatureGateResult(
      allowed: true,
      reason: reason,
      arabicReason: arabicReason,
      showUpgradePrompt: true,
      isSoftPrompt: true,
    );
  }
}

/// Feature Gate Service - centralized gating logic
class FeatureGate {
  // ============================================
  // Daily limits for PAID-COST features only
  // ============================================
  
  /// Free tier daily cloud boost limit (costs money)
  static const int freeDailyBoostLimit = 3;
  
  /// Free tier daily export limit (costs money)
  static const int freeDailyExportLimit = 0; // Export disabled for free
  
  // ============================================
  // Soft prompt thresholds (for offline features)
  // These don't block, just suggest upgrade
  // ============================================
  
  /// Threshold to show soft prompt for scans
  static const int softPromptScanThreshold = 20;
  
  /// Threshold to show soft prompt for searches
  static const int softPromptSearchThreshold = 30;
  
  /// Threshold to show soft prompt for followups
  static const int softPromptFollowupThreshold = 10;
  
  // ============================================
  // Feature checks
  // ============================================
  
  /// Check if a feature is enabled for the current user
  static Future<FeatureGateResult> check(Feature feature) async {
    final entitlement = await EntitlementService.getEntitlement();
    
    switch (feature) {
      case Feature.cloudBoost:
        return _checkCloudBoost(entitlement);
      case Feature.exportPdf:
        return _checkExportPdf(entitlement);
      case Feature.teamMode:
        return _checkTeamMode(entitlement);
      case Feature.verification:
        return _checkVerification(entitlement);
      case Feature.unlimitedFollowups:
        return _checkUnlimitedFollowups(entitlement);
      case Feature.unlimitedScans:
        return _checkUnlimitedScans(entitlement);
      case Feature.unlimitedSearches:
        return _checkUnlimitedSearches(entitlement);
    }
  }
  
  /// Quick check if feature is allowed (boolean only)
  static Future<bool> isAllowed(Feature feature) async {
    final result = await check(feature);
    return result.allowed;
  }
  
  // ============================================
  // HARD-LIMITED features (cost money)
  // ============================================
  
  static Future<FeatureGateResult> _checkCloudBoost(Entitlement entitlement) async {
    if (entitlement.isBusiness) {
      return FeatureGateResult.allow;
    }
    
    // Check daily limit for free users - HARD LIMIT (costs money)
    final todayUsage = await UsageMeterService.getTodayCount(UsageType.cloudBoostAttempted);
    final remaining = freeDailyBoostLimit - todayUsage;
    
    if (remaining > 0) {
      return FeatureGateResult(
        allowed: true,
        remainingUses: remaining,
      );
    }
    
    return FeatureGateResult.deny(
      reason: 'Daily cloud boost limit reached. Upgrade to Business for unlimited.',
      arabicReason: 'وصلت للحد اليومي من التعزيز السحابي. فعّل وضع الأعمال للاستخدام غير المحدود.',
      remainingUses: 0,
    );
  }
  
  static Future<FeatureGateResult> _checkExportPdf(Entitlement entitlement) async {
    if (entitlement.isBusiness) {
      return FeatureGateResult.allow;
    }
    
    // Export is completely disabled for free tier - HARD LIMIT (costs money)
    return FeatureGateResult.deny(
      reason: 'PDF export is a Business feature. Upgrade to unlock.',
      arabicReason: 'تصدير PDF متاح فقط لوضع الأعمال. فعّل للاستخدام.',
    );
  }
  
  static Future<FeatureGateResult> _checkTeamMode(Entitlement entitlement) async {
    // Team mode is not available yet
    return FeatureGateResult.deny(
      reason: 'Team mode coming soon.',
      arabicReason: 'وضع الفريق قريباً.',
      showUpgradePrompt: false,
    );
  }
  
  static Future<FeatureGateResult> _checkVerification(Entitlement entitlement) async {
    // Verification is not available yet
    return FeatureGateResult.deny(
      reason: 'Verification coming soon.',
      arabicReason: 'التحقق قريباً.',
      showUpgradePrompt: false,
    );
  }
  
  // ============================================
  // SOFT-PROMPTED features (offline, no cost)
  // Always allowed, but suggest upgrade at thresholds
  // ============================================
  
  static Future<FeatureGateResult> _checkUnlimitedFollowups(Entitlement entitlement) async {
    if (entitlement.isBusiness) {
      return FeatureGateResult.allow;
    }
    
    // ALWAYS ALLOWED - but show soft prompt at threshold
    final todayUsage = await UsageMeterService.getTodayCount(UsageType.followupCopies);
    
    if (todayUsage >= softPromptFollowupThreshold) {
      return FeatureGateResult.allowWithSoftPrompt(
        reason: 'You\'re using Zidni like a pro! Business mode gives you priority support.',
        arabicReason: 'أنت تستخدم Zidni كمحترف! وضع الأعمال يمنحك دعم أولوية.',
      );
    }
    
    return FeatureGateResult.allow;
  }
  
  static Future<FeatureGateResult> _checkUnlimitedScans(Entitlement entitlement) async {
    if (entitlement.isBusiness) {
      return FeatureGateResult.allow;
    }
    
    // ALWAYS ALLOWED - but show soft prompt at threshold
    final todayUsage = await UsageMeterService.getTodayCount(UsageType.eyesScans);
    
    if (todayUsage >= softPromptScanThreshold) {
      return FeatureGateResult.allowWithSoftPrompt(
        reason: 'You\'re scanning a lot! Business mode unlocks cloud backup.',
        arabicReason: 'أنت تمسح كثيراً! وضع الأعمال يفتح النسخ الاحتياطي السحابي.',
      );
    }
    
    return FeatureGateResult.allow;
  }
  
  static Future<FeatureGateResult> _checkUnlimitedSearches(Entitlement entitlement) async {
    if (entitlement.isBusiness) {
      return FeatureGateResult.allow;
    }
    
    // ALWAYS ALLOWED - but show soft prompt at threshold
    final todayUsage = await UsageMeterService.getTodayCount(UsageType.eyesSearches);
    
    if (todayUsage >= softPromptSearchThreshold) {
      return FeatureGateResult.allowWithSoftPrompt(
        reason: 'You\'re a power searcher! Business mode gives you export and team features.',
        arabicReason: 'أنت باحث محترف! وضع الأعمال يمنحك التصدير وميزات الفريق.',
      );
    }
    
    return FeatureGateResult.allow;
  }
  
  // ============================================
  // Business features list (for upgrade screen)
  // ============================================
  
  /// Get list of features unlocked by business tier
  /// Note: Only PAID-COST features are listed here
  static List<Feature> get businessFeatures => [
    Feature.cloudBoost,
    Feature.exportPdf,
  ];
  
  /// Get list of features coming soon
  static List<Feature> get comingSoonFeatures => [
    Feature.teamMode,
    Feature.verification,
  ];
  
  /// Get list of features that are always free (offline)
  static List<Feature> get alwaysFreeFeatures => [
    Feature.unlimitedScans,
    Feature.unlimitedSearches,
    Feature.unlimitedFollowups,
  ];
}
