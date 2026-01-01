import 'package:zidni_mobile/billing/models/entitlement.dart';
import 'package:zidni_mobile/billing/services/entitlement_service.dart';
import 'package:zidni_mobile/usage/models/usage_record.dart';
import 'package:zidni_mobile/usage/services/usage_meter_service.dart';

/// Feature Gate Service
/// Gate BILL-1: Entitlements + Usage Meter + Paywall
///
/// Centralized feature flag system for gating features by tier

/// Available features that can be gated
enum Feature {
  /// Cloud boost for translation (OFF for free)
  cloudBoost,
  
  /// Export to PDF (ON for business, OFF for free)
  exportPdf,
  
  /// Team mode with shared folders (OFF for now)
  teamMode,
  
  /// Verification/authentication features (OFF for now)
  verification,
  
  /// Unlimited follow-up kits (limited for free)
  unlimitedFollowups,
  
  /// Unlimited Eyes scans (limited for free)
  unlimitedScans,
  
  /// Unlimited searches (limited for free)
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
  
  const FeatureGateResult({
    required this.allowed,
    this.reason,
    this.arabicReason,
    this.showUpgradePrompt = false,
    this.remainingUses,
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
}

/// Feature Gate Service - centralized gating logic
class FeatureGate {
  // ============================================
  // Daily limits for free tier
  // ============================================
  
  /// Free tier daily cloud boost limit
  static const int freeDailyBoostLimit = 3;
  
  /// Free tier daily scan limit
  static const int freeDailyScanLimit = 10;
  
  /// Free tier daily search limit
  static const int freeDailySearchLimit = 15;
  
  /// Free tier daily followup limit
  static const int freeDailyFollowupLimit = 5;
  
  /// Free tier daily export limit
  static const int freeDailyExportLimit = 0; // Export disabled for free
  
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
  // Individual feature checks
  // ============================================
  
  static Future<FeatureGateResult> _checkCloudBoost(Entitlement entitlement) async {
    if (entitlement.isBusiness) {
      return FeatureGateResult.allow;
    }
    
    // Check daily limit for free users
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
    
    // Export is completely disabled for free tier
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
  
  static Future<FeatureGateResult> _checkUnlimitedFollowups(Entitlement entitlement) async {
    if (entitlement.isBusiness) {
      return FeatureGateResult.allow;
    }
    
    final todayUsage = await UsageMeterService.getTodayCount(UsageType.followupCopies);
    final remaining = freeDailyFollowupLimit - todayUsage;
    
    if (remaining > 0) {
      return FeatureGateResult(
        allowed: true,
        remainingUses: remaining,
      );
    }
    
    return FeatureGateResult.deny(
      reason: 'Daily follow-up limit reached. Upgrade to Business for unlimited.',
      arabicReason: 'وصلت للحد اليومي من المتابعات. فعّل وضع الأعمال للاستخدام غير المحدود.',
      remainingUses: 0,
    );
  }
  
  static Future<FeatureGateResult> _checkUnlimitedScans(Entitlement entitlement) async {
    if (entitlement.isBusiness) {
      return FeatureGateResult.allow;
    }
    
    final todayUsage = await UsageMeterService.getTodayCount(UsageType.eyesScans);
    final remaining = freeDailyScanLimit - todayUsage;
    
    if (remaining > 0) {
      return FeatureGateResult(
        allowed: true,
        remainingUses: remaining,
      );
    }
    
    return FeatureGateResult.deny(
      reason: 'Daily scan limit reached. Upgrade to Business for unlimited.',
      arabicReason: 'وصلت للحد اليومي من المسح. فعّل وضع الأعمال للاستخدام غير المحدود.',
      remainingUses: 0,
    );
  }
  
  static Future<FeatureGateResult> _checkUnlimitedSearches(Entitlement entitlement) async {
    if (entitlement.isBusiness) {
      return FeatureGateResult.allow;
    }
    
    final todayUsage = await UsageMeterService.getTodayCount(UsageType.eyesSearches);
    final remaining = freeDailySearchLimit - todayUsage;
    
    if (remaining > 0) {
      return FeatureGateResult(
        allowed: true,
        remainingUses: remaining,
      );
    }
    
    return FeatureGateResult.deny(
      reason: 'Daily search limit reached. Upgrade to Business for unlimited.',
      arabicReason: 'وصلت للحد اليومي من البحث. فعّل وضع الأعمال للاستخدام غير المحدود.',
      remainingUses: 0,
    );
  }
  
  // ============================================
  // Business features list (for upgrade screen)
  // ============================================
  
  /// Get list of features unlocked by business tier
  static List<Feature> get businessFeatures => [
    Feature.cloudBoost,
    Feature.exportPdf,
    Feature.unlimitedFollowups,
    Feature.unlimitedScans,
    Feature.unlimitedSearches,
  ];
  
  /// Get list of features coming soon
  static List<Feature> get comingSoonFeatures => [
    Feature.teamMode,
    Feature.verification,
  ];
}
