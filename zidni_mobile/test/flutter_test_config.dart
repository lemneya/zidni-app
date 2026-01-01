import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Global test configuration for Zidni Mobile
/// GATE TEST-1: Test Foundation + Regression Net
/// 
/// This file is automatically loaded before all tests run.
/// It ensures:
/// - Fonts are loaded for golden tests to render correctly
/// - Test environment is consistent across all tests
/// - Golden test stability is maintained

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  // Load custom fonts for golden tests
  await _loadCustomFonts();
  
  // Set up consistent test environment
  _configureTestEnvironment();
  
  return testMain();
}

/// Load custom fonts from assets for golden test rendering.
/// Fonts loaded:
/// - NotoSansArabic: For Arabic text
/// - Roboto: For Latin text
Future<void> _loadCustomFonts() async {
  try {
    // Load Arabic font
    final fontLoader = FontLoader('NotoSansArabic');
    final arabicFontData = File('assets/fonts/NotoSansArabic-Regular.ttf').readAsBytesSync();
    fontLoader.addFont(Future.value(ByteData.view(arabicFontData.buffer)));
    await fontLoader.load();
    
    // Load Latin font
    final robotoLoader = FontLoader('Roboto');
    final robotoFontData = File('assets/fonts/Roboto-Regular.ttf').readAsBytesSync();
    robotoLoader.addFont(Future.value(ByteData.view(robotoFontData.buffer)));
    await robotoLoader.load();
  } catch (e) {
    // Font loading may fail in CI without font files
    // Tests should still run, but goldens may not render correctly
    // ignore: avoid_print
    print('Warning: Failed to load custom fonts: $e');
  }
}

/// Configure consistent test environment settings.
void _configureTestEnvironment() {
  // Disable animations for faster and more stable tests
  // This is handled by WidgetTester.pumpAndSettle()
  
  // Set consistent locale for tests
  // This ensures date/time formatting is consistent
}

/// Helper to pump widget and wait for all animations to complete.
/// Use this instead of pumpAndSettle() for more control.
extension WidgetTesterExtensions on WidgetTester {
  /// Pumps the widget tree and waits for all pending frames.
  /// More reliable than pumpAndSettle() for complex widgets.
  Future<void> pumpUntilStable({
    Duration timeout = const Duration(seconds: 10),
  }) async {
    final endTime = DateTime.now().add(timeout);
    do {
      await pump(const Duration(milliseconds: 100));
    } while (binding.hasScheduledFrame && DateTime.now().isBefore(endTime));
  }
}

/// Golden test configuration constants.
class GoldenConfig {
  /// Standard tolerance for golden comparisons.
  /// Allows for minor rendering differences across platforms.
  static const double tolerance = 0.05;
  
  /// Standard screen size for golden tests (iPhone 14 Pro).
  static const double screenWidth = 390;
  static const double screenHeight = 844;
  
  /// Golden file naming convention.
  /// Format: {feature}_{variant}.png
  /// Example: eyes_product_card_chinese.png
  static String goldenPath(String feature, String variant) {
    return 'goldens/${feature}_$variant.png';
  }
}
