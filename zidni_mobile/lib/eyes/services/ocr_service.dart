import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:zidni_mobile/eyes/models/eyes_scan_result.dart';

/// OCR Service for Zidni Eyes
/// Gate EYES-1: Text recognition from camera images
class OcrService {
  TextRecognizer? _textRecognizer;
  
  /// Initialize the text recognizer
  Future<void> init() async {
    _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  }
  
  /// Dispose the text recognizer
  void dispose() {
    _textRecognizer?.close();
    _textRecognizer = null;
  }
  
  /// Process an image file and extract text
  /// Returns an EyesScanResult with raw text and detected language
  Future<EyesScanResult> processImage(String imagePath) async {
    if (_textRecognizer == null) {
      await init();
    }
    
    final inputImage = InputImage.fromFilePath(imagePath);
    final recognizedText = await _textRecognizer!.processImage(inputImage);
    
    final rawText = recognizedText.text;
    final detectedLanguage = _detectLanguage(rawText);
    final productNameGuess = _guessProductName(rawText);
    final extractedFields = _extractFields(rawText);
    
    return EyesScanResult(
      rawText: rawText,
      detectedLanguage: detectedLanguage,
      productNameGuess: productNameGuess,
      extractedFields: extractedFields,
      scannedAt: DateTime.now(),
      imagePath: imagePath,
    );
  }
  
  /// Detect the primary language of the text (best effort)
  String _detectLanguage(String text) {
    if (text.isEmpty) return 'unknown';
    
    // Count Chinese characters
    final chinesePattern = RegExp(r'[\u4e00-\u9fff]');
    final chineseCount = chinesePattern.allMatches(text).length;
    
    // Count Arabic characters
    final arabicPattern = RegExp(r'[\u0600-\u06ff]');
    final arabicCount = arabicPattern.allMatches(text).length;
    
    // Count Latin characters
    final latinPattern = RegExp(r'[a-zA-Z]');
    final latinCount = latinPattern.allMatches(text).length;
    
    // Determine primary language
    if (chineseCount > arabicCount && chineseCount > latinCount) {
      return 'zh';
    } else if (arabicCount > chineseCount && arabicCount > latinCount) {
      return 'ar';
    } else if (latinCount > 0) {
      return 'en'; // Default to English for Latin script
    }
    
    return 'unknown';
  }
  
  /// Attempt to guess the product name from OCR text
  String? _guessProductName(String text) {
    if (text.isEmpty) return null;
    
    // Take the first non-empty line as a product name guess
    final lines = text.split('\n').where((line) => line.trim().isNotEmpty).toList();
    if (lines.isEmpty) return null;
    
    // Return the first substantial line (at least 3 characters)
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.length >= 3) {
        // Limit to 100 characters
        return trimmed.length > 100 ? '${trimmed.substring(0, 100)}...' : trimmed;
      }
    }
    
    return null;
  }
  
  /// Extract common product fields from OCR text
  Map<String, String> _extractFields(String text) {
    final fields = <String, String>{};
    
    if (text.isEmpty) return fields;
    
    // Try to extract brand (look for common patterns)
    final brandPatterns = [
      RegExp(r'(?:Brand|品牌|العلامة)[:\s]*([^\n]+)', caseSensitive: false),
    ];
    for (final pattern in brandPatterns) {
      final match = pattern.firstMatch(text);
      if (match != null && match.group(1) != null) {
        fields['brand'] = match.group(1)!.trim();
        break;
      }
    }
    
    // Try to extract model
    final modelPatterns = [
      RegExp(r'(?:Model|型号|الموديل)[:\s]*([^\n]+)', caseSensitive: false),
      RegExp(r'(?:Model No\.?|M/N)[:\s]*([^\n]+)', caseSensitive: false),
    ];
    for (final pattern in modelPatterns) {
      final match = pattern.firstMatch(text);
      if (match != null && match.group(1) != null) {
        fields['model'] = match.group(1)!.trim();
        break;
      }
    }
    
    // Try to extract size/dimensions
    final sizePatterns = [
      RegExp(r'(?:Size|尺寸|المقاس)[:\s]*([^\n]+)', caseSensitive: false),
      RegExp(r'(\d+(?:\.\d+)?\s*[xX×]\s*\d+(?:\.\d+)?(?:\s*[xX×]\s*\d+(?:\.\d+)?)?)\s*(?:mm|cm|m|inch)?', caseSensitive: false),
    ];
    for (final pattern in sizePatterns) {
      final match = pattern.firstMatch(text);
      if (match != null && match.group(1) != null) {
        fields['size'] = match.group(1)!.trim();
        break;
      }
    }
    
    // Try to extract material
    final materialPatterns = [
      RegExp(r'(?:Material|材质|المادة)[:\s]*([^\n]+)', caseSensitive: false),
    ];
    for (final pattern in materialPatterns) {
      final match = pattern.firstMatch(text);
      if (match != null && match.group(1) != null) {
        fields['material'] = match.group(1)!.trim();
        break;
      }
    }
    
    // Try to extract SKU/barcode
    final skuPatterns = [
      RegExp(r'(?:SKU|货号|رقم المنتج)[:\s]*([^\n]+)', caseSensitive: false),
      RegExp(r'(?:Barcode|条码|الباركود)[:\s]*(\d+)', caseSensitive: false),
      RegExp(r'\b(\d{8,14})\b'), // Common barcode lengths
    ];
    for (final pattern in skuPatterns) {
      final match = pattern.firstMatch(text);
      if (match != null && match.group(1) != null) {
        fields['sku'] = match.group(1)!.trim();
        break;
      }
    }
    
    return fields;
  }
}
