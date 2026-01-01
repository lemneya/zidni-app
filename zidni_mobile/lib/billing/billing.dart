/// Zidni Billing Module
/// Gate BILL-1: Entitlements + Usage Meter + Paywall
///
/// Subscription management, feature gating, and upgrade flows

// Models
export 'models/entitlement.dart';

// Services
export 'services/entitlement_service.dart';
export 'services/feature_gate.dart';
export 'services/upgrade_trigger_service.dart';

// Screens
export 'screens/upgrade_screen.dart';

// Widgets
export 'widgets/soft_upgrade_modal.dart';
