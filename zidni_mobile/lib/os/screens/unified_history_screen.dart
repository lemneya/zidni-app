import 'package:flutter/material.dart';
import 'package:zidni_mobile/os/models/unified_history_item.dart';
import 'package:zidni_mobile/os/services/unified_history_service.dart';
import 'package:zidni_mobile/os/widgets/history_item_card.dart';
import 'package:zidni_mobile/os/widgets/history_detail_sheet.dart';

/// Unified History Screen
/// Gate OS-1: GUL↔Eyes Bridge + Unified History
///
/// Shows all history items with filter chips and search

class UnifiedHistoryScreen extends StatefulWidget {
  const UnifiedHistoryScreen({super.key});

  @override
  State<UnifiedHistoryScreen> createState() => _UnifiedHistoryScreenState();
}

class _UnifiedHistoryScreenState extends State<UnifiedHistoryScreen> {
  List<UnifiedHistoryItem> _items = [];
  List<UnifiedHistoryItem> _filteredItems = [];
  final Set<HistoryItemType> _selectedFilters = {};
  String _searchQuery = '';
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
    });

    final items = await UnifiedHistoryService.getAllHistory();

    setState(() {
      _items = items;
      _applyFilters();
      _isLoading = false;
    });
  }

  void _applyFilters() {
    var filtered = _items;

    // Apply type filters
    if (_selectedFilters.isNotEmpty) {
      filtered = filtered
          .where((item) => _selectedFilters.contains(item.type))
          .toList();
    }

    // Apply search query
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((item) {
        return item.title.toLowerCase().contains(query) ||
            (item.subtitle?.toLowerCase().contains(query) ?? false) ||
            (item.preview?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    _filteredItems = filtered;
  }

  void _toggleFilter(HistoryItemType type) {
    setState(() {
      if (_selectedFilters.contains(type)) {
        _selectedFilters.remove(type);
      } else {
        _selectedFilters.add(type);
      }
      _applyFilters();
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _applyFilters();
    });
  }

  void _showItemDetail(UnifiedHistoryItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        builder: (context, scrollController) => HistoryDetailSheet(
          item: item,
          scrollController: scrollController,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        elevation: 0,
        title: const Text(
          'السجل',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white70),
            onPressed: _loadHistory,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          _buildSearchBar(),
          
          // Filter chips
          _buildFilterChips(),
          
          // History list
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.blue),
                  )
                : _filteredItems.isEmpty
                    ? _buildEmptyState()
                    : _buildHistoryList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        style: const TextStyle(color: Colors.white),
        textDirection: TextDirection.rtl,
        decoration: InputDecoration(
          hintText: 'بحث في السجل...',
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
          prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.5)),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: Colors.white.withOpacity(0.5)),
                  onPressed: () {
                    _searchController.clear();
                    _onSearchChanged('');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildFilterChip(
            label: 'الكل',
            icon: Icons.all_inclusive,
            isSelected: _selectedFilters.isEmpty,
            onTap: () {
              setState(() {
                _selectedFilters.clear();
                _applyFilters();
              });
            },
          ),
          const SizedBox(width: 8),
          ...HistoryItemType.values.map((type) => Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _buildFilterChip(
              label: type.arabicName,
              icon: _getIconForType(type),
              isSelected: _selectedFilters.contains(type),
              onTap: () => _toggleFilter(type),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.blue.withOpacity(0.3)
              : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.white.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.blue : Colors.white70,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.blue : Colors.white70,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForType(HistoryItemType type) {
    switch (type) {
      case HistoryItemType.translation:
        return Icons.mic;
      case HistoryItemType.eyesScan:
        return Icons.document_scanner;
      case HistoryItemType.eyesSearch:
        return Icons.search;
      case HistoryItemType.deal:
        return Icons.handshake;
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: Colors.white.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty || _selectedFilters.isNotEmpty
                ? 'لا توجد نتائج'
                : 'السجل فارغ',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty || _selectedFilters.isNotEmpty
                ? 'جرب تغيير الفلاتر أو البحث'
                : 'ابدأ بالترجمة أو المسح لملء السجل',
            style: TextStyle(
              color: Colors.white.withOpacity(0.3),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList() {
    return RefreshIndicator(
      onRefresh: _loadHistory,
      color: Colors.blue,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredItems.length,
        itemBuilder: (context, index) {
          final item = _filteredItems[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: HistoryItemCard(
              item: item,
              onTap: () => _showItemDetail(item),
            ),
          );
        },
      ),
    );
  }
}
