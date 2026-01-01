import 'package:flutter_test/flutter_test.dart';
import 'package:zidni_mobile/os/services/voice_command_router.dart';

void main() {
  group('VoiceCommandRouter', () {
    group('detectCommand', () {
      test('detects Arabic scan command "امسح هذا"', () {
        final result = VoiceCommandRouter.detectCommand('امسح هذا');
        expect(result.isCommand, true);
        expect(result.type, VoiceCommandType.openEyes);
        expect(result.matchedPhrase, 'امسح هذا');
      });

      test('detects Arabic scan command "صور هذا"', () {
        final result = VoiceCommandRouter.detectCommand('صور هذا');
        expect(result.isCommand, true);
        expect(result.type, VoiceCommandType.openEyes);
        expect(result.matchedPhrase, 'صور هذا');
      });

      test('detects English scan command "scan this"', () {
        final result = VoiceCommandRouter.detectCommand('scan this');
        expect(result.isCommand, true);
        expect(result.type, VoiceCommandType.openEyes);
        expect(result.matchedPhrase, 'scan this');
      });

      test('detects English scan command case insensitive', () {
        final result = VoiceCommandRouter.detectCommand('SCAN THIS');
        expect(result.isCommand, true);
        expect(result.type, VoiceCommandType.openEyes);
      });

      test('detects Chinese scan command "扫描"', () {
        final result = VoiceCommandRouter.detectCommand('扫描');
        expect(result.isCommand, true);
        expect(result.type, VoiceCommandType.openEyes);
        expect(result.matchedPhrase, '扫描');
      });

      test('detects Chinese scan command "扫一扫"', () {
        final result = VoiceCommandRouter.detectCommand('扫一扫');
        expect(result.isCommand, true);
        expect(result.type, VoiceCommandType.openEyes);
      });

      test('returns none for regular text', () {
        final result = VoiceCommandRouter.detectCommand('مرحبا كيف حالك');
        expect(result.isCommand, false);
        expect(result.type, VoiceCommandType.none);
      });

      test('returns none for empty string', () {
        final result = VoiceCommandRouter.detectCommand('');
        expect(result.isCommand, false);
        expect(result.type, VoiceCommandType.none);
      });

      test('detects command embedded in longer text', () {
        final result = VoiceCommandRouter.detectCommand('أريد أن امسح هذا المنتج');
        expect(result.isCommand, true);
        expect(result.type, VoiceCommandType.openEyes);
      });
    });

    group('isPureCommand', () {
      test('returns true for exact match "امسح هذا"', () {
        expect(VoiceCommandRouter.isPureCommand('امسح هذا'), true);
      });

      test('returns true for exact match "scan this"', () {
        expect(VoiceCommandRouter.isPureCommand('scan this'), true);
      });

      test('returns true for exact match "扫描"', () {
        expect(VoiceCommandRouter.isPureCommand('扫描'), true);
      });

      test('returns false for command embedded in longer text', () {
        expect(VoiceCommandRouter.isPureCommand('أريد أن امسح هذا المنتج'), false);
      });

      test('returns false for regular text', () {
        expect(VoiceCommandRouter.isPureCommand('مرحبا كيف حالك'), false);
      });

      test('returns true for short command with minor additions', () {
        // "امسح" is most of "امسح " (with trailing space)
        expect(VoiceCommandRouter.isPureCommand('امسح '), true);
      });
    });
  });

  group('VoiceCommand', () {
    test('eyesScanPhrases contains Arabic phrases', () {
      expect(VoiceCommand.eyesScanPhrases, contains('امسح هذا'));
      expect(VoiceCommand.eyesScanPhrases, contains('صور هذا'));
      expect(VoiceCommand.eyesScanPhrases, contains('افتح الكاميرا'));
    });

    test('eyesScanPhrases contains English phrases', () {
      expect(VoiceCommand.eyesScanPhrases, contains('scan this'));
      expect(VoiceCommand.eyesScanPhrases, contains('open camera'));
    });

    test('eyesScanPhrases contains Chinese phrases', () {
      expect(VoiceCommand.eyesScanPhrases, contains('扫描'));
      expect(VoiceCommand.eyesScanPhrases, contains('扫一扫'));
      expect(VoiceCommand.eyesScanPhrases, contains('拍照'));
    });

    test('isEyesScanCommand returns true for valid commands', () {
      expect(VoiceCommand.isEyesScanCommand('امسح هذا'), true);
      expect(VoiceCommand.isEyesScanCommand('scan this'), true);
      expect(VoiceCommand.isEyesScanCommand('扫描'), true);
    });

    test('isEyesScanCommand returns false for invalid commands', () {
      expect(VoiceCommand.isEyesScanCommand('hello'), false);
      expect(VoiceCommand.isEyesScanCommand('مرحبا'), false);
      expect(VoiceCommand.isEyesScanCommand('你好'), false);
    });
  });
}
