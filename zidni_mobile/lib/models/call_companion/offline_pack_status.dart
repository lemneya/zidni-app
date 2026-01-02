/// Offline pack status model for Call Companion Mode
/// Tracks download and readiness status of offline models
/// 
/// Supported Languages:
/// - Arabic (required)
/// - Chinese (for Canton Fair / China)
/// - English (for USA / International)
/// - Turkish (for Turkey)

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
class PackStatus {
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

  PackStatus({
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

/// Alias for backward compatibility
typedef OfflinePackItem = PackStatus;

/// Overall status of all offline packs for Call Companion
class OfflinePackStatus {
  /// Whisper STT model
  final PackStatus whisperModel;

  /// ML Kit Arabic language model (always required)
  final PackStatus arabicTranslation;

  /// ML Kit Chinese language model
  final PackStatus chineseTranslation;

  /// ML Kit English language model
  final PackStatus englishTranslation;

  /// ML Kit Turkish language model
  final PackStatus turkishTranslation;

  /// System TTS Arabic voice availability
  bool arabicTtsAvailable;

  /// System TTS Chinese voice availability
  bool chineseTtsAvailable;

  /// System TTS English voice availability
  bool englishTtsAvailable;

  /// System TTS Turkish voice availability
  bool turkishTtsAvailable;

  OfflinePackStatus({
    required this.whisperModel,
    required this.arabicTranslation,
    required this.chineseTranslation,
    required this.englishTranslation,
    required this.turkishTranslation,
    this.arabicTtsAvailable = false,
    this.chineseTtsAvailable = false,
    this.englishTtsAvailable = false,
    this.turkishTtsAvailable = false,
  });

  /// Create default status with all packs not downloaded
  factory OfflinePackStatus.initial() {
    return OfflinePackStatus(
      whisperModel: PackStatus(
        id: 'whisper_base',
        nameAr: 'نموذج التعرف على الكلام',
        nameEn: 'Speech Recognition Model',
        descriptionAr: 'نموذج Whisper للتعرف على الكلام بدون إنترنت',
        sizeBytes: 150 * 1024 * 1024, // ~150 MB for base model
      ),
      arabicTranslation: PackStatus(
        id: 'mlkit_ar',
        nameAr: 'نموذج الترجمة العربية',
        nameEn: 'Arabic Translation Model',
        descriptionAr: 'نموذج الترجمة من وإلى العربية (مطلوب)',
        sizeBytes: 30 * 1024 * 1024, // ~30 MB
      ),
      chineseTranslation: PackStatus(
        id: 'mlkit_zh',
        nameAr: 'نموذج الترجمة الصينية',
        nameEn: 'Chinese Translation Model',
        descriptionAr: 'نموذج الترجمة من وإلى الصينية',
        sizeBytes: 30 * 1024 * 1024, // ~30 MB
      ),
      englishTranslation: PackStatus(
        id: 'mlkit_en',
        nameAr: 'نموذج الترجمة الإنجليزية',
        nameEn: 'English Translation Model',
        descriptionAr: 'نموذج الترجمة من وإلى الإنجليزية',
        sizeBytes: 25 * 1024 * 1024, // ~25 MB
      ),
      turkishTranslation: PackStatus(
        id: 'mlkit_tr',
        nameAr: 'نموذج الترجمة التركية',
        nameEn: 'Turkish Translation Model',
        descriptionAr: 'نموذج الترجمة من وإلى التركية',
        sizeBytes: 28 * 1024 * 1024, // ~28 MB
      ),
    );
  }

  /// Get all pack items as a list
  List<PackStatus> get allPacks => [
        whisperModel,
        arabicTranslation,
        chineseTranslation,
        englishTranslation,
        turkishTranslation,
      ];

  /// Get translation packs only
  List<PackStatus> get translationPacks => [
        arabicTranslation,
        chineseTranslation,
        englishTranslation,
        turkishTranslation,
      ];

  /// Check if core packs are ready (Whisper + Arabic)
  bool get corePacksReady =>
      whisperModel.isReady && arabicTranslation.isReady;

  /// Check if at least one language pair is ready (Arabic + one other)
  bool get hasOneLanguagePairReady =>
      arabicTranslation.isReady &&
      (chineseTranslation.isReady ||
          englishTranslation.isReady ||
          turkishTranslation.isReady);

  /// Check if all packs are ready
  bool get allPacksReady =>
      whisperModel.isReady &&
      arabicTranslation.isReady &&
      chineseTranslation.isReady &&
      englishTranslation.isReady &&
      turkishTranslation.isReady;

  /// Check if TTS is ready for core languages
  bool get coreTtsReady => arabicTtsAvailable;

  /// Check if fully ready for offline use (core + at least one language pair)
  bool get isFullyReady =>
      corePacksReady && hasOneLanguagePairReady && coreTtsReady;

  /// Get total size of all packs
  int get totalSizeBytes =>
      whisperModel.sizeBytes +
      arabicTranslation.sizeBytes +
      chineseTranslation.sizeBytes +
      englishTranslation.sizeBytes +
      turkishTranslation.sizeBytes;

  /// Get total size display
  String get totalSizeDisplay {
    final bytes = totalSizeBytes;
    return '${(bytes / (1024 * 1024)).toStringAsFixed(0)} MB';
  }

  /// Get number of packs ready
  int get packsReadyCount => allPacks.where((p) => p.isReady).length;

  /// Get total number of packs
  int get totalPacksCount => allPacks.length;

  /// Get list of ready language codes
  List<String> get readyLanguages {
    final languages = <String>[];
    if (arabicTranslation.isReady) languages.add('ar');
    if (chineseTranslation.isReady) languages.add('zh');
    if (englishTranslation.isReady) languages.add('en');
    if (turkishTranslation.isReady) languages.add('tr');
    return languages;
  }

  /// Get readiness summary (Arabic)
  String get readinessSummaryAr {
    if (isFullyReady && allPacksReady) {
      return 'جاهز للاستخدام بدون إنترنت ✓';
    }
    if (isFullyReady) {
      final ready = <String>[];
      if (chineseTranslation.isReady) ready.add('الصينية');
      if (englishTranslation.isReady) ready.add('الإنجليزية');
      if (turkishTranslation.isReady) ready.add('التركية');
      return 'جاهز: ${ready.join('، ')}';
    }

    final missing = <String>[];
    if (!whisperModel.isReady) missing.add('نموذج الكلام');
    if (!arabicTranslation.isReady) missing.add('العربية');
    if (!chineseTranslation.isReady &&
        !englishTranslation.isReady &&
        !turkishTranslation.isReady) {
      missing.add('لغة واحدة على الأقل');
    }
    if (!arabicTtsAvailable) missing.add('صوت عربي');
    return 'مطلوب: ${missing.join('، ')}';
  }

  /// Get language-specific readiness
  String getLanguageReadiness(String languageCode) {
    switch (languageCode) {
      case 'ar':
        return arabicTranslation.isReady ? 'جاهز ✓' : 'غير محمّل';
      case 'zh':
        return chineseTranslation.isReady ? 'جاهز ✓' : 'غير محمّل';
      case 'en':
        return englishTranslation.isReady ? 'جاهز ✓' : 'غير محمّل';
      case 'tr':
        return turkishTranslation.isReady ? 'جاهز ✓' : 'غير محمّل';
      default:
        return 'غير مدعوم';
    }
  }
}
