import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zidni_mobile/eyes/models/eyes_scan_result.dart';
import 'package:zidni_mobile/eyes/models/search_query.dart';
import 'package:zidni_mobile/eyes/services/query_builder_service.dart';
import 'package:zidni_mobile/eyes/services/search_history_service.dart';

/// Find It Results Card - Shows search actions and query builder
/// Gate EYES-2: Find Where To Buy
class FindItResultsCard extends StatefulWidget {
  final EyesScanResult scanResult;

  const FindItResultsCard({
    super.key,
    required this.scanResult,
  });

  @override
  State<FindItResultsCard> createState() => _FindItResultsCardState();
}

class _FindItResultsCardState extends State<FindItResultsCard> {
  late SearchQuery _query;
  late TextEditingController _queryController;
  final Set<String> _selectedChips = {};
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _query = QueryBuilderService.buildFromScanResult(widget.scanResult);
    _queryController = TextEditingController(text: _query.baseQuery);
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  void _updateQuery() {
    setState(() {
      _query = QueryBuilderService.updateBaseQuery(_query, _queryController.text);
      _query = QueryBuilderService.addContextChips(_query, _selectedChips.toList());
    });
  }

  void _toggleChip(String chipId) {
    setState(() {
      if (_selectedChips.contains(chipId)) {
        _selectedChips.remove(chipId);
      } else {
        _selectedChips.add(chipId);
      }
      _query = QueryBuilderService.addContextChips(_query, _selectedChips.toList());
    });
  }

  Future<void> _launchSearch(SearchPlatform platform) async {
    setState(() {
      _isSearching = true;
    });

    try {
      // Build the search URL
      final searchUrl = platform.buildSearchUrl(_query.fullQuery);
      final uri = Uri.parse(searchUrl);

      // Save search attempt to history
      final searchQuery = _query.copyWith(
        platform: platform.name,
        createdAt: DateTime.now(),
      );
      await SearchHistoryService.saveSearchAttempt(searchQuery);

      // Launch external browser
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تعذر فتح ${platform.arabicName}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF2A2A4E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Title
            const Row(
              children: [
                Icon(Icons.search, color: Colors.blue, size: 24),
                SizedBox(width: 8),
                Text(
                  'ابحث عنه',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Query editor
            _buildQueryEditor(),
            const SizedBox(height: 16),

            // Context chips
            _buildContextChips(),
            const SizedBox(height: 20),

            // Search platforms
            _buildSearchPlatforms(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildQueryEditor() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.edit, color: Colors.blue, size: 16),
              const SizedBox(width: 8),
              const Text(
                'استعلام البحث',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              if (_selectedChips.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '+${_selectedChips.length} فلاتر',
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 10,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _queryController,
            onChanged: (_) => _updateQuery(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              hintText: 'أدخل استعلام البحث...',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),
          if (_query.fullQuery != _query.baseQuery) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.auto_fix_high, color: Colors.blue, size: 14),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _query.fullQuery,
                      style: const TextStyle(
                        color: Colors.blue,
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContextChips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'فلاتر البحث',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),
        
        // Location chips
        _buildChipCategory(
          'الموقع',
          Icons.location_on,
          ContextChips.byCategory(ContextChipCategory.location),
        ),
        const SizedBox(height: 8),
        
        // Business type chips
        _buildChipCategory(
          'نوع العمل',
          Icons.business,
          ContextChips.byCategory(ContextChipCategory.businessType),
        ),
        const SizedBox(height: 8),
        
        // Terms chips
        _buildChipCategory(
          'الشروط',
          Icons.receipt_long,
          ContextChips.byCategory(ContextChipCategory.terms),
        ),
      ],
    );
  }

  Widget _buildChipCategory(String label, IconData icon, List<ContextChip> chips) {
    return Row(
      children: [
        Icon(icon, color: Colors.white38, size: 14),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white38,
            fontSize: 10,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Wrap(
            spacing: 6,
            runSpacing: 4,
            children: chips.map((chip) {
              final isSelected = _selectedChips.contains(chip.id);
              return GestureDetector(
                onTap: () => _toggleChip(chip.id),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.blue.withOpacity(0.3)
                        : Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? Colors.blue
                          : Colors.white.withOpacity(0.2),
                    ),
                  ),
                  child: Text(
                    chip.arabicLabel,
                    style: TextStyle(
                      color: isSelected ? Colors.blue : Colors.white70,
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchPlatforms() {
    final platforms = [
      SearchPlatform.alibaba,
      SearchPlatform.alibaba1688,
      SearchPlatform.madeInChina,
      SearchPlatform.google,
      SearchPlatform.baidu,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ابحث في',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 12),
        ...platforms.map((platform) => _buildPlatformButton(platform)),
      ],
    );
  }

  Widget _buildPlatformButton(SearchPlatform platform) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isSearching ? null : () => _launchSearch(platform),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                Text(
                  platform.icon,
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        platform.arabicName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        platform.name,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.open_in_new,
                  color: Colors.white.withOpacity(0.5),
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
