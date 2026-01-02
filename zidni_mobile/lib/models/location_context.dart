/// Location context model containing country detection information.
/// 
/// This model stores the detected country information without precise coordinates
/// to maintain user privacy while enabling mode suggestions.
class LocationContext {
  /// ISO 3166-1 alpha-2 country code (e.g., 'US', 'CN', 'EG')
  final String countryCode;
  
  /// Optional human-readable country name
  final String? countryName;
  
  /// Timestamp when location was detected
  final DateTime timestamp;
  
  /// Source of the location data
  final LocationSource source;

  const LocationContext({
    required this.countryCode,
    this.countryName,
    required this.timestamp,
    required this.source,
  });

  /// Create from JSON map
  factory LocationContext.fromJson(Map<String, dynamic> json) {
    return LocationContext(
      countryCode: json['countryCode'] as String,
      countryName: json['countryName'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      source: LocationSource.fromId(json['source'] as String),
    );
  }

  /// Convert to JSON map
  Map<String, dynamic> toJson() {
    return {
      'countryCode': countryCode,
      'countryName': countryName,
      'timestamp': timestamp.toIso8601String(),
      'source': source.id,
    };
  }

  /// Check if location data is stale (older than specified duration)
  bool isStale({Duration maxAge = const Duration(hours: 24)}) {
    return DateTime.now().difference(timestamp) > maxAge;
  }

  @override
  String toString() {
    return 'LocationContext(countryCode: $countryCode, countryName: $countryName, source: ${source.id})';
  }
}

/// Source of location data
enum LocationSource {
  /// Location from GPS/device location services
  gps('gps', 'GPS'),
  
  /// Fallback location (e.g., from IP, SIM, or default)
  fallback('fallback', 'Fallback'),
  
  /// Manually set by user
  manual('manual', 'Manual');

  const LocationSource(this.id, this.displayName);

  final String id;
  final String displayName;

  static LocationSource fromId(String id) {
    return LocationSource.values.firstWhere(
      (source) => source.id == id,
      orElse: () => LocationSource.fallback,
    );
  }
}
