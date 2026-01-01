import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zidni_mobile/eyes/models/eyes_scan_result.dart';
import 'package:zidni_mobile/eyes/widgets/find_it_results_card.dart';

void main() {
  group('FindItResultsCard Golden Tests', () {
    testWidgets('renders with Chinese product OCR result', (tester) async {
      final result = EyesScanResult(
        id: 'test-1',
        rawText: '三星 Galaxy S24 Ultra\n型号: SM-S928B\n颜色: 钛黑色\n存储: 256GB',
        detectedLanguage: 'zh',
        productNameGuess: '三星 Galaxy S24 Ultra',
        extractedFields: {
          'brand': 'Samsung',
          'model': 'Galaxy S24 Ultra',
          'sku': 'SM-S928B',
        },
        scannedAt: DateTime(2024, 1, 15, 10, 30),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            body: Directionality(
              textDirection: TextDirection.rtl,
              child: FindItResultsCard(scanResult: result),
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(FindItResultsCard),
        matchesGoldenFile('goldens/find_it_card_chinese.png'),
      );
    });

    testWidgets('renders with Arabic product OCR result', (tester) async {
      final result = EyesScanResult(
        id: 'test-2',
        rawText: 'مصباح LED\nقوة: 12 واط\nاللون: أبيض بارد\nالجهد: 220V',
        detectedLanguage: 'ar',
        productNameGuess: 'مصباح LED 12 واط',
        extractedFields: {
          'brand': 'Philips',
          'model': 'LED-12W',
        },
        scannedAt: DateTime(2024, 1, 15, 10, 30),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            body: Directionality(
              textDirection: TextDirection.rtl,
              child: FindItResultsCard(scanResult: result),
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(FindItResultsCard),
        matchesGoldenFile('goldens/find_it_card_arabic.png'),
      );
    });

    testWidgets('renders with minimal OCR result (barcode only)', (tester) async {
      final result = EyesScanResult(
        id: 'test-3',
        rawText: '6901234567890',
        detectedLanguage: 'en',
        extractedFields: {
          'sku': '6901234567890',
        },
        scannedAt: DateTime(2024, 1, 15, 10, 30),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            body: Directionality(
              textDirection: TextDirection.rtl,
              child: FindItResultsCard(scanResult: result),
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(FindItResultsCard),
        matchesGoldenFile('goldens/find_it_card_barcode.png'),
      );
    });
  });
}
