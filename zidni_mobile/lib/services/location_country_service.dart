import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:zidni_mobile/screens/conversation/conversation_mode_screen.dart';

/// Service for detecting country based on device location
/// 
/// Used for auto-selecting target language in Conversation Mode
class LocationCountryService {
  String? _cachedCountryCode;
  DateTime? _lastFetch;
  
  /// Country code to target language mapping
  static const Map<String, TargetLang> _countryToTarget = {
    'CN': TargetLang.zh, // China
    'TW': TargetLang.zh, // Taiwan
    'HK': TargetLang.zh, // Hong Kong
    'TR': TargetLang.tr, // Turkey
    'ES': TargetLang.es, // Spain
    'MX': TargetLang.es, // Mexico
    'AR': TargetLang.es, // Argentina
    'CO': TargetLang.es, // Colombia
    'PE': TargetLang.es, // Peru
    'CL': TargetLang.es, // Chile
    'FR': TargetLang.fr, // France
    'MA': TargetLang.fr, // Morocco
    'DZ': TargetLang.fr, // Algeria
    'TN': TargetLang.fr, // Tunisia
    'SN': TargetLang.fr, // Senegal
    'CI': TargetLang.fr, // Ivory Coast
    'BE': TargetLang.fr, // Belgium
    'CH': TargetLang.fr, // Switzerland (French-speaking)
    'CA': TargetLang.fr, // Canada (Quebec)
  };
  
  /// Country code to Arabic display name
  static const Map<String, String> _countryNames = {
    'CN': 'الصين',
    'TW': 'تايوان',
    'HK': 'هونغ كونغ',
    'TR': 'تركيا',
    'ES': 'إسبانيا',
    'MX': 'المكسيك',
    'AR': 'الأرجنتين',
    'CO': 'كولومبيا',
    'PE': 'بيرو',
    'CL': 'تشيلي',
    'US': 'الولايات المتحدة',
    'GB': 'المملكة المتحدة',
    'AE': 'الإمارات',
    'SA': 'السعودية',
    'FR': 'فرنسا',
    'MA': 'المغرب',
    'DZ': 'الجزائر',
    'TN': 'تونس',
    'SN': 'السنغال',
    'CI': 'ساحل العاج',
    'BE': 'بلجيكا',
    'CH': 'سويسرا',
    'CA': 'كندا',
  };
  
  /// Check if location permission is granted
  Future<bool> hasPermission() async {
    final permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always ||
           permission == LocationPermission.whileInUse;
  }
  
  /// Request location permission
  Future<bool> requestPermission() async {
    final permission = await Geolocator.requestPermission();
    return permission == LocationPermission.always ||
           permission == LocationPermission.whileInUse;
  }
  
  /// Get current country code (ISO 3166-1 alpha-2)
  /// Returns null if location unavailable or permission denied
  Future<String?> getCountryCode() async {
    // Use cache if recent (within 5 minutes)
    if (_cachedCountryCode != null && _lastFetch != null) {
      final age = DateTime.now().difference(_lastFetch!);
      if (age.inMinutes < 5) {
        return _cachedCountryCode;
      }
    }
    
    try {
      // Check permission
      if (!await hasPermission()) {
        return null;
      }
      
      // Check if location services are enabled
      if (!await Geolocator.isLocationServiceEnabled()) {
        return null;
      }
      
      // Get position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low, // Low accuracy is faster
        timeLimit: const Duration(seconds: 10),
      );
      
      // Reverse geocode to get country
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      
      if (placemarks.isNotEmpty) {
        _cachedCountryCode = placemarks.first.isoCountryCode;
        _lastFetch = DateTime.now();
        return _cachedCountryCode;
      }
    } catch (e) {
      // Silently fail - location is optional
    }
    
    return null;
  }
  
  /// Get target language for a country code
  /// Returns EN as default if country not in mapping
  TargetLang getTargetForCountry(String? countryCode) {
    if (countryCode == null) return TargetLang.en;
    return _countryToTarget[countryCode.toUpperCase()] ?? TargetLang.en;
  }
  
  /// Get Arabic display name for a country code
  String getCountryName(String? countryCode) {
    if (countryCode == null) return 'غير معروف';
    return _countryNames[countryCode.toUpperCase()] ?? countryCode;
  }
  
  /// Clear cached country (for testing or refresh)
  void clearCache() {
    _cachedCountryCode = null;
    _lastFetch = null;
  }
}
