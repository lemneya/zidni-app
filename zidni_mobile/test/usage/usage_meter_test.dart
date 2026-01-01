import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zidni_mobile/usage/models/usage_record.dart';
import 'package:zidni_mobile/usage/services/usage_meter_service.dart';

void main() {
  group('UsageType', () {
    test('has storage keys', () {
      expect(UsageType.eyesScans.storageKey, 'eyes_scans');
      expect(UsageType.eyesSearches.storageKey, 'eyes_searches');
      expect(UsageType.dealsCreated.storageKey, 'deals_created');
      expect(UsageType.followupCopies.storageKey, 'followup_copies');
      expect(UsageType.exportsAttempted.storageKey, 'exports_attempted');
      expect(UsageType.cloudBoostAttempted.storageKey, 'cloud_boost_attempted');
      expect(UsageType.gulTranslations.storageKey, 'gul_translations');
    });
    
    test('has Arabic and English names', () {
      for (final type in UsageType.values) {
        expect(type.arabicName, isNotEmpty);
        expect(type.englishName, isNotEmpty);
      }
    });
    
    test('fromKey returns correct type', () {
      expect(UsageTypeExtension.fromKey('eyes_scans'), UsageType.eyesScans);
      expect(UsageTypeExtension.fromKey('deals_created'), UsageType.dealsCreated);
    });
  });
  
  group('UsageRecord', () {
    test('creates record with correct date key', () {
      final record = UsageRecord(
        type: UsageType.eyesScans,
        date: DateTime(2025, 1, 15),
        count: 5,
      );
      
      expect(record.dateKey, '2025-01-15');
    });
    
    test('increment increases count', () {
      final record = UsageRecord(
        type: UsageType.eyesScans,
        date: DateTime.now(),
        count: 5,
      );
      
      final incremented = record.increment(3);
      
      expect(incremented.count, 8);
      expect(incremented.type, record.type);
    });
    
    test('serializes to and from JSON', () {
      final original = UsageRecord(
        type: UsageType.dealsCreated,
        date: DateTime(2025, 1, 15),
        count: 10,
      );
      
      final json = original.toJson();
      final restored = UsageRecord.fromJson(json);
      
      expect(restored.type, original.type);
      expect(restored.count, original.count);
    });
  });
  
  group('UsageSummary', () {
    test('creates empty summary', () {
      final summary = UsageSummary.empty();
      
      expect(summary.todayCount, 0);
      expect(summary.weekCount, 0);
      expect(summary.monthCount, 0);
      expect(summary.totalCount, 0);
      expect(summary.firstUsageDate, isNull);
      expect(summary.lastUsageDate, isNull);
    });
  });
  
  group('UsageMeterService', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await UsageMeterService.clearAll();
    });
    
    test('increment increases today count', () async {
      final count1 = await UsageMeterService.increment(UsageType.eyesScans);
      expect(count1, 1);
      
      final count2 = await UsageMeterService.increment(UsageType.eyesScans);
      expect(count2, 2);
      
      final todayCount = await UsageMeterService.getTodayCount(UsageType.eyesScans);
      expect(todayCount, 2);
    });
    
    test('increment by custom amount', () async {
      final count = await UsageMeterService.increment(UsageType.eyesScans, 5);
      expect(count, 5);
    });
    
    test('different types are tracked separately', () async {
      await UsageMeterService.increment(UsageType.eyesScans, 3);
      await UsageMeterService.increment(UsageType.eyesSearches, 7);
      
      expect(await UsageMeterService.getTodayCount(UsageType.eyesScans), 3);
      expect(await UsageMeterService.getTodayCount(UsageType.eyesSearches), 7);
    });
    
    test('convenience methods work correctly', () async {
      await UsageMeterService.trackEyesScan();
      await UsageMeterService.trackEyesScan();
      await UsageMeterService.trackDealCreated();
      
      expect(await UsageMeterService.getTodayCount(UsageType.eyesScans), 2);
      expect(await UsageMeterService.getTodayCount(UsageType.dealsCreated), 1);
    });
    
    test('getSummary returns correct totals', () async {
      await UsageMeterService.increment(UsageType.eyesScans, 5);
      
      final summary = await UsageMeterService.getSummary(UsageType.eyesScans);
      
      expect(summary.todayCount, 5);
      expect(summary.weekCount, 5);
      expect(summary.monthCount, 5);
      expect(summary.totalCount, 5);
    });
    
    test('getAllSummaries returns all types', () async {
      await UsageMeterService.trackEyesScan();
      await UsageMeterService.trackDealCreated();
      
      final summaries = await UsageMeterService.getAllSummaries();
      
      expect(summaries.length, UsageType.values.length);
      expect(summaries[UsageType.eyesScans]!.todayCount, 1);
      expect(summaries[UsageType.dealsCreated]!.todayCount, 1);
    });
    
    test('setCountForDate works for testing', () async {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      await UsageMeterService.setCountForDate(UsageType.eyesScans, yesterday, 10);
      
      // Today should still be 0
      expect(await UsageMeterService.getTodayCount(UsageType.eyesScans), 0);
      
      // But week count should include yesterday
      expect(await UsageMeterService.getWeekCount(UsageType.eyesScans), 10);
    });
    
    test('getCountForDays calculates correctly', () async {
      final today = DateTime.now();
      final yesterday = today.subtract(const Duration(days: 1));
      final twoDaysAgo = today.subtract(const Duration(days: 2));
      
      await UsageMeterService.setCountForDate(UsageType.eyesScans, today, 5);
      await UsageMeterService.setCountForDate(UsageType.eyesScans, yesterday, 3);
      await UsageMeterService.setCountForDate(UsageType.eyesScans, twoDaysAgo, 2);
      
      expect(await UsageMeterService.getCountForDays(UsageType.eyesScans, 1), 5);
      expect(await UsageMeterService.getCountForDays(UsageType.eyesScans, 2), 8);
      expect(await UsageMeterService.getCountForDays(UsageType.eyesScans, 3), 10);
    });
    
    test('clearAll removes all data', () async {
      await UsageMeterService.trackEyesScan();
      await UsageMeterService.trackDealCreated();
      
      await UsageMeterService.clearAll();
      
      expect(await UsageMeterService.getTodayCount(UsageType.eyesScans), 0);
      expect(await UsageMeterService.getTodayCount(UsageType.dealsCreated), 0);
    });
  });
  
  group('Weekly/Monthly Tracking', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await UsageMeterService.clearAll();
    });
    
    test('week count includes last 7 days', () async {
      final today = DateTime.now();
      
      // Add data for multiple days
      for (int i = 0; i < 10; i++) {
        final date = today.subtract(Duration(days: i));
        await UsageMeterService.setCountForDate(UsageType.eyesScans, date, 1);
      }
      
      // Week should only count 7 days
      expect(await UsageMeterService.getWeekCount(UsageType.eyesScans), 7);
    });
    
    test('month count includes last 30 days', () async {
      final today = DateTime.now();
      
      // Add data for multiple days
      for (int i = 0; i < 35; i++) {
        final date = today.subtract(Duration(days: i));
        await UsageMeterService.setCountForDate(UsageType.eyesScans, date, 1);
      }
      
      // Month should only count 30 days
      expect(await UsageMeterService.getMonthCount(UsageType.eyesScans), 30);
    });
  });
}
