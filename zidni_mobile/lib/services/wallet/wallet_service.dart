import 'dart:async';
import '../../models/wallet_models.dart';

/// Wallet service for Zidni Pay.
/// Currently returns local in-memory/mock state (0 balance, empty tx list).
/// Future versions will integrate with payment providers.
class WalletService {
  // Singleton pattern
  WalletService._internal() {
    // Initialize with empty state
    _stateController.add(_state);
  }

  static final WalletService _instance = WalletService._internal();
  
  /// Returns the singleton instance of WalletService.
  static WalletService get instance => _instance;
  
  /// Factory constructor that returns the singleton instance.
  factory WalletService() => _instance;

  WalletState _state = WalletState.empty();
  final StreamController<WalletState> _stateController =
      StreamController<WalletState>.broadcast();

  /// Returns the current wallet state.
  WalletState get currentState => _state;

  /// Stream of wallet state changes.
  Stream<WalletState> get stateStream => _stateController.stream;

  /// Fetches the latest wallet state.
  /// Currently returns mock data (0 balance, empty transactions).
  Future<WalletState> fetchWalletState() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Return empty state (UI shell only)
    _state = WalletState.empty();
    _stateController.add(_state);
    return _state;
  }

  /// Checks if adding funds is available.
  /// Currently always returns false (Coming Soon).
  bool get isAddFundsAvailable => false;

  /// Checks if withdrawals are available.
  /// Currently always returns false (Coming Soon).
  bool get isWithdrawAvailable => false;

  /// Checks if transfers are available.
  /// Currently always returns false (Coming Soon).
  bool get isTransferAvailable => false;

  /// Returns the "Coming Soon" message in Arabic.
  String get comingSoonMessageArabic => 'قريبًا — Zidni Pay';

  /// Returns the "Coming Soon" description in Arabic.
  String get comingSoonDescriptionArabic =>
      'نعمل على إضافة خدمات الدفع والتحويل. ترقبوا التحديثات القادمة!';

  /// Placeholder for future add funds functionality.
  Future<void> addFunds(int amountCents) async {
    // Not implemented - Coming Soon
    throw UnimplementedError('Add funds is coming soon');
  }

  /// Placeholder for future withdrawal functionality.
  Future<void> withdraw(int amountCents) async {
    // Not implemented - Coming Soon
    throw UnimplementedError('Withdrawals are coming soon');
  }

  /// Placeholder for future transfer functionality.
  Future<void> transfer(String recipientId, int amountCents) async {
    // Not implemented - Coming Soon
    throw UnimplementedError('Transfers are coming soon');
  }

  void dispose() {
    _stateController.close();
  }
}
