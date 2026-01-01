import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zidni_mobile/eyes/models/deal_record.dart';
import 'package:zidni_mobile/eyes/widgets/followup_kit_card.dart';

void main() {
  group('FollowupKitCard Golden Tests', () {
    testWidgets('renders with English supplier template (Alibaba)', (tester) async {
      final deal = DealRecord(
        id: 'deal_123',
        productName: 'Samsung Galaxy S24 Ultra',
        ocrRawText: 'Samsung Galaxy S24 Ultra\nModel: SM-S928B\nColor: Titanium Black',
        extractedFields: {
          'brand': 'Samsung',
          'model': 'Galaxy S24 Ultra',
          'sku': 'SM-S928B',
        },
        searchQuery: 'Samsung Galaxy S24 Ultra',
        selectedPlatform: 'alibaba',
        contextChips: [],
        createdAt: DateTime(2024, 1, 15, 10, 30),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            body: Directionality(
              textDirection: TextDirection.rtl,
              child: FollowupKitCard(deal: deal),
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(FollowupKitCard),
        matchesGoldenFile('goldens/followup_kit_english.png'),
      );
    });

    testWidgets('renders with Chinese supplier template (1688)', (tester) async {
      final deal = DealRecord(
        id: 'deal_456',
        productName: 'LED灯泡 12W',
        ocrRawText: 'LED灯泡\n功率: 12W\n电压: 220V\n品牌: 飞利浦',
        extractedFields: {
          'brand': '飞利浦',
          'model': 'LED-12W',
        },
        searchQuery: 'LED灯泡 飞利浦 广州 工厂',
        selectedPlatform: '1688',
        contextChips: ['广州', '工厂'],
        createdAt: DateTime(2024, 1, 15, 10, 30),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            body: Directionality(
              textDirection: TextDirection.rtl,
              child: FollowupKitCard(deal: deal),
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(FollowupKitCard),
        matchesGoldenFile('goldens/followup_kit_chinese.png'),
      );
    });

    testWidgets('renders with Arabic product (minimal fields)', (tester) async {
      final deal = DealRecord(
        id: 'deal_789',
        productName: 'مصباح LED',
        ocrRawText: 'مصباح LED\nقوة: 12 واط',
        extractedFields: {},
        searchQuery: 'مصباح LED',
        createdAt: DateTime(2024, 1, 15, 10, 30),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            body: Directionality(
              textDirection: TextDirection.rtl,
              child: FollowupKitCard(deal: deal),
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(FollowupKitCard),
        matchesGoldenFile('goldens/followup_kit_arabic.png'),
      );
    });
  });
}
