import 'package:flutter/material.dart';

/// Standard test app wrapper for widget and golden tests.
/// Provides consistent theme, localization, and directionality.
class TestApp extends StatelessWidget {
  final Widget child;
  final ThemeData? theme;
  final TextDirection textDirection;
  final Locale locale;
  final Size screenSize;

  const TestApp({
    super.key,
    required this.child,
    this.theme,
    this.textDirection = TextDirection.rtl,
    this.locale = const Locale('ar'),
    this.screenSize = const Size(390, 844), // iPhone 14 Pro
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme ?? _defaultTheme,
      locale: locale,
      home: Directionality(
        textDirection: textDirection,
        child: MediaQuery(
          data: MediaQueryData(size: screenSize),
          child: Scaffold(
            body: child,
          ),
        ),
      ),
    );
  }

  static ThemeData get _defaultTheme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        fontFamily: 'NotoSansArabic',
      );

  /// Creates a test app with Arabic RTL configuration.
  factory TestApp.arabic({required Widget child, ThemeData? theme}) {
    return TestApp(
      child: child,
      theme: theme,
      textDirection: TextDirection.rtl,
      locale: const Locale('ar'),
    );
  }

  /// Creates a test app with English LTR configuration.
  factory TestApp.english({required Widget child, ThemeData? theme}) {
    return TestApp(
      child: child,
      theme: theme,
      textDirection: TextDirection.ltr,
      locale: const Locale('en'),
    );
  }

  /// Creates a test app with Chinese LTR configuration.
  factory TestApp.chinese({required Widget child, ThemeData? theme}) {
    return TestApp(
      child: child,
      theme: theme,
      textDirection: TextDirection.ltr,
      locale: const Locale('zh'),
    );
  }
}

/// Standard screen sizes for golden tests.
class TestScreenSizes {
  static const Size iphone14Pro = Size(390, 844);
  static const Size iphone14ProMax = Size(430, 932);
  static const Size iphoneSE = Size(375, 667);
  static const Size pixel7 = Size(412, 915);
  static const Size galaxyS23 = Size(360, 780);
}
