/// Phrase Pack Model for Service Cards
/// Gate QT-2: Service Cards + Phrase Sheet (Arabic-first)

import 'package:flutter/material.dart';

/// Service type enum with Arabic labels and colors
enum ServiceType {
  taxi,
  hotel,
  supplier,
  restaurant,
  emergency,
}

/// Extension for ServiceType properties
extension ServiceTypeExtension on ServiceType {
  String get arabicLabel {
    switch (this) {
      case ServiceType.taxi:
        return 'تاكسي';
      case ServiceType.hotel:
        return 'فندق';
      case ServiceType.supplier:
        return 'مورد';
      case ServiceType.restaurant:
        return 'مطعم';
      case ServiceType.emergency:
        return 'طوارئ';
    }
  }

  String get icon {
    switch (this) {
      case ServiceType.taxi:
        return '🚕';
      case ServiceType.hotel:
        return '🏨';
      case ServiceType.supplier:
        return '📦';
      case ServiceType.restaurant:
        return '🍽️';
      case ServiceType.emergency:
        return '🆘';
    }
  }

  Color get color {
    switch (this) {
      case ServiceType.taxi:
        return const Color(0xFF2196F3); // Blue
      case ServiceType.hotel:
        return const Color(0xFF4CAF50); // Green
      case ServiceType.supplier:
        return const Color(0xFFFF9800); // Orange
      case ServiceType.restaurant:
        return const Color(0xFF9C27B0); // Purple
      case ServiceType.emergency:
        return const Color(0xFFF44336); // Red
    }
  }
}

/// A single phrase with Arabic and target language translations
class Phrase {
  final String id;
  final String arabic;
  final Map<String, String> translations; // 'zh', 'en', 'tr', 'es'

  const Phrase({
    required this.id,
    required this.arabic,
    required this.translations,
  });

  String getTranslation(String langCode) {
    return translations[langCode] ?? translations['en'] ?? arabic;
  }

  factory Phrase.fromJson(Map<String, dynamic> json) {
    return Phrase(
      id: json['id'] as String,
      arabic: json['arabic'] as String,
      translations: Map<String, String>.from(json['translations'] as Map),
    );
  }
}

/// A phrase pack for a specific service
class PhrasePack {
  final ServiceType service;
  final List<Phrase> phrases;

  const PhrasePack({
    required this.service,
    required this.phrases,
  });

  factory PhrasePack.fromJson(Map<String, dynamic> json) {
    final serviceStr = json['service'] as String;
    final service = ServiceType.values.firstWhere(
      (s) => s.name == serviceStr,
      orElse: () => ServiceType.taxi,
    );
    final phrasesList = (json['phrases'] as List)
        .map((p) => Phrase.fromJson(p as Map<String, dynamic>))
        .toList();
    return PhrasePack(service: service, phrases: phrasesList);
  }
}
