/// Listen Button Widget for Call Companion Mode
/// Green button for LISTEN mode (Chinese → Arabic)

import 'package:flutter/material.dart';

/// Button for LISTEN mode - captures Chinese, shows Arabic translation
class ListenButton extends StatelessWidget {
  /// Whether the button is currently active (recording)
  final bool isActive;

  /// Whether the button is disabled
  final bool isDisabled;

  /// Callback when button is pressed
  final VoidCallback? onPressed;

  const ListenButton({
    super.key,
    required this.isActive,
    required this.isDisabled,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Button
        GestureDetector(
          onTap: isDisabled ? null : onPressed,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: isActive ? 100 : 80,
            height: isActive ? 100 : 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDisabled
                  ? Colors.grey.withOpacity(0.3)
                  : isActive
                      ? Colors.green
                      : Colors.green.withOpacity(0.8),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.5),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ]
                  : null,
              border: Border.all(
                color: isActive ? Colors.white : Colors.green,
                width: isActive ? 4 : 2,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isActive ? Icons.hearing : Icons.hearing_outlined,
                    color: isDisabled
                        ? Colors.grey
                        : isActive
                            ? Colors.white
                            : Colors.white,
                    size: isActive ? 40 : 32,
                  ),
                  if (isActive)
                    const Text(
                      'يستمع...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Label
        Text(
          'استمع',
          style: TextStyle(
            color: isDisabled
                ? Colors.grey.withOpacity(0.5)
                : Colors.green,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 4),

        // Subtitle
        Text(
          'صيني ← عربي',
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
