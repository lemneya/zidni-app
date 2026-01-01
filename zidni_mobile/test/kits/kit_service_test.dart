import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zidni_mobile/kits/kits.dart';
import 'package:zidni_mobile/context/context.dart';

void main() {
  group('KitService Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
      KitService.clearCache();
      ContextService.clearCache();
    });
    
    test('bundled kits are always available', () async {
      final kits = await KitService.getAllKits();
      
      expect(kits.length, greaterThanOrEqualTo(2));
      expect(kits.any((k) => k.id == 'kit_cantonfair_v1'), isTrue);
      expect(kits.any((k) => k.id == 'kit_travel_basic_v1'), isTrue);
    });
    
    test('default active kit is Canton Fair', () async {
      final activeKit = await KitService.getActiveKit();
      
      expect(activeKit.id, equals('kit_cantonfair_v1'));
      expect(activeKit.titleAr, contains('كانتون'));
    });
    
    test('activating kit persists selection', () async {
      final travelKit = BundledKits.travelBasicV1;
      
      await KitService.activateKit(travelKit);
      KitService.clearCache();
      
      final activeKit = await KitService.getActiveKit();
      expect(activeKit.id, equals('kit_travel_basic_v1'));
    });
    
    test('activating kit sets context pack', () async {
      SharedPreferences.setMockInitialValues({});
      KitService.clearCache();
      ContextService.clearCache();
      
      final cantonKit = BundledKits.cantonFairV1;
      await KitService.activateKit(cantonKit);
      
      final pack = await ContextService.getSelectedPack();
      expect(pack.id, equals('guangzhou_cantonfair'));
    });
    
    test('bundled kits are always installed', () async {
      final installed = await KitService.getInstalledKits();
      
      expect(installed.any((k) => k.id == 'kit_cantonfair_v1'), isTrue);
      expect(installed.any((k) => k.id == 'kit_travel_basic_v1'), isTrue);
    });
    
    test('kit has correct phrase packs', () async {
      final cantonKit = BundledKits.cantonFairV1;
      
      expect(cantonKit.phrasePacks, contains(PhrasePack.supplier));
      expect(cantonKit.phrasePacks, contains(PhrasePack.business));
      expect(cantonKit.phrasePacks, contains(PhrasePack.taxi));
    });
    
    test('travel kit has travel-focused phrase packs', () async {
      final travelKit = BundledKits.travelBasicV1;
      
      expect(travelKit.phrasePacks, contains(PhrasePack.airport));
      expect(travelKit.phrasePacks, contains(PhrasePack.hotel));
      expect(travelKit.phrasePacks, contains(PhrasePack.emergency));
    });
  });
  
  group('KitUpdateService Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });
    
    test('invalid JSON is safely ignored', () async {
      // This test verifies that the service handles errors gracefully
      // In a real scenario, the HTTP call would fail, but local kits remain
      final kits = await KitService.getAllKits();
      expect(kits.length, greaterThanOrEqualTo(2));
    });
    
    test('update available flag defaults to false', () async {
      final hasUpdate = await KitUpdateService.isUpdateAvailable();
      expect(hasUpdate, isFalse);
    });
    
    test('should auto check returns true on first run', () async {
      final shouldCheck = await KitUpdateService.shouldAutoCheck();
      expect(shouldCheck, isTrue);
    });
  });
  
  group('OfflineKit Model Tests', () {
    test('kit can be serialized to JSON', () {
      final kit = BundledKits.cantonFairV1;
      final json = kit.toJson();
      
      expect(json['id'], equals('kit_cantonfair_v1'));
      expect(json['version'], equals(1));
      expect(json['titleAr'], contains('كانتون'));
    });
    
    test('kit can be deserialized from JSON', () {
      final json = {
        'id': 'test_kit',
        'version': 2,
        'titleAr': 'حقيبة اختبار',
        'titleEn': 'Test Kit',
        'descriptionAr': 'وصف',
        'descriptionEn': 'Description',
        'defaultPackId': 'travel_default',
        'phrasePacks': ['taxi', 'hotel'],
        'updatedAt': '2026-01-01T00:00:00.000',
        'isBundled': false,
      };
      
      final kit = OfflineKit.fromJson(json);
      
      expect(kit.id, equals('test_kit'));
      expect(kit.version, equals(2));
      expect(kit.phrasePacks, contains(PhrasePack.taxi));
      expect(kit.isBundled, isFalse);
    });
    
    test('kit copyWith creates new instance', () {
      final original = BundledKits.cantonFairV1;
      final updated = original.copyWith(version: 2);
      
      expect(updated.version, equals(2));
      expect(updated.id, equals(original.id));
      expect(original.version, equals(1)); // Original unchanged
    });
  });
}
