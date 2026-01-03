/// Price Calculation Models
/// Gate EYES-4: Price Intelligence
///
/// Models for pricing calculations, comparisons, and market analysis

/// Basic price calculation result
class PriceCalculation {
  /// Unit price from supplier
  final double unitPrice;

  /// Quantity ordered
  final int quantity;

  /// Shipping cost (total, not per unit)
  final double shippingCost;

  /// Import duties/taxes (percentage)
  final double dutiesPercent;

  /// Other fees (flat amount)
  final double otherFees;

  /// Currency code (ISO 4217)
  final String currency;

  /// Exchange rate to user's local currency
  final double? exchangeRate;

  /// User's local currency code
  final String? localCurrency;

  PriceCalculation({
    required this.unitPrice,
    required this.quantity,
    this.shippingCost = 0,
    this.dutiesPercent = 0,
    this.otherFees = 0,
    this.currency = 'USD',
    this.exchangeRate,
    this.localCurrency,
  });

  /// Subtotal (unit price × quantity)
  double get subtotal => unitPrice * quantity;

  /// Duties amount
  double get dutiesAmount => subtotal * (dutiesPercent / 100);

  /// Total cost in supplier currency
  double get totalCost => subtotal + shippingCost + dutiesAmount + otherFees;

  /// Cost per unit including all fees (landed cost)
  double get landedCostPerUnit => totalCost / quantity;

  /// Total cost in user's local currency
  double? get totalCostLocal {
    if (exchangeRate == null) return null;
    return totalCost * exchangeRate!;
  }

  /// Landed cost per unit in local currency
  double? get landedCostPerUnitLocal {
    if (exchangeRate == null) return null;
    return landedCostPerUnit * exchangeRate!;
  }

  /// Breakdown of costs
  Map<String, double> get breakdown => {
        'subtotal': subtotal,
        'shipping': shippingCost,
        'duties': dutiesAmount,
        'other_fees': otherFees,
        'total': totalCost,
        'landed_cost_per_unit': landedCostPerUnit,
      };

  /// Create from JSON
  factory PriceCalculation.fromJson(Map<String, dynamic> json) {
    return PriceCalculation(
      unitPrice: (json['unit_price'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 1,
      shippingCost: (json['shipping_cost'] ?? 0).toDouble(),
      dutiesPercent: (json['duties_percent'] ?? 0).toDouble(),
      otherFees: (json['other_fees'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'USD',
      exchangeRate: json['exchange_rate']?.toDouble(),
      localCurrency: json['local_currency'],
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() => {
        'unit_price': unitPrice,
        'quantity': quantity,
        'shipping_cost': shippingCost,
        'duties_percent': dutiesPercent,
        'other_fees': otherFees,
        'currency': currency,
        'exchange_rate': exchangeRate,
        'local_currency': localCurrency,
        'subtotal': subtotal,
        'total_cost': totalCost,
        'landed_cost_per_unit': landedCostPerUnit,
      };
}

/// Market price insight (Business tier feature)
class PriceInsight {
  /// Product category
  final String category;

  /// Supplier's quoted price
  final double quotedPrice;

  /// Market average price
  final double marketAverage;

  /// Market price range (min-max)
  final PriceRange marketRange;

  /// Percentile (0-100) - 50 = median, 25 = better than 75% of market
  final int percentile;

  /// Recommendation level
  final PriceRecommendation recommendation;

  /// Confidence score (0-100)
  final int confidence;

  /// Data freshness timestamp
  final DateTime updatedAt;

  /// Comparable products for reference
  final List<ComparableProduct> comparables;

  /// Regional market data
  final String? region;

  PriceInsight({
    required this.category,
    required this.quotedPrice,
    required this.marketAverage,
    required this.marketRange,
    required this.percentile,
    required this.recommendation,
    this.confidence = 75,
    required this.updatedAt,
    this.comparables = const [],
    this.region,
  });

  /// Price difference from market average
  double get differenceFromAverage => quotedPrice - marketAverage;

  /// Percentage difference from market average
  double get percentageDifference =>
      ((quotedPrice - marketAverage) / marketAverage) * 100;

  /// Is this a good deal?
  bool get isGoodDeal =>
      recommendation == PriceRecommendation.excellent ||
      recommendation == PriceRecommendation.good;

  /// Is this above market?
  bool get isAboveMarket => quotedPrice > marketAverage;

  /// Get recommendation text (English)
  String get recommendationText {
    switch (recommendation) {
      case PriceRecommendation.excellent:
        return 'Excellent Deal';
      case PriceRecommendation.good:
        return 'Good Price';
      case PriceRecommendation.fair:
        return 'Fair Price';
      case PriceRecommendation.high:
        return 'Above Average';
      case PriceRecommendation.tooHigh:
        return 'Too High - Negotiate';
    }
  }

  /// Get recommendation text (Arabic)
  String get recommendationTextArabic {
    switch (recommendation) {
      case PriceRecommendation.excellent:
        return 'صفقة ممتازة';
      case PriceRecommendation.good:
        return 'سعر جيد';
      case PriceRecommendation.fair:
        return 'سعر مقبول';
      case PriceRecommendation.high:
        return 'أعلى من المتوسط';
      case PriceRecommendation.tooHigh:
        return 'مرتفع جداً - تفاوض';
    }
  }

  /// Get action suggestion
  String get actionSuggestion {
    switch (recommendation) {
      case PriceRecommendation.excellent:
        return 'Accept immediately - ${percentageDifference.abs().toStringAsFixed(0)}% below market';
      case PriceRecommendation.good:
        return 'Good value - consider placing order';
      case PriceRecommendation.fair:
        return 'Fair price - negotiate for volume discount';
      case PriceRecommendation.high:
        return 'Try negotiating ${(percentageDifference - 10).toStringAsFixed(0)}% lower';
      case PriceRecommendation.tooHigh:
        return 'Negotiate down to market average: \$${marketAverage.toStringAsFixed(2)}';
    }
  }

  /// Create from JSON
  factory PriceInsight.fromJson(Map<String, dynamic> json) {
    return PriceInsight(
      category: json['category'] ?? '',
      quotedPrice: (json['quoted_price'] ?? 0).toDouble(),
      marketAverage: (json['market_average'] ?? 0).toDouble(),
      marketRange: PriceRange.fromJson(json['market_range'] ?? {}),
      percentile: json['percentile'] ?? 50,
      recommendation: PriceRecommendation.values[json['recommendation'] ?? 2],
      confidence: json['confidence'] ?? 75,
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
      comparables: (json['comparables'] as List<dynamic>? ?? [])
          .map((c) => ComparableProduct.fromJson(c))
          .toList(),
      region: json['region'],
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() => {
        'category': category,
        'quoted_price': quotedPrice,
        'market_average': marketAverage,
        'market_range': marketRange.toJson(),
        'percentile': percentile,
        'recommendation': recommendation.index,
        'confidence': confidence,
        'updated_at': updatedAt.toIso8601String(),
        'comparables': comparables.map((c) => c.toJson()).toList(),
        'region': region,
      };
}

/// Price range (min-max)
class PriceRange {
  final double min;
  final double max;

  PriceRange({required this.min, required this.max});

  double get range => max - min;
  double get average => (min + max) / 2;

  factory PriceRange.fromJson(Map<String, dynamic> json) {
    return PriceRange(
      min: (json['min'] ?? 0).toDouble(),
      max: (json['max'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {'min': min, 'max': max};
}

/// Price recommendation levels
enum PriceRecommendation {
  excellent, // 15%+ below market
  good, // 5-15% below market
  fair, // ±5% of market
  high, // 5-20% above market
  tooHigh, // 20%+ above market
}

/// Comparable product for price reference
class ComparableProduct {
  final String name;
  final String supplier;
  final double price;
  final String? source;
  final DateTime? date;

  ComparableProduct({
    required this.name,
    required this.supplier,
    required this.price,
    this.source,
    this.date,
  });

  factory ComparableProduct.fromJson(Map<String, dynamic> json) {
    return ComparableProduct(
      name: json['name'] ?? '',
      supplier: json['supplier'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      source: json['source'],
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'supplier': supplier,
        'price': price,
        'source': source,
        'date': date?.toIso8601String(),
      };
}

/// Currency exchange rate
class ExchangeRate {
  final String from;
  final String to;
  final double rate;
  final DateTime updatedAt;

  ExchangeRate({
    required this.from,
    required this.to,
    required this.rate,
    required this.updatedAt,
  });

  /// Convert amount from source to target currency
  double convert(double amount) => amount * rate;

  factory ExchangeRate.fromJson(Map<String, dynamic> json) {
    return ExchangeRate(
      from: json['from'] ?? 'USD',
      to: json['to'] ?? 'USD',
      rate: (json['rate'] ?? 1.0).toDouble(),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() => {
        'from': from,
        'to': to,
        'rate': rate,
        'updated_at': updatedAt.toIso8601String(),
      };
}

/// Price history entry
class PriceHistoryEntry {
  final DateTime date;
  final double price;
  final String? supplierName;
  final int? quantity;

  PriceHistoryEntry({
    required this.date,
    required this.price,
    this.supplierName,
    this.quantity,
  });

  factory PriceHistoryEntry.fromJson(Map<String, dynamic> json) {
    return PriceHistoryEntry(
      date: DateTime.parse(json['date']),
      price: (json['price'] ?? 0).toDouble(),
      supplierName: json['supplier_name'],
      quantity: json['quantity'],
    );
  }

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'price': price,
        'supplier_name': supplierName,
        'quantity': quantity,
      };
}
