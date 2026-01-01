import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zidni_mobile/billing/screens/upgrade_screen.dart';
import 'package:zidni_mobile/billing/widgets/soft_upgrade_modal.dart';
import 'package:zidni_mobile/billing/services/feature_gate.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('Upgrade Screen Golden Tests', () {
    testWidgets('upgrade screen renders correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: UpgradeScreen(),
        ),
      );
      
      await tester.pumpAndSettle();
      
      await expectLater(
        find.byType(UpgradeScreen),
        matchesGoldenFile('goldens/upgrade_screen.png'),
      );
    });
    
    testWidgets('upgrade screen with triggered feature', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: UpgradeScreen(
            triggeredByFeature: Feature.exportPdf,
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      await expectLater(
        find.byType(UpgradeScreen),
        matchesGoldenFile('goldens/upgrade_screen_triggered.png'),
      );
    });
  });
  
  group('Soft Upgrade Modal Golden Tests', () {
    testWidgets('many deals trigger modal', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => Center(
                child: SoftUpgradeModal(
                  trigger: UpgradeTrigger.manyDeals,
                ),
              ),
            ),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      await expectLater(
        find.byType(SoftUpgradeModal),
        matchesGoldenFile('goldens/soft_modal_deals.png'),
      );
    });
    
    testWidgets('frequent searches trigger modal', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => Center(
                child: SoftUpgradeModal(
                  trigger: UpgradeTrigger.frequentSearches,
                ),
              ),
            ),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      await expectLater(
        find.byType(SoftUpgradeModal),
        matchesGoldenFile('goldens/soft_modal_searches.png'),
      );
    });
    
    testWidgets('export attempt trigger modal', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => Center(
                child: SoftUpgradeModal(
                  trigger: UpgradeTrigger.exportAttempt,
                ),
              ),
            ),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      await expectLater(
        find.byType(SoftUpgradeModal),
        matchesGoldenFile('goldens/soft_modal_export.png'),
      );
    });
    
    testWidgets('daily limit trigger modal', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => Center(
                child: SoftUpgradeModal(
                  trigger: UpgradeTrigger.dailyLimitReached,
                ),
              ),
            ),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      await expectLater(
        find.byType(SoftUpgradeModal),
        matchesGoldenFile('goldens/soft_modal_limit.png'),
      );
    });
  });
}
