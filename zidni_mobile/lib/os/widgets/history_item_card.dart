import 'package:flutter/material.dart';
import 'package:zidni_mobile/os/models/unified_history_item.dart';

/// History Item Card Widget
/// Gate OS-1: GUL↔Eyes Bridge + Unified History
///
/// Displays a single history item in the unified history feed

class HistoryItemCard extends StatelessWidget {
  final UnifiedHistoryItem item;
  final VoidCallback? onTap;

  const HistoryItemCard({
    super.key,
    required this.item,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header with type badge and time
            _buildHeader(),
            
            // Content
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    item.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textDirection: _getTextDirection(item.title),
                  ),
                  
                  // Subtitle
                  if (item.subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      item.subtitle!,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  
                  // Preview
                  if (item.preview != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item.preview!,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
                          height: 1.4,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        textDirection: _getTextDirection(item.preview!),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getTypeColor().withOpacity(0.1),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
      ),
      child: Row(
        children: [
          // Type badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _getTypeColor().withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getTypeIcon(),
                  size: 14,
                  color: _getTypeColor(),
                ),
                const SizedBox(width: 6),
                Text(
                  item.type.arabicName,
                  style: TextStyle(
                    color: _getTypeColor(),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          const Spacer(),
          
          // Time
          Text(
            item.timeAgo,
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 11,
            ),
          ),
          
          // Arrow
          const SizedBox(width: 8),
          Icon(
            Icons.chevron_left,
            size: 18,
            color: Colors.white.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor() {
    switch (item.type) {
      case HistoryItemType.translation:
        return Colors.blue;
      case HistoryItemType.eyesScan:
        return Colors.purple;
      case HistoryItemType.eyesSearch:
        return Colors.orange;
      case HistoryItemType.deal:
        return Colors.green;
    }
  }

  IconData _getTypeIcon() {
    switch (item.type) {
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

  TextDirection _getTextDirection(String text) {
    // Check if text starts with Arabic characters
    if (text.isEmpty) return TextDirection.ltr;
    
    final firstChar = text.codeUnitAt(0);
    // Arabic Unicode range
    if (firstChar >= 0x0600 && firstChar <= 0x06FF) {
      return TextDirection.rtl;
    }
    return TextDirection.ltr;
  }
}
