import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../models/immigration/immigration_document.dart';
import 'doc_parsers.dart';

/// Service for scanning and parsing immigration documents using OCR.
/// 
/// Integrates with the existing EYES OCR system to scan:
/// - I-94 (Arrival/Departure Record)
/// - Visa stamps and pages
/// - Green Card (front and back)
/// - SSN card
/// - EAD card
class DocScannerService {
  DocScannerService._();
  static final DocScannerService instance = DocScannerService._();

  /// Scan a document image and extract data
  /// 
  /// [imagePath] - Path to the image file
  /// [documentType] - Expected document type (optional, will auto-detect if null)
  Future<ScanResult> scanDocument({
    required String imagePath,
    ImmigrationDocumentType? documentType,
  }) async {
    try {
      // TODO: Integrate with EYES OCR service
      // For now, return mock result
      
      debugPrint('DocScannerService: Scanning document at $imagePath');
      
      // Simulate OCR processing
      await Future.delayed(const Duration(seconds: 2));
      
      // Mock OCR text (in production, this comes from EYES)
      final mockOcrText = _getMockOcrText(documentType);
      
      // Parse the OCR text
      final document = await _parseOcrText(
        ocrText: mockOcrText,
        documentType: documentType,
      );
      
      return ScanResult(
        success: true,
        document: document,
        rawText: mockOcrText,
        confidence: 0.85,
      );
    } catch (e) {
      debugPrint('DocScannerService: Error scanning document: $e');
      return ScanResult(
        success: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Auto-detect document type from image
  Future<ImmigrationDocumentType?> detectDocumentType(String imagePath) async {
    // TODO: Implement document type detection using ML
    // For now, return null (unknown)
    return null;
  }

  /// Parse OCR text into structured document
  Future<ImmigrationDocument?> _parseOcrText({
    required String ocrText,
    ImmigrationDocumentType? documentType,
  }) async {
    // Auto-detect type if not provided
    final detectedType = documentType ?? _detectTypeFromText(ocrText);
    
    switch (detectedType) {
      case ImmigrationDocumentType.i94:
        return DocParsers.parseI94(ocrText);
      case ImmigrationDocumentType.visa:
        return DocParsers.parseVisa(ocrText);
      case ImmigrationDocumentType.greenCard:
        return DocParsers.parseGreenCard(ocrText);
      case ImmigrationDocumentType.ssn:
        return DocParsers.parseSSN(ocrText);
      case ImmigrationDocumentType.ead:
        return DocParsers.parseEAD(ocrText);
      default:
        return null;
    }
  }

  /// Detect document type from OCR text
  ImmigrationDocumentType _detectTypeFromText(String text) {
    final upperText = text.toUpperCase();
    
    if (upperText.contains('I-94') || upperText.contains('ARRIVAL') && upperText.contains('DEPARTURE')) {
      return ImmigrationDocumentType.i94;
    }
    if (upperText.contains('VISA') || upperText.contains('NONIMMIGRANT')) {
      return ImmigrationDocumentType.visa;
    }
    if (upperText.contains('PERMANENT RESIDENT') || upperText.contains('GREEN CARD')) {
      return ImmigrationDocumentType.greenCard;
    }
    if (upperText.contains('SOCIAL SECURITY')) {
      return ImmigrationDocumentType.ssn;
    }
    if (upperText.contains('EMPLOYMENT AUTHORIZATION') || upperText.contains('EAD')) {
      return ImmigrationDocumentType.ead;
    }
    
    return ImmigrationDocumentType.other;
  }

  /// Get mock OCR text for testing
  String _getMockOcrText(ImmigrationDocumentType? type) {
    switch (type) {
      case ImmigrationDocumentType.i94:
        return '''
I-94 ARRIVAL/DEPARTURE RECORD
Admission Number: 123456789012
Name: AHMED MOHAMMED
Date of Birth: 01 JAN 1990
Country of Citizenship: MAURITANIA
Class of Admission: B1/B2
Admit Until Date: 15 JUL 2026
''';
      case ImmigrationDocumentType.visa:
        return '''
NONIMMIGRANT VISA
Visa Type: B1/B2
Issue Date: 01 JAN 2024
Expiration Date: 01 JAN 2034
Name: AHMED MOHAMMED
Nationality: MAURITANIA
''';
      case ImmigrationDocumentType.greenCard:
        return '''
PERMANENT RESIDENT CARD
USCIS#: 123-456-789
Category: IR1
Country of Birth: MAURITANIA
Resident Since: 01 JAN 2020
Card Expires: 01 JAN 2030
Name: AHMED MOHAMMED
''';
      default:
        return 'Unknown document type';
    }
  }
}

/// Result of a document scan
class ScanResult {
  /// Whether the scan was successful
  final bool success;
  
  /// Parsed document (if successful)
  final ImmigrationDocument? document;
  
  /// Raw OCR text
  final String? rawText;
  
  /// Confidence score (0-1)
  final double? confidence;
  
  /// Error message (if failed)
  final String? errorMessage;

  const ScanResult({
    required this.success,
    this.document,
    this.rawText,
    this.confidence,
    this.errorMessage,
  });
}
