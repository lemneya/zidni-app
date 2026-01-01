import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zidni_mobile/context/context.dart';

/// Load fonts before running golden tests
Future<void> loadFonts() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  // Load NotoSansArabic from file
  final arabicFontLoader = FontLoader('NotoSansArabic');
  final arabicFontFile = File('assets/fonts/NotoSansArabic-Regular.ttf');
  if (arabicFontFile.existsSync()) {
    final arabicFontData = arabicFontFile.readAsBytesSync();
    arabicFontLoader.addFont(Future.value(ByteData.view(arabicFontData.buffer)));
    await arabicFontLoader.load();
  }
  
  // Load Roboto from file
  final robotoLoader = FontLoader('Roboto');
  final robotoFontFile = File('assets/fonts/Roboto-Regular.ttf');
  if (robotoFontFile.existsSync()) {
    final robotoFontData = robotoFontFile.readAsBytesSync();
    robotoLoader.addFont(Future.value(ByteData.view(robotoFontData.buffer)));
    await robotoLoader.load();
  }
}

/// Arabic-enabled theme for golden tests
ThemeData get arabicTheme => ThemeData(
  fontFamily: 'NotoSansArabic',
  brightness: Brightness.dark,
  scaffoldBackgroundColor: const Color(0xFF0F0F23),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(fontFamily: 'NotoSansArabic'),
    bodyMedium: TextStyle(fontFamily: 'NotoSansArabic'),
    bodySmall: TextStyle(fontFamily: 'NotoSansArabic'),
    titleLarge: TextStyle(fontFamily: 'NotoSansArabic'),
    titleMedium: TextStyle(fontFamily: 'NotoSansArabic'),
    titleSmall: TextStyle(fontFamily: 'NotoSansArabic'),
    labelLarge: TextStyle(fontFamily: 'NotoSansArabic'),
    labelMedium: TextStyle(fontFamily: 'NotoSansArabic'),
    labelSmall: TextStyle(fontFamily: 'NotoSansArabic'),
  ),
);

/// Widget wrapper that applies Arabic font to all text
Widget withArabicFont(Widget child) {
  return DefaultTextStyle(
    style: const TextStyle(fontFamily: 'NotoSansArabic'),
    child: child,
  );
}

void main() {
  setUpAll(() async {
    await loadFonts();
  });
  
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    ContextService.clearCache();
  });

  group('Mode Selector Chip Golden Tests', () {
    testWidgets('mode selector chip - guangzhou pack', (tester) async {
      await ContextService.setSelectedPack(ContextPacks.guangzhouCantonFair);
      
      await tester.pumpWidget(
        MaterialApp(
          theme: arabicTheme,
          home: Scaffold(
            backgroundColor: const Color(0xFF1A1A2E),
            body: Center(
              child: withArabicFont(const ModeSelectorChip()),
            ),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      await expectLater(
        find.byType(ModeSelectorChip),
        matchesGoldenFile('goldens/mode_chip_guangzhou.png'),
      );
    });
    
    testWidgets('mode selector chip - usa pack', (tester) async {
      await ContextService.setSelectedPack(ContextPacks.usa);
      
      await tester.pumpWidget(
        MaterialApp(
          theme: arabicTheme,
          home: Scaffold(
            backgroundColor: const Color(0xFF1A1A2E),
            body: Center(
              child: withArabicFont(const ModeSelectorChip()),
            ),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      await expectLater(
        find.byType(ModeSelectorChip),
        matchesGoldenFile('goldens/mode_chip_usa.png'),
      );
    });
    
    testWidgets('mode selector chip - travel default pack', (tester) async {
      await ContextService.setSelectedPack(ContextPacks.travelDefault);
      
      await tester.pumpWidget(
        MaterialApp(
          theme: arabicTheme,
          home: Scaffold(
            backgroundColor: const Color(0xFF1A1A2E),
            body: Center(
              child: withArabicFont(const ModeSelectorChip()),
            ),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      await expectLater(
        find.byType(ModeSelectorChip),
        matchesGoldenFile('goldens/mode_chip_travel.png'),
      );
    });
  });
  
  group('Mode Picker Sheet Golden Tests', () {
    testWidgets('mode picker sheet with all packs', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: arabicTheme,
          home: Scaffold(
            backgroundColor: const Color(0xFF1A1A2E),
            body: withArabicFont(
              ModePickerSheet(
                currentPack: ContextPacks.guangzhouCantonFair,
              ),
            ),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      await expectLater(
        find.byType(ModePickerSheet),
        matchesGoldenFile('goldens/mode_picker_sheet.png'),
      );
    });
    
    testWidgets('mode picker sheet with usa selected', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: arabicTheme,
          home: Scaffold(
            backgroundColor: const Color(0xFF1A1A2E),
            body: withArabicFont(
              ModePickerSheet(
                currentPack: ContextPacks.usa,
              ),
            ),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      await expectLater(
        find.byType(ModePickerSheet),
        matchesGoldenFile('goldens/mode_picker_usa_selected.png'),
      );
    });
  });
  
  group('Context Suggestion Modal Golden Tests', () {
    testWidgets('suggestion modal - guangzhou', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: arabicTheme,
          home: Scaffold(
            backgroundColor: const Color(0xFF1A1A2E),
            body: Center(
              child: withArabicFont(
                ContextSuggestionModal(
                  suggestedPack: ContextPacks.guangzhouCantonFair,
                ),
              ),
            ),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      await expectLater(
        find.byType(ContextSuggestionModal),
        matchesGoldenFile('goldens/suggestion_modal_guangzhou.png'),
      );
    });
    
    testWidgets('suggestion modal - travel default', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: arabicTheme,
          home: Scaffold(
            backgroundColor: const Color(0xFF1A1A2E),
            body: Center(
              child: withArabicFont(
                ContextSuggestionModal(
                  suggestedPack: ContextPacks.travelDefault,
                ),
              ),
            ),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      await expectLater(
        find.byType(ContextSuggestionModal),
        matchesGoldenFile('goldens/suggestion_modal_travel.png'),
      );
    });
  });
}
