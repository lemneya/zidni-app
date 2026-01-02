import 'package:flutter_test/flutter_test.dart';
import 'package:zidni_mobile/models/app_mode.dart';
import 'package:zidni_mobile/services/mode/mode_rules.dart';

void main() {
  group('ModeRules', () {
    group('getSuggestedMode', () {
      test('returns Immigration mode for USA', () {
        expect(ModeRules.getSuggestedMode('US'), AppMode.immigration);
        expect(ModeRules.getSuggestedMode('us'), AppMode.immigration);
        expect(ModeRules.getSuggestedMode(' US '), AppMode.immigration);
      });

      test('returns Canton Fair mode for China', () {
        expect(ModeRules.getSuggestedMode('CN'), AppMode.cantonFair);
        expect(ModeRules.getSuggestedMode('cn'), AppMode.cantonFair);
      });

      test('returns Home mode for MENA countries', () {
        // Test multiple MENA countries
        expect(ModeRules.getSuggestedMode('EG'), AppMode.home); // Egypt
        expect(ModeRules.getSuggestedMode('DZ'), AppMode.home); // Algeria
        expect(ModeRules.getSuggestedMode('MA'), AppMode.home); // Morocco
        expect(ModeRules.getSuggestedMode('SA'), AppMode.home); // Saudi Arabia
        expect(ModeRules.getSuggestedMode('AE'), AppMode.home); // UAE
        expect(ModeRules.getSuggestedMode('MR'), AppMode.home); // Mauritania
      });

      test('returns Travel mode for non-MENA countries', () {
        expect(ModeRules.getSuggestedMode('ES'), AppMode.travel); // Spain
        expect(ModeRules.getSuggestedMode('FR'), AppMode.travel); // France
        expect(ModeRules.getSuggestedMode('DE'), AppMode.travel); // Germany
        expect(ModeRules.getSuggestedMode('JP'), AppMode.travel); // Japan
        expect(ModeRules.getSuggestedMode('BR'), AppMode.travel); // Brazil
      });

      test('returns Travel mode for unknown country codes', () {
        expect(ModeRules.getSuggestedMode('XX'), AppMode.travel);
        expect(ModeRules.getSuggestedMode(''), AppMode.travel);
      });
    });

    group('isMenaCountry', () {
      test('returns true for MENA countries', () {
        expect(ModeRules.isMenaCountry('EG'), true);
        expect(ModeRules.isMenaCountry('DZ'), true);
        expect(ModeRules.isMenaCountry('SA'), true);
      });

      test('returns false for non-MENA countries', () {
        expect(ModeRules.isMenaCountry('US'), false);
        expect(ModeRules.isMenaCountry('CN'), false);
        expect(ModeRules.isMenaCountry('FR'), false);
      });
    });

    group('isChina', () {
      test('returns true for China', () {
        expect(ModeRules.isChina('CN'), true);
        expect(ModeRules.isChina('cn'), true);
      });

      test('returns false for other countries', () {
        expect(ModeRules.isChina('US'), false);
        expect(ModeRules.isChina('TW'), false);
      });
    });

    group('isUsa', () {
      test('returns true for USA', () {
        expect(ModeRules.isUsa('US'), true);
        expect(ModeRules.isUsa('us'), true);
      });

      test('returns false for other countries', () {
        expect(ModeRules.isUsa('CN'), false);
        expect(ModeRules.isUsa('CA'), false);
      });
    });

    group('getSuggestionReason', () {
      test('returns Arabic reason when arabic=true', () {
        final reason = ModeRules.getSuggestionReason('US', arabic: true);
        expect(reason, contains('الولايات المتحدة'));
      });

      test('returns English reason when arabic=false', () {
        final reason = ModeRules.getSuggestionReason('US', arabic: false);
        expect(reason, contains('USA'));
      });
    });
  });
}
