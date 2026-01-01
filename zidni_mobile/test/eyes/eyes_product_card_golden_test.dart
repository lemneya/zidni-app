import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zidni_mobile/eyes/models/eyes_scan_result.dart';
import 'package:zidni_mobile/eyes/widgets/product_insight_card.dart';

/// Golden tests for Eyes Product Insight Card
/// Gate EYES-1: Visual proof of OCR result card
void main() {
  group('Eyes Product Insight Card Golden Tests', () {
    testWidgets('renders with Chinese text result', (tester) async {
      final result = EyesScanResult(
        rawText: '智能摄像头\n品牌: 海康威视\n型号: DS-2CD2143G2-I\n尺寸: 110x90mm',
        detectedLanguage: 'zh',
        productNameGuess: '智能摄像头',
        extractedFields: {
          'brand': '海康威视',
          'model': 'DS-2CD2143G2-I',
          'size': '110x90mm',
        },
        scannedAt: DateTime(2025, 1, 1, 12, 0),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              backgroundColor: const Color(0xFF1A1A2E),
              body: ProductInsightCard(
                result: result,
                imagePath: null,
                onRetake: () {},
                onSaveComplete: (_) {},
              ),
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(ProductInsightCard),
        matchesGoldenFile('goldens/eyes_product_card_chinese.png'),
      );
    });

    testWidgets('renders with Arabic text result', (tester) async {
      final result = EyesScanResult(
        rawText: 'كاميرا مراقبة ذكية\nالعلامة: هيكفيجن\nالموديل: DS-2CD2143',
        detectedLanguage: 'ar',
        productNameGuess: 'كاميرا مراقبة ذكية',
        extractedFields: {
          'brand': 'هيكفيجن',
          'model': 'DS-2CD2143',
        },
        scannedAt: DateTime(2025, 1, 1, 12, 0),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              backgroundColor: const Color(0xFF1A1A2E),
              body: ProductInsightCard(
                result: result,
                imagePath: null,
                onRetake: () {},
                onSaveComplete: (_) {},
              ),
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(ProductInsightCard),
        matchesGoldenFile('goldens/eyes_product_card_arabic.png'),
      );
    });

    testWidgets('renders with no product name detected', (tester) async {
      final result = EyesScanResult(
        rawText: '12345678901234',
        detectedLanguage: 'unknown',
        productNameGuess: null,
        extractedFields: {
          'sku': '12345678901234',
        },
        scannedAt: DateTime(2025, 1, 1, 12, 0),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              backgroundColor: const Color(0xFF1A1A2E),
              body: ProductInsightCard(
                result: result,
                imagePath: null,
                onRetake: () {},
                onSaveComplete: (_) {},
              ),
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(ProductInsightCard),
        matchesGoldenFile('goldens/eyes_product_card_no_name.png'),
      );
    });
  });
}
