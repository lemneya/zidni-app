/// Model for Eyes OCR scan result
/// Gate EYES-1: OCR Scan → Product Insight Card → Save
class EyesScanResult {
  final String? id;
  final String rawText;
  final String? detectedLanguage;
  final String? productNameGuess;
  final Map<String, String> extractedFields;
  final DateTime scannedAt;
  final String? imagePath;

  EyesScanResult({
    this.id,
    required this.rawText,
    this.detectedLanguage,
    this.productNameGuess,
    this.extractedFields = const {},
    required this.scannedAt,
    this.imagePath,
  });

  /// Create from JSON (for SharedPreferences storage)
  factory EyesScanResult.fromJson(Map<String, dynamic> json) {
    return EyesScanResult(
      id: json['id'],
      rawText: json['rawText'] ?? '',
      detectedLanguage: json['detectedLanguage'],
      productNameGuess: json['productNameGuess'],
      extractedFields: Map<String, String>.from(json['extractedFields'] ?? {}),
      scannedAt: DateTime.parse(json['scannedAt']),
      imagePath: json['imagePath'],
    );
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() => {
    'id': id,
    'rawText': rawText,
    'detectedLanguage': detectedLanguage,
    'productNameGuess': productNameGuess,
    'extractedFields': extractedFields,
    'scannedAt': scannedAt.toIso8601String(),
    'imagePath': imagePath,
  };

  /// Get a preview of the raw text (first 100 chars)
  String get textPreview {
    if (rawText.length <= 100) return rawText;
    return '${rawText.substring(0, 100)}...';
  }

  /// Copy with new values
  EyesScanResult copyWith({
    String? id,
    String? rawText,
    String? detectedLanguage,
    String? productNameGuess,
    Map<String, String>? extractedFields,
    DateTime? scannedAt,
    String? imagePath,
  }) {
    return EyesScanResult(
      id: id ?? this.id,
      rawText: rawText ?? this.rawText,
      detectedLanguage: detectedLanguage ?? this.detectedLanguage,
      productNameGuess: productNameGuess ?? this.productNameGuess,
      extractedFields: extractedFields ?? this.extractedFields,
      scannedAt: scannedAt ?? this.scannedAt,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}
