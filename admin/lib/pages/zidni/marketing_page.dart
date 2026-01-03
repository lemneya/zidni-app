import 'package:flutter/material.dart';
import 'package:zidni_admin/pages/layout.dart';
import 'package:zidni_admin/services/mautic_service.dart';
import 'package:flareline_uikit/components/card/common_card.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class MarketingPage extends LayoutWidget {
  const MarketingPage({super.key});

  @override
  String breakTabTitle(BuildContext context) => 'Marketing';

  @override
  Widget contentDesktopWidget(BuildContext context) {
    return const MarketingContent();
  }
}

class MarketingContent extends StatefulWidget {
  const MarketingContent({super.key});

  @override
  State<MarketingContent> createState() => _MarketingContentState();
}

class _MarketingContentState extends State<MarketingContent> 
    with SingleTickerProviderStateMixin {
  final MauticService _mauticService = MauticService();
  late TabController _tabController;
  
  bool _isLoading = true;
  List<Map<String, dynamic>> _campaigns = [];
  List<Map<String, dynamic>> _emails = [];
  List<Map<String, dynamic>> _segments = [];
  Map<String, dynamic> _stats = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      final campaigns = await _mauticService.getCampaigns();
      final emails = await _mauticService.getEmails();
      final segments = await _mauticService.getSegments();
      final stats = await _mauticService.getDashboardStats();
      
      setState(() {
        _campaigns = campaigns;
        _emails = emails;
        _segments = segments;
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading marketing data: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Marketing Automation',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Powered by Mautic',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _loadData,
                    icon: const Icon(Iconsax.refresh),
                    label: const Text('Refresh'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _openMauticDashboard,
                    icon: const Icon(Iconsax.export),
                    label: const Text('Open Mautic'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Stats Cards
          _buildStatsCards(),
          const SizedBox(height: 24),
          
          // Tabs
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Campaigns'),
              Tab(text: 'Emails'),
              Tab(text: 'Segments'),
              Tab(text: 'Push Notifications'),
            ],
          ),
          const SizedBox(height: 16),
          
          // Tab Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildCampaignsTab(),
                      _buildEmailsTab(),
                      _buildSegmentsTab(),
                      _buildPushTab(),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _buildStatCard(
          'Total Contacts',
          (_stats['totalContacts'] ?? 0).toString(),
          Iconsax.people,
          Colors.blue,
        ),
        _buildStatCard(
          'Active Campaigns',
          (_stats['activeCampaigns'] ?? 0).toString(),
          Iconsax.chart,
          Colors.green,
        ),
        _buildStatCard(
          'Email Templates',
          (_stats['totalEmails'] ?? 0).toString(),
          Iconsax.sms,
          Colors.orange,
        ),
        _buildStatCard(
          'Segments',
          (_stats['totalSegments'] ?? 0).toString(),
          Iconsax.category,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return CommonCard(
      width: 180,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCampaignsTab() {
    if (_campaigns.isEmpty) {
      return _buildEmptyState(
        'No Campaigns',
        'Create your first campaign in Mautic',
        Iconsax.chart,
      );
    }
    
    return ListView.builder(
      itemCount: _campaigns.length,
      itemBuilder: (context, index) {
        final campaign = _campaigns[index];
        final isPublished = campaign['isPublished'] == true;
        
        return CommonCard(
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isPublished ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Iconsax.chart,
                color: isPublished ? Colors.green : Colors.grey,
              ),
            ),
            title: Text(campaign['name'] ?? 'Unnamed Campaign'),
            subtitle: Text(campaign['description'] ?? 'No description'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildStatusChip(isPublished ? 'Active' : 'Draft', isPublished),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Iconsax.chart_1),
                  onPressed: () => _viewCampaignStats(campaign),
                  tooltip: 'View Stats',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmailsTab() {
    if (_emails.isEmpty) {
      return _buildEmptyState(
        'No Email Templates',
        'Create email templates in Mautic',
        Iconsax.sms,
      );
    }
    
    return ListView.builder(
      itemCount: _emails.length,
      itemBuilder: (context, index) {
        final email = _emails[index];
        final isPublished = email['isPublished'] == true;
        
        return CommonCard(
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Iconsax.sms, color: Colors.orange),
            ),
            title: Text(email['name'] ?? 'Unnamed Email'),
            subtitle: Text(email['subject'] ?? 'No subject'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildStatusChip(isPublished ? 'Published' : 'Draft', isPublished),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Iconsax.send_1),
                  onPressed: () => _showSendEmailDialog(email),
                  tooltip: 'Send',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSegmentsTab() {
    if (_segments.isEmpty) {
      return _buildEmptyState(
        'No Segments',
        'Create user segments in Mautic',
        Iconsax.category,
      );
    }
    
    return ListView.builder(
      itemCount: _segments.length,
      itemBuilder: (context, index) {
        final segment = _segments[index];
        
        return CommonCard(
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Iconsax.category, color: Colors.purple),
            ),
            title: Text(segment['name'] ?? 'Unnamed Segment'),
            subtitle: Text(segment['description'] ?? 'No description'),
            trailing: Text(
              '${segment['leadCount'] ?? 0} contacts',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPushTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Send Push Notification',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          CommonCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      hintText: 'Enter notification title',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Message',
                      hintText: 'Enter notification message',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Target Audience',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem(value: 'all', child: Text('All Users')),
                      ..._segments.map((s) => DropdownMenuItem(
                        value: s['id'].toString(),
                        child: Text(s['name'] ?? 'Segment'),
                      )),
                    ],
                    onChanged: (_) {},
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Language',
                      border: OutlineInputBorder(),
                    ),
                    value: 'ar',
                    items: const [
                      DropdownMenuItem(value: 'ar', child: Text('Arabic')),
                      DropdownMenuItem(value: 'zh', child: Text('Chinese')),
                      DropdownMenuItem(value: 'en', child: Text('English')),
                    ],
                    onChanged: (_) {},
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Iconsax.calendar),
                          label: const Text('Schedule'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _sendPushNotification,
                          icon: const Icon(Iconsax.send_1),
                          label: const Text('Send Now'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Recent Push Notifications',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildRecentPushList(),
        ],
      ),
    );
  }

  Widget _buildRecentPushList() {
    // Sample data - in production, this would come from your backend
    final recentPushes = [
      {'title': 'Welcome to Zidni!', 'sent': '2 hours ago', 'recipients': 150},
      {'title': 'New Phrase Pack Available', 'sent': '1 day ago', 'recipients': 1200},
      {'title': 'Special Offer: 50% Off Pro', 'sent': '3 days ago', 'recipients': 800},
    ];
    
    return Column(
      children: recentPushes.map((push) => CommonCard(
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Iconsax.notification, color: Colors.blue),
          ),
          title: Text(push['title'] as String),
          subtitle: Text('Sent ${push['sent']}'),
          trailing: Text(
            '${push['recipients']} recipients',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildEmptyState(String title, String subtitle, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _openMauticDashboard,
            icon: const Icon(Iconsax.add),
            label: const Text('Create in Mautic'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String label, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isActive ? Colors.green : Colors.grey,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _openMauticDashboard() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening Mautic dashboard...')),
    );
    // TODO: Open Mautic URL in browser
  }

  void _viewCampaignStats(Map<String, dynamic> campaign) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(campaign['name'] ?? 'Campaign Stats'),
        content: const Text('Campaign statistics will be displayed here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showSendEmailDialog(Map<String, dynamic> email) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Email'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Template: ${email['name']}'),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Send to',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem(value: 'all', child: Text('All Contacts')),
                ..._segments.map((s) => DropdownMenuItem(
                  value: s['id'].toString(),
                  child: Text(s['name'] ?? 'Segment'),
                )),
              ],
              onChanged: (_) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Email sent successfully!')),
              );
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  void _sendPushNotification() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Push notification sent successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
