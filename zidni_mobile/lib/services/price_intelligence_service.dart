import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:zidni_mobile/models/price_calculation.dart';
import 'package:zidni_mobile/billing/services/entitlement_service.dart';
import 'package:zidni_mobile/usage/services/usage_meter_service.dart';
import 'package:zidni_mobile/usage/models/usage_record.dart';

/// Price Intelligence Service
/// Gate EYES-4: Price Comparison & Calculator
///
/// FREE TIER: Basic calculator (unit price × quantity + shipping)
/// BUSINESS TIER: Market price comparison + recommendations
///
/// VALUE PROPOSITION:
/// - Prevents exploitation (users know if price is fair)
/// - Data-driven negotiation ("Your price is 20% above market")
/// - Builds trust through transparency
class PriceIntelligenceService {
  static const String _apiBaseUrl = 'https://api.zidni.com/v1'; // TODO: Replace with actual API

  /// Calculate total price with all fees (FREE TIER)
  ///
  /// Example:
  /// ```dart
  /// final calc = PriceIntelligenceService.calculatePricing(
  ///   unitPrice: 52.00,
  ///   quantity: 300,
  ///   shippingCost: 500.00,
  ///   dutiesPercent: 10,
  ///   currency: 'CNY',
  ///   exchangeRate: 0.14, // CNY to USD
  ///   localCurrency: 'USD',
  /// );
  ///
  /// print('Total cost: ${calc.totalCost}');
  /// print('Per unit landed: ${calc.landedCostPerUnit}');
  /// ```
  static PriceCalculation calculatePricing({
    required double unitPrice,
    required int quantity,
    double shippingCost = 0,
    double dutiesPercent = 0,
    double otherFees = 0,
    String currency = 'USD',
    double? exchangeRate,
    String? localCurrency,
  }) {
    return PriceCalculation(
      unitPrice: unitPrice,
      quantity: quantity,
      shippingCost: shippingCost,
      dutiesPercent: dutiesPercent,
      otherFees: otherFees,
      currency: currency,
      exchangeRate: exchangeRate,
      localCurrency: localCurrency,
    );
  }

  /// Analyze pricing with market comparison (BUSINESS TIER)
  ///
  /// Returns market insights, percentile, and recommendations.
  /// Requires Business tier subscription.
  ///
  /// Example:
  /// ```dart
  /// final insight = await PriceIntelligenceService.analyzePricing(
  ///   productName: 'Cotton T-Shirts',
  ///   category: 'Textiles',
  ///   quotedPrice: 52.00,
  ///   quantity: 300,
  ///   currency: 'CNY',
  /// );
  ///
  /// if (insight != null) {
  ///   print(insight.recommendationText); // "Too High - Negotiate"
  ///   print(insight.actionSuggestion);   // "Try negotiating 15% lower"
  /// }
  /// ```
  static Future<PriceInsight?> analyzePricing({
    required String productName,
    required String category,
    required double quotedPrice,
    int? quantity,
    String currency = 'USD',
    String? region,
  }) async {
    try {
      // Check entitlement
      final entitlement = await EntitlementService.getEntitlement();
      if (!entitlement.canExportPDF) {
        // Free tier doesn't get market analysis
        return null;
      }

      // Track usage
      await UsageMeterService.increment(UsageType.eyesSearches);

      // Call price analysis API
      // TODO: Replace with actual API call
      final insight = await _getMockPriceInsight(
        productName: productName,
        category: category,
        quotedPrice: quotedPrice,
        currency: currency,
        region: region,
      );

      return insight;
    } catch (e) {
      print('[PriceIntelligence] Error analyzing price: $e');
      return null;
    }
  }

  /// Get exchange rate between currencies
  ///
  /// Uses cached rates (updated daily) to avoid excessive API calls.
  /// Falls back to approximations if API unavailable.
  static Future<ExchangeRate> getExchangeRate({
    required String from,
    required String to,
  }) async {
    try {
      // TODO: Call real exchange rate API (e.g., exchangerate-api.com)
      // For now, return mock data
      return _getMockExchangeRate(from, to);
    } catch (e) {
      print('[PriceIntelligence] Error getting exchange rate: $e');
      // Return 1:1 as fallback
      return ExchangeRate(
        from: from,
        to: to,
        rate: 1.0,
        updatedAt: DateTime.now(),
      );
    }
  }

  /// Convert price between currencies
  static Future<double> convertCurrency({
    required double amount,
    required String from,
    required String to,
  }) async {
    if (from == to) return amount;

    final rate = await getExchangeRate(from: from, to: to);
    return rate.convert(amount);
  }

  /// Get price history for product/category
  ///
  /// Returns historical price data points for trend analysis.
  /// Business tier only.
  static Future<List<PriceHistoryEntry>> getPriceHistory({
    required String category,
    String? productName,
    int daysBack = 90,
  }) async {
    try {
      final entitlement = await EntitlementService.getEntitlement();
      if (!entitlement.canExportPDF) {
        return [];
      }

      // TODO: Call API for historical data
      return _getMockPriceHistory(category, daysBack);
    } catch (e) {
      print('[PriceIntelligence] Error getting price history: $e');
      return [];
    }
  }

  // ==================== MOCK DATA (Replace with real API) ====================

  /// Mock price insight generator
  /// TODO: Replace with actual API call to backend
  static Future<PriceInsight> _getMockPriceInsight({
    required String productName,
    required String category,
    required double quotedPrice,
    String currency = 'USD',
    String? region,
  }) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Mock market data based on category
    final marketData = _getMarketDataForCategory(category);
    final marketAverage = marketData['average']!;
    final marketMin = marketData['min']!;
    final marketMax = marketData['max']!;

    // Calculate percentile
    final percentile = _calculatePercentile(quotedPrice, marketMin, marketMax);

    // Determine recommendation
    final recommendation = _getRecommendation(quotedPrice, marketAverage);

    // Generate comparable products
    final comparables = _generateComparables(category, marketAverage);

    return PriceInsight(
      category: category,
      quotedPrice: quotedPrice,
      marketAverage: marketAverage,
      marketRange: PriceRange(min: marketMin, max: marketMax),
      percentile: percentile,
      recommendation: recommendation,
      confidence: 80, // Mock confidence score
      updatedAt: DateTime.now(),
      comparables: comparables,
      region: region ?? 'Global',
    );
  }

  /// Mock market data by category
  static Map<String, double> _getMarketDataForCategory(String category) {
    // Realistic market data for common Canton Fair categories
    final marketData = {
      'Textiles': {'min': 35.0, 'max': 65.0, 'average': 48.0},
      'Electronics': {'min': 80.0, 'max': 150.0, 'average': 110.0},
      'Furniture': {'min': 120.0, 'max': 250.0, 'average': 180.0},
      'Machinery': {'min': 5000.0, 'max': 15000.0, 'average': 9500.0},
      'Home Appliances': {'min': 50.0, 'max': 120.0, 'average': 80.0},
      'Toys': {'min': 8.0, 'max': 25.0, 'average': 15.0},
      'Packaging': {'min': 0.50, 'max': 3.0, 'average': 1.5},
      'Lighting': {'min': 12.0, 'max': 45.0, 'average': 25.0},
      'Kitchenware': {'min': 5.0, 'max': 20.0, 'average': 12.0},
      'Default': {'min': 10.0, 'max': 100.0, 'average': 50.0},
    };

    return marketData[category] ?? marketData['Default']!;
  }

  /// Calculate price percentile (0-100)
  static int _calculatePercentile(double price, double min, double max) {
    if (price <= min) return 0;
    if (price >= max) return 100;

    final range = max - min;
    final position = price - min;
    final percentile = (position / range * 100).round();

    return 100 - percentile; // Invert: lower price = higher percentile rank
  }

  /// Get recommendation based on price vs market average
  static PriceRecommendation _getRecommendation(
    double quotedPrice,
    double marketAverage,
  ) {
    final difference = ((quotedPrice - marketAverage) / marketAverage) * 100;

    if (difference <= -15) return PriceRecommendation.excellent;
    if (difference <= -5) return PriceRecommendation.good;
    if (difference <= 5) return PriceRecommendation.fair;
    if (difference <= 20) return PriceRecommendation.high;
    return PriceRecommendation.tooHigh;
  }

  /// Generate comparable products
  static List<ComparableProduct> _generateComparables(
    String category,
    double averagePrice,
  ) {
    // Mock comparable products
    return [
      ComparableProduct(
        name: 'Similar product A',
        supplier: 'Supplier A',
        price: averagePrice * 0.95,
        source: 'Alibaba',
        date: DateTime.now().subtract(const Duration(days: 7)),
      ),
      ComparableProduct(
        name: 'Similar product B',
        supplier: 'Supplier B',
        price: averagePrice * 1.05,
        source: 'Canton Fair 2024',
        date: DateTime.now().subtract(const Duration(days: 30)),
      ),
      ComparableProduct(
        name: 'Similar product C',
        supplier: 'Supplier C',
        price: averagePrice * 0.98,
        source: 'Global Sources',
        date: DateTime.now().subtract(const Duration(days: 14)),
      ),
    ];
  }

  /// Mock exchange rates
  /// TODO: Replace with real API (exchangerate-api.com, fixer.io, etc.)
  static ExchangeRate _getMockExchangeRate(String from, String to) {
    // Common rates as of 2026 (approximate)
    final rates = {
      'CNY_USD': 0.14,
      'CNY_EUR': 0.13,
      'CNY_SAR': 0.52,
      'CNY_AED': 0.51,
      'USD_CNY': 7.20,
      'USD_EUR': 0.92,
      'USD_SAR': 3.75,
      'USD_AED': 3.67,
      'EUR_USD': 1.09,
      'SAR_USD': 0.27,
      'AED_USD': 0.27,
    };

    final key = '${from}_$to';
    final rate = rates[key] ?? 1.0;

    return ExchangeRate(
      from: from,
      to: to,
      rate: rate,
      updatedAt: DateTime.now(),
    );
  }

  /// Mock price history
  static Future<List<PriceHistoryEntry>> _getMockPriceHistory(
    String category,
    int daysBack,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final marketData = _getMarketDataForCategory(category);
    final average = marketData['average']!;

    final history = <PriceHistoryEntry>[];
    for (int i = 0; i < daysBack; i += 7) {
      // One entry per week
      final date = DateTime.now().subtract(Duration(days: i));
      // Add some random variation (±10%)
      final variation = (i % 3 - 1) * 0.05;
      final price = average * (1 + variation);

      history.add(PriceHistoryEntry(
        date: date,
        price: price,
        supplierName: 'Supplier ${String.fromCharCode(65 + (i ~/ 7) % 26)}',
      ));
    }

    return history;
  }
}
