/// Offline pack status model for Call Companion Mode
/// Tracks download and readiness status of offline models

enum PackDownloadStatus {
  /// Not downloaded yet
  notDownloaded,

  /// Currently downloading
  downloading,

  /// Downloaded and ready
  ready,

  /// Download failed
  failed,
}

/// Status of a single offline pack/model
class OfflinePackItem {
  /// Pack identifier
  final String id;

  /// Display name (Arabic)
  final String nameAr;

  /// Display name (English)
  final String nameEn;

  /// Description (Arabic)
  final String descriptionAr;

  /// Size in bytes (approximate)
  final int sizeBytes;

  /// Current download status
  PackDownloadStatus status;

  /// Download progress (0.0 to 1.0)
  double progress;

  /// Error message if failed
  String? errorMessage;

  OfflinePackItem({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.descriptionAr,
    required this.sizeBytes,
    this.status = PackDownloadStatus.notDownloaded,
    this.progress = 0.0,
    this.errorMessage,
  });

  /// Get human-readable size
  String get sizeDisplay {
    if (sizeBytes < 1024 * 1024) {
      return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    } else if (sizeBytes < 1024 * 1024 * 1024) {
      return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(sizeBytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    }
  }

  /// Check if ready to use
  bool get isReady => status == PackDownloadStatus.ready;

  /// Check if downloading
  bool get isDownloading => status == PackDownloadStatus.downloading;

  /// Get progress percentage
  int get progressPercent => (progress * 100).round();
}

/// Overall status of all offline packs for Call Companion
class OfflinePackStatus {
  /// Whisper STT model
  final OfflinePackItem whisperModel;

  /// ML Kit Chinese language model
  final OfflinePackItem chineseTranslation;

  /// ML Kit Arabic language model
  final OfflinePackItem arabicTranslation;

  /// System TTS Chinese voice availability
  bool chineseTtsAvailable;

  /// System TTS Arabic voice availability
  bool arabicTtsAvailable;

  OfflinePackStatus({
    required this.whisperModel,
    required this.chineseTranslation,
    required this.arabicTranslation,
    this.chineseTtsAvailable = false,
    this.arabicTtsAvailable = false,
  });

  /// Create default status with all packs not downloaded
  factory OfflinePackStatus.initial() {
    return OfflinePackStatus(
      whisperModel: OfflinePackItem(
        id: 'whisper_base',
        nameAr: 'نموذج التعرف على الكلام',
        nameEn: 'Speech Recognition Model',
        descriptionAr: 'نموذج Whisper للتعرف على الكلام بدون إنترنت',
        sizeBytes: 150 * 1024 * 1024, // ~150 MB for base model
      ),
      chineseTranslation: OfflinePackItem(
        id: 'mlkit_zh',
        nameAr: 'نموذج الترجمة الصينية',
        nameEn: 'Chinese Translation Model',
        descriptionAr: 'نموذج الترجمة من وإلى الصينية',
        sizeBytes: 30 * 1024 * 1024, // ~30 MB
      ),
      arabicTranslation: OfflinePackItem(
        id: 'mlkit_ar',
        nameAr: 'نموذج الترجمة العربية',
        nameEn: 'Arabic Translation Model',
        descriptionAr: 'نموذج الترجمة من وإلى العربية',
        sizeBytes: 30 * 1024 * 1024, // ~30 MB
      ),
    );
  }

  /// Get all pack items as a list
  List<OfflinePackItem> get allPacks => [
        whisperModel,
        chineseTranslation,
        arabicTranslation,
      ];

  /// Check if all required packs are ready
  bool get allPacksReady =>
      whisperModel.isReady &&
      chineseTranslation.isReady &&
      arabicTranslation.isReady;

  /// Check if TTS is ready for both languages
  bool get ttsReady => chineseTtsAvailable && arabicTtsAvailable;

  /// Check if fully ready for offline use
  bool get isFullyReady => allPacksReady && ttsReady;

  /// Get total size of all packs
  int get totalSizeBytes =>
      whisperModel.sizeBytes +
      chineseTranslation.sizeBytes +
      arabicTranslation.sizeBytes;

  /// Get total size display
  String get totalSizeDisplay {
    final bytes = totalSizeBytes;
    return '${(bytes / (1024 * 1024)).toStringAsFixed(0)} MB';
  }

  /// Get number of packs ready
  int get packsReadyCount => allPacks.where((p) => p.isReady).length;

  /// Get total number of packs
  int get totalPacksCount => allPacks.length;

  /// Get readiness summary (Arabic)
  String get readinessSummaryAr {
    if (isFullyReady) {
      return 'جاهز للاستخدام بدون إنترنت ✓';
    }
    final missing = <String>[];
    if (!whisperModel.isReady) missing.add('نموذج الكلام');
    if (!chineseTranslation.isReady) missing.add('الترجمة الصينية');
    if (!arabicTranslation.isReady) missing.add('الترجمة العربية');
    if (!chineseTtsAvailable) missing.add('صوت صيني');
    if (!arabicTtsAvailable) missing.add('صوت عربي');
    return 'مطلوب: ${missing.join('، ')}';
  }
}
