import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zidni_mobile/os/models/unified_history_item.dart';
import 'package:zidni_mobile/os/widgets/history_item_card.dart';

void main() {
  group('History Item Card Golden Tests', () {
    testWidgets('Translation item card', (tester) async {
      final item = UnifiedHistoryItem.fromTranslation(
        id: 'trans_123',
        transcript: 'مرحبا، كيف حالك؟',
        translation: 'Hello, how are you?',
        fromLang: 'ar',
        toLang: 'en',
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            backgroundColor: const Color(0xFF1A1A2E),
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: HistoryItemCard(item: item),
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/history_card_translation.png'),
      );
    });

    testWidgets('Eyes scan item card', (tester) async {
      final item = UnifiedHistoryItem.fromEyesScan(
        id: 'scan_123',
        productName: 'Samsung Galaxy S24 Ultra',
        rawText: 'Samsung Galaxy S24 Ultra 256GB Black SM-S928B/DS',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        extractedFields: {
          'brand': 'Samsung',
          'model': 'S24 Ultra',
          'sku': 'SM-S928B',
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            backgroundColor: const Color(0xFF1A1A2E),
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: HistoryItemCard(item: item),
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/history_card_eyes_scan.png'),
      );
    });

    testWidgets('Eyes search item card', (tester) async {
      final item = UnifiedHistoryItem.fromEyesSearch(
        id: 'search_123',
        query: 'LED light wholesale Guangzhou',
        platform: 'alibaba',
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        contextChips: ['广州', '工厂', 'MOQ'],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            backgroundColor: const Color(0xFF1A1A2E),
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: HistoryItemCard(item: item),
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/history_card_search.png'),
      );
    });

    testWidgets('Deal item card', (tester) async {
      final item = UnifiedHistoryItem.fromDeal(
        id: 'deal_123',
        productName: 'مصباح LED 12W',
        platform: '1688',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        status: 'جديدة',
        contextChips: ['广州', '批发'],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            backgroundColor: const Color(0xFF1A1A2E),
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: HistoryItemCard(item: item),
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/history_card_deal.png'),
      );
    });

    testWidgets('Mixed history feed', (tester) async {
      final items = [
        UnifiedHistoryItem.fromTranslation(
          id: 'trans_1',
          transcript: 'كم سعر هذا المنتج؟',
          translation: '这个产品多少钱？',
          fromLang: 'ar',
          toLang: 'zh',
          createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
        ),
        UnifiedHistoryItem.fromEyesScan(
          id: 'scan_1',
          productName: 'LED Light Bulb',
          rawText: 'LED 12W E27 Warm White',
          createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        ),
        UnifiedHistoryItem.fromDeal(
          id: 'deal_1',
          productName: 'LED Light Bulb',
          platform: '1688',
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            backgroundColor: const Color(0xFF1A1A2E),
            body: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: HistoryItemCard(item: items[index]),
              ),
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/history_feed_mixed.png'),
      );
    });
  });
}
