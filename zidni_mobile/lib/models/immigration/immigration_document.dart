/// Immigration document types and parsed data models.
/// 
/// Supports common US immigration documents:
/// - I-94 (Arrival/Departure Record)
/// - Visa (various types)
/// - Green Card (Permanent Resident Card)
/// - SSN (Social Security Number)
/// - EAD (Employment Authorization Document)

/// Types of immigration documents
enum ImmigrationDocumentType {
  i94('i94', 'I-94', 'سجل الوصول/المغادرة'),
  visa('visa', 'Visa', 'تأشيرة'),
  greenCard('green_card', 'Green Card', 'البطاقة الخضراء'),
  ssn('ssn', 'Social Security', 'الضمان الاجتماعي'),
  ead('ead', 'EAD', 'تصريح العمل'),
  passport('passport', 'Passport', 'جواز السفر'),
  other('other', 'Other', 'أخرى');

  const ImmigrationDocumentType(this.id, this.englishName, this.arabicName);

  final String id;
  final String englishName;
  final String arabicName;

  String getLocalizedName(String locale) {
    return locale.startsWith('ar') ? arabicName : englishName;
  }

  static ImmigrationDocumentType fromId(String id) {
    return ImmigrationDocumentType.values.firstWhere(
      (type) => type.id == id,
      orElse: () => ImmigrationDocumentType.other,
    );
  }
}

/// Visa categories
enum VisaCategory {
  b1b2('B1/B2', 'سياحة/أعمال'),
  f1('F-1', 'طالب'),
  h1b('H-1B', 'عمل متخصص'),
  j1('J-1', 'تبادل ثقافي'),
  l1('L-1', 'نقل داخل شركة'),
  o1('O-1', 'قدرات استثنائية'),
  k1('K-1', 'خطيب/خطيبة'),
  other('Other', 'أخرى');

  const VisaCategory(this.code, this.arabicName);

  final String code;
  final String arabicName;
}

/// Parsed immigration document data
class ImmigrationDocument {
  /// Unique identifier
  final String id;
  
  /// Document type
  final ImmigrationDocumentType type;
  
  /// Document number (if applicable)
  final String? documentNumber;
  
  /// Issue date
  final DateTime? issueDate;
  
  /// Expiration date
  final DateTime? expirationDate;
  
  /// Visa category (for visa documents)
  final VisaCategory? visaCategory;
  
  /// Class of admission (for I-94)
  final String? classOfAdmission;
  
  /// Admit until date (for I-94)
  final DateTime? admitUntilDate;
  
  /// Name as shown on document
  final String? fullName;
  
  /// Country of citizenship
  final String? countryOfCitizenship;
  
  /// Date of birth
  final DateTime? dateOfBirth;
  
  /// Raw OCR text (for debugging)
  final String? rawText;
  
  /// Confidence score (0-1)
  final double? confidence;
  
  /// When this document was scanned
  final DateTime scannedAt;
  
  /// Optional notes
  final String? notes;

  const ImmigrationDocument({
    required this.id,
    required this.type,
    this.documentNumber,
    this.issueDate,
    this.expirationDate,
    this.visaCategory,
    this.classOfAdmission,
    this.admitUntilDate,
    this.fullName,
    this.countryOfCitizenship,
    this.dateOfBirth,
    this.rawText,
    this.confidence,
    required this.scannedAt,
    this.notes,
  });

  /// Create from JSON
  factory ImmigrationDocument.fromJson(Map<String, dynamic> json) {
    return ImmigrationDocument(
      id: json['id'] as String,
      type: ImmigrationDocumentType.fromId(json['type'] as String),
      documentNumber: json['documentNumber'] as String?,
      issueDate: json['issueDate'] != null 
          ? DateTime.parse(json['issueDate'] as String) 
          : null,
      expirationDate: json['expirationDate'] != null 
          ? DateTime.parse(json['expirationDate'] as String) 
          : null,
      visaCategory: json['visaCategory'] != null
          ? VisaCategory.values.firstWhere(
              (v) => v.code == json['visaCategory'],
              orElse: () => VisaCategory.other,
            )
          : null,
      classOfAdmission: json['classOfAdmission'] as String?,
      admitUntilDate: json['admitUntilDate'] != null
          ? DateTime.parse(json['admitUntilDate'] as String)
          : null,
      fullName: json['fullName'] as String?,
      countryOfCitizenship: json['countryOfCitizenship'] as String?,
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'] as String)
          : null,
      rawText: json['rawText'] as String?,
      confidence: json['confidence'] as double?,
      scannedAt: DateTime.parse(json['scannedAt'] as String),
      notes: json['notes'] as String?,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.id,
      'documentNumber': documentNumber,
      'issueDate': issueDate?.toIso8601String(),
      'expirationDate': expirationDate?.toIso8601String(),
      'visaCategory': visaCategory?.code,
      'classOfAdmission': classOfAdmission,
      'admitUntilDate': admitUntilDate?.toIso8601String(),
      'fullName': fullName,
      'countryOfCitizenship': countryOfCitizenship,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'rawText': rawText,
      'confidence': confidence,
      'scannedAt': scannedAt.toIso8601String(),
      'notes': notes,
    };
  }

  /// Check if document is expired
  bool get isExpired {
    if (expirationDate == null) return false;
    return DateTime.now().isAfter(expirationDate!);
  }

  /// Check if document expires within given duration
  bool expiresWithin(Duration duration) {
    if (expirationDate == null) return false;
    return expirationDate!.isBefore(DateTime.now().add(duration));
  }

  /// Days until expiration (negative if expired)
  int? get daysUntilExpiration {
    if (expirationDate == null) return null;
    return expirationDate!.difference(DateTime.now()).inDays;
  }
}
