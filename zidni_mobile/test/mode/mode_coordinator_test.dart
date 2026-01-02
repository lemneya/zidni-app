import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zidni_mobile/models/app_mode.dart';
import 'package:zidni_mobile/services/mode/mode_coordinator.dart';
import 'package:zidni_mobile/services/mode/mode_state_store.dart';

void main() {
  group('ModeCoordinator', () {
    setUp(() async {
      // Set up mock shared preferences
      SharedPreferences.setMockInitialValues({});
      await ModeCoordinator.instance.init();
    });

    tearDown(() async {
      await ModeStateStore.instance.reset();
    });

    group('currentMode', () {
      test('returns travel mode by default', () {
        expect(ModeCoordinator.instance.currentMode, AppMode.travel);
      });
    });

    group('setMode', () {
      test('changes current mode', () async {
        await ModeCoordinator.instance.setMode(AppMode.immigration);
        expect(ModeCoordinator.instance.currentMode, AppMode.immigration);
      });

      test('emits mode change event', () async {
        AppMode? emittedMode;
        ModeCoordinator.instance.modeChangeStream.listen((mode) {
          emittedMode = mode;
        });

        await ModeCoordinator.instance.setMode(AppMode.cantonFair);
        
        // Allow stream to emit
        await Future.delayed(const Duration(milliseconds: 100));
        
        expect(emittedMode, AppMode.cantonFair);
      });
    });

    group('acceptSuggestion', () {
      test('changes mode to suggested mode', () async {
        final suggestion = ModeSuggestion(
          currentMode: AppMode.travel,
          suggestedMode: AppMode.immigration,
          countryCode: 'US',
          countryName: 'United States',
          reason: 'Test reason',
          reasonEnglish: 'Test reason',
        );

        await ModeCoordinator.instance.acceptSuggestion(suggestion);

        expect(ModeCoordinator.instance.currentMode, AppMode.immigration);
        expect(ModeStateStore.instance.lastCountryCode, 'US');
      });
    });

    group('declineSuggestion', () {
      test('updates last prompted time', () async {
        final suggestion = ModeSuggestion(
          currentMode: AppMode.travel,
          suggestedMode: AppMode.immigration,
          countryCode: 'US',
          countryName: 'United States',
          reason: 'Test reason',
          reasonEnglish: 'Test reason',
        );

        await ModeCoordinator.instance.declineSuggestion(suggestion);

        expect(ModeStateStore.instance.lastPromptedAt, isNotNull);
      });
    });

    group('declinePermanently', () {
      test('sets dont ask again flag', () async {
        final suggestion = ModeSuggestion(
          currentMode: AppMode.travel,
          suggestedMode: AppMode.immigration,
          countryCode: 'US',
          countryName: 'United States',
          reason: 'Test reason',
          reasonEnglish: 'Test reason',
        );

        await ModeCoordinator.instance.declinePermanently(suggestion);

        expect(ModeStateStore.instance.dontAskAgain, true);
        expect(ModeStateStore.instance.canPromptAgain(), false);
      });
    });

    group('maybeSuggestMode', () {
      test('returns null when auto mode is disabled', () async {
        await ModeStateStore.instance.setAutoModeEnabled(false);

        final suggestion = await ModeCoordinator.instance.maybeSuggestMode();

        expect(suggestion, null);
      });

      test('returns null when dont ask again is set', () async {
        await ModeStateStore.instance.setDontAskAgain(true);

        final suggestion = await ModeCoordinator.instance.maybeSuggestMode();

        expect(suggestion, null);
      });
    });
  });

  group('ModeSuggestion', () {
    test('getLocalizedReason returns Arabic for ar locale', () {
      final suggestion = ModeSuggestion(
        currentMode: AppMode.travel,
        suggestedMode: AppMode.immigration,
        countryCode: 'US',
        reason: 'سبب عربي',
        reasonEnglish: 'English reason',
      );

      expect(suggestion.getLocalizedReason('ar'), 'سبب عربي');
      expect(suggestion.getLocalizedReason('ar_EG'), 'سبب عربي');
    });

    test('getLocalizedReason returns English for non-ar locale', () {
      final suggestion = ModeSuggestion(
        currentMode: AppMode.travel,
        suggestedMode: AppMode.immigration,
        countryCode: 'US',
        reason: 'سبب عربي',
        reasonEnglish: 'English reason',
      );

      expect(suggestion.getLocalizedReason('en'), 'English reason');
      expect(suggestion.getLocalizedReason('fr'), 'English reason');
    });
  });
}
