import 'package:uuid/uuid.dart';
import '../../models/immigration/immigration_document.dart';
import '../../models/immigration/immigration_timeline.dart';

/// Service for calculating and managing immigration timeline milestones.
/// 
/// Automatically generates milestones based on scanned documents:
/// - Visa expiration reminders
/// - I-94 admit until date
/// - Green card renewal eligibility (6 months before expiration)
/// - Citizenship eligibility (5 years for regular, 3 years for spouse of USC)
class TimelineService {
  TimelineService._();
  static final TimelineService instance = TimelineService._();

  static const _uuid = Uuid();

  /// Generate milestones from a scanned document
  List<ImmigrationMilestone> generateMilestonesFromDocument(
    ImmigrationDocument document,
  ) {
    final milestones = <ImmigrationMilestone>[];

    switch (document.type) {
      case ImmigrationDocumentType.i94:
        if (document.admitUntilDate != null) {
          milestones.add(_createMilestone(
            type: MilestoneType.i94Expiration,
            targetDate: document.admitUntilDate!,
            description: 'Your authorized stay expires on this date',
            descriptionArabic: 'تنتهي إقامتك المصرح بها في هذا التاريخ',
            priority: MilestonePriority.urgent,
            relatedDocumentId: document.id,
          ));
        }
        break;

      case ImmigrationDocumentType.visa:
        if (document.expirationDate != null) {
          milestones.add(_createMilestone(
            type: MilestoneType.visaExpiration,
            targetDate: document.expirationDate!,
            description: 'Your visa expires on this date',
            descriptionArabic: 'تنتهي تأشيرتك في هذا التاريخ',
            priority: MilestonePriority.high,
            relatedDocumentId: document.id,
          ));
        }
        break;

      case ImmigrationDocumentType.greenCard:
        if (document.expirationDate != null) {
          // Green card renewal (6 months before expiration)
          final renewalDate = document.expirationDate!.subtract(
            const Duration(days: 180),
          );
          milestones.add(_createMilestone(
            type: MilestoneType.greenCardRenewal,
            targetDate: renewalDate,
            description: 'You can start renewing your green card (I-90)',
            descriptionArabic: 'يمكنك البدء في تجديد بطاقتك الخضراء (I-90)',
            priority: MilestonePriority.medium,
            relatedDocumentId: document.id,
          ));
        }

        if (document.issueDate != null) {
          // Citizenship eligibility (5 years from green card)
          final citizenshipDate = document.issueDate!.add(
            const Duration(days: 5 * 365),
          );
          // Can apply 90 days before eligibility
          final applyDate = citizenshipDate.subtract(const Duration(days: 90));
          
          milestones.add(_createMilestone(
            type: MilestoneType.citizenshipEligibility,
            targetDate: applyDate,
            description: 'You can apply for citizenship (N-400)',
            descriptionArabic: 'يمكنك التقدم للحصول على الجنسية (N-400)',
            priority: MilestonePriority.medium,
            relatedDocumentId: document.id,
          ));
        }
        break;

      case ImmigrationDocumentType.ead:
        if (document.expirationDate != null) {
          // EAD renewal (6 months before expiration)
          final renewalDate = document.expirationDate!.subtract(
            const Duration(days: 180),
          );
          milestones.add(_createMilestone(
            type: MilestoneType.eadExpiration,
            targetDate: renewalDate,
            description: 'You should start renewing your EAD (I-765)',
            descriptionArabic: 'يجب أن تبدأ في تجديد تصريح العمل (I-765)',
            priority: MilestonePriority.high,
            relatedDocumentId: document.id,
          ));
        }
        break;

      default:
        break;
    }

    return milestones;
  }

  /// Calculate citizenship eligibility date
  /// 
  /// [greenCardDate] - Date permanent residency was granted
  /// [isSpouseOfUSC] - Whether married to US citizen (3 years instead of 5)
  DateTime calculateCitizenshipEligibility({
    required DateTime greenCardDate,
    bool isSpouseOfUSC = false,
  }) {
    final years = isSpouseOfUSC ? 3 : 5;
    return greenCardDate.add(Duration(days: years * 365));
  }

  /// Calculate green card renewal eligibility (6 months before expiration)
  DateTime calculateGreenCardRenewal(DateTime expirationDate) {
    return expirationDate.subtract(const Duration(days: 180));
  }

  /// Create a milestone with standard settings
  ImmigrationMilestone _createMilestone({
    required MilestoneType type,
    required DateTime targetDate,
    required String description,
    required String descriptionArabic,
    required MilestonePriority priority,
    String? relatedDocumentId,
  }) {
    return ImmigrationMilestone(
      id: _uuid.v4(),
      type: type,
      targetDate: targetDate,
      priority: priority,
      description: description,
      descriptionArabic: descriptionArabic,
      createdAt: DateTime.now(),
      relatedDocumentId: relatedDocumentId,
      reminderDays: _getReminderDays(priority),
    );
  }

  /// Get reminder days based on priority
  List<int> _getReminderDays(MilestonePriority priority) {
    switch (priority) {
      case MilestonePriority.urgent:
        return [90, 60, 30, 14, 7, 3, 1];
      case MilestonePriority.high:
        return [90, 60, 30, 14, 7];
      case MilestonePriority.medium:
        return [90, 60, 30];
      case MilestonePriority.low:
        return [30, 7];
    }
  }
}
