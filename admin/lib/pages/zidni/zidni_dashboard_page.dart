import 'package:flutter/material.dart';
import 'package:zidni_admin/pages/layout.dart';
import 'package:zidni_admin/services/firebase_service.dart';
import 'package:zidni_admin/services/mautic_service.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flareline_uikit/components/card/common_card.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class ZidniDashboardPage extends LayoutWidget {
  const ZidniDashboardPage({super.key});

  @override
  String breakTabTitle(BuildContext context) => 'Zidni Dashboard';

  @override
  Widget contentDesktopWidget(BuildContext context) {
    return const ZidniDashboardContent();
  }
}

class ZidniDashboardContent extends StatefulWidget {
  const ZidniDashboardContent({super.key});

  @override
  State<ZidniDashboardContent> createState() => _ZidniDashboardContentState();
}

class _ZidniDashboardContentState extends State<ZidniDashboardContent> {
  final FirebaseService _firebaseService = FirebaseService();
  final MauticService _mauticService = MauticService();
  
  bool _isLoading = true;
  
  // KPI Data
  int _totalUsers = 0;
  int _totalDeals = 0;
  int _activeDeals = 0;
  int _translationCalls = 0;
  Map<String, int> _dealStats = {};
  Map<String, dynamic> _mauticStats = {};

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    
    try {
      // Load Firebase data
      final userCount = await _firebaseService.getUserCount();
      final dealCount = await _firebaseService.getDealCount();
      final dealStats = await _firebaseService.getDealStats();
      final translationStats = await _firebaseService.getTranslationStats();
      
      // Load Mautic data
      final mauticStats = await _mauticService.getDashboardStats();
      
      setState(() {
        _totalUsers = userCount;
        _totalDeals = dealCount;
        _dealStats = dealStats;
        _activeDeals = dealStats['active'] ?? 0;
        _translationCalls = translationStats['todayCalls'] ?? 0;
        _mauticStats = mauticStats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading dashboard: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Zidni Admin Dashboard',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Welcome back! Here\'s what\'s happening with Zidni today.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            
            // KPI Cards Row
            _buildKPICards(),
            const SizedBox(height: 24),
            
            // Charts Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildDealStatusChart()),
                const SizedBox(width: 16),
                Expanded(child: _buildMarketingStats()),
              ],
            ),
            const SizedBox(height: 24),
            
            // Recent Activity
            _buildRecentActivity(),
          ],
        ),
      ),
    );
  }

  Widget _buildKPICards() {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _buildKPICard(
          title: 'Total Users',
          value: _totalUsers.toString(),
          icon: Iconsax.people,
          color: Colors.blue,
          trend: '+12%',
          trendUp: true,
        ),
        _buildKPICard(
          title: 'Total Deals',
          value: _totalDeals.toString(),
          icon: Iconsax.document,
          color: Colors.green,
          trend: '+8%',
          trendUp: true,
        ),
        _buildKPICard(
          title: 'Active Deals',
          value: _activeDeals.toString(),
          icon: Iconsax.activity,
          color: Colors.orange,
          trend: '+5%',
          trendUp: true,
        ),
        _buildKPICard(
          title: 'Translations Today',
          value: _translationCalls.toString(),
          icon: Iconsax.translate,
          color: Colors.purple,
          trend: '+23%',
          trendUp: true,
        ),
        _buildKPICard(
          title: 'Mautic Contacts',
          value: (_mauticStats['totalContacts'] ?? 0).toString(),
          icon: Iconsax.sms,
          color: Colors.teal,
          trend: '+15%',
          trendUp: true,
        ),
        _buildKPICard(
          title: 'Active Campaigns',
          value: (_mauticStats['activeCampaigns'] ?? 0).toString(),
          icon: Iconsax.chart,
          color: Colors.red,
          trend: '0%',
          trendUp: false,
        ),
      ],
    );
  }

  Widget _buildKPICard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String trend,
    required bool trendUp,
  }) {
    return CommonCard(
      width: 200,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: trendUp ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        trendUp ? Icons.trending_up : Icons.trending_flat,
                        size: 14,
                        color: trendUp ? Colors.green : Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        trend,
                        style: TextStyle(
                          fontSize: 12,
                          color: trendUp ? Colors.green : Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDealStatusChart() {
    final chartData = _dealStats.entries.map((e) => 
      ChartData(e.key.toUpperCase(), e.value.toDouble())
    ).toList();
    
    return CommonCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Deals by Status',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: SfCircularChart(
                legend: const Legend(
                  isVisible: true,
                  position: LegendPosition.bottom,
                ),
                series: <CircularSeries>[
                  DoughnutSeries<ChartData, String>(
                    dataSource: chartData,
                    xValueMapper: (ChartData data, _) => data.category,
                    yValueMapper: (ChartData data, _) => data.value,
                    dataLabelSettings: const DataLabelSettings(
                      isVisible: true,
                      labelPosition: ChartDataLabelPosition.outside,
                    ),
                    pointColorMapper: (ChartData data, _) {
                      switch (data.category.toLowerCase()) {
                        case 'draft': return Colors.grey;
                        case 'active': return Colors.blue;
                        case 'negotiating': return Colors.orange;
                        case 'completed': return Colors.green;
                        case 'cancelled': return Colors.red;
                        default: return Colors.grey;
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMarketingStats() {
    return CommonCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Marketing Overview (Mautic)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            _buildMarketingStat(
              'Total Contacts',
              (_mauticStats['totalContacts'] ?? 0).toString(),
              Iconsax.people,
              Colors.blue,
            ),
            const Divider(),
            _buildMarketingStat(
              'Email Campaigns',
              (_mauticStats['totalEmails'] ?? 0).toString(),
              Iconsax.sms,
              Colors.green,
            ),
            const Divider(),
            _buildMarketingStat(
              'Active Campaigns',
              (_mauticStats['activeCampaigns'] ?? 0).toString(),
              Iconsax.chart,
              Colors.orange,
            ),
            const Divider(),
            _buildMarketingStat(
              'Segments',
              (_mauticStats['totalSegments'] ?? 0).toString(),
              Iconsax.category,
              Colors.purple,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Open Mautic dashboard
                },
                icon: const Icon(Iconsax.export),
                label: const Text('Open Mautic Dashboard'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMarketingStat(String label, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    return CommonCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Activity',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildActivityItem(
              'New user registered',
              'Ahmed from Saudi Arabia joined Zidni',
              '5 minutes ago',
              Iconsax.user_add,
              Colors.green,
            ),
            _buildActivityItem(
              'Deal completed',
              'Deal #1234 marked as completed',
              '15 minutes ago',
              Iconsax.tick_circle,
              Colors.blue,
            ),
            _buildActivityItem(
              'Translation spike',
              '150 translations in the last hour',
              '1 hour ago',
              Iconsax.translate,
              Colors.orange,
            ),
            _buildActivityItem(
              'Campaign sent',
              'Welcome email sent to 50 new users',
              '2 hours ago',
              Iconsax.sms,
              Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(
    String title,
    String description,
    String time,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}

class ChartData {
  final String category;
  final double value;
  
  ChartData(this.category, this.value);
}
