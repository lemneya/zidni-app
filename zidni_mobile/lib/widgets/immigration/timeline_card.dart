import 'package:flutter/material.dart';
import '../../models/immigration/immigration_timeline.dart';

/// Card widget for displaying an immigration timeline milestone.
class TimelineCard extends StatelessWidget {
  final ImmigrationMilestone milestone;
  final VoidCallback? onTap;

  const TimelineCard({
    super.key,
    required this.milestone,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final daysUntil = milestone.daysUntil;
    final isOverdue = milestone.isOverdue;
    final isUrgent = daysUntil <= 30 && daysUntil > 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isOverdue
          ? Colors.red.shade50
          : isUrgent
              ? Colors.orange.shade50
              : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getPriorityColor(milestone.priority).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getTypeIcon(milestone.type),
                  color: _getPriorityColor(milestone.priority),
                ),
              ),
              const SizedBox(width: 16),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      milestone.getTitle(isArabic ? 'ar' : 'en'),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(milestone.targetDate),
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              // Days indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isOverdue
                      ? Colors.red
                      : isUrgent
                          ? Colors.orange
                          : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  isOverdue
                      ? (isArabic ? 'متأخر' : 'Overdue')
                      : '$daysUntil ${isArabic ? 'يوم' : 'days'}',
                  style: TextStyle(
                    color: isOverdue || isUrgent ? Colors.white : Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getPriorityColor(MilestonePriority priority) {
    switch (priority) {
      case MilestonePriority.urgent:
        return Colors.red;
      case MilestonePriority.high:
        return Colors.orange;
      case MilestonePriority.medium:
        return Colors.blue;
      case MilestonePriority.low:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon(MilestoneType type) {
    switch (type) {
      case MilestoneType.visaExpiration:
        return Icons.badge;
      case MilestoneType.i94Expiration:
        return Icons.flight_land;
      case MilestoneType.greenCardRenewal:
        return Icons.card_membership;
      case MilestoneType.citizenshipEligibility:
        return Icons.flag;
      case MilestoneType.eadExpiration:
        return Icons.work;
      case MilestoneType.statusChange:
        return Icons.swap_horiz;
      case MilestoneType.custom:
        return Icons.event;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
