import 'package:flutter_test/flutter_test.dart';
import 'package:zidni_mobile/os/models/unified_history_item.dart';

void main() {
  group('UnifiedHistoryItem', () {
    group('fromEyesScan', () {
      test('creates item with correct type', () {
        final item = UnifiedHistoryItem.fromEyesScan(
          id: 'scan_123',
          productName: 'Samsung Galaxy S24',
          rawText: 'Samsung Galaxy S24 Ultra 256GB',
          createdAt: DateTime.now(),
        );

        expect(item.type, HistoryItemType.eyesScan);
        expect(item.title, 'Samsung Galaxy S24');
        expect(item.id, 'scan_123');
      });

      test('uses default title when productName is empty', () {
        final item = UnifiedHistoryItem.fromEyesScan(
          id: 'scan_123',
          productName: '',
          rawText: 'Some text',
          createdAt: DateTime.now(),
        );

        expect(item.title, 'مسح منتج');
      });

      test('stores extracted fields in metadata', () {
        final item = UnifiedHistoryItem.fromEyesScan(
          id: 'scan_123',
          productName: 'Test',
          rawText: 'text',
          createdAt: DateTime.now(),
          extractedFields: {'brand': 'Samsung', 'model': 'S24'},
        );

        expect(item.metadata['extractedFields'], {'brand': 'Samsung', 'model': 'S24'});
      });
    });

    group('fromEyesSearch', () {
      test('creates item with correct type', () {
        final item = UnifiedHistoryItem.fromEyesSearch(
          id: 'search_123',
          query: 'LED light wholesale',
          platform: 'alibaba',
          createdAt: DateTime.now(),
        );

        expect(item.type, HistoryItemType.eyesSearch);
        expect(item.title, 'LED light wholesale');
        expect(item.subtitle, 'alibaba');
      });

      test('includes context chips in preview', () {
        final item = UnifiedHistoryItem.fromEyesSearch(
          id: 'search_123',
          query: 'LED light',
          platform: 'alibaba',
          createdAt: DateTime.now(),
          contextChips: ['Guangzhou', 'Factory', 'MOQ'],
        );

        expect(item.preview, 'Guangzhou • Factory • MOQ');
      });
    });

    group('fromDeal', () {
      test('creates item with correct type', () {
        final item = UnifiedHistoryItem.fromDeal(
          id: 'deal_123',
          productName: 'LED Light Bulb',
          platform: '1688',
          createdAt: DateTime.now(),
        );

        expect(item.type, HistoryItemType.deal);
        expect(item.title, 'LED Light Bulb');
        expect(item.subtitle, '1688');
      });
    });

    group('fromTranslation', () {
      test('creates item with correct type', () {
        final item = UnifiedHistoryItem.fromTranslation(
          id: 'trans_123',
          transcript: 'مرحبا',
          translation: 'Hello',
          fromLang: 'ar',
          toLang: 'en',
          createdAt: DateTime.now(),
        );

        expect(item.type, HistoryItemType.translation);
        expect(item.subtitle, 'ar → en');
      });

      test('truncates long transcript in title', () {
        const longText = 'هذا نص طويل جدا يحتوي على أكثر من خمسين حرفا ويجب أن يتم اقتطاعه';
        final item = UnifiedHistoryItem.fromTranslation(
          id: 'trans_123',
          transcript: longText,
          translation: 'translation',
          fromLang: 'ar',
          toLang: 'en',
          createdAt: DateTime.now(),
        );

        expect(item.title.length, lessThanOrEqualTo(53)); // 50 + "..."
        expect(item.title.endsWith('...'), true);
      });
    });

    group('serialization', () {
      test('toJson and fromJson roundtrip', () {
        final original = UnifiedHistoryItem.fromEyesScan(
          id: 'scan_123',
          productName: 'Test Product',
          rawText: 'Raw text content',
          createdAt: DateTime(2024, 1, 15, 10, 30),
          extractedFields: {'brand': 'TestBrand'},
        );

        final json = original.toJson();
        final restored = UnifiedHistoryItem.fromJson(json);

        expect(restored.id, original.id);
        expect(restored.type, original.type);
        expect(restored.title, original.title);
        expect(restored.createdAt, original.createdAt);
      });
    });

    group('timeAgo', () {
      test('returns "الآن" for recent items', () {
        final item = UnifiedHistoryItem(
          id: 'test',
          type: HistoryItemType.eyesScan,
          title: 'Test',
          createdAt: DateTime.now(),
        );

        expect(item.timeAgo, 'الآن');
      });

      test('returns minutes ago for items within an hour', () {
        final item = UnifiedHistoryItem(
          id: 'test',
          type: HistoryItemType.eyesScan,
          title: 'Test',
          createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
        );

        expect(item.timeAgo, contains('دقيقة'));
      });

      test('returns hours ago for items within a day', () {
        final item = UnifiedHistoryItem(
          id: 'test',
          type: HistoryItemType.eyesScan,
          title: 'Test',
          createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        );

        expect(item.timeAgo, contains('ساعة'));
      });
    });
  });

  group('HistoryItemType', () {
    test('arabicName returns correct values', () {
      expect(HistoryItemType.translation.arabicName, 'ترجمة');
      expect(HistoryItemType.eyesScan.arabicName, 'مسح');
      expect(HistoryItemType.eyesSearch.arabicName, 'بحث');
      expect(HistoryItemType.deal.arabicName, 'صفقة');
    });

    test('englishName returns correct values', () {
      expect(HistoryItemType.translation.englishName, 'Translation');
      expect(HistoryItemType.eyesScan.englishName, 'Scan');
      expect(HistoryItemType.eyesSearch.englishName, 'Search');
      expect(HistoryItemType.deal.englishName, 'Deal');
    });

    test('auditEvent returns correct values', () {
      expect(HistoryItemType.translation.auditEvent, 'gul_capture_saved');
      expect(HistoryItemType.eyesScan.auditEvent, 'eyes_scan_saved');
      expect(HistoryItemType.eyesSearch.auditEvent, 'eyes_search_saved');
      expect(HistoryItemType.deal.auditEvent, 'deal_created_from_eyes');
    });
  });
}
