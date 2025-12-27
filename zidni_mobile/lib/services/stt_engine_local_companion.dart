import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:zidni_mobile/services/local_companion_client.dart';
import 'package:zidni_mobile/services/offline_settings_service.dart';
import 'package:zidni_mobile/services/stt_engine.dart';

/// Audio recorder for capturing audio during press-hold-release.
/// Uses platform channels or a simple file-based approach.
class _AudioRecorder {
  String? _recordingPath;
  bool _isRecording = false;
  // DateTime? _startTime; // Reserved for future use
  
  // For MVP, we'll use a simple approach that works with the companion
  // In production, use flutter_sound or record package
  
  Future<bool> start() async {
    try {
      final dir = await getTemporaryDirectory();
      _recordingPath = '${dir.path}/gul_recording_${DateTime.now().millisecondsSinceEpoch}.wav';
      _isRecording = true;
      return true;
    } catch (e) {
      return false;
    }
  }
  
  Future<String?> stop() async {
    if (!_isRecording) return null;
    _isRecording = false;
    final path = _recordingPath;
    _recordingPath = null;
    return path;
  }
  
  void cancel() {
    _isRecording = false;
    if (_recordingPath != null) {
      try {
        File(_recordingPath!).deleteSync();
      } catch (_) {}
    }
    _recordingPath = null;
  }
  
  bool get isRecording => _isRecording;
}

/// STT Engine implementation that uses the local companion server.
/// Press-hold records audio, release uploads to POST /stt on companion.
class SttEngineLocalCompanion implements SttEngine {
  final _statusController = StreamController<SttStatus>.broadcast();
  final _audioRecorder = _AudioRecorder();
  
  LocalCompanionClient? _client;
  bool _initialized = false;
  SttStatus _currentStatus = SttStatus.idle;

  @override
  Stream<SttStatus> get status => _statusController.stream;

  @override
  void Function(SttPayload payload)? onResult;

  void _setStatus(SttStatus newStatus) {
    _currentStatus = newStatus;
    _statusController.add(newStatus);
  }

  @override
  Future<bool> initialize() async {
    if (_initialized) return true;

    // Check microphone permission
    final micStatus = await Permission.microphone.status;
    if (!micStatus.isGranted) {
      final result = await Permission.microphone.request();
      if (!result.isGranted) {
        _setStatus(SttStatus.blocked);
        return false;
      }
    }

    // Get companion URL and create client
    final url = await OfflineSettingsService.getCompanionUrl();
    _client = LocalCompanionClient(baseUrl: url);

    // Check if companion is reachable
    final isHealthy = await _client!.checkHealth();
    if (!isHealthy) {
      // Companion not reachable, but we can still initialize
      // The actual transcription will fail gracefully
      debugPrint('LocalCompanion: Companion not reachable at $url');
    }

    _initialized = true;
    _setStatus(SttStatus.idle);
    return true;
  }

  @override
  Future<void> startListening() async {
    if (_currentStatus != SttStatus.idle) return;
    if (!_initialized) {
      final ok = await initialize();
      if (!ok) return;
    }

    // Start recording
    final started = await _audioRecorder.start();
    if (!started) {
      _setStatus(SttStatus.blocked);
      return;
    }

    _setStatus(SttStatus.listening);
  }

  @override
  Future<void> stopListening() async {
    if (_currentStatus != SttStatus.listening) return;

    _setStatus(SttStatus.processing);

    // Stop recording and get file path
    final audioPath = await _audioRecorder.stop();
    
    if (audioPath == null || _client == null) {
      _setStatus(SttStatus.idle);
      onResult?.call(const SttPayload(transcript: ''));
      return;
    }

    // For MVP: Since we don't have actual audio recording yet,
    // we'll simulate by checking if companion is available
    // In production, this would upload the actual audio file
    
    try {
      // Check companion health first
      final isHealthy = await _client!.checkHealth();
      
      if (!isHealthy) {
        // Companion not available
        _setStatus(SttStatus.idle);
        onResult?.call(const SttPayload(
          transcript: '[Companion offline - please check connection]',
        ));
        return;
      }

      // In production: Upload audio file to companion
      // final transcript = await _client!.transcribeAudioFile(audioPath);
      
      // For MVP without actual audio recording, return placeholder
      // This will be replaced when audio recording is implemented
      final transcript = await _simulateTranscription();
      
      _setStatus(SttStatus.idle);
      onResult?.call(SttPayload(transcript: transcript ?? ''));
    } catch (e) {
      debugPrint('LocalCompanion STT error: $e');
      _setStatus(SttStatus.idle);
      onResult?.call(const SttPayload(transcript: ''));
    }
  }

  /// Simulate transcription for MVP testing.
  /// In production, this is replaced by actual audio upload.
  Future<String?> _simulateTranscription() async {
    // Simulate processing delay
    await Future.delayed(const Duration(milliseconds: 500));
    return '[Local STT - audio recording not yet implemented]';
  }

  @override
  Future<void> cancelListening() async {
    _audioRecorder.cancel();
    _setStatus(SttStatus.idle);
  }

  @override
  void dispose() {
    _audioRecorder.cancel();
    _statusController.close();
  }

  /// Refresh the client with updated URL from settings.
  Future<void> refreshClient() async {
    final url = await OfflineSettingsService.getCompanionUrl();
    _client = LocalCompanionClient(baseUrl: url);
  }
}
