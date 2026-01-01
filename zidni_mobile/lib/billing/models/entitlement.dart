/// Entitlement and Tier Model
/// Gate BILL-1: Entitlements + Usage Meter + Paywall
///
/// Defines subscription tiers and user entitlements

/// Subscription tiers available in Zidni
enum SubscriptionTier {
  /// Free personal tier - offline-first, basic features
  personalFree,
  
  /// Business solo tier - paid, full features for individual traders
  businessSolo,
  
  /// Business team tier - paid, team features (future-ready)
  businessTeam,
}

extension SubscriptionTierExtension on SubscriptionTier {
  /// Get the tier ID for storage
  String get id {
    switch (this) {
      case SubscriptionTier.personalFree:
        return 'personal_free';
      case SubscriptionTier.businessSolo:
        return 'business_solo';
      case SubscriptionTier.businessTeam:
        return 'business_team';
    }
  }
  
  /// Get Arabic display name
  String get arabicName {
    switch (this) {
      case SubscriptionTier.personalFree:
        return 'شخصي مجاني';
      case SubscriptionTier.businessSolo:
        return 'أعمال فردي';
      case SubscriptionTier.businessTeam:
        return 'أعمال فريق';
    }
  }
  
  /// Get English display name
  String get englishName {
    switch (this) {
      case SubscriptionTier.personalFree:
        return 'Personal Free';
      case SubscriptionTier.businessSolo:
        return 'Business Solo';
      case SubscriptionTier.businessTeam:
        return 'Business Team';
    }
  }
  
  /// Check if this is a business tier
  bool get isBusiness {
    return this == SubscriptionTier.businessSolo || 
           this == SubscriptionTier.businessTeam;
  }
  
  /// Check if this is a team tier
  bool get isTeam {
    return this == SubscriptionTier.businessTeam;
  }
  
  /// Get tier from ID string
  static SubscriptionTier fromId(String id) {
    switch (id) {
      case 'business_solo':
        return SubscriptionTier.businessSolo;
      case 'business_team':
        return SubscriptionTier.businessTeam;
      case 'personal_free':
      default:
        return SubscriptionTier.personalFree;
    }
  }
}

/// User's current entitlement state
class Entitlement {
  /// Current subscription tier
  final SubscriptionTier tier;
  
  /// When the subscription expires (null for free tier)
  final DateTime? expiresAt;
  
  /// When the entitlement was last updated
  final DateTime updatedAt;
  
  /// Whether the user has ever been a paying customer
  final bool hasEverPaid;
  
  Entitlement({
    required this.tier,
    this.expiresAt,
    required this.updatedAt,
    this.hasEverPaid = false,
  });
  
  /// Check if the subscription is currently active
  bool get isActive {
    if (tier == SubscriptionTier.personalFree) {
      return true; // Free tier is always active
    }
    if (expiresAt == null) {
      return true; // No expiry set means active
    }
    return DateTime.now().isBefore(expiresAt!);
  }
  
  /// Check if this is a business entitlement
  bool get isBusiness => tier.isBusiness && isActive;
  
  /// Check if this is a team entitlement
  bool get isTeam => tier.isTeam && isActive;
  
  /// Create default free entitlement
  factory Entitlement.free() {
    return Entitlement(
      tier: SubscriptionTier.personalFree,
      updatedAt: DateTime.now(),
    );
  }
  
  /// Create from JSON (for SharedPreferences storage)
  factory Entitlement.fromJson(Map<String, dynamic> json) {
    return Entitlement(
      tier: SubscriptionTierExtension.fromId(json['tier'] ?? 'personal_free'),
      expiresAt: json['expiresAt'] != null 
          ? DateTime.parse(json['expiresAt']) 
          : null,
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      hasEverPaid: json['hasEverPaid'] ?? false,
    );
  }
  
  /// Convert to JSON for storage
  Map<String, dynamic> toJson() => {
    'tier': tier.id,
    'expiresAt': expiresAt?.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'hasEverPaid': hasEverPaid,
  };
  
  /// Copy with new values
  Entitlement copyWith({
    SubscriptionTier? tier,
    DateTime? expiresAt,
    DateTime? updatedAt,
    bool? hasEverPaid,
  }) {
    return Entitlement(
      tier: tier ?? this.tier,
      expiresAt: expiresAt ?? this.expiresAt,
      updatedAt: updatedAt ?? this.updatedAt,
      hasEverPaid: hasEverPaid ?? this.hasEverPaid,
    );
  }
  
  @override
  String toString() {
    return 'Entitlement(tier: ${tier.id}, active: $isActive, expires: $expiresAt)';
  }
}
