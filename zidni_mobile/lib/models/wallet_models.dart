/// Wallet state model for Zidni Pay.
/// Stores balance and transaction history.
class WalletState {
  final int balanceCents;
  final String currencyCode;
  final List<Tx> transactions;

  WalletState({
    this.balanceCents = 0,
    this.currencyCode = 'USD',
    this.transactions = const [],
  });

  /// Returns the balance formatted as a string with currency symbol.
  String get formattedBalance {
    final dollars = balanceCents / 100;
    final symbol = _currencySymbol;
    return '$symbol${dollars.toStringAsFixed(2)}';
  }

  /// Returns the balance formatted for Arabic display.
  String get formattedBalanceArabic {
    final dollars = balanceCents / 100;
    return '${dollars.toStringAsFixed(2)} ${_currencyNameArabic}';
  }

  String get _currencySymbol {
    switch (currencyCode) {
      case 'USD':
        return '\$';
      case 'CNY':
        return '¥';
      case 'EUR':
        return '€';
      case 'SAR':
        return 'ر.س';
      case 'AED':
        return 'د.إ';
      default:
        return currencyCode;
    }
  }

  String get _currencyNameArabic {
    switch (currencyCode) {
      case 'USD':
        return 'دولار';
      case 'CNY':
        return 'يوان';
      case 'EUR':
        return 'يورو';
      case 'SAR':
        return 'ريال';
      case 'AED':
        return 'درهم';
      default:
        return currencyCode;
    }
  }

  /// Creates a copy with updated fields.
  WalletState copyWith({
    int? balanceCents,
    String? currencyCode,
    List<Tx>? transactions,
  }) {
    return WalletState(
      balanceCents: balanceCents ?? this.balanceCents,
      currencyCode: currencyCode ?? this.currencyCode,
      transactions: transactions ?? this.transactions,
    );
  }

  /// Converts to JSON map for storage.
  Map<String, dynamic> toJson() {
    return {
      'balanceCents': balanceCents,
      'currencyCode': currencyCode,
      'transactions': transactions.map((tx) => tx.toJson()).toList(),
    };
  }

  /// Creates from JSON map.
  factory WalletState.fromJson(Map<String, dynamic> json) {
    return WalletState(
      balanceCents: json['balanceCents'] as int? ?? 0,
      currencyCode: json['currencyCode'] as String? ?? 'USD',
      transactions: (json['transactions'] as List<dynamic>?)
              ?.map((tx) => Tx.fromJson(tx as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  /// Returns an empty wallet state.
  factory WalletState.empty() {
    return WalletState(
      balanceCents: 0,
      currencyCode: 'USD',
      transactions: [],
    );
  }
}

/// Transaction type enum.
enum TxType {
  deposit,
  withdrawal,
  transfer,
  payment,
  refund,
}

/// Transaction model for wallet history.
class Tx {
  final String id;
  final TxType type;
  final int amountCents;
  final DateTime createdAt;
  final String? note;
  final String? counterparty;

  Tx({
    required this.id,
    required this.type,
    required this.amountCents,
    required this.createdAt,
    this.note,
    this.counterparty,
  });

  /// Returns the amount formatted as a string.
  String get formattedAmount {
    final dollars = amountCents / 100;
    final sign = type == TxType.deposit || type == TxType.refund ? '+' : '-';
    return '$sign\$${dollars.abs().toStringAsFixed(2)}';
  }

  /// Returns the transaction type in Arabic.
  String get typeArabic {
    switch (type) {
      case TxType.deposit:
        return 'إيداع';
      case TxType.withdrawal:
        return 'سحب';
      case TxType.transfer:
        return 'تحويل';
      case TxType.payment:
        return 'دفع';
      case TxType.refund:
        return 'استرداد';
    }
  }

  /// Returns the icon for this transaction type.
  String get iconName {
    switch (type) {
      case TxType.deposit:
        return 'arrow_downward';
      case TxType.withdrawal:
        return 'arrow_upward';
      case TxType.transfer:
        return 'swap_horiz';
      case TxType.payment:
        return 'shopping_cart';
      case TxType.refund:
        return 'replay';
    }
  }

  /// Converts to JSON map for storage.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'amountCents': amountCents,
      'createdAt': createdAt.toIso8601String(),
      'note': note,
      'counterparty': counterparty,
    };
  }

  /// Creates from JSON map.
  factory Tx.fromJson(Map<String, dynamic> json) {
    return Tx(
      id: json['id'] as String,
      type: TxType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => TxType.payment,
      ),
      amountCents: json['amountCents'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      note: json['note'] as String?,
      counterparty: json['counterparty'] as String?,
    );
  }
}
