import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zidni_mobile/context/context.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    ContextService.clearCache();
  });

  group('Context Pack Selection', () {
    test('returns default pack when none selected', () async {
      final pack = await ContextService.getSelectedPack();
      expect(pack.id, equals(ContextPacks.defaultPack.id));
    });
    
    test('persists selected pack', () async {
      await ContextService.setSelectedPack(ContextPacks.guangzhouCantonFair);
      ContextService.clearCache();
      
      final pack = await ContextService.getSelectedPack();
      expect(pack.id, equals('guangzhou_cantonfair'));
    });
    
    test('returns correct pack after selection', () async {
      await ContextService.setSelectedPack(ContextPacks.usa);
      
      final pack = await ContextService.getSelectedPack();
      expect(pack.id, equals('usa'));
      expect(pack.titleAr, equals('الولايات المتحدة'));
    });
    
    test('cache works correctly', () async {
      await ContextService.setSelectedPack(ContextPacks.egypt);
      
      // First call loads from cache
      final pack1 = await ContextService.getSelectedPack();
      final pack2 = await ContextService.getSelectedPack();
      
      expect(pack1.id, equals(pack2.id));
      expect(pack1.id, equals('egypt'));
    });
  });
  
  group('Suggestion Modal', () {
    test('should show suggestion on first open', () async {
      final shouldShow = await ContextService.shouldShowSuggestion();
      expect(shouldShow, isTrue);
    });
    
    test('should not show after being shown', () async {
      await ContextService.markSuggestionShown();
      
      final shouldShow = await ContextService.shouldShowSuggestion();
      expect(shouldShow, isFalse);
    });
    
    test('should not show after being dismissed', () async {
      await ContextService.dismissSuggestion();
      
      final shouldShow = await ContextService.shouldShowSuggestion();
      expect(shouldShow, isFalse);
    });
    
    test('dismiss persists across sessions', () async {
      await ContextService.dismissSuggestion();
      
      // Simulate new session
      ContextService.clearCache();
      
      final shouldShow = await ContextService.shouldShowSuggestion();
      expect(shouldShow, isFalse);
    });
  });
  
  group('Pack Impacts', () {
    test('returns correct language pair for Guangzhou pack', () async {
      await ContextService.setSelectedPack(ContextPacks.guangzhouCantonFair);
      
      final langPair = await ContextService.getDefaultLanguagePair();
      expect(langPair, equals(LanguagePair.arZh));
      expect(langPair.targetCode, equals('zh'));
    });
    
    test('returns correct language pair for USA pack', () async {
      await ContextService.setSelectedPack(ContextPacks.usa);
      
      final langPair = await ContextService.getDefaultLanguagePair();
      expect(langPair, equals(LanguagePair.arEn));
      expect(langPair.targetCode, equals('en'));
    });
    
    test('loud mode enabled for Guangzhou pack', () async {
      await ContextService.setSelectedPack(ContextPacks.guangzhouCantonFair);
      
      final shouldEnableLoud = await ContextService.shouldEnableLoudMode();
      expect(shouldEnableLoud, isTrue);
    });
    
    test('loud mode disabled for USA pack', () async {
      await ContextService.setSelectedPack(ContextPacks.usa);
      
      final shouldEnableLoud = await ContextService.shouldEnableLoudMode();
      expect(shouldEnableLoud, isFalse);
    });
    
    test('returns correct quick packs for Guangzhou', () async {
      await ContextService.setSelectedPack(ContextPacks.guangzhouCantonFair);
      
      final quickPacks = await ContextService.getQuickPacks();
      expect(quickPacks.first, equals(QuickPack.supplier));
    });
    
    test('returns correct primary shortcuts for Guangzhou', () async {
      await ContextService.setSelectedPack(ContextPacks.guangzhouCantonFair);
      
      final shortcuts = await ContextService.getPrimaryShortcuts();
      expect(shortcuts.contains(PrimaryShortcut.eyesScan), isTrue);
      expect(shortcuts.contains(PrimaryShortcut.createDeal), isTrue);
    });
  });
  
  group('Context Packs Registry', () {
    test('all packs are registered', () {
      expect(ContextPacks.all.length, equals(4));
    });
    
    test('getById returns correct pack', () {
      final pack = ContextPacks.getById('guangzhou_cantonfair');
      expect(pack, isNotNull);
      expect(pack!.titleAr, equals('قوانغتشو / معرض كانتون'));
    });
    
    test('getById returns null for unknown id', () {
      final pack = ContextPacks.getById('unknown_pack');
      expect(pack, isNull);
    });
    
    test('each pack has unique id', () {
      final ids = ContextPacks.all.map((p) => p.id).toSet();
      expect(ids.length, equals(ContextPacks.all.length));
    });
    
    test('each pack has required fields', () {
      for (final pack in ContextPacks.all) {
        expect(pack.id, isNotEmpty);
        expect(pack.titleAr, isNotEmpty);
        expect(pack.titleEn, isNotEmpty);
        expect(pack.descriptionAr, isNotEmpty);
        expect(pack.quickPacks, isNotEmpty);
        expect(pack.primaryShortcuts, isNotEmpty);
      }
    });
  });
  
  group('Reset', () {
    test('resetAll clears all settings', () async {
      await ContextService.setSelectedPack(ContextPacks.guangzhouCantonFair);
      await ContextService.dismissSuggestion();
      
      await ContextService.resetAll();
      
      final pack = await ContextService.getSelectedPack();
      expect(pack.id, equals(ContextPacks.defaultPack.id));
      
      final shouldShow = await ContextService.shouldShowSuggestion();
      expect(shouldShow, isTrue);
    });
  });
}
