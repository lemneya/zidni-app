/// OfflineKit Model
/// Gate LOC-3: Offline Kits + Safe Optional Updates
///
/// Represents a downloadable/bundled kit containing packs and phrases.
/// Kits are local-first: bundled kits work offline, remote updates are optional.

import 'package:flutter/material.dart';

/// Quick phrase pack identifiers
enum PhrasePack {
  supplier,
  business,
  taxi,
  hotel,
  restaurant,
  airport,
  shopping,
  greetings,
  numbers,
  emergency,
  customs,
  medical,
}

/// Extension for PhrasePack display names
extension PhrasePackExtension on PhrasePack {
  String get titleAr {
    switch (this) {
      case PhrasePack.supplier:
        return 'المورد';
      case PhrasePack.business:
        return 'الأعمال';
      case PhrasePack.taxi:
        return 'تاكسي';
      case PhrasePack.hotel:
        return 'فندق';
      case PhrasePack.restaurant:
        return 'مطعم';
      case PhrasePack.airport:
        return 'مطار';
      case PhrasePack.shopping:
        return 'تسوق';
      case PhrasePack.greetings:
        return 'تحيات';
      case PhrasePack.numbers:
        return 'أرقام';
      case PhrasePack.emergency:
        return 'طوارئ';
      case PhrasePack.customs:
        return 'جمارك';
      case PhrasePack.medical:
        return 'طبي';
    }
  }
  
  String get titleEn {
    switch (this) {
      case PhrasePack.supplier:
        return 'Supplier';
      case PhrasePack.business:
        return 'Business';
      case PhrasePack.taxi:
        return 'Taxi';
      case PhrasePack.hotel:
        return 'Hotel';
      case PhrasePack.restaurant:
        return 'Restaurant';
      case PhrasePack.airport:
        return 'Airport';
      case PhrasePack.shopping:
        return 'Shopping';
      case PhrasePack.greetings:
        return 'Greetings';
      case PhrasePack.numbers:
        return 'Numbers';
      case PhrasePack.emergency:
        return 'Emergency';
      case PhrasePack.customs:
        return 'Customs';
      case PhrasePack.medical:
        return 'Medical';
    }
  }
  
  IconData get icon {
    switch (this) {
      case PhrasePack.supplier:
        return Icons.factory;
      case PhrasePack.business:
        return Icons.business_center;
      case PhrasePack.taxi:
        return Icons.local_taxi;
      case PhrasePack.hotel:
        return Icons.hotel;
      case PhrasePack.restaurant:
        return Icons.restaurant;
      case PhrasePack.airport:
        return Icons.flight;
      case PhrasePack.shopping:
        return Icons.shopping_bag;
      case PhrasePack.greetings:
        return Icons.waving_hand;
      case PhrasePack.numbers:
        return Icons.numbers;
      case PhrasePack.emergency:
        return Icons.emergency;
      case PhrasePack.customs:
        return Icons.gavel;
      case PhrasePack.medical:
        return Icons.medical_services;
    }
  }
}

/// Offline Kit model
class OfflineKit {
  final String id;
  final int version;
  final String titleAr;
  final String titleEn;
  final String descriptionAr;
  final String descriptionEn;
  final String defaultPackId; // ContextPack id to activate
  final List<PhrasePack> phrasePacks;
  final DateTime updatedAt;
  final bool isBundled; // true = shipped with app, false = downloaded
  final IconData icon;
  final Color themeColor;
  
  const OfflineKit({
    required this.id,
    required this.version,
    required this.titleAr,
    required this.titleEn,
    required this.descriptionAr,
    required this.descriptionEn,
    required this.defaultPackId,
    required this.phrasePacks,
    required this.updatedAt,
    this.isBundled = true,
    this.icon = Icons.inventory_2,
    this.themeColor = const Color(0xFF6366F1),
  });
  
  /// Create from JSON (for remote updates)
  factory OfflineKit.fromJson(Map<String, dynamic> json) {
    return OfflineKit(
      id: json['id'] as String,
      version: json['version'] as int,
      titleAr: json['titleAr'] as String,
      titleEn: json['titleEn'] as String,
      descriptionAr: json['descriptionAr'] as String? ?? '',
      descriptionEn: json['descriptionEn'] as String? ?? '',
      defaultPackId: json['defaultPackId'] as String,
      phrasePacks: (json['phrasePacks'] as List<dynamic>?)
          ?.map((e) => PhrasePack.values.firstWhere(
                (p) => p.name == e,
                orElse: () => PhrasePack.greetings,
              ))
          .toList() ?? [],
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? DateTime.now(),
      isBundled: json['isBundled'] as bool? ?? false,
    );
  }
  
  /// Convert to JSON (for caching)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'version': version,
      'titleAr': titleAr,
      'titleEn': titleEn,
      'descriptionAr': descriptionAr,
      'descriptionEn': descriptionEn,
      'defaultPackId': defaultPackId,
      'phrasePacks': phrasePacks.map((e) => e.name).toList(),
      'updatedAt': updatedAt.toIso8601String(),
      'isBundled': isBundled,
    };
  }
  
  /// Copy with new values
  OfflineKit copyWith({
    String? id,
    int? version,
    String? titleAr,
    String? titleEn,
    String? descriptionAr,
    String? descriptionEn,
    String? defaultPackId,
    List<PhrasePack>? phrasePacks,
    DateTime? updatedAt,
    bool? isBundled,
    IconData? icon,
    Color? themeColor,
  }) {
    return OfflineKit(
      id: id ?? this.id,
      version: version ?? this.version,
      titleAr: titleAr ?? this.titleAr,
      titleEn: titleEn ?? this.titleEn,
      descriptionAr: descriptionAr ?? this.descriptionAr,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      defaultPackId: defaultPackId ?? this.defaultPackId,
      phrasePacks: phrasePacks ?? this.phrasePacks,
      updatedAt: updatedAt ?? this.updatedAt,
      isBundled: isBundled ?? this.isBundled,
      icon: icon ?? this.icon,
      themeColor: themeColor ?? this.themeColor,
    );
  }
}
