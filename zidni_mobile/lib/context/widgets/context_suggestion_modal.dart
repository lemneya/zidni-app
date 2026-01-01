import 'package:flutter/material.dart';
import '../models/context_pack.dart';
import '../services/context_service.dart';

/// Context Suggestion Modal
/// Gate LOC-1: Context Packs + Mode Selector
///
/// One-time suggestion modal shown on app start based on timezone/locale.
/// Non-creepy: No GPS, only uses timezone/locale detection.

class ContextSuggestionModal extends StatelessWidget {
  /// The suggested context pack
  final ContextPack suggestedPack;
  
  /// Callback when user accepts the suggestion
  final VoidCallback? onAccept;
  
  /// Callback when user dismisses
  final VoidCallback? onDismiss;
  
  const ContextSuggestionModal({
    super.key,
    required this.suggestedPack,
    this.onAccept,
    this.onDismiss,
  });
  
  /// Show the suggestion modal if appropriate
  static Future<void> showIfNeeded(
    BuildContext context, {
    VoidCallback? onPackSelected,
  }) async {
    // Check if we should show
    final shouldShow = await ContextService.shouldShowSuggestion();
    if (!shouldShow) return;
    
    // Mark as shown
    await ContextService.markSuggestionShown();
    
    // Get suggested pack
    final suggestedPack = ContextService.getSuggestedPack();
    
    // Show modal
    if (context.mounted) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => ContextSuggestionModal(
          suggestedPack: suggestedPack,
          onAccept: () async {
            await ContextService.setSelectedPack(suggestedPack);
            await ContextService.dismissSuggestion();
            if (context.mounted) {
              Navigator.of(context).pop();
            }
            onPackSelected?.call();
          },
          onDismiss: () async {
            await ContextService.dismissSuggestion();
            if (context.mounted) {
              Navigator.of(context).pop();
            }
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: suggestedPack.themeColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  suggestedPack.icon,
                  color: suggestedPack.themeColor,
                  size: 36,
                ),
              ),
              const SizedBox(height: 20),
              
              // Title
              const Text(
                'مرحباً بك في Zidni!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              
              // Message
              Text(
                'يبدو أنك في ${suggestedPack.titleAr}',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'هل تريد تفعيل الوضع المناسب؟',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              
              // Pack preview card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: suggestedPack.themeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: suggestedPack.themeColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          suggestedPack.icon,
                          color: suggestedPack.themeColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          suggestedPack.titleAr,
                          style: TextStyle(
                            color: suggestedPack.themeColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      suggestedPack.descriptionAr,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Features row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildFeatureChip(
                          suggestedPack.defaultLangPair.arabicName,
                          Icons.translate,
                        ),
                        if (suggestedPack.loudModeDefault)
                          _buildFeatureChip(
                            'صوت عالٍ',
                            Icons.volume_up,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Accept button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: onAccept,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: suggestedPack.themeColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'نعم، فعّل هذا الوضع',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              
              // Dismiss button
              TextButton(
                onPressed: onDismiss,
                child: Text(
                  'لا، سأختار لاحقاً',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildFeatureChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: suggestedPack.themeColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: suggestedPack.themeColor,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: suggestedPack.themeColor,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
