/// Zidni Eyes - OCR Scan + Product Intelligence
/// Gate EYES-1: OCR Scan → Product Insight Card → Save
/// Gate EYES-2: Find Where To Buy - Safe outbound search
///
/// Entry points:
/// - EyesScanButton: Icon button for AppBar/toolbar
/// - EyesScanFab: Floating action button variant
/// - EyesScanScreen: Full camera + OCR screen
/// - EyesHistoryScreen: View saved scan results
/// - FindItResultsCard: Search actions with query builder

// Models
export 'models/eyes_scan_result.dart';
export 'models/search_query.dart';

// Services
export 'services/ocr_service.dart';
export 'services/eyes_history_service.dart';
export 'services/query_builder_service.dart';
export 'services/search_history_service.dart';

// Screens
export 'screens/eyes_scan_screen.dart';
export 'screens/eyes_history_screen.dart';

// Widgets
export 'widgets/product_insight_card.dart';
export 'widgets/eyes_scan_button.dart';
export 'widgets/find_it_results_card.dart';
