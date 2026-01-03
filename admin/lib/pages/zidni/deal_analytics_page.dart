import 'package:flutter/material.dart';
import 'package:zidni_admin/pages/layout.dart';
import 'package:zidni_admin/services/firebase_service.dart';
import 'package:flareline_uikit/components/card/common_card.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class DealAnalyticsPage extends LayoutWidget {
  const DealAnalyticsPage({super.key});

  @override
  String breakTabTitle(BuildContext context) => 'Deal Analytics';

  @override
  Widget contentDesktopWidget(BuildContext context) {
    return const DealAnalyticsContent();
  }
}

class DealAnalyticsContent extends StatefulWidget {
  const DealAnalyticsContent({super.key});

  @override
  State<DealAnalyticsContent> createState() => _DealAnalyticsContentState();
}

class _DealAnalyticsContentState extends State<DealAnalyticsContent> {
  final FirebaseService _firebaseService = FirebaseService();
  
  bool _isLoading = true;
  Map<String, int> _dealStats = {};
  List<Map<String, dynamic>> _recentDeals = [];
  int _totalDeals = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      final stats = await _firebaseService.getDealStats();
      final deals = await _firebaseService.getDeals(limit: 10);
      final totalCount = await _firebaseService.getDealCount();
      
      setState(() {
        _dealStats = stats;
        _recentDeals = deals;
        _totalDeals = totalCount;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
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
      onRefresh: _loadData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Deal Analytics',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Track deal performance and conversion metrics',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            
            // Stats Cards
            _buildStatsCards(),
            const SizedBox(height: 24),
            
            // Charts Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 2, child: _buildStatusChart()),
                const SizedBox(width: 16),
                Expanded(child: _buildConversionFunnel()),
              ],
            ),
            const SizedBox(height: 24),
            
            // Deals Over Time
            _buildDealsOverTimeChart(),
            const SizedBox(height: 24),
            
            // Recent Deals Table
            _buildRecentDealsTable(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCards() {
    final completed = _dealStats['completed'] ?? 0;
    final active = _dealStats['active'] ?? 0;
    final cancelled = _dealStats['cancelled'] ?? 0;
    final conversionRate = _totalDeals > 0 
        ? ((completed / _totalDeals) * 100).toStringAsFixed(1) 
        : '0';
    
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _buildStatCard(
          'Total Deals',
          _totalDeals.toString(),
          Iconsax.document,
          Colors.blue,
          'All time',
        ),
        _buildStatCard(
          'Active Deals',
          active.toString(),
          Iconsax.activity,
          Colors.orange,
          'In progress',
        ),
        _buildStatCard(
          'Completed',
          completed.toString(),
          Iconsax.tick_circle,
          Colors.green,
          'Successfully closed',
        ),
        _buildStatCard(
          'Cancelled',
          cancelled.toString(),
          Iconsax.close_circle,
          Colors.red,
          'Not completed',
        ),
        _buildStatCard(
          'Conversion Rate',
          '$conversionRate%',
          Iconsax.chart_1,
          Colors.purple,
          'Completed / Total',
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    String subtitle,
  ) {
    return CommonCard(
      width: 180,
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
                  child: Icon(icon, color: color, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChart() {
    final chartData = _dealStats.entries.map((e) => 
      ChartData(e.key, e.value.toDouble())
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
                  position: LegendPosition.right,
                ),
                series: <CircularSeries>[
                  PieSeries<ChartData, String>(
                    dataSource: chartData,
                    xValueMapper: (ChartData data, _) => _formatStatus(data.category),
                    yValueMapper: (ChartData data, _) => data.value,
                    dataLabelSettings: const DataLabelSettings(
                      isVisible: true,
                      labelPosition: ChartDataLabelPosition.outside,
                    ),
                    pointColorMapper: (ChartData data, _) => _getStatusColor(data.category),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConversionFunnel() {
    final draft = _dealStats['draft'] ?? 0;
    final active = _dealStats['active'] ?? 0;
    final negotiating = _dealStats['negotiating'] ?? 0;
    final completed = _dealStats['completed'] ?? 0;
    
    return CommonCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Conversion Funnel',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            _buildFunnelStep('Draft', draft, Colors.grey, 1.0),
            _buildFunnelStep('Active', active, Colors.blue, 0.85),
            _buildFunnelStep('Negotiating', negotiating, Colors.orange, 0.65),
            _buildFunnelStep('Completed', completed, Colors.green, 0.45),
          ],
        ),
      ),
    );
  }

  Widget _buildFunnelStep(String label, int count, Color color, double widthFactor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
              Text(count.toString(), style: TextStyle(color: Colors.grey[600])),
            ],
          ),
          const SizedBox(height: 4),
          FractionallySizedBox(
            widthFactor: widthFactor,
            child: Container(
              height: 24,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDealsOverTimeChart() {
    // Sample data - in production, this would come from Firebase
    final chartData = [
      TimeSeriesData(DateTime.now().subtract(const Duration(days: 30)), 5),
      TimeSeriesData(DateTime.now().subtract(const Duration(days: 25)), 8),
      TimeSeriesData(DateTime.now().subtract(const Duration(days: 20)), 12),
      TimeSeriesData(DateTime.now().subtract(const Duration(days: 15)), 10),
      TimeSeriesData(DateTime.now().subtract(const Duration(days: 10)), 15),
      TimeSeriesData(DateTime.now().subtract(const Duration(days: 5)), 18),
      TimeSeriesData(DateTime.now(), 22),
    ];
    
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
                  'Deals Over Time',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                DropdownButton<String>(
                  value: '30d',
                  items: const [
                    DropdownMenuItem(value: '7d', child: Text('Last 7 days')),
                    DropdownMenuItem(value: '30d', child: Text('Last 30 days')),
                    DropdownMenuItem(value: '90d', child: Text('Last 90 days')),
                  ],
                  onChanged: (_) {},
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: SfCartesianChart(
                primaryXAxis: const DateTimeAxis(),
                primaryYAxis: const NumericAxis(),
                series: <CartesianSeries>[
                  AreaSeries<TimeSeriesData, DateTime>(
                    dataSource: chartData,
                    xValueMapper: (TimeSeriesData data, _) => data.date,
                    yValueMapper: (TimeSeriesData data, _) => data.value,
                    color: Colors.blue.withOpacity(0.3),
                    borderColor: Colors.blue,
                    borderWidth: 2,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentDealsTable() {
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
                  'Recent Deals',
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
            if (_recentDeals.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(Iconsax.document, size: 48, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text('No deals yet', style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                ),
              )
            else
              DataTable(
                columns: const [
                  DataColumn(label: Text('Product')),
                  DataColumn(label: Text('Supplier')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Value')),
                  DataColumn(label: Text('Date')),
                ],
                rows: _recentDeals.take(5).map((deal) {
                  return DataRow(cells: [
                    DataCell(Text(deal['productName'] ?? 'N/A')),
                    DataCell(Text(deal['supplierName'] ?? 'N/A')),
                    DataCell(_buildStatusBadge(deal['status'] ?? 'draft')),
                    DataCell(Text('\$${deal['totalValue'] ?? 0}')),
                    DataCell(Text(_formatDate(deal['createdAt']))),
                  ]);
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final color = _getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _formatStatus(status),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatStatus(String status) {
    return status[0].toUpperCase() + status.substring(1);
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'draft': return Colors.grey;
      case 'active': return Colors.blue;
      case 'negotiating': return Colors.orange;
      case 'completed': return Colors.green;
      case 'cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'N/A';
    try {
      final date = timestamp.toDate();
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'N/A';
    }
  }
}

class ChartData {
  final String category;
  final double value;
  
  ChartData(this.category, this.value);
}

class TimeSeriesData {
  final DateTime date;
  final double value;
  
  TimeSeriesData(this.date, this.value);
}
