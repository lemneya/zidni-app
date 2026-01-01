import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zidni_mobile/context/context.dart';

void main() {
  group('Pack Shortcuts Ordering Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
      ContextService.clearCache();
    });
    
    test('Guangzhou pack should have trade-focused shortcuts', () async {
      // Set Guangzhou pack
      final pack = ContextPacks.getById('guangzhou_cantonfair')!;
      await ContextService.setSelectedPack(pack);
      
      // Verify pack is selected
      final selectedPack = await ContextService.getSelectedPack();
      expect(selectedPack.id, equals('guangzhou_cantonfair'));
      
      // Guangzhou shortcuts should include: Eyes Scan, Create Deal, Find Supplier, History
      expect(selectedPack.primaryShortcuts, contains(PrimaryShortcut.eyesScan));
      expect(selectedPack.primaryShortcuts, contains(PrimaryShortcut.createDeal));
      expect(selectedPack.primaryShortcuts, contains(PrimaryShortcut.findSupplier));
      expect(selectedPack.primaryShortcuts, contains(PrimaryShortcut.history));
    });
    
    test('USA pack should have travel-focused shortcuts', () async {
      // Set USA pack
      final pack = ContextPacks.getById('usa')!;
      await ContextService.setSelectedPack(pack);
      
      // Verify pack is selected
      final selectedPack = await ContextService.getSelectedPack();
      expect(selectedPack.id, equals('usa'));
      
      // USA shortcuts should include: Translate, Quick Phrases, History, Eyes Scan
      expect(selectedPack.primaryShortcuts, contains(PrimaryShortcut.eyesScan));
      expect(selectedPack.primaryShortcuts, contains(PrimaryShortcut.history));
      expect(selectedPack.primaryShortcuts, contains(PrimaryShortcut.translate));
      expect(selectedPack.primaryShortcuts, contains(PrimaryShortcut.quickPhrases));
    });
    
    test('Egypt pack should have travel-focused shortcuts', () async {
      // Set Egypt pack
      final pack = ContextPacks.getById('egypt')!;
      await ContextService.setSelectedPack(pack);
      
      // Verify pack is selected
      final selectedPack = await ContextService.getSelectedPack();
      expect(selectedPack.id, equals('egypt'));
      
      // Egypt shortcuts should include travel-focused items
      expect(selectedPack.primaryShortcuts, contains(PrimaryShortcut.eyesScan));
      expect(selectedPack.primaryShortcuts, contains(PrimaryShortcut.history));
    });
    
    test('Travel default pack should have balanced shortcuts', () async {
      // Set travel default pack
      final pack = ContextPacks.getById('travel_default')!;
      await ContextService.setSelectedPack(pack);
      
      // Verify pack is selected
      final selectedPack = await ContextService.getSelectedPack();
      expect(selectedPack.id, equals('travel_default'));
      
      // Travel default should have balanced shortcuts
      expect(selectedPack.primaryShortcuts, contains(PrimaryShortcut.eyesScan));
      expect(selectedPack.primaryShortcuts, contains(PrimaryShortcut.history));
    });
    
    test('Pack selection persists across service calls', () async {
      // Select Guangzhou pack
      final guangzhou = ContextPacks.getById('guangzhou_cantonfair')!;
      await ContextService.setSelectedPack(guangzhou);
      
      // Get pack in new call
      final pack1 = await ContextService.getSelectedPack();
      expect(pack1.id, equals('guangzhou_cantonfair'));
      
      // Change to USA
      ContextService.clearCache();
      final usa = ContextPacks.getById('usa')!;
      await ContextService.setSelectedPack(usa);
      
      // Verify change persisted
      final pack2 = await ContextService.getSelectedPack();
      expect(pack2.id, equals('usa'));
    });
    
    test('Shortcuts differ between Guangzhou and other packs', () async {
      // Get Guangzhou pack
      final guangzhouPack = ContextPacks.getById('guangzhou_cantonfair')!;
      
      // Get USA pack
      final usaPack = ContextPacks.getById('usa')!;
      
      // Guangzhou has trade-focused shortcuts
      expect(guangzhouPack.primaryShortcuts, contains(PrimaryShortcut.createDeal));
      expect(guangzhouPack.primaryShortcuts, contains(PrimaryShortcut.findSupplier));
      
      // USA has travel-focused shortcuts (no createDeal or findSupplier)
      expect(usaPack.primaryShortcuts, isNot(contains(PrimaryShortcut.createDeal)));
      expect(usaPack.primaryShortcuts, isNot(contains(PrimaryShortcut.findSupplier)));
      expect(usaPack.primaryShortcuts, contains(PrimaryShortcut.translate));
    });
  });
}
