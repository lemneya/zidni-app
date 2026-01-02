import 'package:flutter/material.dart';
import '../../services/tutorial/tutorial_registry.dart';

/// Tutorial card widget for displaying a tutorial item in the help screen.
class TutorialCard extends StatelessWidget {
  final TutorialData tutorial;
  final VoidCallback onTap;
  final bool showYoutubeLink;

  const TutorialCard({
    super.key,
    required this.tutorial,
    required this.onTap,
    this.showYoutubeLink = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon container
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: _getIconColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  _getIcon(),
                  color: _getIconColor(),
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),

              // Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tutorial.nameArabic,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${tutorial.steps.length} خطوات',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

              // Action buttons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // YouTube link (if available)
                  if (showYoutubeLink && tutorial.youtubeUrl != null)
                    IconButton(
                      icon: Icon(
                        Icons.play_circle_outline,
                        color: Colors.red[400],
                        size: 24,
                      ),
                      onPressed: () {
                        // Future: open YouTube link
                      },
                      tooltip: 'شاهد على يوتيوب',
                    ),
                  // Play in-app
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey[400],
                    size: 16,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIcon() {
    switch (tutorial.topic) {
      case TutorialTopic.gul:
        return Icons.mic;
      case TutorialTopic.eyes:
        return Icons.camera_alt;
      case TutorialTopic.alwakil:
        return Icons.support_agent;
      case TutorialTopic.memory:
        return Icons.history;
      case TutorialTopic.dealMaker:
        return Icons.handshake;
      case TutorialTopic.wallet:
        return Icons.account_balance_wallet;
      case TutorialTopic.contextPacks:
        return Icons.inventory_2;
    }
  }

  Color _getIconColor() {
    switch (tutorial.topic) {
      case TutorialTopic.gul:
        return const Color(0xFF2196F3); // Blue
      case TutorialTopic.eyes:
        return const Color(0xFF4CAF50); // Green
      case TutorialTopic.alwakil:
        return const Color(0xFF9C27B0); // Purple
      case TutorialTopic.memory:
        return const Color(0xFFFF9800); // Orange
      case TutorialTopic.dealMaker:
        return const Color(0xFFE91E63); // Pink
      case TutorialTopic.wallet:
        return const Color(0xFF1565C0); // Dark Blue
      case TutorialTopic.contextPacks:
        return const Color(0xFF00BCD4); // Cyan
    }
  }
}
