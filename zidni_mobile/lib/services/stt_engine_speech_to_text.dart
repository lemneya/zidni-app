import 'dart:async';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'stt_engine.dart';

class SttEngineSpeechToText implements SttEngine {
  final stt.SpeechToText _speech;
  final StreamController<SttStatus> _statusController =
      StreamController<SttStatus>.broadcast();

  bool _initialized = false;
  bool _available = false;

  // Terminal per interaction: once blocked, ignore further status updates
  // until caller ends interaction (cancel) and a new one starts.
  bool _blockedThisInteraction = false;

  @override
  void Function(SttPayload payload)? onResult;

  SttEngineSpeechToText({stt.SpeechToText? speech})
      : _speech = speech ?? stt.SpeechToText();

  @override
  Stream<SttStatus> get status => _statusController.stream;

  @override
  Future<bool> initialize() async {
    if (_initialized) return _available;

    // Silent check for both microphone and speech recognition permissions.
    final micStatus = await Permission.microphone.status;
    final speechStatus = await Permission.speech.status; // Required for iOS

    if (!micStatus.isGranted || !speechStatus.isGranted) {
      _initialized = true;
      _available = false;
      return false; // Do NOT call _speech.initialize()
    }

    final ok = await _speech.initialize(
      onStatus: _handleStatusChange,
      onError: (_) => _setBlocked(),
      debugLogging: false,
    );

    _initialized = true;
    _available = ok && _speech.isAvailable && _speech.hasPermission;
    return _available;
  }

  void _setBlocked() {
    _blockedThisInteraction = true;
    _statusController.add(SttStatus.blocked);
    // Best-effort stop; silence.
    // ignore: discarded_futures
    _speech.cancel();
  }

  void _handleStatusChange(String status) {
    if (_blockedThisInteraction) return;

    if (status == stt.SpeechToText.listeningStatus) {
      _statusController.add(SttStatus.listening);
    } else if (status == stt.SpeechToText.notListeningStatus) {
      _statusController.add(SttStatus.processing);
    } else if (status == stt.SpeechToText.doneStatus) {
      _statusController.add(SttStatus.idle);
    }
  }

  @override
  Future<void> startListening() async {
    // Start of a new interaction attempt
    _blockedThisInteraction = false;

    if (_speech.isListening) return;

    // Use the initialize method which now contains the silent permission checks.
    if (!_initialized) {
      final ok = await initialize();
      if (!ok) {
        _setBlocked();
        return;
      }
    }

    if (!_available) {
      _setBlocked();
      return;
    }

    // Begin listening
    try {
      final ok = await _speech.listen(
        onResult: (res) {
          if (_blockedThisInteraction) return;
          if (res.finalResult) {
            onResult?.call(SttPayload(transcript: res.recognizedWords));
          }
        },
        partialResults: false,
        cancelOnError: true,
        listenMode: stt.ListenMode.confirmation,
        listenFor: const Duration(seconds: 45),
        pauseFor: const Duration(seconds: 3),
      );
      if (!ok) {
        _setBlocked();
        return;
      }
      _statusController.add(SttStatus.listening);
    } catch (_) {
      _setBlocked();
    }
  }

  @override
  Future<void> stopListening() async {
    if (_blockedThisInteraction) return;
    if (_speech.isListening) {
      await _speech.stop();
    }
  }

  @override
  Future<void> cancelListening() async {
    // Explicit termination of interaction.
    try {
      await _speech.cancel();
    } catch (_) {
      // silence
    }
    _blockedThisInteraction = false;
    _statusController.add(SttStatus.idle);
  }

  @override
  void dispose() {
    // ignore: discarded_futures
    _speech.cancel();
    _statusController.close();
  }
}
