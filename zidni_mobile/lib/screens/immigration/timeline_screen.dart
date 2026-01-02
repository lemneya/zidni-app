import 'package:flutter/material.dart';
import '../../models/immigration/immigration_timeline.dart';

/// Screen for viewing and managing immigration timeline milestones.
class TimelineScreen extends StatelessWidget {
  const TimelineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final textDirection = isArabic ? TextDirection.rtl : TextDirection.ltr;

    return Directionality(
      textDirection: textDirection,
      child: Scaffold(
        appBar: AppBar(
          title: Text(isArabic ? 'الجدول الزمني' : 'Immigration Timeline'),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _addMilestone(context),
              tooltip: isArabic ? 'إضافة حدث' : 'Add Milestone',
            ),
          ],
        ),
        body: _buildEmptyState(context, isArabic),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isArabic) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.timeline,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 24),
            Text(
              isArabic ? 'لا توجد أحداث بعد' : 'No Milestones Yet',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              isArabic
                  ? 'امسح مستنداتك لإنشاء جدول زمني تلقائي'
                  : 'Scan your documents to auto-generate a timeline',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade500),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.document_scanner),
              label: Text(isArabic ? 'مسح مستند' : 'Scan Document'),
            ),
          ],
        ),
      ),
    );
  }

  void _addMilestone(BuildContext context) {
    // TODO: Implement add milestone dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          Localizations.localeOf(context).languageCode == 'ar'
              ? 'قريباً'
              : 'Coming Soon',
        ),
      ),
    );
  }
}
