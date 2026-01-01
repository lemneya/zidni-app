import 'package:flutter_test/flutter_test.dart';
import 'package:zidni_mobile/eyes/models/deal_record.dart';
import 'package:zidni_mobile/eyes/models/eyes_scan_result.dart';
import 'package:zidni_mobile/eyes/models/search_query.dart';
import 'package:zidni_mobile/eyes/services/followup_kit_service.dart';

void main() {
  group('DealRecord', () {
    test('creates from scan result and query', () {
      final scanResult = EyesScanResult(
        id: 'scan-123',
        rawText: 'Samsung Galaxy S24 Ultra\nModel: SM-S928B',
        productNameGuess: 'Samsung Galaxy S24 Ultra',
        extractedFields: {
          'brand': 'Samsung',
          'model': 'Galaxy S24 Ultra',
          'sku': 'SM-S928B',
        },
        scannedAt: DateTime(2024, 1, 15),
      );

      final query = SearchQuery(
        baseQuery: 'Samsung Galaxy S24 Ultra',
        brand: 'Samsung',
        model: 'Galaxy S24 Ultra',
        contextChips: ['广州', '工厂'],
        platform: 'alibaba',
        createdAt: DateTime.now(),
      );

      final deal = DealRecord.fromScanAndQuery(
        scanResult: scanResult,
        query: query,
        selectedPlatform: 'alibaba',
      );

      expect(deal.productName, 'Samsung Galaxy S24 Ultra');
      expect(deal.ocrRawText, contains('Samsung'));
      expect(deal.extractedFields['brand'], 'Samsung');
      expect(deal.extractedFields['model'], 'Galaxy S24 Ultra');
      expect(deal.searchQuery, 'Samsung Galaxy S24 Ultra 广州 工厂');
      expect(deal.selectedPlatform, 'alibaba');
      expect(deal.contextChips, ['广州', '工厂']);
      expect(deal.scanResultId, 'scan-123');
      expect(deal.status, DealStatus.created);
    });

    test('serializes to JSON and back', () {
      final original = DealRecord(
        id: 'deal_123',
        productName: 'Test Product',
        ocrRawText: 'Raw OCR text',
        extractedFields: {'brand': 'TestBrand'},
        searchQuery: 'Test Product 广州',
        selectedPlatform: '1688',
        contextChips: ['广州', '工厂'],
        createdAt: DateTime(2024, 1, 15, 10, 30),
        imagePath: '/path/to/image.jpg',
        scanResultId: 'scan-456',
        status: DealStatus.followedUp,
      );

      final json = original.toJson();
      final restored = DealRecord.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.productName, original.productName);
      expect(restored.ocrRawText, original.ocrRawText);
      expect(restored.extractedFields, original.extractedFields);
      expect(restored.searchQuery, original.searchQuery);
      expect(restored.selectedPlatform, original.selectedPlatform);
      expect(restored.contextChips, original.contextChips);
      expect(restored.imagePath, original.imagePath);
      expect(restored.scanResultId, original.scanResultId);
      expect(restored.status, original.status);
    });

    test('displayName returns product name when available', () {
      final deal = DealRecord(
        id: 'deal_123',
        productName: 'Samsung Galaxy',
        ocrRawText: 'text',
        searchQuery: 'query',
        createdAt: DateTime.now(),
      );

      expect(deal.displayName, 'Samsung Galaxy');
    });

    test('displayName returns truncated query when no product name', () {
      final deal = DealRecord(
        id: 'deal_123',
        ocrRawText: 'text',
        searchQuery: 'This is a very long search query that should be truncated',
        createdAt: DateTime.now(),
      );

      expect(deal.displayName.length, lessThanOrEqualTo(33)); // 30 + "..."
    });

    test('copyWith creates new instance with updated values', () {
      final original = DealRecord(
        id: 'deal_123',
        productName: 'Original',
        ocrRawText: 'text',
        searchQuery: 'query',
        createdAt: DateTime.now(),
        status: DealStatus.created,
      );

      final updated = original.copyWith(
        productName: 'Updated',
        status: DealStatus.completed,
      );

      expect(updated.id, original.id);
      expect(updated.productName, 'Updated');
      expect(updated.status, DealStatus.completed);
      expect(original.productName, 'Original');
      expect(original.status, DealStatus.created);
    });
  });

  group('DealStatus', () {
    test('has correct Arabic names', () {
      expect(DealStatus.created.arabicName, 'جديدة');
      expect(DealStatus.followedUp.arabicName, 'تم المتابعة');
      expect(DealStatus.completed.arabicName, 'مكتملة');
    });

    test('has correct English names', () {
      expect(DealStatus.created.englishName, 'New');
      expect(DealStatus.followedUp.englishName, 'Followed Up');
      expect(DealStatus.completed.englishName, 'Completed');
    });
  });

  group('FollowupKitService', () {
    test('generates kit with Arabic and English templates', () {
      final deal = DealRecord(
        id: 'deal_123',
        productName: 'LED Light Bulb',
        ocrRawText: 'LED Light 12W',
        extractedFields: {
          'brand': 'Philips',
          'model': 'LED-12W',
        },
        searchQuery: 'LED Light Philips',
        selectedPlatform: 'alibaba',
        createdAt: DateTime.now(),
      );

      final kit = FollowupKitService.generateKit(deal);

      expect(kit.dealId, 'deal_123');
      // When brand+model exist, productDesc becomes "brand model"
      expect(kit.arabicTemplate, contains('Philips LED-12W'));
      expect(kit.arabicTemplate, contains('Philips'));
      expect(kit.supplierTemplate, contains('Philips LED-12W'));
      expect(kit.supplierTemplate, contains('Philips'));
      expect(kit.supplierLanguage, 'en');
    });

    test('generates Chinese template for 1688 platform', () {
      final deal = DealRecord(
        id: 'deal_123',
        productName: 'LED灯泡',
        ocrRawText: 'LED灯 12W',
        extractedFields: {
          'brand': '飞利浦',
        },
        searchQuery: 'LED灯 飞利浦',
        selectedPlatform: '1688',
        createdAt: DateTime.now(),
      );

      final kit = FollowupKitService.generateKit(deal);

      expect(kit.supplierLanguage, 'zh');
      expect(kit.supplierTemplate, contains('您好'));
      expect(kit.supplierTemplate, contains('产品'));
      expect(kit.supplierLanguageName, '中文');
      expect(kit.supplierLanguageArabicName, 'الصينية');
    });

    test('generates Chinese template when context chips include Chinese locations', () {
      final deal = DealRecord(
        id: 'deal_123',
        productName: 'Test Product',
        ocrRawText: 'Test',
        searchQuery: 'Test 广州',
        contextChips: ['广州', '工厂'],
        createdAt: DateTime.now(),
      );

      final kit = FollowupKitService.generateKit(deal);

      expect(kit.supplierLanguage, 'zh');
    });

    test('Arabic template includes product details', () {
      final deal = DealRecord(
        id: 'deal_123',
        productName: 'Samsung Phone',
        ocrRawText: 'text',
        extractedFields: {
          'brand': 'Samsung',
          'model': 'Galaxy S24',
          'sku': 'SM-S928B',
        },
        searchQuery: 'Samsung Galaxy',
        createdAt: DateTime.now(),
      );

      final kit = FollowupKitService.generateKit(deal);

      // When brand+model exist, productDesc becomes "brand model"
      expect(kit.arabicTemplate, contains('Samsung Galaxy S24'));
      expect(kit.arabicTemplate, contains('Samsung'));
      expect(kit.arabicTemplate, contains('Galaxy S24'));
      expect(kit.arabicTemplate, contains('SM-S928B'));
      expect(kit.arabicTemplate, contains('ملخص الصفقة'));
    });

    test('English template includes inquiry structure', () {
      final deal = DealRecord(
        id: 'deal_123',
        productName: 'Test Product',
        ocrRawText: 'text',
        extractedFields: {
          'brand': 'TestBrand',
        },
        searchQuery: 'Test',
        selectedPlatform: 'alibaba',
        createdAt: DateTime.now(),
      );

      final kit = FollowupKitService.generateKit(deal);

      expect(kit.supplierTemplate, contains('Hello'));
      expect(kit.supplierTemplate, contains('interested'));
      expect(kit.supplierTemplate, contains('MOQ'));
      expect(kit.supplierTemplate, contains('Shipping'));
      expect(kit.supplierTemplate, contains('Payment'));
    });
  });
}
