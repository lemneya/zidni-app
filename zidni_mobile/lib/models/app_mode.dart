/// App Mode enum representing different operational modes based on user location.
/// 
/// Each mode customizes the Zidni experience for specific user contexts:
/// - [home]: For users in MENA region (Egypt, Algeria, Morocco, etc.)
/// - [travel]: Default mode for users in unrecognized locations
/// - [cantonFair]: For users in China (Guangzhou, Yiwu, Foshan)
/// - [immigration]: For users in USA (Arab immigrants)
enum AppMode {
  /// Home mode for MENA region users
  home('home', 'الوضع المحلي', 'Home Mode'),
  
  /// Travel mode for users in unrecognized locations
  travel('travel', 'وضع السفر', 'Travel Mode'),
  
  /// Canton Fair mode for users in China
  cantonFair('canton_fair', 'وضع معرض كانتون', 'Canton Fair Mode'),
  
  /// Immigration mode for Arab immigrants in USA
  immigration('immigration', 'وضع الهجرة', 'Immigration Mode');

  const AppMode(this.id, this.arabicName, this.englishName);

  /// Unique identifier for persistence
  final String id;
  
  /// Arabic display name
  final String arabicName;
  
  /// English display name
  final String englishName;

  /// Get mode from string ID
  static AppMode fromId(String id) {
    return AppMode.values.firstWhere(
      (mode) => mode.id == id,
      orElse: () => AppMode.travel,
    );
  }

  /// Get localized name based on locale
  String getLocalizedName(String locale) {
    return locale.startsWith('ar') ? arabicName : englishName;
  }
}
