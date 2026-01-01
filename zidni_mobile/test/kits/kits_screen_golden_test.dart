import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zidni_mobile/kits/kits.dart';

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
  
  group('KitsScreen Golden Tests', () {
    testWidgets('kits screen shows Canton Fair and Travel kits', (tester) async {
      SharedPreferences.setMockInitialValues({
        'kits_active_kit_id': 'kit_cantonfair_v1',
      });
      KitService.clearCache();
      
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            fontFamily: 'NotoSansArabic',
          ),
          home: const KitsScreen(),
        ),
      );
      
      // Wait for async loading
      await tester.pumpAndSettle();
      
      await expectLater(
        find.byType(KitsScreen),
        matchesGoldenFile('goldens/kits_screen.png'),
      );
    });
    
    testWidgets('kits screen with travel kit active', (tester) async {
      SharedPreferences.setMockInitialValues({
        'kits_active_kit_id': 'kit_travel_basic_v1',
      });
      KitService.clearCache();
      
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            fontFamily: 'NotoSansArabic',
          ),
          home: const KitsScreen(),
        ),
      );
      
      await tester.pumpAndSettle();
      
      await expectLater(
        find.byType(KitsScreen),
        matchesGoldenFile('goldens/kits_screen_travel_active.png'),
      );
    });
  });
  
  group('Kit Card Widget Tests', () {
    testWidgets('Canton Fair kit card displays correctly', (tester) async {
      SharedPreferences.setMockInitialValues({});
      
      final kit = BundledKits.cantonFairV1;
      
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(fontFamily: 'NotoSansArabic'),
          home: Scaffold(
            backgroundColor: const Color(0xFF1A1A2E),
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: _TestKitCard(kit: kit, isActive: true),
            ),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      await expectLater(
        find.byType(_TestKitCard),
        matchesGoldenFile('goldens/kit_card_canton_fair.png'),
      );
    });
    
    testWidgets('Travel kit card displays correctly', (tester) async {
      SharedPreferences.setMockInitialValues({});
      
      final kit = BundledKits.travelBasicV1;
      
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(fontFamily: 'NotoSansArabic'),
          home: Scaffold(
            backgroundColor: const Color(0xFF1A1A2E),
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: _TestKitCard(kit: kit, isActive: false),
            ),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      await expectLater(
        find.byType(_TestKitCard),
        matchesGoldenFile('goldens/kit_card_travel.png'),
      );
    });
  });
}

/// Test widget for kit card golden tests
class _TestKitCard extends StatelessWidget {
  final OfflineKit kit;
  final bool isActive;
  
  const _TestKitCard({required this.kit, required this.isActive});
  
  @override
  Widget build(BuildContext context) {
    return Card(
      color: isActive ? kit.themeColor.withOpacity(0.2) : const Color(0xFF16213E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isActive ? kit.themeColor : Colors.transparent,
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: kit.themeColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                kit.icon,
                color: kit.themeColor,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          kit.titleAr,
                          style: const TextStyle(
                            fontFamily: 'NotoSansArabic',
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (isActive)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: kit.themeColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'نشط',
                            style: TextStyle(
                              fontFamily: 'NotoSansArabic',
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    kit.descriptionAr,
                    style: TextStyle(
                      fontFamily: 'NotoSansArabic',
                      color: Colors.grey.shade400,
                      fontSize: 13,
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: kit.phrasePacks.take(4).map((pack) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade800,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          pack.titleAr,
                          style: const TextStyle(
                            fontFamily: 'NotoSansArabic',
                            color: Colors.white70,
                            fontSize: 11,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
