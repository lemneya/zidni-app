/// Speak Button Widget for Call Companion Mode
/// Blue button for SPEAK mode (Arabic → Chinese)

import 'package:flutter/material.dart';

/// Button for SPEAK mode - captures Arabic, speaks Chinese translation
class SpeakButton extends StatelessWidget {
  /// Whether the button is currently active (recording)
  final bool isActive;

  /// Whether the button is disabled
  final bool isDisabled;

  /// Callback when button is pressed
  final VoidCallback? onPressed;

  const SpeakButton({
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
                      ? Colors.blue
                      : Colors.blue.withOpacity(0.8),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.5),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ]
                  : null,
              border: Border.all(
                color: isActive ? Colors.white : Colors.blue,
                width: isActive ? 4 : 2,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isActive ? Icons.mic : Icons.mic_none,
                    color: isDisabled
                        ? Colors.grey
                        : isActive
                            ? Colors.white
                            : Colors.white,
                    size: isActive ? 40 : 32,
                  ),
                  if (isActive)
                    const Text(
                      'يسجل...',
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
          'تحدث',
          style: TextStyle(
            color: isDisabled
                ? Colors.grey.withOpacity(0.5)
                : Colors.blue,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 4),

        // Subtitle
        Text(
          'عربي ← صيني',
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
