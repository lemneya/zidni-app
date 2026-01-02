/// User profile model for Zidni app.
/// Stores user identity and profession information.
class UserProfile {
  final String uid;
  final String? displayName;
  final String? email;
  final String? phone;
  final String? profession;
  final String? subProfession;
  final DateTime createdAt;
  final bool isGuest;

  UserProfile({
    required this.uid,
    this.displayName,
    this.email,
    this.phone,
    this.profession,
    this.subProfession,
    required this.createdAt,
    this.isGuest = false,
  });

  /// Creates a guest user profile.
  factory UserProfile.guest() {
    return UserProfile(
      uid: 'guest_${DateTime.now().millisecondsSinceEpoch}',
      displayName: 'ضيف', // Guest in Arabic
      createdAt: DateTime.now(),
      isGuest: true,
    );
  }

  /// Creates a copy with updated fields.
  UserProfile copyWith({
    String? uid,
    String? displayName,
    String? email,
    String? phone,
    String? profession,
    String? subProfession,
    DateTime? createdAt,
    bool? isGuest,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profession: profession ?? this.profession,
      subProfession: subProfession ?? this.subProfession,
      createdAt: createdAt ?? this.createdAt,
      isGuest: isGuest ?? this.isGuest,
    );
  }

  /// Converts to JSON map for storage.
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'displayName': displayName,
      'email': email,
      'phone': phone,
      'profession': profession,
      'subProfession': subProfession,
      'createdAt': createdAt.toIso8601String(),
      'isGuest': isGuest,
    };
  }

  /// Creates from JSON map.
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      uid: json['uid'] as String,
      displayName: json['displayName'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      profession: json['profession'] as String?,
      subProfession: json['subProfession'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isGuest: json['isGuest'] as bool? ?? false,
    );
  }

  /// Returns the profession display string in Arabic.
  String get professionDisplayArabic {
    if (profession == null) return 'غير محدد';
    
    final professionMap = {
      'trader_importer': 'تاجر/مستورد',
      'manufacturer': 'مصنّع',
      'service_provider': 'مقدم خدمات',
      'student': 'طالب',
      'traveler': 'مسافر',
      'other': 'أخرى',
    };
    
    String base = professionMap[profession] ?? profession!;
    if (subProfession != null) {
      final subMap = {
        'carpenter': 'نجار',
        'electrician': 'كهربائي',
        'plumber': 'سباك',
        'other': 'أخرى',
      };
      base += ' - ${subMap[subProfession] ?? subProfession}';
    }
    return base;
  }
}
