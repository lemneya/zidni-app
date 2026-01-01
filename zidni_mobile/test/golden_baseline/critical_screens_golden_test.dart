import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:zidni_mobile/eyes/widgets/product_insight_card.dart';
import 'package:zidni_mobile/eyes/widgets/find_it_results_card.dart';
import 'package:zidni_mobile/eyes/widgets/followup_kit_card.dart';
import 'package:zidni_mobile/context/widgets/mode_selector_chip.dart';
import 'package:zidni_mobile/context/widgets/pack_shortcuts_row.dart';
import 'package:zidni_mobile/os/widgets/history_item_card.dart';

import '../helpers/fakes.dart';
import '../helpers/test_app.dart';

/// GATE TEST-1: Golden Baseline Suite
/// 
/// This file contains golden tests for all critical screens in the app.
/// These tests serve as a regression net to catch unintended UI changes.
/// 
/// Run with: flutter test --update-goldens test/golden_baseline/

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    
    // Load fonts
    try {
      final fontLoader = FontLoader('NotoSansArabic');
      final arabicFontData = File('assets/fonts/NotoSansArabic-Regular.ttf').readAsBytesSync();
      fontLoader.addFont(Future.value(ByteData.view(arabicFontData.buffer)));
      await fontLoader.load();
      
      final robotoLoader = FontLoader('Roboto');
      final robotoFontData = File('assets/fonts/Roboto-Regular.ttf').readAsBytesSync();
      robotoLoader.addFont(Future.value(ByteData.view(robotoFontData.buffer)));
      await robotoLoader.load();
    } catch (e) {
      // Fonts may not be available in CI
    }
  });

  group('Golden Baseline Suite', () {
    // ============================================
    // EYES MODULE GOLDENS
    // ============================================
    
    testWidgets('Eyes: Product Insight Card (Chinese)', (tester) async {
      await tester.pumpWidget(
        TestApp.arabic(
          child: SingleChildScrollView(
            child: ProductInsightCard(
              result: FakeData.eyesScanChinese(),
              onRetake: () {},
              onSaveComplete: (_) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      
      await expectLater(
        find.byType(ProductInsightCard),
        matchesGoldenFile('goldens/baseline_eyes_product_card.png'),
      );
    });

    testWidgets('Eyes: Find It Results Card', (tester) async {
      await tester.pumpWidget(
        TestApp.arabic(
          child: SingleChildScrollView(
            child: FindItResultsCard(
              scanResult: FakeData.eyesScanChinese(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      
      await expectLater(
        find.byType(FindItResultsCard),
        matchesGoldenFile('goldens/baseline_eyes_find_it_card.png'),
      );
    });

    testWidgets('Eyes: Follow-up Kit Card (English)', (tester) async {
      final deal = FakeData.dealRecord();
      
      await tester.pumpWidget(
        TestApp.arabic(
          child: SingleChildScrollView(
            child: FollowupKitCard(
              deal: deal,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      
      await expectLater(
        find.byType(FollowupKitCard),
        matchesGoldenFile('goldens/baseline_eyes_followup_kit.png'),
      );
    });

    // ============================================
    // CONTEXT MODULE GOLDENS
    // ============================================
    
    testWidgets('Context: Mode Selector Chip (Guangzhou)', (tester) async {
      SharedPreferences.setMockInitialValues({
        'context_selected_pack_id': 'guangzhou_cantonfair',
      });
      
      await tester.pumpWidget(
        TestApp.arabic(
          child: const Padding(
            padding: EdgeInsets.all(16),
            child: ModeSelectorChip(
              onPackChanged: null,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      
      await expectLater(
        find.byType(ModeSelectorChip),
        matchesGoldenFile('goldens/baseline_context_mode_chip.png'),
      );
    });

    testWidgets('Context: Pack Shortcuts Row (Guangzhou)', (tester) async {
      SharedPreferences.setMockInitialValues({
        'context_selected_pack_id': 'guangzhou_cantonfair',
      });
      
      await tester.pumpWidget(
        TestApp.arabic(
          child: const Padding(
            padding: EdgeInsets.all(16),
            child: PackShortcutsRow(
              onEyesScanTap: null,
              onHistoryTap: null,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      
      await expectLater(
        find.byType(PackShortcutsRow),
        matchesGoldenFile('goldens/baseline_context_shortcuts.png'),
      );
    });

    // ============================================
    // HISTORY MODULE GOLDENS
    // ============================================
    
    testWidgets('History: Item Card (Eyes Scan)', (tester) async {
      final historyItems = FakeData.mixedHistoryItems();
      final scanItem = historyItems.first; // Eyes scan item
      
      await tester.pumpWidget(
        TestApp.arabic(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: HistoryItemCard(
              item: scanItem,
              onTap: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      
      await expectLater(
        find.byType(HistoryItemCard),
        matchesGoldenFile('goldens/baseline_history_card_scan.png'),
      );
    });

    testWidgets('History: Item Card (Deal)', (tester) async {
      final historyItems = FakeData.mixedHistoryItems();
      final dealItem = historyItems[2]; // Deal item
      
      await tester.pumpWidget(
        TestApp.arabic(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: HistoryItemCard(
              item: dealItem,
              onTap: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      
      await expectLater(
        find.byType(HistoryItemCard),
        matchesGoldenFile('goldens/baseline_history_card_deal.png'),
      );
    });
  });
}
