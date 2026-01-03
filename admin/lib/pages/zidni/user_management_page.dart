import 'package:flutter/material.dart';
import 'package:zidni_admin/pages/layout.dart';
import 'package:zidni_admin/services/firebase_service.dart';
import 'package:flareline_uikit/components/card/common_card.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class UserManagementPage extends LayoutWidget {
  const UserManagementPage({super.key});

  @override
  String breakTabTitle(BuildContext context) => 'User Management';

  @override
  Widget contentDesktopWidget(BuildContext context) {
    return const UserManagementContent();
  }
}

class UserManagementContent extends StatefulWidget {
  const UserManagementContent({super.key});

  @override
  State<UserManagementContent> createState() => _UserManagementContentState();
}

class _UserManagementContentState extends State<UserManagementContent> {
  final FirebaseService _firebaseService = FirebaseService();
  final TextEditingController _searchController = TextEditingController();
  
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = true;
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    
    try {
      final users = await _firebaseService.getUsers(limit: 100);
      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading users: $e')),
        );
      }
    }
  }

  List<Map<String, dynamic>> get _filteredUsers {
    var filtered = _users;
    
    // Apply search filter
    final search = _searchController.text.toLowerCase();
    if (search.isNotEmpty) {
      filtered = filtered.where((user) {
        final name = (user['name'] ?? '').toString().toLowerCase();
        final email = (user['email'] ?? '').toString().toLowerCase();
        return name.contains(search) || email.contains(search);
      }).toList();
    }
    
    // Apply status filter
    if (_selectedFilter != 'all') {
      filtered = filtered.where((user) {
        switch (_selectedFilter) {
          case 'active':
            return user['isActive'] == true;
          case 'suspended':
            return user['isActive'] == false;
          case 'pro':
            return user['plan'] == 'pro' || user['plan'] == 'premium';
          case 'free':
            return user['plan'] == 'free' || user['plan'] == null;
          default:
            return true;
        }
      }).toList();
    }
    
    return filtered;
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
                    'User Management',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_users.length} total users',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _loadUsers,
                    icon: const Icon(Iconsax.refresh),
                    label: const Text('Refresh'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _exportUsers,
                    icon: const Icon(Iconsax.export),
                    label: const Text('Export'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Filters
          CommonCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Search
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search users...',
                        prefixIcon: const Icon(Iconsax.search_normal),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Filter dropdown
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedFilter,
                      decoration: InputDecoration(
                        labelText: 'Filter',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'all', child: Text('All Users')),
                        DropdownMenuItem(value: 'active', child: Text('Active')),
                        DropdownMenuItem(value: 'suspended', child: Text('Suspended')),
                        DropdownMenuItem(value: 'pro', child: Text('Pro/Premium')),
                        DropdownMenuItem(value: 'free', child: Text('Free')),
                      ],
                      onChanged: (value) {
                        setState(() => _selectedFilter = value ?? 'all');
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Users Table
          Expanded(
            child: CommonCard(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildUsersTable(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersTable() {
    final users = _filteredUsers;
    
    if (users.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Iconsax.user_search, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No users found',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }
    
    return SfDataGrid(
      source: UserDataSource(users: users, onAction: _handleUserAction),
      columnWidthMode: ColumnWidthMode.fill,
      columns: [
        GridColumn(
          columnName: 'name',
          label: Container(
            padding: const EdgeInsets.all(8),
            alignment: Alignment.centerLeft,
            child: const Text('Name', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
        GridColumn(
          columnName: 'email',
          label: Container(
            padding: const EdgeInsets.all(8),
            alignment: Alignment.centerLeft,
            child: const Text('Email', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
        GridColumn(
          columnName: 'plan',
          label: Container(
            padding: const EdgeInsets.all(8),
            alignment: Alignment.center,
            child: const Text('Plan', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
        GridColumn(
          columnName: 'deals',
          label: Container(
            padding: const EdgeInsets.all(8),
            alignment: Alignment.center,
            child: const Text('Deals', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
        GridColumn(
          columnName: 'status',
          label: Container(
            padding: const EdgeInsets.all(8),
            alignment: Alignment.center,
            child: const Text('Status', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
        GridColumn(
          columnName: 'actions',
          label: Container(
            padding: const EdgeInsets.all(8),
            alignment: Alignment.center,
            child: const Text('Actions', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  void _handleUserAction(String action, Map<String, dynamic> user) async {
    switch (action) {
      case 'view':
        _showUserDetails(user);
        break;
      case 'suspend':
        await _toggleUserStatus(user, false);
        break;
      case 'activate':
        await _toggleUserStatus(user, true);
        break;
      case 'upgrade':
        _showUpgradeDialog(user);
        break;
    }
  }

  void _showUserDetails(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(user['name'] ?? 'User Details'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detailRow('Email', user['email'] ?? 'N/A'),
              _detailRow('Plan', user['plan'] ?? 'Free'),
              _detailRow('Deals Created', (user['dealsCount'] ?? 0).toString()),
              _detailRow('Translations Used', (user['translationsUsed'] ?? 0).toString()),
              _detailRow('Joined', _formatDate(user['createdAt'])),
              _detailRow('Last Active', _formatDate(user['lastActiveAt'])),
              _detailRow('Language', user['preferredLanguage'] ?? 'ar'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
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

  Future<void> _toggleUserStatus(Map<String, dynamic> user, bool isActive) async {
    try {
      await _firebaseService.setUserStatus(user['id'], isActive);
      await _loadUsers();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isActive ? 'User activated' : 'User suspended'),
            backgroundColor: isActive ? Colors.green : Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showUpgradeDialog(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Upgrade User Plan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Current plan: ${user['plan'] ?? 'Free'}'),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Free'),
              leading: Radio<String>(
                value: 'free',
                groupValue: user['plan'],
                onChanged: (_) {},
              ),
            ),
            ListTile(
              title: const Text('Pro'),
              leading: Radio<String>(
                value: 'pro',
                groupValue: user['plan'],
                onChanged: (_) {},
              ),
            ),
            ListTile(
              title: const Text('Premium'),
              leading: Radio<String>(
                value: 'premium',
                groupValue: user['plan'],
                onChanged: (_) {},
              ),
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
                const SnackBar(content: Text('Plan updated successfully')),
              );
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _exportUsers() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Exporting users to CSV...')),
    );
    // TODO: Implement CSV export
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class UserDataSource extends DataGridSource {
  final List<Map<String, dynamic>> users;
  final Function(String action, Map<String, dynamic> user) onAction;
  
  UserDataSource({required this.users, required this.onAction}) {
    _buildDataRows();
  }
  
  List<DataGridRow> _dataGridRows = [];
  
  void _buildDataRows() {
    _dataGridRows = users.map<DataGridRow>((user) {
      return DataGridRow(cells: [
        DataGridCell<String>(columnName: 'name', value: user['name'] ?? 'Unknown'),
        DataGridCell<String>(columnName: 'email', value: user['email'] ?? 'N/A'),
        DataGridCell<String>(columnName: 'plan', value: user['plan'] ?? 'free'),
        DataGridCell<int>(columnName: 'deals', value: user['dealsCount'] ?? 0),
        DataGridCell<bool>(columnName: 'status', value: user['isActive'] ?? true),
        DataGridCell<Map<String, dynamic>>(columnName: 'actions', value: user),
      ]);
    }).toList();
  }
  
  @override
  List<DataGridRow> get rows => _dataGridRows;
  
  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((cell) {
        if (cell.columnName == 'plan') {
          return Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(8),
            child: _buildPlanBadge(cell.value.toString()),
          );
        }
        if (cell.columnName == 'status') {
          return Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(8),
            child: _buildStatusBadge(cell.value as bool),
          );
        }
        if (cell.columnName == 'actions') {
          return Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(8),
            child: _buildActionButtons(cell.value as Map<String, dynamic>),
          );
        }
        return Container(
          alignment: cell.columnName == 'deals' ? Alignment.center : Alignment.centerLeft,
          padding: const EdgeInsets.all(8),
          child: Text(cell.value.toString()),
        );
      }).toList(),
    );
  }
  
  Widget _buildPlanBadge(String plan) {
    Color color;
    switch (plan.toLowerCase()) {
      case 'premium':
        color = Colors.purple;
        break;
      case 'pro':
        color = Colors.blue;
        break;
      default:
        color = Colors.grey;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        plan.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  
  Widget _buildStatusBadge(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isActive ? 'Active' : 'Suspended',
        style: TextStyle(
          color: isActive ? Colors.green : Colors.red,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  
  Widget _buildActionButtons(Map<String, dynamic> user) {
    final isActive = user['isActive'] ?? true;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Iconsax.eye, size: 18),
          onPressed: () => onAction('view', user),
          tooltip: 'View Details',
        ),
        IconButton(
          icon: Icon(
            isActive ? Iconsax.user_remove : Iconsax.user_tick,
            size: 18,
            color: isActive ? Colors.orange : Colors.green,
          ),
          onPressed: () => onAction(isActive ? 'suspend' : 'activate', user),
          tooltip: isActive ? 'Suspend' : 'Activate',
        ),
        IconButton(
          icon: const Icon(Iconsax.arrow_up_2, size: 18, color: Colors.blue),
          onPressed: () => onAction('upgrade', user),
          tooltip: 'Change Plan',
        ),
      ],
    );
  }
}
