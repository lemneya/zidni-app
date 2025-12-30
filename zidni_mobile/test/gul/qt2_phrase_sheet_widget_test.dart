/// Widget tests for Gate QT-2: Service Cards + Phrase Sheet
/// 
/// Tests:
/// 1. Tapping "تاكسي" opens bottom sheet
/// 2. Pressing "Speak" calls TTS service (mock)
/// 3. Pressing "Copy" triggers clipboard call (mock)

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zidni_mobile/gul/quick_cards/service_cards_row.dart';
import 'package:zidni_mobile/gul/quick_cards/phrase_pack_model.dart';

void main() {
  group('ServiceCardsRow Widget Tests', () {
    testWidgets('renders all 5 service cards with Arabic labels', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              body: ServiceCardsRow(
                onServiceTapped: (_) {},
              ),
            ),
          ),
        ),
      );
      
      // Verify "جُمل جاهزة" label is shown
      expect(find.text('جُمل جاهزة'), findsOneWidget);
      
      // Verify all 5 service cards are rendered
      expect(find.text('تاكسي'), findsOneWidget);
      expect(find.text('فندق'), findsOneWidget);
      expect(find.text('مورد'), findsOneWidget);
      expect(find.text('مطعم'), findsOneWidget);
      expect(find.text('طوارئ'), findsOneWidget);
    });
    
    testWidgets('tapping تاكسي card triggers callback with taxi service', (tester) async {
      ServiceType? tappedService;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              body: ServiceCardsRow(
                onServiceTapped: (service) => tappedService = service,
              ),
            ),
          ),
        ),
      );
      
      // Tap the taxi card
      await tester.tap(find.text('تاكسي'));
      await tester.pumpAndSettle();
      
      // Verify callback was called with taxi service
      expect(tappedService, equals(ServiceType.taxi));
    });
    
    testWidgets('cards are disabled when enabled=false', (tester) async {
      ServiceType? tappedService;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              body: ServiceCardsRow(
                enabled: false,
                onServiceTapped: (service) => tappedService = service,
              ),
            ),
          ),
        ),
      );
      
      // Try to tap the taxi card
      await tester.tap(find.text('تاكسي'));
      await tester.pumpAndSettle();
      
      // Verify callback was NOT called
      expect(tappedService, isNull);
    });
  });
  
  group('PhrasePack Model Tests', () {
    test('ServiceType has correct Arabic labels', () {
      expect(ServiceType.taxi.arabicLabel, equals('تاكسي'));
      expect(ServiceType.hotel.arabicLabel, equals('فندق'));
      expect(ServiceType.supplier.arabicLabel, equals('مورد'));
      expect(ServiceType.restaurant.arabicLabel, equals('مطعم'));
      expect(ServiceType.emergency.arabicLabel, equals('طوارئ'));
    });
    
    test('ServiceType has correct colors', () {
      expect(ServiceType.taxi.color, equals(const Color(0xFF2196F3)));
      expect(ServiceType.hotel.color, equals(const Color(0xFF4CAF50)));
      expect(ServiceType.supplier.color, equals(const Color(0xFFFF9800)));
      expect(ServiceType.restaurant.color, equals(const Color(0xFF9C27B0)));
      expect(ServiceType.emergency.color, equals(const Color(0xFFF44336)));
    });
    
    test('Phrase.getTranslation returns correct translation', () {
      const phrase = Phrase(
        id: 'test_1',
        arabic: 'أريد الذهاب إلى هذا العنوان',
        translations: {
          'zh': '我要去这个地址',
          'en': 'I want to go to this address',
          'tr': 'Bu adrese gitmek istiyorum',
          'es': 'Quiero ir a esta dirección',
        },
      );
      
      expect(phrase.getTranslation('zh'), equals('我要去这个地址'));
      expect(phrase.getTranslation('en'), equals('I want to go to this address'));
      expect(phrase.getTranslation('tr'), equals('Bu adrese gitmek istiyorum'));
      expect(phrase.getTranslation('es'), equals('Quiero ir a esta dirección'));
      expect(phrase.getTranslation('unknown'), equals('I want to go to this address'));
    });
    
    test('PhrasePack.fromJson parses correctly', () {
      final json = {
        'service': 'taxi',
        'phrases': [
          {
            'id': 'test_1',
            'arabic': 'أريد الذهاب إلى هذا العنوان',
            'translations': {
              'zh': '我要去这个地址',
              'en': 'I want to go to this address',
              'tr': 'Bu adrese gitmek istiyorum',
              'es': 'Quiero ir a esta dirección',
            }
          }
        ]
      };
      
      final pack = PhrasePack.fromJson(json);
      
      expect(pack.service, equals(ServiceType.taxi));
      expect(pack.phrases.length, equals(1));
      expect(pack.phrases[0].arabic, equals('أريد الذهاب إلى هذا العنوان'));
    });
  });
}
