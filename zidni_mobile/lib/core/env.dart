/// Environment configuration for Zidni.
///
/// This file provides a minimal dev/prod environment configuration.
/// It allows the app to behave differently based on the environment.
library;

/// The current environment.
enum Environment {
  /// Development environment.
  dev,

  /// Production environment.
  prod,
}

/// The current environment configuration.
class EnvConfig {
  /// The current environment.
  static Environment current = Environment.dev;

  /// Whether the app is running in development mode.
  static bool get isDev => current == Environment.dev;

  /// Whether the app is running in production mode.
  static bool get isProd => current == Environment.prod;

  /// The base URL for the API.
  static String get apiBaseUrl {
    switch (current) {
      case Environment.dev:
        return 'http://localhost:8000';
      case Environment.prod:
        return 'https://api.zidni.app';
    }
  }

  /// Whether to enable verbose logging.
  static bool get enableVerboseLogging => isDev;

  /// Whether to enable analytics.
  static bool get enableAnalytics => isProd;
}
