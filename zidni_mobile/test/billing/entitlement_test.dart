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
  
  group('FeatureGate', () {
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
    
    test('businessFeatures list is not empty', () {
      expect(FeatureGate.businessFeatures, isNotEmpty);
      expect(FeatureGate.businessFeatures.contains(Feature.exportPdf), true);
    });
    
    test('comingSoonFeatures list contains team mode', () {
      expect(FeatureGate.comingSoonFeatures.contains(Feature.teamMode), true);
    });
  });
  
  group('Feature Limits', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      EntitlementService.clearCache();
      await UsageMeterService.clearAll();
    });
    
    test('scan limit is enforced for free tier', () async {
      await EntitlementService.resetToFree();
      
      // Simulate hitting the limit
      for (int i = 0; i < FeatureGate.freeDailyScanLimit; i++) {
        await UsageMeterService.trackEyesScan();
      }
      
      final result = await FeatureGate.check(Feature.unlimitedScans);
      
      expect(result.allowed, false);
      expect(result.remainingUses, 0);
    });
    
    test('scan limit is not enforced for business tier', () async {
      await EntitlementService.setTierForTesting(SubscriptionTier.businessSolo);
      
      // Simulate heavy usage
      for (int i = 0; i < 100; i++) {
        await UsageMeterService.trackEyesScan();
      }
      
      final result = await FeatureGate.check(Feature.unlimitedScans);
      
      expect(result.allowed, true);
    });
  });
}
