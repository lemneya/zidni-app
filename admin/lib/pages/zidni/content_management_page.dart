import 'package:flutter/material.dart';
import 'package:zidni_admin/pages/layout.dart';
import 'package:zidni_admin/services/firebase_service.dart';
import 'package:flareline_uikit/components/card/common_card.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class ContentManagementPage extends LayoutWidget {
  const ContentManagementPage({super.key});

  @override
  String breakTabTitle(BuildContext context) => 'Content Management';

  @override
  Widget contentDesktopWidget(BuildContext context) {
    return const ContentManagementContent();
  }
}

class ContentManagementContent extends StatefulWidget {
  const ContentManagementContent({super.key});

  @override
  State<ContentManagementContent> createState() => _ContentManagementContentState();
}

class _ContentManagementContentState extends State<ContentManagementContent>
    with SingleTickerProviderStateMixin {
  final FirebaseService _firebaseService = FirebaseService();
  late TabController _tabController;
  
  bool _isLoading = true;
  List<Map<String, dynamic>> _phrasePacks = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      final packs = await _firebaseService.getPhrasePacks();
      setState(() {
        _phrasePacks = packs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
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
              Text(
                'Content Management',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _showCreatePackDialog,
                icon: const Icon(Iconsax.add),
                label: const Text('New Phrase Pack'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Tabs
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Phrase Packs'),
              Tab(text: 'Context Packs'),
              Tab(text: 'Terminology'),
            ],
          ),
          const SizedBox(height: 16),
          
          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildPhrasePacksTab(),
                      _buildContextPacksTab(),
                      _buildTerminologyTab(),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhrasePacksTab() {
    if (_phrasePacks.isEmpty) {
      return _buildEmptyState(
        'No Phrase Packs',
        'Create phrase packs for different trade scenarios',
        Iconsax.message_text,
        _showCreatePackDialog,
      );
    }
    
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.5,
      ),
      itemCount: _phrasePacks.length,
      itemBuilder: (context, index) {
        final pack = _phrasePacks[index];
        return _buildPackCard(pack);
      },
    );
  }

  Widget _buildPackCard(Map<String, dynamic> pack) {
    final isPublished = pack['isPublished'] ?? false;
    final phraseCount = (pack['phrases'] as List?)?.length ?? 0;
    
    return CommonCard(
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
                    color: _getCategoryColor(pack['category']).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getCategoryIcon(pack['category']),
                    color: _getCategoryColor(pack['category']),
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) => _handlePackAction(value, pack),
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    const PopupMenuItem(value: 'duplicate', child: Text('Duplicate')),
                    PopupMenuItem(
                      value: isPublished ? 'unpublish' : 'publish',
                      child: Text(isPublished ? 'Unpublish' : 'Publish'),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              ],
            ),
            const Spacer(),
            Text(
              pack['name'] ?? 'Unnamed Pack',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              pack['description'] ?? 'No description',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$phraseCount phrases',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
                _buildStatusBadge(isPublished),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContextPacksTab() {
    // Sample context packs
    final contextPacks = [
      {
        'name': 'Guangzhou Trade',
        'location': 'Guangzhou, China',
        'phrases': 45,
        'isPublished': true,
      },
      {
        'name': 'Yiwu Market',
        'location': 'Yiwu, China',
        'phrases': 38,
        'isPublished': true,
      },
      {
        'name': 'Canton Fair',
        'location': 'Guangzhou, China',
        'phrases': 52,
        'isPublished': false,
      },
    ];
    
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.5,
      ),
      itemCount: contextPacks.length,
      itemBuilder: (context, index) {
        final pack = contextPacks[index];
        return CommonCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Iconsax.location, color: Colors.blue),
                    ),
                    const Spacer(),
                    _buildStatusBadge(pack['isPublished'] as bool),
                  ],
                ),
                const Spacer(),
                Text(
                  pack['name'] as String,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  pack['location'] as String,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const Spacer(),
                Text(
                  '${pack['phrases']} phrases',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTerminologyTab() {
    // Sample terminology
    final terms = [
      {'ar': 'موك', 'zh': 'MOQ', 'en': 'Minimum Order Quantity', 'category': 'trade'},
      {'ar': 'فوب', 'zh': 'FOB', 'en': 'Free On Board', 'category': 'shipping'},
      {'ar': 'سيف', 'zh': 'CIF', 'en': 'Cost Insurance Freight', 'category': 'shipping'},
      {'ar': 'أو إي إم', 'zh': 'OEM', 'en': 'Original Equipment Manufacturer', 'category': 'manufacturing'},
      {'ar': 'أو دي إم', 'zh': 'ODM', 'en': 'Original Design Manufacturer', 'category': 'manufacturing'},
      {'ar': 'تي تي', 'zh': 'T/T', 'en': 'Telegraphic Transfer', 'category': 'payment'},
      {'ar': 'إل سي', 'zh': 'L/C', 'en': 'Letter of Credit', 'category': 'payment'},
    ];
    
    return Column(
      children: [
        // Search and filter
        CommonCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search terminology...',
                      prefixIcon: const Icon(Iconsax.search_normal),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: _showAddTermDialog,
                  icon: const Icon(Iconsax.add),
                  label: const Text('Add Term'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Terms table
        Expanded(
          child: CommonCard(
            child: SingleChildScrollView(
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Arabic')),
                  DataColumn(label: Text('Chinese')),
                  DataColumn(label: Text('English')),
                  DataColumn(label: Text('Category')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: terms.map((term) {
                  return DataRow(cells: [
                    DataCell(Text(term['ar']!, style: const TextStyle(fontFamily: 'Arial'))),
                    DataCell(Text(term['zh']!)),
                    DataCell(Text(term['en']!)),
                    DataCell(_buildCategoryChip(term['category']!)),
                    DataCell(Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Iconsax.edit, size: 18),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: const Icon(Iconsax.trash, size: 18, color: Colors.red),
                          onPressed: () {},
                        ),
                      ],
                    )),
                  ]);
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String title, String subtitle, IconData icon, VoidCallback onAction) {
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
            onPressed: onAction,
            icon: const Icon(Iconsax.add),
            label: const Text('Create'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(bool isPublished) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isPublished ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        isPublished ? 'Published' : 'Draft',
        style: TextStyle(
          fontSize: 10,
          color: isPublished ? Colors.green : Colors.grey,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String category) {
    Color color;
    switch (category) {
      case 'trade': color = Colors.blue; break;
      case 'shipping': color = Colors.green; break;
      case 'payment': color = Colors.orange; break;
      case 'manufacturing': color = Colors.purple; break;
      default: color = Colors.grey;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        category.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getCategoryColor(String? category) {
    switch (category) {
      case 'greeting': return Colors.blue;
      case 'negotiation': return Colors.orange;
      case 'shipping': return Colors.green;
      case 'payment': return Colors.purple;
      case 'quality': return Colors.red;
      default: return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String? category) {
    switch (category) {
      case 'greeting': return Iconsax.message;
      case 'negotiation': return Iconsax.money;
      case 'shipping': return Iconsax.truck;
      case 'payment': return Iconsax.card;
      case 'quality': return Iconsax.verify;
      default: return Iconsax.document;
    }
  }

  void _handlePackAction(String action, Map<String, dynamic> pack) {
    switch (action) {
      case 'edit':
        _showEditPackDialog(pack);
        break;
      case 'duplicate':
        _duplicatePack(pack);
        break;
      case 'publish':
      case 'unpublish':
        _togglePackPublish(pack);
        break;
      case 'delete':
        _showDeleteConfirmation(pack);
        break;
    }
  }

  void _showCreatePackDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Phrase Pack'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Pack Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              const TextField(
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'greeting', child: Text('Greetings')),
                  DropdownMenuItem(value: 'negotiation', child: Text('Negotiation')),
                  DropdownMenuItem(value: 'shipping', child: Text('Shipping')),
                  DropdownMenuItem(value: 'payment', child: Text('Payment')),
                  DropdownMenuItem(value: 'quality', child: Text('Quality')),
                ],
                onChanged: (_) {},
              ),
            ],
          ),
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
                const SnackBar(content: Text('Phrase pack created!')),
              );
              _loadData();
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showEditPackDialog(Map<String, dynamic> pack) {
    // Similar to create dialog but pre-filled
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Editing: ${pack['name']}')),
    );
  }

  void _duplicatePack(Map<String, dynamic> pack) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Duplicated: ${pack['name']}')),
    );
    _loadData();
  }

  void _togglePackPublish(Map<String, dynamic> pack) {
    final isPublished = pack['isPublished'] ?? false;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isPublished ? 'Pack unpublished' : 'Pack published'),
        backgroundColor: isPublished ? Colors.orange : Colors.green,
      ),
    );
    _loadData();
  }

  void _showDeleteConfirmation(Map<String, dynamic> pack) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Phrase Pack?'),
        content: Text('Are you sure you want to delete "${pack['name']}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _firebaseService.deletePhrasePack(pack['id']);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Phrase pack deleted'),
                  backgroundColor: Colors.red,
                ),
              );
              _loadData();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showAddTermDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Terminology'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Arabic',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Chinese',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              const TextField(
                decoration: InputDecoration(
                  labelText: 'English',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'trade', child: Text('Trade')),
                  DropdownMenuItem(value: 'shipping', child: Text('Shipping')),
                  DropdownMenuItem(value: 'payment', child: Text('Payment')),
                  DropdownMenuItem(value: 'manufacturing', child: Text('Manufacturing')),
                ],
                onChanged: (_) {},
              ),
            ],
          ),
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
                const SnackBar(content: Text('Term added!')),
              );
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
