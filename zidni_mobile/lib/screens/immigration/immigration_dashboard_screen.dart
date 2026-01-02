import 'package:flutter/material.dart';
import '../../models/immigration/immigration_timeline.dart';
import '../../services/immigration/case_store.dart';
import '../../services/immigration/timeline_service.dart';
import '../../widgets/immigration/timeline_card.dart';
import '../../widgets/immigration/quick_action_grid.dart';
import 'doc_scanner_screen.dart';
import 'timeline_screen.dart';
import 'case_tracker_screen.dart';
import 'templates_screen.dart';
import 'alwakil_screen.dart';
import 'remittance_screen.dart';

/// Main dashboard for Immigration Mode.
/// 
/// Provides quick access to all immigration features:
/// - Document Scanner (OCR)
/// - Immigration Timeline
/// - USCIS Case Tracker
/// - Legal Phrase Templates
/// - Immigration Alwakil (AI Assistant)
/// - Remittance (Money Transfer) UI
class ImmigrationDashboardScreen extends StatefulWidget {
  const ImmigrationDashboardScreen({super.key});

  @override
  State<ImmigrationDashboardScreen> createState() =>
      _ImmigrationDashboardScreenState();
}

class _ImmigrationDashboardScreenState
    extends State<ImmigrationDashboardScreen> {
  List<ImmigrationMilestone> _urgentMilestones = [];
  int _trackedCasesCount = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await CaseStore.instance.init();
    setState(() {
      _trackedCasesCount = CaseStore.instance.cases.length;
      // TODO: Load milestones from storage
    });
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final textDirection = isArabic ? TextDirection.rtl : TextDirection.ltr;

    return Directionality(
      textDirection: textDirection,
      child: Scaffold(
        appBar: AppBar(
          title: Text(isArabic ? 'وضع الهجرة' : 'Immigration Mode'),
          actions: [
            IconButton(
              icon: const Icon(Icons.help_outline),
              onPressed: () => _navigateToAlwakil(context),
              tooltip: isArabic ? 'مساعدة' : 'Help',
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: _loadData,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Welcome banner
              _buildWelcomeBanner(isArabic),
              const SizedBox(height: 24),

              // Urgent milestones (if any)
              if (_urgentMilestones.isNotEmpty) ...[
                _buildSectionHeader(
                  isArabic ? 'تنبيهات عاجلة' : 'Urgent Alerts',
                  Icons.warning_amber,
                  Colors.orange,
                ),
                const SizedBox(height: 8),
                ..._urgentMilestones.map((m) => TimelineCard(milestone: m)),
                const SizedBox(height: 24),
              ],

              // Quick actions grid
              _buildSectionHeader(
                isArabic ? 'الإجراءات السريعة' : 'Quick Actions',
                Icons.grid_view,
                Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 8),
              QuickActionGrid(
                actions: _getQuickActions(context, isArabic),
              ),
              const SizedBox(height: 24),

              // Tracked cases summary
              if (_trackedCasesCount > 0) ...[
                _buildCasesSummary(context, isArabic),
                const SizedBox(height: 24),
              ],

              // Tips section
              _buildTipsSection(isArabic),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeBanner(bool isArabic) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade700, Colors.blue.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.flag, color: Colors.white, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isArabic ? 'مرحباً بك في وضع الهجرة' : 'Welcome to Immigration Mode',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            isArabic
                ? 'أدوات مخصصة للمهاجرين العرب في الولايات المتحدة'
                : 'Tools designed for Arab immigrants in the USA',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  List<QuickAction> _getQuickActions(BuildContext context, bool isArabic) {
    return [
      QuickAction(
        icon: Icons.document_scanner,
        labelEn: 'Scan Document',
        labelAr: 'مسح مستند',
        color: Colors.blue,
        onTap: () => _navigateToDocScanner(context),
      ),
      QuickAction(
        icon: Icons.timeline,
        labelEn: 'Timeline',
        labelAr: 'الجدول الزمني',
        color: Colors.green,
        onTap: () => _navigateToTimeline(context),
      ),
      QuickAction(
        icon: Icons.track_changes,
        labelEn: 'Case Tracker',
        labelAr: 'تتبع الطلب',
        color: Colors.orange,
        onTap: () => _navigateToCaseTracker(context),
      ),
      QuickAction(
        icon: Icons.chat_bubble_outline,
        labelEn: 'Phrases',
        labelAr: 'العبارات',
        color: Colors.purple,
        onTap: () => _navigateToTemplates(context),
      ),
      QuickAction(
        icon: Icons.smart_toy,
        labelEn: 'Ask Alwakil',
        labelAr: 'اسأل الوكيل',
        color: Colors.teal,
        onTap: () => _navigateToAlwakil(context),
      ),
      QuickAction(
        icon: Icons.send,
        labelEn: 'Send Money',
        labelAr: 'إرسال أموال',
        color: Colors.indigo,
        onTap: () => _navigateToRemittance(context),
      ),
    ];
  }

  Widget _buildCasesSummary(BuildContext context, bool isArabic) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.orange.shade100,
          child: Text(
            '$_trackedCasesCount',
            style: TextStyle(
              color: Colors.orange.shade800,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          isArabic ? 'طلبات قيد التتبع' : 'Cases Being Tracked',
        ),
        subtitle: Text(
          isArabic ? 'اضغط للتحقق من الحالة' : 'Tap to check status',
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _navigateToCaseTracker(context),
      ),
    );
  }

  Widget _buildTipsSection(bool isArabic) {
    return Card(
      color: Colors.amber.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb, color: Colors.amber.shade700),
                const SizedBox(width: 8),
                Text(
                  isArabic ? 'نصيحة اليوم' : 'Tip of the Day',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.amber.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              isArabic
                  ? 'احتفظ دائمًا بنسخ من جميع وثائق الهجرة الخاصة بك في مكان آمن.'
                  : 'Always keep copies of all your immigration documents in a safe place.',
              style: TextStyle(color: Colors.amber.shade900),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToDocScanner(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const DocScannerScreen()),
    );
  }

  void _navigateToTimeline(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TimelineScreen()),
    );
  }

  void _navigateToCaseTracker(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CaseTrackerScreen()),
    );
  }

  void _navigateToTemplates(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TemplatesScreen()),
    );
  }

  void _navigateToAlwakil(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AlwakilScreen()),
    );
  }

  void _navigateToRemittance(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RemittanceScreen()),
    );
  }
}
