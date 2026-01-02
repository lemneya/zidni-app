import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zidni_mobile/models/app_mode.dart';
import 'package:zidni_mobile/services/mode/mode_state_store.dart';

void main() {
  group('ModeStateStore', () {
    setUp(() async {
      // Set up mock shared preferences
      SharedPreferences.setMockInitialValues({});
      await ModeStateStore.instance.init();
    });

    tearDown(() async {
      await ModeStateStore.instance.reset();
    });

    group('autoModeEnabled', () {
      test('defaults to true', () {
        expect(ModeStateStore.instance.autoModeEnabled, true);
      });

      test('can be set to false', () async {
        await ModeStateStore.instance.setAutoModeEnabled(false);
        expect(ModeStateStore.instance.autoModeEnabled, false);
      });

      test('persists value', () async {
        await ModeStateStore.instance.setAutoModeEnabled(false);
        
        // Re-initialize to simulate app restart
        SharedPreferences.setMockInitialValues({
          'mode_auto_enabled': false,
        });
        await ModeStateStore.instance.init();
        
        expect(ModeStateStore.instance.autoModeEnabled, false);
      });
    });

    group('currentMode', () {
      test('defaults to travel', () {
        expect(ModeStateStore.instance.currentMode, AppMode.travel);
      });

      test('can be set to any mode', () async {
        await ModeStateStore.instance.setCurrentMode(AppMode.immigration);
        expect(ModeStateStore.instance.currentMode, AppMode.immigration);

        await ModeStateStore.instance.setCurrentMode(AppMode.cantonFair);
        expect(ModeStateStore.instance.currentMode, AppMode.cantonFair);
      });
    });

    group('lastCountryCode', () {
      test('defaults to null', () {
        expect(ModeStateStore.instance.lastCountryCode, null);
      });

      test('can be set and retrieved', () async {
        await ModeStateStore.instance.setLastCountryCode('US');
        expect(ModeStateStore.instance.lastCountryCode, 'US');
      });
    });

    group('canPromptAgain', () {
      test('returns true when never prompted', () {
        expect(ModeStateStore.instance.canPromptAgain(), true);
      });

      test('returns false when dontAskAgain is true', () async {
        await ModeStateStore.instance.setDontAskAgain(true);
        expect(ModeStateStore.instance.canPromptAgain(), false);
      });

      test('returns false within cooldown period', () async {
        await ModeStateStore.instance.setLastPromptedAt(DateTime.now());
        expect(
          ModeStateStore.instance.canPromptAgain(
            cooldown: const Duration(hours: 24),
          ),
          false,
        );
      });

      test('returns true after cooldown period', () async {
        await ModeStateStore.instance.setLastPromptedAt(
          DateTime.now().subtract(const Duration(hours: 25)),
        );
        expect(
          ModeStateStore.instance.canPromptAgain(
            cooldown: const Duration(hours: 24),
          ),
          true,
        );
      });
    });

    group('hasCountryChanged', () {
      test('returns true when no previous country', () {
        expect(ModeStateStore.instance.hasCountryChanged('US'), true);
      });

      test('returns false when country is same', () async {
        await ModeStateStore.instance.setLastCountryCode('US');
        expect(ModeStateStore.instance.hasCountryChanged('US'), false);
        expect(ModeStateStore.instance.hasCountryChanged('us'), false);
      });

      test('returns true when country is different', () async {
        await ModeStateStore.instance.setLastCountryCode('US');
        expect(ModeStateStore.instance.hasCountryChanged('CN'), true);
      });
    });

    group('reset', () {
      test('resets all values to defaults', () async {
        // Set some values
        await ModeStateStore.instance.setAutoModeEnabled(false);
        await ModeStateStore.instance.setCurrentMode(AppMode.immigration);
        await ModeStateStore.instance.setLastCountryCode('US');
        await ModeStateStore.instance.setDontAskAgain(true);

        // Reset
        await ModeStateStore.instance.reset();

        // Verify defaults
        expect(ModeStateStore.instance.autoModeEnabled, true);
        expect(ModeStateStore.instance.currentMode, AppMode.travel);
        expect(ModeStateStore.instance.lastCountryCode, null);
        expect(ModeStateStore.instance.dontAskAgain, false);
      });
    });

    group('toJson', () {
      test('exports current state', () async {
        await ModeStateStore.instance.setCurrentMode(AppMode.immigration);
        await ModeStateStore.instance.setLastCountryCode('US');

        final json = ModeStateStore.instance.toJson();

        expect(json['currentMode'], 'immigration');
        expect(json['lastCountryCode'], 'US');
        expect(json['autoModeEnabled'], true);
      });
    });
  });
}
