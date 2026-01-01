import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zidni_mobile/eyes/models/eyes_scan_result.dart';
import 'package:zidni_mobile/eyes/services/eyes_history_service.dart';

/// Unit tests for Eyes History Service
/// Gate EYES-1: Save to History functionality
void main() {
  group('EyesHistoryService', () {
    setUp(() {
      // Set up mock SharedPreferences
      SharedPreferences.setMockInitialValues({});
    });

    test('saveToHistory adds result with generated ID', () async {
      final result = EyesScanResult(
        rawText: 'Test OCR text',
        detectedLanguage: 'en',
        productNameGuess: 'Test Product',
        extractedFields: {'brand': 'TestBrand'},
        scannedAt: DateTime.now(),
      );

      final savedResult = await EyesHistoryService.saveToHistory(result);

      expect(savedResult.id, isNotNull);
      expect(savedResult.rawText, equals('Test OCR text'));
    });

    test('getHistory returns saved items', () async {
      final result1 = EyesScanResult(
        rawText: 'First scan',
        detectedLanguage: 'zh',
        scannedAt: DateTime.now(),
      );
      final result2 = EyesScanResult(
        rawText: 'Second scan',
        detectedLanguage: 'ar',
        scannedAt: DateTime.now(),
      );

      await EyesHistoryService.saveToHistory(result1);
      await EyesHistoryService.saveToHistory(result2);

      final history = await EyesHistoryService.getHistory();

      expect(history.length, equals(2));
      // Most recent first
      expect(history[0].rawText, equals('Second scan'));
      expect(history[1].rawText, equals('First scan'));
    });

    test('deleteHistoryItem removes item by ID', () async {
      final result = EyesScanResult(
        rawText: 'To be deleted',
        detectedLanguage: 'en',
        scannedAt: DateTime.now(),
      );

      final savedResult = await EyesHistoryService.saveToHistory(result);
      await EyesHistoryService.deleteHistoryItem(savedResult.id!);

      final history = await EyesHistoryService.getHistory();
      expect(history.length, equals(0));
    });

    test('clearHistory removes all items', () async {
      await EyesHistoryService.saveToHistory(EyesScanResult(
        rawText: 'Item 1',
        detectedLanguage: 'en',
        scannedAt: DateTime.now(),
      ));
      await EyesHistoryService.saveToHistory(EyesScanResult(
        rawText: 'Item 2',
        detectedLanguage: 'en',
        scannedAt: DateTime.now(),
      ));

      await EyesHistoryService.clearHistory();

      final history = await EyesHistoryService.getHistory();
      expect(history.length, equals(0));
    });

    test('audit log records eyes_scan_saved event', () async {
      await EyesHistoryService.saveToHistory(EyesScanResult(
        rawText: 'Audit test',
        detectedLanguage: 'zh',
        scannedAt: DateTime.now(),
      ));

      final logs = await EyesHistoryService.getAuditLogs();

      expect(logs.length, greaterThan(0));
      expect(logs[0]['event'], equals('eyes_scan_saved'));
    });
  });

  group('EyesScanResult', () {
    test('toJson and fromJson roundtrip', () {
      final original = EyesScanResult(
        id: 'test-id',
        rawText: 'Test text',
        detectedLanguage: 'zh',
        productNameGuess: 'Test Product',
        extractedFields: {'brand': 'TestBrand', 'model': 'TM-100'},
        scannedAt: DateTime(2025, 1, 1, 12, 0),
        imagePath: '/path/to/image.jpg',
      );

      final json = original.toJson();
      final restored = EyesScanResult.fromJson(json);

      expect(restored.id, equals(original.id));
      expect(restored.rawText, equals(original.rawText));
      expect(restored.detectedLanguage, equals(original.detectedLanguage));
      expect(restored.productNameGuess, equals(original.productNameGuess));
      expect(restored.extractedFields, equals(original.extractedFields));
      expect(restored.imagePath, equals(original.imagePath));
    });

    test('textPreview truncates long text', () {
      final result = EyesScanResult(
        rawText: 'A' * 200,
        scannedAt: DateTime.now(),
      );

      expect(result.textPreview.length, lessThan(110));
      expect(result.textPreview.endsWith('...'), isTrue);
    });

    test('copyWith creates modified copy', () {
      final original = EyesScanResult(
        rawText: 'Original',
        detectedLanguage: 'en',
        scannedAt: DateTime.now(),
      );

      final modified = original.copyWith(
        id: 'new-id',
        productNameGuess: 'New Name',
      );

      expect(modified.id, equals('new-id'));
      expect(modified.productNameGuess, equals('New Name'));
      expect(modified.rawText, equals('Original')); // Unchanged
    });
  });
}
