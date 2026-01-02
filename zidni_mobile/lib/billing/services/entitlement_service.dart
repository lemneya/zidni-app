import 'dart:convert';
import 'package:zidni_mobile/billing/models/entitlement.dart';
import 'package:zidni_mobile/core/secure_storage_service.dart';

/// Entitlement Service
/// Gate BILL-1: Entitlements + Usage Meter + Paywall
///
/// Single source of truth for user's subscription state
///
/// SECURITY: Uses SecureStorageService to prevent local tampering
/// with subscription status (e.g., users upgrading themselves to business tier)

class EntitlementService {
  static const String _storageKey = 'zidni_entitlement';
  static final _secureStorage = SecureStorageService();

  // Cached entitlement for quick access
  static Entitlement? _cachedEntitlement;

  /// Get the current entitlement (cached for performance)
  static Future<Entitlement> getEntitlement() async {
    if (_cachedEntitlement != null) {
      return _cachedEntitlement!;
    }

    final json = await _secureStorage.read(_storageKey);
    
    if (json != null) {
      try {
        final data = jsonDecode(json) as Map<String, dynamic>;
        _cachedEntitlement = Entitlement.fromJson(data);
        return _cachedEntitlement!;
      } catch (e) {
        // If parsing fails, return free tier
        _cachedEntitlement = Entitlement.free();
        return _cachedEntitlement!;
      }
    }
    
    // Default to free tier
    _cachedEntitlement = Entitlement.free();
    return _cachedEntitlement!;
  }
  
  /// Update the entitlement
  static Future<void> setEntitlement(Entitlement entitlement) async {
    await _secureStorage.write(_storageKey, jsonEncode(entitlement.toJson()));
    _cachedEntitlement = entitlement;
  }
  
  /// Check if user is on business tier (quick check)
  static Future<bool> isBusiness() async {
    final entitlement = await getEntitlement();
    return entitlement.isBusiness;
  }
  
  /// Check if user is on team tier (quick check)
  static Future<bool> isTeam() async {
    final entitlement = await getEntitlement();
    return entitlement.isTeam;
  }
  
  /// Get current tier
  static Future<SubscriptionTier> getTier() async {
    final entitlement = await getEntitlement();
    return entitlement.tier;
  }
  
  /// Upgrade to business solo (placeholder - will be called by payment flow in BILL-2)
  static Future<void> upgradeToBusinessSolo({DateTime? expiresAt}) async {
    final current = await getEntitlement();
    final upgraded = Entitlement(
      tier: SubscriptionTier.businessSolo,
      expiresAt: expiresAt,
      updatedAt: DateTime.now(),
      hasEverPaid: true,
    );
    await setEntitlement(upgraded);
    
    // Log audit event
    _logAuditEvent('entitlement_upgraded', {
      'from': current.tier.id,
      'to': upgraded.tier.id,
    });
  }
  
  /// Downgrade to free tier (e.g., subscription expired)
  static Future<void> downgradeToFree() async {
    final current = await getEntitlement();
    final downgraded = Entitlement(
      tier: SubscriptionTier.personalFree,
      updatedAt: DateTime.now(),
      hasEverPaid: current.hasEverPaid,
    );
    await setEntitlement(downgraded);
    
    // Log audit event
    _logAuditEvent('entitlement_downgraded', {
      'from': current.tier.id,
      'to': downgraded.tier.id,
    });
  }
  
  /// Restore purchase (placeholder - will verify with store in BILL-2)
  static Future<bool> restorePurchase() async {
    // Placeholder: In BILL-2, this will:
    // 1. Check with RevenueCat/App Store/Play Store
    // 2. Verify any existing subscriptions
    // 3. Update entitlement if valid subscription found
    
    _logAuditEvent('restore_purchase_attempted', {});
    
    // For now, return false (no purchase to restore)
    return false;
  }
  
  /// Clear cache (useful for testing or logout)
  static void clearCache() {
    _cachedEntitlement = null;
  }
  
  /// Log audit event (placeholder for analytics)
  static void _logAuditEvent(String event, Map<String, dynamic> data) {
    // TODO: Integrate with analytics in future
    print('[EntitlementService] $event: $data');
  }
  
  // ============================================
  // Development/Testing helpers
  // ============================================
  
  /// Set tier directly (for testing only)
  static Future<void> setTierForTesting(SubscriptionTier tier) async {
    final entitlement = Entitlement(
      tier: tier,
      updatedAt: DateTime.now(),
      hasEverPaid: tier.isBusiness,
    );
    await setEntitlement(entitlement);
  }
  
  /// Reset to free tier (for testing)
  static Future<void> resetToFree() async {
    await setEntitlement(Entitlement.free());
  }
}
