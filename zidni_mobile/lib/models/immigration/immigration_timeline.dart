/// Immigration timeline model for tracking milestones and deadlines.
/// 
/// Tracks key immigration dates:
/// - Visa expiration
/// - I-94 admit until date
/// - Green card renewal eligibility
/// - Citizenship eligibility (5 years / 3 years for spouse)
/// - EAD expiration

/// Types of timeline milestones
enum MilestoneType {
  visaExpiration('visa_expiration', 'Visa Expiration', 'انتهاء التأشيرة'),
  i94Expiration('i94_expiration', 'I-94 Expiration', 'انتهاء I-94'),
  greenCardRenewal('green_card_renewal', 'Green Card Renewal', 'تجديد البطاقة الخضراء'),
  citizenshipEligibility('citizenship_eligibility', 'Citizenship Eligibility', 'أهلية الجنسية'),
  eadExpiration('ead_expiration', 'EAD Expiration', 'انتهاء تصريح العمل'),
  statusChange('status_change', 'Status Change', 'تغيير الحالة'),
  custom('custom', 'Custom', 'مخصص');

  const MilestoneType(this.id, this.englishName, this.arabicName);

  final String id;
  final String englishName;
  final String arabicName;

  String getLocalizedName(String locale) {
    return locale.startsWith('ar') ? arabicName : englishName;
  }

  static MilestoneType fromId(String id) {
    return MilestoneType.values.firstWhere(
      (type) => type.id == id,
      orElse: () => MilestoneType.custom,
    );
  }
}

/// Priority levels for milestones
enum MilestonePriority {
  urgent('urgent', 'Urgent', 'عاجل'),
  high('high', 'High', 'مرتفع'),
  medium('medium', 'Medium', 'متوسط'),
  low('low', 'Low', 'منخفض');

  const MilestonePriority(this.id, this.englishName, this.arabicName);

  final String id;
  final String englishName;
  final String arabicName;

  static MilestonePriority fromId(String id) {
    return MilestonePriority.values.firstWhere(
      (p) => p.id == id,
      orElse: () => MilestonePriority.medium,
    );
  }
}

/// A single milestone in the immigration timeline
class ImmigrationMilestone {
  /// Unique identifier
  final String id;
  
  /// Milestone type
  final MilestoneType type;
  
  /// Custom title (for custom milestones)
  final String? customTitle;
  
  /// Target date
  final DateTime targetDate;
  
  /// Priority level
  final MilestonePriority priority;
  
  /// Description or notes
  final String? description;
  
  /// Arabic description
  final String? descriptionArabic;
  
  /// Whether this milestone is completed
  final bool isCompleted;
  
  /// When this milestone was created
  final DateTime createdAt;
  
  /// Related document ID (if any)
  final String? relatedDocumentId;
  
  /// Reminder days before (e.g., [90, 60, 30, 7])
  final List<int> reminderDays;

  const ImmigrationMilestone({
    required this.id,
    required this.type,
    this.customTitle,
    required this.targetDate,
    required this.priority,
    this.description,
    this.descriptionArabic,
    this.isCompleted = false,
    required this.createdAt,
    this.relatedDocumentId,
    this.reminderDays = const [90, 60, 30, 7],
  });

  /// Get title based on type or custom title
  String getTitle(String locale) {
    if (customTitle != null) return customTitle!;
    return type.getLocalizedName(locale);
  }

  /// Get description based on locale
  String? getDescription(String locale) {
    if (locale.startsWith('ar') && descriptionArabic != null) {
      return descriptionArabic;
    }
    return description;
  }

  /// Days until target date (negative if past)
  int get daysUntil => targetDate.difference(DateTime.now()).inDays;

  /// Check if milestone is overdue
  bool get isOverdue => !isCompleted && DateTime.now().isAfter(targetDate);

  /// Check if milestone is upcoming within given days
  bool isUpcoming(int days) => daysUntil > 0 && daysUntil <= days;

  /// Create from JSON
  factory ImmigrationMilestone.fromJson(Map<String, dynamic> json) {
    return ImmigrationMilestone(
      id: json['id'] as String,
      type: MilestoneType.fromId(json['type'] as String),
      customTitle: json['customTitle'] as String?,
      targetDate: DateTime.parse(json['targetDate'] as String),
      priority: MilestonePriority.fromId(json['priority'] as String),
      description: json['description'] as String?,
      descriptionArabic: json['descriptionArabic'] as String?,
      isCompleted: json['isCompleted'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      relatedDocumentId: json['relatedDocumentId'] as String?,
      reminderDays: (json['reminderDays'] as List<dynamic>?)
          ?.map((e) => e as int)
          .toList() ?? const [90, 60, 30, 7],
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.id,
      'customTitle': customTitle,
      'targetDate': targetDate.toIso8601String(),
      'priority': priority.id,
      'description': description,
      'descriptionArabic': descriptionArabic,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'relatedDocumentId': relatedDocumentId,
      'reminderDays': reminderDays,
    };
  }

  /// Create a copy with updated fields
  ImmigrationMilestone copyWith({
    String? id,
    MilestoneType? type,
    String? customTitle,
    DateTime? targetDate,
    MilestonePriority? priority,
    String? description,
    String? descriptionArabic,
    bool? isCompleted,
    DateTime? createdAt,
    String? relatedDocumentId,
    List<int>? reminderDays,
  }) {
    return ImmigrationMilestone(
      id: id ?? this.id,
      type: type ?? this.type,
      customTitle: customTitle ?? this.customTitle,
      targetDate: targetDate ?? this.targetDate,
      priority: priority ?? this.priority,
      description: description ?? this.description,
      descriptionArabic: descriptionArabic ?? this.descriptionArabic,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      relatedDocumentId: relatedDocumentId ?? this.relatedDocumentId,
      reminderDays: reminderDays ?? this.reminderDays,
    );
  }
}

/// Immigration timeline containing all milestones
class ImmigrationTimeline {
  final List<ImmigrationMilestone> milestones;

  const ImmigrationTimeline({required this.milestones});

  /// Get upcoming milestones sorted by date
  List<ImmigrationMilestone> get upcoming {
    return milestones
        .where((m) => !m.isCompleted && m.daysUntil >= 0)
        .toList()
      ..sort((a, b) => a.targetDate.compareTo(b.targetDate));
  }

  /// Get overdue milestones
  List<ImmigrationMilestone> get overdue {
    return milestones.where((m) => m.isOverdue).toList();
  }

  /// Get urgent milestones (within 30 days)
  List<ImmigrationMilestone> get urgent {
    return milestones
        .where((m) => !m.isCompleted && m.isUpcoming(30))
        .toList();
  }

  /// Get completed milestones
  List<ImmigrationMilestone> get completed {
    return milestones.where((m) => m.isCompleted).toList();
  }
}
