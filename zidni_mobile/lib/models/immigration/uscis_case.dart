/// USCIS case tracking model.
/// 
/// Stores receipt numbers and case status for tracking immigration applications.

/// USCIS case status
enum CaseStatus {
  received('received', 'Case Received', 'تم استلام الطلب'),
  processing('processing', 'Processing', 'قيد المعالجة'),
  requestForEvidence('rfe', 'Request for Evidence', 'طلب أدلة إضافية'),
  approved('approved', 'Approved', 'تمت الموافقة'),
  denied('denied', 'Denied', 'مرفوض'),
  cardProduction('card_production', 'Card Being Produced', 'البطاقة قيد الإنتاج'),
  cardMailed('card_mailed', 'Card Mailed', 'تم إرسال البطاقة'),
  unknown('unknown', 'Unknown', 'غير معروف');

  const CaseStatus(this.id, this.englishName, this.arabicName);

  final String id;
  final String englishName;
  final String arabicName;

  String getLocalizedName(String locale) {
    return locale.startsWith('ar') ? arabicName : englishName;
  }

  static CaseStatus fromId(String id) {
    return CaseStatus.values.firstWhere(
      (s) => s.id == id,
      orElse: () => CaseStatus.unknown,
    );
  }
}

/// USCIS form types
enum USCISFormType {
  i130('I-130', 'Petition for Alien Relative', 'التماس لقريب أجنبي'),
  i140('I-140', 'Immigrant Petition for Worker', 'التماس هجرة للعامل'),
  i485('I-485', 'Adjustment of Status', 'تعديل الوضع'),
  i765('I-765', 'Employment Authorization', 'تصريح العمل'),
  i131('I-131', 'Travel Document', 'وثيقة السفر'),
  n400('N-400', 'Naturalization', 'التجنس'),
  i90('I-90', 'Green Card Renewal', 'تجديد البطاقة الخضراء'),
  i751('I-751', 'Remove Conditions', 'إزالة الشروط'),
  other('Other', 'Other', 'أخرى');

  const USCISFormType(this.code, this.englishName, this.arabicName);

  final String code;
  final String englishName;
  final String arabicName;

  String getLocalizedName(String locale) {
    return locale.startsWith('ar') ? arabicName : englishName;
  }

  static USCISFormType fromCode(String code) {
    return USCISFormType.values.firstWhere(
      (f) => f.code == code,
      orElse: () => USCISFormType.other,
    );
  }
}

/// A USCIS case being tracked
class USCISCase {
  /// Unique identifier
  final String id;
  
  /// Receipt number (e.g., WAC2190012345)
  final String receiptNumber;
  
  /// Form type
  final USCISFormType formType;
  
  /// Current status
  final CaseStatus status;
  
  /// Custom label for this case
  final String? label;
  
  /// Date case was filed
  final DateTime? filedDate;
  
  /// Last status update date
  final DateTime? lastUpdated;
  
  /// Status history
  final List<CaseStatusUpdate> statusHistory;
  
  /// Notes
  final String? notes;
  
  /// When this case was added to tracking
  final DateTime addedAt;

  const USCISCase({
    required this.id,
    required this.receiptNumber,
    required this.formType,
    required this.status,
    this.label,
    this.filedDate,
    this.lastUpdated,
    this.statusHistory = const [],
    this.notes,
    required this.addedAt,
  });

  /// Validate receipt number format
  static bool isValidReceiptNumber(String number) {
    // Format: 3 letters + 10 digits (e.g., WAC2190012345)
    final regex = RegExp(r'^[A-Z]{3}\d{10}$');
    return regex.hasMatch(number.toUpperCase().replaceAll(' ', ''));
  }

  /// Get service center from receipt number
  String? get serviceCenter {
    if (receiptNumber.length < 3) return null;
    final prefix = receiptNumber.substring(0, 3).toUpperCase();
    switch (prefix) {
      case 'WAC':
        return 'California Service Center';
      case 'EAC':
        return 'Vermont Service Center';
      case 'LIN':
        return 'Nebraska Service Center';
      case 'SRC':
        return 'Texas Service Center';
      case 'NBC':
        return 'National Benefits Center';
      case 'IOE':
        return 'USCIS Electronic Immigration System';
      default:
        return null;
    }
  }

  /// Create from JSON
  factory USCISCase.fromJson(Map<String, dynamic> json) {
    return USCISCase(
      id: json['id'] as String,
      receiptNumber: json['receiptNumber'] as String,
      formType: USCISFormType.fromCode(json['formType'] as String),
      status: CaseStatus.fromId(json['status'] as String),
      label: json['label'] as String?,
      filedDate: json['filedDate'] != null
          ? DateTime.parse(json['filedDate'] as String)
          : null,
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'] as String)
          : null,
      statusHistory: (json['statusHistory'] as List<dynamic>?)
          ?.map((e) => CaseStatusUpdate.fromJson(e as Map<String, dynamic>))
          .toList() ?? const [],
      notes: json['notes'] as String?,
      addedAt: DateTime.parse(json['addedAt'] as String),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'receiptNumber': receiptNumber,
      'formType': formType.code,
      'status': status.id,
      'label': label,
      'filedDate': filedDate?.toIso8601String(),
      'lastUpdated': lastUpdated?.toIso8601String(),
      'statusHistory': statusHistory.map((s) => s.toJson()).toList(),
      'notes': notes,
      'addedAt': addedAt.toIso8601String(),
    };
  }

  /// Create a copy with updated fields
  USCISCase copyWith({
    String? id,
    String? receiptNumber,
    USCISFormType? formType,
    CaseStatus? status,
    String? label,
    DateTime? filedDate,
    DateTime? lastUpdated,
    List<CaseStatusUpdate>? statusHistory,
    String? notes,
    DateTime? addedAt,
  }) {
    return USCISCase(
      id: id ?? this.id,
      receiptNumber: receiptNumber ?? this.receiptNumber,
      formType: formType ?? this.formType,
      status: status ?? this.status,
      label: label ?? this.label,
      filedDate: filedDate ?? this.filedDate,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      statusHistory: statusHistory ?? this.statusHistory,
      notes: notes ?? this.notes,
      addedAt: addedAt ?? this.addedAt,
    );
  }
}

/// A status update in case history
class CaseStatusUpdate {
  final CaseStatus status;
  final DateTime date;
  final String? description;

  const CaseStatusUpdate({
    required this.status,
    required this.date,
    this.description,
  });

  factory CaseStatusUpdate.fromJson(Map<String, dynamic> json) {
    return CaseStatusUpdate(
      status: CaseStatus.fromId(json['status'] as String),
      date: DateTime.parse(json['date'] as String),
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status.id,
      'date': date.toIso8601String(),
      'description': description,
    };
  }
}
