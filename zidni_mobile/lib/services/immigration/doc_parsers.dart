import 'package:uuid/uuid.dart';
import '../../models/immigration/immigration_document.dart';

/// Parsers for extracting structured data from OCR text of immigration documents.
class DocParsers {
  DocParsers._();

  static const _uuid = Uuid();

  /// Parse I-94 Arrival/Departure Record
  static ImmigrationDocument? parseI94(String ocrText) {
    try {
      final lines = ocrText.split('\n').map((l) => l.trim()).toList();
      
      String? admissionNumber;
      String? fullName;
      DateTime? dateOfBirth;
      String? countryOfCitizenship;
      String? classOfAdmission;
      DateTime? admitUntilDate;

      for (final line in lines) {
        final upperLine = line.toUpperCase();
        
        // Parse admission number
        if (upperLine.contains('ADMISSION') && upperLine.contains('NUMBER')) {
          admissionNumber = _extractValue(line);
        }
        
        // Parse name
        if (upperLine.contains('NAME:') || upperLine.startsWith('NAME')) {
          fullName = _extractValue(line);
        }
        
        // Parse date of birth
        if (upperLine.contains('DATE OF BIRTH') || upperLine.contains('DOB')) {
          dateOfBirth = _parseDate(_extractValue(line));
        }
        
        // Parse country
        if (upperLine.contains('COUNTRY') || upperLine.contains('CITIZENSHIP')) {
          countryOfCitizenship = _extractValue(line);
        }
        
        // Parse class of admission
        if (upperLine.contains('CLASS') && upperLine.contains('ADMISSION')) {
          classOfAdmission = _extractValue(line);
        }
        
        // Parse admit until date
        if (upperLine.contains('ADMIT UNTIL') || upperLine.contains('UNTIL DATE')) {
          admitUntilDate = _parseDate(_extractValue(line));
        }
      }

      return ImmigrationDocument(
        id: _uuid.v4(),
        type: ImmigrationDocumentType.i94,
        documentNumber: admissionNumber,
        fullName: fullName,
        dateOfBirth: dateOfBirth,
        countryOfCitizenship: countryOfCitizenship,
        classOfAdmission: classOfAdmission,
        admitUntilDate: admitUntilDate,
        rawText: ocrText,
        scannedAt: DateTime.now(),
      );
    } catch (e) {
      return null;
    }
  }

  /// Parse Visa document
  static ImmigrationDocument? parseVisa(String ocrText) {
    try {
      final lines = ocrText.split('\n').map((l) => l.trim()).toList();
      
      String? fullName;
      DateTime? issueDate;
      DateTime? expirationDate;
      String? countryOfCitizenship;
      VisaCategory? visaCategory;

      for (final line in lines) {
        final upperLine = line.toUpperCase();
        
        // Parse visa type
        if (upperLine.contains('VISA TYPE') || upperLine.contains('TYPE:')) {
          final typeStr = _extractValue(line);
          visaCategory = _parseVisaCategory(typeStr);
        }
        
        // Parse name
        if (upperLine.contains('NAME:') || upperLine.startsWith('NAME')) {
          fullName = _extractValue(line);
        }
        
        // Parse issue date
        if (upperLine.contains('ISSUE DATE') || upperLine.contains('ISSUED')) {
          issueDate = _parseDate(_extractValue(line));
        }
        
        // Parse expiration date
        if (upperLine.contains('EXPIRATION') || upperLine.contains('EXPIRES')) {
          expirationDate = _parseDate(_extractValue(line));
        }
        
        // Parse nationality
        if (upperLine.contains('NATIONALITY') || upperLine.contains('COUNTRY')) {
          countryOfCitizenship = _extractValue(line);
        }
      }

      return ImmigrationDocument(
        id: _uuid.v4(),
        type: ImmigrationDocumentType.visa,
        fullName: fullName,
        issueDate: issueDate,
        expirationDate: expirationDate,
        countryOfCitizenship: countryOfCitizenship,
        visaCategory: visaCategory,
        rawText: ocrText,
        scannedAt: DateTime.now(),
      );
    } catch (e) {
      return null;
    }
  }

  /// Parse Green Card (Permanent Resident Card)
  static ImmigrationDocument? parseGreenCard(String ocrText) {
    try {
      final lines = ocrText.split('\n').map((l) => l.trim()).toList();
      
      String? documentNumber;
      String? fullName;
      DateTime? issueDate;
      DateTime? expirationDate;
      String? countryOfCitizenship;

      for (final line in lines) {
        final upperLine = line.toUpperCase();
        
        // Parse USCIS number
        if (upperLine.contains('USCIS') || upperLine.contains('CARD#')) {
          documentNumber = _extractValue(line).replaceAll('-', '');
        }
        
        // Parse name
        if (upperLine.contains('NAME:') || upperLine.startsWith('NAME')) {
          fullName = _extractValue(line);
        }
        
        // Parse resident since (issue date)
        if (upperLine.contains('RESIDENT SINCE') || upperLine.contains('SINCE')) {
          issueDate = _parseDate(_extractValue(line));
        }
        
        // Parse expiration
        if (upperLine.contains('EXPIRES') || upperLine.contains('CARD EXPIRES')) {
          expirationDate = _parseDate(_extractValue(line));
        }
        
        // Parse country of birth
        if (upperLine.contains('COUNTRY OF BIRTH') || upperLine.contains('BIRTH')) {
          countryOfCitizenship = _extractValue(line);
        }
      }

      return ImmigrationDocument(
        id: _uuid.v4(),
        type: ImmigrationDocumentType.greenCard,
        documentNumber: documentNumber,
        fullName: fullName,
        issueDate: issueDate,
        expirationDate: expirationDate,
        countryOfCitizenship: countryOfCitizenship,
        rawText: ocrText,
        scannedAt: DateTime.now(),
      );
    } catch (e) {
      return null;
    }
  }

  /// Parse SSN card
  static ImmigrationDocument? parseSSN(String ocrText) {
    try {
      final lines = ocrText.split('\n').map((l) => l.trim()).toList();
      
      String? documentNumber;
      String? fullName;

      for (final line in lines) {
        // Look for SSN pattern (XXX-XX-XXXX)
        final ssnRegex = RegExp(r'\d{3}-\d{2}-\d{4}');
        final match = ssnRegex.firstMatch(line);
        if (match != null) {
          documentNumber = match.group(0);
        }
        
        // Parse name (usually the line without numbers)
        if (!line.contains(RegExp(r'\d')) && line.length > 3) {
          fullName = line;
        }
      }

      return ImmigrationDocument(
        id: _uuid.v4(),
        type: ImmigrationDocumentType.ssn,
        documentNumber: documentNumber,
        fullName: fullName,
        rawText: ocrText,
        scannedAt: DateTime.now(),
      );
    } catch (e) {
      return null;
    }
  }

  /// Parse EAD (Employment Authorization Document)
  static ImmigrationDocument? parseEAD(String ocrText) {
    try {
      final lines = ocrText.split('\n').map((l) => l.trim()).toList();
      
      String? documentNumber;
      String? fullName;
      DateTime? issueDate;
      DateTime? expirationDate;

      for (final line in lines) {
        final upperLine = line.toUpperCase();
        
        // Parse card number
        if (upperLine.contains('CARD#') || upperLine.contains('USCIS')) {
          documentNumber = _extractValue(line);
        }
        
        // Parse name
        if (upperLine.contains('NAME:') || upperLine.startsWith('NAME')) {
          fullName = _extractValue(line);
        }
        
        // Parse valid from
        if (upperLine.contains('VALID FROM') || upperLine.contains('FROM:')) {
          issueDate = _parseDate(_extractValue(line));
        }
        
        // Parse expiration
        if (upperLine.contains('EXPIRES') || upperLine.contains('TO:')) {
          expirationDate = _parseDate(_extractValue(line));
        }
      }

      return ImmigrationDocument(
        id: _uuid.v4(),
        type: ImmigrationDocumentType.ead,
        documentNumber: documentNumber,
        fullName: fullName,
        issueDate: issueDate,
        expirationDate: expirationDate,
        rawText: ocrText,
        scannedAt: DateTime.now(),
      );
    } catch (e) {
      return null;
    }
  }

  /// Extract value after colon or from end of line
  static String _extractValue(String line) {
    if (line.contains(':')) {
      return line.split(':').last.trim();
    }
    // Return last word(s) after known keywords
    final parts = line.split(' ');
    if (parts.length > 1) {
      return parts.sublist(parts.length ~/ 2).join(' ').trim();
    }
    return line.trim();
  }

  /// Parse date from various formats
  static DateTime? _parseDate(String dateStr) {
    if (dateStr.isEmpty) return null;
    
    // Try various date formats
    final formats = [
      RegExp(r'(\d{2})\s+([A-Z]{3})\s+(\d{4})'), // 01 JAN 2024
      RegExp(r'(\d{2})/(\d{2})/(\d{4})'), // 01/01/2024
      RegExp(r'(\d{4})-(\d{2})-(\d{2})'), // 2024-01-01
    ];

    for (final format in formats) {
      final match = format.firstMatch(dateStr.toUpperCase());
      if (match != null) {
        try {
          if (format.pattern.contains('[A-Z]')) {
            // Month name format
            final day = int.parse(match.group(1)!);
            final month = _parseMonth(match.group(2)!);
            final year = int.parse(match.group(3)!);
            return DateTime(year, month, day);
          } else if (format.pattern.startsWith(r'(\d{4})')) {
            // ISO format
            return DateTime.parse(dateStr);
          } else {
            // MM/DD/YYYY format
            final month = int.parse(match.group(1)!);
            final day = int.parse(match.group(2)!);
            final year = int.parse(match.group(3)!);
            return DateTime(year, month, day);
          }
        } catch (e) {
          continue;
        }
      }
    }
    
    return null;
  }

  /// Parse month name to number
  static int _parseMonth(String month) {
    const months = {
      'JAN': 1, 'FEB': 2, 'MAR': 3, 'APR': 4, 'MAY': 5, 'JUN': 6,
      'JUL': 7, 'AUG': 8, 'SEP': 9, 'OCT': 10, 'NOV': 11, 'DEC': 12,
    };
    return months[month.toUpperCase()] ?? 1;
  }

  /// Parse visa category from string
  static VisaCategory _parseVisaCategory(String typeStr) {
    final upper = typeStr.toUpperCase().replaceAll(' ', '');
    
    if (upper.contains('B1') || upper.contains('B2') || upper.contains('B1/B2')) {
      return VisaCategory.b1b2;
    }
    if (upper.contains('F1') || upper.contains('F-1')) {
      return VisaCategory.f1;
    }
    if (upper.contains('H1B') || upper.contains('H-1B')) {
      return VisaCategory.h1b;
    }
    if (upper.contains('J1') || upper.contains('J-1')) {
      return VisaCategory.j1;
    }
    if (upper.contains('L1') || upper.contains('L-1')) {
      return VisaCategory.l1;
    }
    if (upper.contains('O1') || upper.contains('O-1')) {
      return VisaCategory.o1;
    }
    if (upper.contains('K1') || upper.contains('K-1')) {
      return VisaCategory.k1;
    }
    
    return VisaCategory.other;
  }
}
