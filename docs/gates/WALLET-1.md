# Gate WALLET-1: Zidni Pay Wallet UI Shell (Expectation Setting)

## Overview

This gate adds a Wallet screen that sets user expectations for the upcoming Zidni Pay feature. The wallet displays a balance of 0, an empty transaction history, and shows "Coming Soon" when users attempt to add funds.

## Purpose

The wallet UI shell serves several strategic purposes:

1. **Expectation Setting**: Users see the wallet from day one, setting the expectation that payment features are coming
2. **Zero Regulatory Risk**: No actual money transmission, just a UI shell
3. **Future-Ready Architecture**: Models and services are structured for easy integration with payment providers later
4. **User Feedback**: Allows gathering user interest and feedback on wallet features before full implementation

## Architecture

### Wallet State Model

```dart
WalletState {
  balanceCents: int,      // Always 0 for now
  currencyCode: String,   // Default: 'USD'
  transactions: List<Tx>  // Always empty for now
}

Tx {
  id: String,
  type: TxType,           // deposit, withdrawal, transfer, payment, refund
  amountCents: int,
  createdAt: DateTime,
  note: String?,
  counterparty: String?
}
```

### Service Layer

```dart
WalletService {
  currentState: WalletState        // Returns empty state
  stateStream: Stream<WalletState> // For reactive updates
  fetchWalletState(): Future       // Returns mock data
  isAddFundsAvailable: bool        // Always false
  isWithdrawAvailable: bool        // Always false
  isTransferAvailable: bool        // Always false
}
```

## Files Created

| File | Purpose |
|------|---------|
| `lib/models/wallet_models.dart` | WalletState and Tx models |
| `lib/services/wallet/wallet_service.dart` | Wallet service (mock state) |
| `lib/screens/wallet/wallet_screen.dart` | Main wallet screen |
| `lib/widgets/wallet/balance_card.dart` | Balance display card |
| `lib/widgets/wallet/tx_list_empty_state.dart` | Empty transaction list |
| `lib/widgets/wallet/coming_soon_sheet.dart` | Coming Soon bottom sheet |
| `docs/gates/WALLET-1.md` | This documentation |

## UI Components

### Balance Card
- Gradient blue background with Zidni Pay branding
- Shows "0.00 دولار" (or configured currency)
- "إضافة رصيد" (Add Funds) button → opens Coming Soon sheet

### Quick Actions Row
- إرسال (Send) → Coming Soon
- استلام (Receive) → Coming Soon
- السجل (History) → Scrolls to transactions

### Transaction List
- Empty state: "لا توجد معاملات بعد" (No transactions yet)
- "ستظهر هنا جميع معاملاتك المالية" (All your transactions will appear here)

### Coming Soon Sheet
- Title: "قريبًا — Zidni Pay"
- Description: "نعمل على إضافة خدمات الدفع والتحويل. ترقبوا التحديثات القادمة!"
- Feature preview list:
  - إضافة رصيد (Add funds)
  - تحويل الأموال (Transfer money)
  - الدفع للموردين (Pay suppliers)

## Navigation Entry Point

The wallet can be accessed via:
- **Option A (Preferred)**: Shortcut button in pack shortcuts row: "المحفظة"
- **Option B**: AppBar icon "💳" on main screens

Note: Navigation integration is minimal to avoid redesigning the app's navigation system.

## Future Payment Integration Notes

When ready to implement actual payments:

1. **KYC Integration**: Add identity verification flow
2. **Payment Providers**: Integrate with Alipay, WeChat Pay, or local providers
3. **Server-Side State**: Replace local mock with API calls
4. **Security**: Add PIN/biometric authentication for transactions
5. **Compliance**: Ensure compliance with money transmission laws in target markets

## Acceptance Criteria

- [x] Balance card shows 0.00 (default currency)
- [x] Transaction list shows empty state: "لا توجد معاملات بعد"
- [x] "Add Funds" button opens Coming Soon sheet
- [x] Coming Soon sheet: "قريبًا — Zidni Pay"
- [x] Entry point visible from main UI (shortcut or AppBar)
- [x] Tapping opens Wallet screen
- [x] All labels Arabic-first
- [x] Locked files untouched (gul_control.dart, stt_engine.dart, stt_engine_speech_to_text.dart)

## DO NOT BUILD

- ❌ Real payment processing
- ❌ Bank/card integrations
- ❌ Server-side wallet state
- ❌ KYC / identity verification
