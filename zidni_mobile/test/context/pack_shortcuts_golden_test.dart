import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zidni_mobile/context/context.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    
    // Load Arabic font
    final arabicFontData = File('assets/fonts/NotoSansArabic-Regular.ttf').readAsBytesSync();
    final arabicFontLoader = FontLoader('NotoSansArabic')
      ..addFont(Future.value(ByteData.view(arabicFontData.buffer)));
    await arabicFontLoader.load();
    
    // Load Roboto font
    final robotoFontData = File('assets/fonts/Roboto-Regular.ttf').readAsBytesSync();
    final robotoFontLoader = FontLoader('Roboto')
      ..addFont(Future.value(ByteData.view(robotoFontData.buffer)));
    await robotoFontLoader.load();
  });
  
  group('Pack Shortcuts Row Golden Tests', () {
    testWidgets('shortcuts row - guangzhou pack', (tester) async {
      SharedPreferences.setMockInitialValues({
        'context_selected_pack_id': 'guangzhou_cantonfair',
      });
      ContextService.clearCache();
      
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            fontFamily: 'NotoSansArabic',
            scaffoldBackgroundColor: const Color(0xFF1A1A2E),
          ),
          home: Scaffold(
            backgroundColor: const Color(0xFF1A1A2E),
            body: Center(
              child: PackShortcutsRow(
                onEyesScanTap: () {},
                onCreateDealTap: () {},
                onHistoryTap: () {},
              ),
            ),
          ),
        ),
      );
      
      // Wait for async loading
      await tester.pumpAndSettle();
      
      await expectLater(
        find.byType(PackShortcutsRow),
        matchesGoldenFile('goldens/shortcuts_guangzhou.png'),
      );
    });
    
    testWidgets('shortcuts row - usa pack', (tester) async {
      SharedPreferences.setMockInitialValues({
        'context_selected_pack_id': 'usa',
      });
      ContextService.clearCache();
      
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            fontFamily: 'NotoSansArabic',
            scaffoldBackgroundColor: const Color(0xFF1A1A2E),
          ),
          home: Scaffold(
            backgroundColor: const Color(0xFF1A1A2E),
            body: Center(
              child: PackShortcutsRow(
                onEyesScanTap: () {},
                onCreateDealTap: () {},
                onHistoryTap: () {},
              ),
            ),
          ),
        ),
      );
      
      // Wait for async loading
      await tester.pumpAndSettle();
      
      await expectLater(
        find.byType(PackShortcutsRow),
        matchesGoldenFile('goldens/shortcuts_usa.png'),
      );
    });
    
    testWidgets('pack accent header - guangzhou', (tester) async {
      SharedPreferences.setMockInitialValues({
        'context_selected_pack_id': 'guangzhou_cantonfair',
      });
      ContextService.clearCache();
      
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            fontFamily: 'NotoSansArabic',
            scaffoldBackgroundColor: const Color(0xFF1A1A2E),
          ),
          home: const Scaffold(
            backgroundColor: Color(0xFF1A1A2E),
            body: Center(
              child: SizedBox(
                width: 400,
                child: PackAccentHeader(),
              ),
            ),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      await expectLater(
        find.byType(PackAccentHeader),
        matchesGoldenFile('goldens/accent_header_guangzhou.png'),
      );
    });
    
    testWidgets('pack accent header - usa (blue)', (tester) async {
      SharedPreferences.setMockInitialValues({
        'context_selected_pack_id': 'usa',
      });
      ContextService.clearCache();
      
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            fontFamily: 'NotoSansArabic',
            scaffoldBackgroundColor: const Color(0xFF1A1A2E),
          ),
          home: const Scaffold(
            backgroundColor: Color(0xFF1A1A2E),
            body: Center(
              child: SizedBox(
                width: 400,
                child: PackAccentHeader(),
              ),
            ),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      await expectLater(
        find.byType(PackAccentHeader),
        matchesGoldenFile('goldens/accent_header_usa.png'),
      );
    });
  });
}
