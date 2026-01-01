import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Global test configuration for Zidni Mobile
/// 
/// This file is automatically loaded before all tests run.
/// It ensures fonts are loaded for golden tests to render correctly.

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  // Load custom fonts for golden tests
  await _loadCustomFonts();
  
  return testMain();
}

/// Load custom fonts from assets
Future<void> _loadCustomFonts() async {
  final fontLoader = FontLoader('NotoSansArabic');
  final arabicFontData = File('assets/fonts/NotoSansArabic-Regular.ttf').readAsBytesSync();
  fontLoader.addFont(Future.value(ByteData.view(arabicFontData.buffer)));
  await fontLoader.load();
  
  final robotoLoader = FontLoader('Roboto');
  final robotoFontData = File('assets/fonts/Roboto-Regular.ttf').readAsBytesSync();
  robotoLoader.addFont(Future.value(ByteData.view(robotoFontData.buffer)));
  await robotoLoader.load();
}
