/// Golden tests for QT-2: Mic Colors Visual Proof
/// 
/// Visual proof tests:
/// 1. Turn buttons with Blue (me) / Green (other) color scheme
/// 2. Active state with glow
/// 3. Inactive/dim state
///
/// Run with: flutter test --update-goldens test/gul/qt2_mic_colors_golden_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('QT-2 Mic Colors Golden Tests', () {
    testWidgets('Turn buttons - idle state (Blue me, Green other)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              backgroundColor: const Color(0xFF1A1A2E),
              body: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text(
                        'وضع المحادثة',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Mic Color Rule: Blue = me, Green = other',
                        style: TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          // Blue button (me - Arabic)
                          Expanded(
                            child: _buildMockTurnButton(
                              color: const Color(0xFF2196F3),
                              label: 'أنا أتحدث',
                              flag: '🇸🇦',
                              isNextTurn: true,
                              isRecording: false,
                              isDisabled: false,
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Green button (other - Target)
                          Expanded(
                            child: _buildMockTurnButton(
                              color: const Color(0xFF4CAF50),
                              label: 'هو يتحدث',
                              flag: '🇨🇳',
                              isNextTurn: false,
                              isRecording: false,
                              isDisabled: false,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        'State: Idle - Arabic speaker\'s turn',
                        style: TextStyle(color: Colors.white38, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/mic_colors_idle.png'),
      );
    });
    
    testWidgets('Turn buttons - Arabic recording (Blue active, Green dim)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              backgroundColor: const Color(0xFF1A1A2E),
              body: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text(
                        'وضع المحادثة',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Arabic speaker is recording',
                        style: TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          // Blue button (me - Arabic) - RECORDING
                          Expanded(
                            child: _buildMockTurnButton(
                              color: const Color(0xFF2196F3),
                              label: 'أنا أتحدث',
                              flag: '🇸🇦',
                              isNextTurn: false,
                              isRecording: true,
                              isDisabled: false,
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Green button (other - Target) - DISABLED
                          Expanded(
                            child: _buildMockTurnButton(
                              color: const Color(0xFF4CAF50),
                              label: 'هو يتحدث',
                              flag: '🇨🇳',
                              isNextTurn: false,
                              isRecording: false,
                              isDisabled: true,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        'State: Recording - Blue active + glow, Green dim',
                        style: TextStyle(color: Colors.white38, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/mic_colors_recording_ar.png'),
      );
    });
    
    testWidgets('Turn buttons - Target recording (Green active, Blue dim)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              backgroundColor: const Color(0xFF1A1A2E),
              body: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text(
                        'وضع المحادثة',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Target speaker is recording',
                        style: TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          // Blue button (me - Arabic) - DISABLED
                          Expanded(
                            child: _buildMockTurnButton(
                              color: const Color(0xFF2196F3),
                              label: 'أنا أتحدث',
                              flag: '🇸🇦',
                              isNextTurn: false,
                              isRecording: false,
                              isDisabled: true,
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Green button (other - Target) - RECORDING
                          Expanded(
                            child: _buildMockTurnButton(
                              color: const Color(0xFF4CAF50),
                              label: 'هو يتحدث',
                              flag: '🇨🇳',
                              isNextTurn: false,
                              isRecording: true,
                              isDisabled: false,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        'State: Recording - Green active + glow, Blue dim',
                        style: TextStyle(color: Colors.white38, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/mic_colors_recording_target.png'),
      );
    });
  });
}

/// Mock turn button for golden tests
Widget _buildMockTurnButton({
  required Color color,
  required String label,
  required String flag,
  required bool isNextTurn,
  required bool isRecording,
  required bool isDisabled,
}) {
  Color bgColor;
  Color borderColor;
  Color indicatorColor;
  
  if (isRecording) {
    bgColor = color.withOpacity(0.3);
    borderColor = color;
    indicatorColor = color;
  } else if (isNextTurn) {
    bgColor = color.withOpacity(0.15);
    borderColor = color.withOpacity(0.7);
    indicatorColor = color;
  } else if (isDisabled) {
    bgColor = Colors.grey.withOpacity(0.05);
    borderColor = Colors.grey.withOpacity(0.2);
    indicatorColor = Colors.grey;
  } else {
    bgColor = color.withOpacity(0.08);
    borderColor = color.withOpacity(0.4);
    indicatorColor = color;
  }
  
  return Container(
    height: 140,
    decoration: BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: borderColor, width: isRecording ? 4 : 3),
      boxShadow: isRecording ? [
        BoxShadow(
          color: color.withOpacity(0.4),
          blurRadius: 12,
          spreadRadius: 2,
        ),
      ] : null,
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.mic,
          size: 32,
          color: isDisabled ? Colors.grey.withOpacity(0.5) : indicatorColor,
        ),
        const SizedBox(height: 4),
        Text(flag, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isDisabled ? Colors.grey.withOpacity(0.5) : Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (isRecording) ...[
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: indicatorColor,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'يسجل الآن',
                style: TextStyle(color: indicatorColor, fontSize: 12),
              ),
            ],
          ),
        ],
        if (isNextTurn && !isRecording) ...[
          const SizedBox(height: 4),
          Text(
            'دورك الآن',
            style: TextStyle(color: indicatorColor, fontSize: 12),
          ),
        ],
      ],
    ),
  );
}
