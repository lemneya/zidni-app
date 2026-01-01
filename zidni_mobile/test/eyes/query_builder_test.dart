import 'package:flutter_test/flutter_test.dart';
import 'package:zidni_mobile/eyes/models/eyes_scan_result.dart';
import 'package:zidni_mobile/eyes/models/search_query.dart';
import 'package:zidni_mobile/eyes/services/query_builder_service.dart';

void main() {
  group('QueryBuilderService', () {
    test('builds query from brand and model', () {
      final result = EyesScanResult(
        rawText: 'Some raw text',
        scannedAt: DateTime.now(),
        extractedFields: {
          'brand': 'Samsung',
          'model': 'Galaxy S24',
        },
      );

      final query = QueryBuilderService.buildFromScanResult(result);

      expect(query.baseQuery, 'Samsung Galaxy S24');
      expect(query.brand, 'Samsung');
      expect(query.model, 'Galaxy S24');
    });

    test('builds query from product name guess when no brand/model', () {
      final result = EyesScanResult(
        rawText: 'Some raw text',
        productNameGuess: 'LED Light Bulb 12W',
        scannedAt: DateTime.now(),
      );

      final query = QueryBuilderService.buildFromScanResult(result);

      expect(query.baseQuery, 'LED Light Bulb 12W');
    });

    test('builds query from SKU when no other fields', () {
      final result = EyesScanResult(
        rawText: 'Some raw text\n12345678',
        scannedAt: DateTime.now(),
        extractedFields: {
          'sku': '6901234567890',
        },
      );

      final query = QueryBuilderService.buildFromScanResult(result);

      expect(query.baseQuery, '6901234567890');
      expect(query.sku, '6901234567890');
    });

    test('builds query from raw text keywords as fallback', () {
      final result = EyesScanResult(
        rawText: 'Wireless Bluetooth Speaker\nPortable\nHigh Quality',
        scannedAt: DateTime.now(),
      );

      final query = QueryBuilderService.buildFromScanResult(result);

      expect(query.baseQuery.isNotEmpty, true);
      expect(query.keywords.isNotEmpty, true);
    });

    test('adds context chips to query', () {
      final result = EyesScanResult(
        rawText: 'Test product',
        productNameGuess: 'Test Product',
        scannedAt: DateTime.now(),
      );

      var query = QueryBuilderService.buildFromScanResult(result);
      query = QueryBuilderService.addContextChips(query, ['guangzhou', 'factory']);

      expect(query.contextChips.length, 2);
      expect(query.contextChips.contains('广州'), true);
      expect(query.contextChips.contains('工厂'), true);
      expect(query.fullQuery, 'Test Product 广州 工厂');
    });

    test('updates base query', () {
      final result = EyesScanResult(
        rawText: 'Original text',
        productNameGuess: 'Original Product',
        scannedAt: DateTime.now(),
      );

      var query = QueryBuilderService.buildFromScanResult(result);
      query = QueryBuilderService.updateBaseQuery(query, 'Updated Product Name');

      expect(query.baseQuery, 'Updated Product Name');
    });

    test('cleans query with special characters', () {
      final result = EyesScanResult(
        rawText: 'Test <script>alert("xss")</script>',
        productNameGuess: 'Test <script>alert("xss")</script>',
        scannedAt: DateTime.now(),
      );

      final query = QueryBuilderService.buildFromScanResult(result);

      expect(query.baseQuery.contains('<'), false);
      expect(query.baseQuery.contains('>'), false);
      expect(query.baseQuery.contains('"'), false);
    });

    test('limits query length to 100 characters', () {
      final longText = 'A' * 200;
      final result = EyesScanResult(
        rawText: longText,
        productNameGuess: longText,
        scannedAt: DateTime.now(),
      );

      final query = QueryBuilderService.buildFromScanResult(result);

      expect(query.baseQuery.length, lessThanOrEqualTo(100));
    });
  });

  group('SearchQuery', () {
    test('fullQuery combines base query and context chips', () {
      final query = SearchQuery(
        baseQuery: 'LED Light',
        contextChips: ['广州', '工厂'],
        platform: 'alibaba',
        createdAt: DateTime.now(),
      );

      expect(query.fullQuery, 'LED Light 广州 工厂');
    });

    test('serializes to JSON and back', () {
      final original = SearchQuery(
        baseQuery: 'Test Product',
        brand: 'TestBrand',
        model: 'TestModel',
        sku: '123456',
        keywords: ['keyword1', 'keyword2'],
        contextChips: ['广州'],
        platform: 'alibaba',
        createdAt: DateTime(2024, 1, 1, 12, 0, 0),
        scanResultId: 'scan-123',
      );

      final json = original.toJson();
      final restored = SearchQuery.fromJson(json);

      expect(restored.baseQuery, original.baseQuery);
      expect(restored.brand, original.brand);
      expect(restored.model, original.model);
      expect(restored.sku, original.sku);
      expect(restored.keywords, original.keywords);
      expect(restored.contextChips, original.contextChips);
      expect(restored.platform, original.platform);
      expect(restored.scanResultId, original.scanResultId);
    });
  });

  group('SearchPlatform', () {
    test('builds correct Alibaba search URL', () {
      final url = SearchPlatform.alibaba.buildSearchUrl('LED Light');
      expect(url, contains('alibaba.com'));
      expect(url, contains('LED%20Light'));
    });

    test('builds correct 1688 search URL', () {
      final url = SearchPlatform.alibaba1688.buildSearchUrl('LED灯');
      expect(url, contains('1688.com'));
      expect(url, contains('LED'));
    });

    test('builds correct Made-in-China search URL', () {
      final url = SearchPlatform.madeInChina.buildSearchUrl('Speaker');
      expect(url, contains('made-in-china.com'));
      expect(url, contains('Speaker'));
    });

    test('builds correct Google search URL', () {
      final url = SearchPlatform.google.buildSearchUrl('Test Query');
      expect(url, contains('google.com'));
      expect(url, contains('Test%20Query'));
    });

    test('builds correct Baidu search URL', () {
      final url = SearchPlatform.baidu.buildSearchUrl('测试');
      expect(url, contains('baidu.com'));
    });
  });

  group('ContextChips', () {
    test('has location chips', () {
      final locationChips = ContextChips.byCategory(ContextChipCategory.location);
      expect(locationChips.length, 3);
      expect(locationChips.any((c) => c.id == 'guangzhou'), true);
      expect(locationChips.any((c) => c.id == 'foshan'), true);
      expect(locationChips.any((c) => c.id == 'yiwu'), true);
    });

    test('has business type chips', () {
      final businessChips = ContextChips.byCategory(ContextChipCategory.businessType);
      expect(businessChips.length, 2);
      expect(businessChips.any((c) => c.id == 'factory'), true);
      expect(businessChips.any((c) => c.id == 'wholesaler'), true);
    });

    test('has terms chips', () {
      final termsChips = ContextChips.byCategory(ContextChipCategory.terms);
      expect(termsChips.length, 2);
      expect(termsChips.any((c) => c.id == 'moq'), true);
      expect(termsChips.any((c) => c.id == 'price'), true);
    });
  });
}
