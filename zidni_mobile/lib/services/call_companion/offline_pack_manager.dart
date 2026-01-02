/// Offline Pack Manager for Call Companion Mode
/// Manages download and status of offline models:
/// - Whisper STT model
/// - ML Kit translation models (Chinese, Arabic)
/// - System TTS voice availability

import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import '../../models/call_companion/offline_pack_status.dart';
import 'whisper_stt_service.dart';
import 'mlkit_translation_service.dart';
import 'tts_to_file_service.dart';

/// Callback for download progress
typedef DownloadProgressCallback = void Function(String packId, double progress);

/// Callback for status changes
typedef StatusChangeCallback = void Function(OfflinePackStatus status);

/// Manager for offline packs and models
class OfflinePackManager {
  static OfflinePackManager? _instance;

  /// Singleton instance
  static OfflinePackManager get instance {
    _instance ??= OfflinePackManager._();
    return _instance!;
  }

  OfflinePackManager._();

  /// Current status
  OfflinePackStatus _status = OfflinePackStatus.initial();

  /// Download progress callback
  DownloadProgressCallback? onDownloadProgress;

  /// Status change callback
  StatusChangeCallback? onStatusChanged;

  /// Get current status
  OfflinePackStatus get status => _status;

  /// Check if fully ready for offline use
  bool get isReady => _status.isFullyReady;

  /// Initialize and check current status
  Future<OfflinePackStatus> initialize() async {
    // Check Whisper model
    final whisperPath = await _getWhisperModelPath();
    if (await File(whisperPath).exists()) {
      _status.whisperModel.status = PackDownloadStatus.ready;
      _status.whisperModel.progress = 1.0;
    }

    // Check ML Kit models
    final mlkitService = MlkitTranslationService.instance;
    await mlkitService.initialize();
    
    if (mlkitService.isChineseModelReady) {
      _status.chineseTranslation.status = PackDownloadStatus.ready;
      _status.chineseTranslation.progress = 1.0;
    }
    
    if (mlkitService.isArabicModelReady) {
      _status.arabicTranslation.status = PackDownloadStatus.ready;
      _status.arabicTranslation.progress = 1.0;
    }

    // Check TTS availability
    final ttsService = TtsToFileService.instance;
    await ttsService.initialize();
    _status.chineseTtsAvailable = ttsService.isChineseTtsAvailable;
    _status.arabicTtsAvailable = ttsService.isArabicTtsAvailable;

    _notifyStatusChanged();
    return _status;
  }

  /// Download all required packs
  Future<bool> downloadAll() async {
    bool success = true;

    // Download Whisper model
    if (!_status.whisperModel.isReady) {
      success = success && await downloadWhisperModel();
    }

    // Download ML Kit Chinese model
    if (!_status.chineseTranslation.isReady) {
      success = success && await downloadChineseTranslation();
    }

    // Download ML Kit Arabic model
    if (!_status.arabicTranslation.isReady) {
      success = success && await downloadArabicTranslation();
    }

    return success;
  }

  /// Download Whisper STT model
  Future<bool> downloadWhisperModel({
    WhisperModelSize size = WhisperModelSize.base,
  }) async {
    final pack = _status.whisperModel;
    pack.status = PackDownloadStatus.downloading;
    pack.progress = 0.0;
    _notifyStatusChanged();

    try {
      final modelPath = await _getWhisperModelPath();
      final modelUrl = WhisperSttService.getModelDownloadUrl(size);

      // Download the model
      await _downloadFile(
        url: modelUrl,
        savePath: modelPath,
        onProgress: (progress) {
          pack.progress = progress;
          onDownloadProgress?.call(pack.id, progress);
          _notifyStatusChanged();
        },
      );

      // Initialize the STT service with the downloaded model
      await WhisperSttService.instance.initialize(
        modelPath: modelPath,
        modelSize: size,
      );

      pack.status = PackDownloadStatus.ready;
      pack.progress = 1.0;
      _notifyStatusChanged();
      return true;
    } catch (e) {
      pack.status = PackDownloadStatus.failed;
      pack.errorMessage = e.toString();
      _notifyStatusChanged();
      return false;
    }
  }

  /// Download Chinese translation model
  Future<bool> downloadChineseTranslation() async {
    final pack = _status.chineseTranslation;
    pack.status = PackDownloadStatus.downloading;
    pack.progress = 0.0;
    _notifyStatusChanged();

    try {
      final mlkitService = MlkitTranslationService.instance;
      final success = await mlkitService.downloadModel(
        'zh',
        onProgress: (progress) {
          pack.progress = progress;
          onDownloadProgress?.call(pack.id, progress);
          _notifyStatusChanged();
        },
      );

      if (success) {
        pack.status = PackDownloadStatus.ready;
        pack.progress = 1.0;
      } else {
        pack.status = PackDownloadStatus.failed;
        pack.errorMessage = 'Download failed';
      }
      _notifyStatusChanged();
      return success;
    } catch (e) {
      pack.status = PackDownloadStatus.failed;
      pack.errorMessage = e.toString();
      _notifyStatusChanged();
      return false;
    }
  }

  /// Download Arabic translation model
  Future<bool> downloadArabicTranslation() async {
    final pack = _status.arabicTranslation;
    pack.status = PackDownloadStatus.downloading;
    pack.progress = 0.0;
    _notifyStatusChanged();

    try {
      final mlkitService = MlkitTranslationService.instance;
      final success = await mlkitService.downloadModel(
        'ar',
        onProgress: (progress) {
          pack.progress = progress;
          onDownloadProgress?.call(pack.id, progress);
          _notifyStatusChanged();
        },
      );

      if (success) {
        pack.status = PackDownloadStatus.ready;
        pack.progress = 1.0;
      } else {
        pack.status = PackDownloadStatus.failed;
        pack.errorMessage = 'Download failed';
      }
      _notifyStatusChanged();
      return success;
    } catch (e) {
      pack.status = PackDownloadStatus.failed;
      pack.errorMessage = e.toString();
      _notifyStatusChanged();
      return false;
    }
  }

  /// Delete a downloaded pack
  Future<bool> deletePack(String packId) async {
    try {
      switch (packId) {
        case 'whisper_base':
          final modelPath = await _getWhisperModelPath();
          final file = File(modelPath);
          if (await file.exists()) {
            await file.delete();
          }
          await WhisperSttService.instance.dispose();
          _status.whisperModel.status = PackDownloadStatus.notDownloaded;
          _status.whisperModel.progress = 0.0;
          break;

        case 'mlkit_zh':
          await MlkitTranslationService.instance.deleteModel('zh');
          _status.chineseTranslation.status = PackDownloadStatus.notDownloaded;
          _status.chineseTranslation.progress = 0.0;
          break;

        case 'mlkit_ar':
          await MlkitTranslationService.instance.deleteModel('ar');
          _status.arabicTranslation.status = PackDownloadStatus.notDownloaded;
          _status.arabicTranslation.progress = 0.0;
          break;
      }

      _notifyStatusChanged();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get path for Whisper model storage
  Future<String> _getWhisperModelPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/models/whisper/ggml-base.bin';
  }

  /// Download a file with progress
  Future<void> _downloadFile({
    required String url,
    required String savePath,
    required void Function(double progress) onProgress,
  }) async {
    // Ensure directory exists
    final file = File(savePath);
    await file.parent.create(recursive: true);

    // TODO: Implement actual HTTP download with progress
    // Using dio or http package
    // final response = await dio.download(
    //   url,
    //   savePath,
    //   onReceiveProgress: (received, total) {
    //     if (total != -1) {
    //       onProgress(received / total);
    //     }
    //   },
    // );

    // Placeholder: simulate download
    for (int i = 0; i <= 100; i += 5) {
      await Future.delayed(const Duration(milliseconds: 100));
      onProgress(i / 100);
    }

    // Create placeholder file
    await file.writeAsString('placeholder');
  }

  /// Notify status change callback
  void _notifyStatusChanged() {
    onStatusChanged?.call(_status);
  }

  /// Get TTS installation instructions
  String getTtsInstallInstructions(String languageCode) {
    return TtsToFileService.instance.getVoiceInstallInstructions(languageCode);
  }

  /// Refresh TTS availability
  Future<void> refreshTtsStatus() async {
    final ttsService = TtsToFileService.instance;
    await ttsService.initialize();
    _status.chineseTtsAvailable = ttsService.isChineseTtsAvailable;
    _status.arabicTtsAvailable = ttsService.isArabicTtsAvailable;
    _notifyStatusChanged();
  }
}
