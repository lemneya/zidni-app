import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zidni_mobile/billing/models/entitlement.dart';
import 'package:zidni_mobile/billing/services/entitlement_service.dart';
import 'package:zidni_mobile/billing/services/feature_gate.dart';
import 'package:zidni_mobile/usage/services/usage_meter_service.dart';


void main() {
  group('Entitlement Model', () {
    test('creates free entitlement by default', () {
      final entitlement = Entitlement.free();
      
      expect(entitlement.tier, SubscriptionTier.personalFree);
      expect(entitlement.isActive, true);
      expect(entitlement.isBusiness, false);
      expect(entitlement.isTeam, false);
    });
    
    test('business solo tier is marked as business', () {
      final entitlement = Entitlement(
        tier: SubscriptionTier.businessSolo,
        updatedAt: DateTime.now(),
      );
      
      expect(entitlement.isBusiness, true);
      expect(entitlement.isTeam, false);
    });
    
    test('business team tier is marked as team', () {
      final entitlement = Entitlement(
        tier: SubscriptionTier.businessTeam,
        updatedAt: DateTime.now(),
      );
      
      expect(entitlement.isBusiness, true);
      expect(entitlement.isTeam, true);
    });
    
    test('expired subscription is not active', () {
      final entitlement = Entitlement(
        tier: SubscriptionTier.businessSolo,
        expiresAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now(),
      );
      
      expect(entitlement.isActive, false);
      expect(entitlement.isBusiness, false); // Not business if expired
    });
    
    test('serializes to and from JSON correctly', () {
      final original = Entitlement(
        tier: SubscriptionTier.businessSolo,
        expiresAt: DateTime(2025, 12, 31),
        updatedAt: DateTime(2025, 1, 1),
        hasEverPaid: true,
      );
      
      final json = original.toJson();
      final restored = Entitlement.fromJson(json);
      
      expect(restored.tier, original.tier);
      expect(restored.hasEverPaid, original.hasEverPaid);
    });
  });
  
  group('SubscriptionTier Extension', () {
    test('tier IDs are correct', () {
      expect(SubscriptionTier.personalFree.id, 'personal_free');
      expect(SubscriptionTier.businessSolo.id, 'business_solo');
      expect(SubscriptionTier.businessTeam.id, 'business_team');
    });
    
    test('fromId returns correct tier', () {
      expect(SubscriptionTierExtension.fromId('personal_free'), SubscriptionTier.personalFree);
      expect(SubscriptionTierExtension.fromId('business_solo'), SubscriptionTier.businessSolo);
      expect(SubscriptionTierExtension.fromId('business_team'), SubscriptionTier.businessTeam);
      expect(SubscriptionTierExtension.fromId('unknown'), SubscriptionTier.personalFree);
    });
    
    test('has Arabic and English names', () {
      expect(SubscriptionTier.personalFree.arabicName, isNotEmpty);
      expect(SubscriptionTier.personalFree.englishName, isNotEmpty);
      expect(SubscriptionTier.businessSolo.arabicName, isNotEmpty);
      expect(SubscriptionTier.businessSolo.englishName, isNotEmpty);
    });
  });
  
  group('EntitlementService', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      EntitlementService.clearCache();
    });
    
    test('returns free entitlement by default', () async {
      final entitlement = await EntitlementService.getEntitlement();
      
      expect(entitlement.tier, SubscriptionTier.personalFree);
    });
    
    test('isBusiness returns false for free tier', () async {
      expect(await EntitlementService.isBusiness(), false);
    });
    
    test('setTierForTesting works correctly', () async {
      await EntitlementService.setTierForTesting(SubscriptionTier.businessSolo);
      
      expect(await EntitlementService.isBusiness(), true);
      expect(await EntitlementService.getTier(), SubscriptionTier.businessSolo);
    });
    
    test('resetToFree works correctly', () async {
      await EntitlementService.setTierForTesting(SubscriptionTier.businessSolo);
      await EntitlementService.resetToFree();
      
      expect(await EntitlementService.isBusiness(), false);
      expect(await EntitlementService.getTier(), SubscriptionTier.personalFree);
    });
  });
  
  group('FeatureGate - Hard Limits (Paid Features)', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      EntitlementService.clearCache();
      await UsageMeterService.clearAll();
    });
    
    test('export PDF is denied for free tier', () async {
      await EntitlementService.resetToFree();
      
      final result = await FeatureGate.check(Feature.exportPdf);
      
      expect(result.allowed, false);
      expect(result.showUpgradePrompt, true);
      expect(result.arabicReason, isNotEmpty);
    });
    
    test('export PDF is allowed for business tier', () async {
      await EntitlementService.setTierForTesting(SubscriptionTier.businessSolo);
      
      final result = await FeatureGate.check(Feature.exportPdf);
      
      expect(result.allowed, true);
    });
    
    test('cloud boost has daily limit for free tier', () async {
      await EntitlementService.resetToFree();
      
      // First check should be allowed with remaining uses
      final result = await FeatureGate.check(Feature.cloudBoost);
      
      expect(result.allowed, true);
      expect(result.remainingUses, FeatureGate.freeDailyBoostLimit);
    });
    
    test('cloud boost is unlimited for business tier', () async {
      await EntitlementService.setTierForTesting(SubscriptionTier.businessSolo);
      
      final result = await FeatureGate.check(Feature.cloudBoost);
      
      expect(result.allowed, true);
      expect(result.remainingUses, isNull); // No limit
    });
    
    test('team mode is not available yet', () async {
      await EntitlementService.setTierForTesting(SubscriptionTier.businessSolo);
      
      final result = await FeatureGate.check(Feature.teamMode);
      
      expect(result.allowed, false);
      expect(result.showUpgradePrompt, false); // Coming soon, not upgrade prompt
    });
    
    test('isAllowed returns boolean correctly', () async {
      await EntitlementService.resetToFree();
      
      expect(await FeatureGate.isAllowed(Feature.exportPdf), false);
      expect(await FeatureGate.isAllowed(Feature.cloudBoost), true);
    });
    
    test('businessFeatures list contains only paid features', () {
      expect(FeatureGate.businessFeatures, isNotEmpty);
      expect(FeatureGate.businessFeatures.contains(Feature.exportPdf), true);
      expect(FeatureGate.businessFeatures.contains(Feature.cloudBoost), true);
      // Offline features should NOT be in businessFeatures
      expect(FeatureGate.businessFeatures.contains(Feature.unlimitedScans), false);
    });
    
    test('comingSoonFeatures list contains team mode', () {
      expect(FeatureGate.comingSoonFeatures.contains(Feature.teamMode), true);
    });
    
    test('alwaysFreeFeatures list contains offline features', () {
      expect(FeatureGate.alwaysFreeFeatures.contains(Feature.unlimitedScans), true);
      expect(FeatureGate.alwaysFreeFeatures.contains(Feature.unlimitedSearches), true);
      expect(FeatureGate.alwaysFreeFeatures.contains(Feature.unlimitedFollowups), true);
    });
  });
  
  group('FeatureGate - Soft Prompts (Offline Features)', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      EntitlementService.clearCache();
      await UsageMeterService.clearAll();
    });
    
    test('scans are ALWAYS allowed for free tier (no hard limit)', () async {
      await EntitlementService.resetToFree();
      
      // Simulate heavy usage - should still be allowed
      for (int i = 0; i < 100; i++) {
        await UsageMeterService.trackEyesScan();
      }
      
      final result = await FeatureGate.check(Feature.unlimitedScans);
      
      expect(result.allowed, true); // ALWAYS allowed
    });
    
    test('scans show soft prompt at threshold', () async {
      await EntitlementService.resetToFree();
      
      // Simulate hitting soft prompt threshold
      for (int i = 0; i < FeatureGate.softPromptScanThreshold; i++) {
        await UsageMeterService.trackEyesScan();
      }
      
      final result = await FeatureGate.check(Feature.unlimitedScans);
      
      expect(result.allowed, true); // Still allowed
      expect(result.isSoftPrompt, true); // But with soft prompt
      expect(result.showUpgradePrompt, true);
    });
    
    test('searches are ALWAYS allowed for free tier (no hard limit)', () async {
      await EntitlementService.resetToFree();
      
      // Simulate heavy usage - should still be allowed
      for (int i = 0; i < 100; i++) {
        await UsageMeterService.trackEyesSearch();
      }
      
      final result = await FeatureGate.check(Feature.unlimitedSearches);
      
      expect(result.allowed, true); // ALWAYS allowed
    });
    
    test('followups are ALWAYS allowed for free tier (no hard limit)', () async {
      await EntitlementService.resetToFree();
      
      // Simulate heavy usage - should still be allowed
      for (int i = 0; i < 50; i++) {
        await UsageMeterService.trackFollowupCopy();
      }
      
      final result = await FeatureGate.check(Feature.unlimitedFollowups);
      
      expect(result.allowed, true); // ALWAYS allowed
    });
    
    test('business tier never sees soft prompts', () async {
      await EntitlementService.setTierForTesting(SubscriptionTier.businessSolo);
      
      // Simulate heavy usage
      for (int i = 0; i < 100; i++) {
        await UsageMeterService.trackEyesScan();
      }
      
      final result = await FeatureGate.check(Feature.unlimitedScans);
      
      expect(result.allowed, true);
      expect(result.isSoftPrompt, false); // No soft prompt for business
    });
  });
  
  group('Feature.hasCost', () {
    test('paid features have cost', () {
      expect(Feature.cloudBoost.hasCost, true);
      expect(Feature.exportPdf.hasCost, true);
      expect(Feature.teamMode.hasCost, true);
    });
    
    test('offline features have no cost', () {
      expect(Feature.unlimitedScans.hasCost, false);
      expect(Feature.unlimitedSearches.hasCost, false);
      expect(Feature.unlimitedFollowups.hasCost, false);
    });
  });
}
