/// Language Selector Widget for Call Companion Mode
/// Allows user to select the source language for translation

import 'package:flutter/material.dart';

import '../../models/call_companion/supported_language.dart';

/// Widget for selecting the source language
class LanguageSelector extends StatelessWidget {
  /// Currently selected language pair
  final LanguagePair selectedPair;

  /// Callback when language pair is changed
  final ValueChanged<LanguagePair> onChanged;

  /// Available language pairs (only show pairs with downloaded models)
  final List<LanguagePair> availablePairs;

  const LanguageSelector({
    super.key,
    required this.selectedPair,
    required this.onChanged,
    required this.availablePairs,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Current selection display
          GestureDetector(
            onTap: () => _showLanguageSheet(context),
            child: Row(
              children: [
                // Source language flag
                Text(
                  selectedPair.source.flag,
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 8),

                // Arrow
                Icon(
                  Icons.swap_horiz,
                  color: Colors.white.withOpacity(0.5),
                  size: 20,
                ),
                const SizedBox(width: 8),

                // Target language flag (Arabic)
                Text(
                  selectedPair.target.flag,
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 8),

                // Dropdown indicator
                Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.white.withOpacity(0.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguageSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _LanguageSelectionSheet(
        selectedPair: selectedPair,
        availablePairs: availablePairs,
        onSelected: (pair) {
          Navigator.pop(context);
          onChanged(pair);
        },
      ),
    );
  }
}

/// Bottom sheet for language selection
class _LanguageSelectionSheet extends StatelessWidget {
  final LanguagePair selectedPair;
  final List<LanguagePair> availablePairs;
  final ValueChanged<LanguagePair> onSelected;

  const _LanguageSelectionSheet({
    required this.selectedPair,
    required this.availablePairs,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A2E),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Title
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'اختر لغة المحادثة',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Language options
            ...LanguagePair.allPairs.map((pair) {
              final isAvailable = availablePairs.contains(pair);
              final isSelected = pair == selectedPair;

              return _LanguageOption(
                pair: pair,
                isSelected: isSelected,
                isAvailable: isAvailable,
                onTap: isAvailable ? () => onSelected(pair) : null,
              );
            }),

            // Note about downloading
            if (availablePairs.length < LanguagePair.allPairs.length)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.amber.withOpacity(0.7),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'بعض اللغات تتطلب تحميل النماذج أولاً',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

/// Single language option in the selection sheet
class _LanguageOption extends StatelessWidget {
  final LanguagePair pair;
  final bool isSelected;
  final bool isAvailable;
  final VoidCallback? onTap;

  const _LanguageOption({
    required this.pair,
    required this.isSelected,
    required this.isAvailable,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? pair.source.color.withOpacity(0.2)
              : Colors.transparent,
          border: Border(
            bottom: BorderSide(
              color: Colors.white.withOpacity(0.05),
            ),
          ),
        ),
        child: Row(
          children: [
            // Flags
            Text(
              pair.source.flag,
              style: TextStyle(
                fontSize: 28,
                color: isAvailable ? null : Colors.grey,
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              Icons.arrow_forward,
              color: isAvailable
                  ? Colors.white.withOpacity(0.5)
                  : Colors.grey.withOpacity(0.3),
              size: 16,
            ),
            const SizedBox(width: 12),
            Text(
              pair.target.flag,
              style: TextStyle(
                fontSize: 28,
                color: isAvailable ? null : Colors.grey,
              ),
            ),

            const SizedBox(width: 16),

            // Language names
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pair.source.nameAr,
                    style: TextStyle(
                      color: isAvailable
                          ? Colors.white
                          : Colors.white.withOpacity(0.3),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    pair.source.nameNative,
                    style: TextStyle(
                      color: isAvailable
                          ? Colors.white.withOpacity(0.5)
                          : Colors.white.withOpacity(0.2),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // Status indicator
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: pair.source.color,
                size: 24,
              )
            else if (!isAvailable)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'يتطلب تحميل',
                  style: TextStyle(
                    color: Colors.orange.withOpacity(0.8),
                    fontSize: 10,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Compact language indicator for the app bar
class LanguageIndicator extends StatelessWidget {
  final LanguagePair pair;
  final VoidCallback? onTap;

  const LanguageIndicator({
    super.key,
    required this.pair,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: pair.source.color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: pair.source.color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(pair.source.flag, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 4),
            Icon(
              Icons.swap_horiz,
              color: Colors.white.withOpacity(0.5),
              size: 14,
            ),
            const SizedBox(width: 4),
            Text(pair.target.flag, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
